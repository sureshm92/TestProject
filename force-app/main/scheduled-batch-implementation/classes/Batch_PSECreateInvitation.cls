/**
 * Created by Igor Malyuta on 29.05.2019.
 */ 

public without sharing class Batch_PSECreateInvitation extends Batch_ScheduledAbstract {
    private List<Trial_Survey__c> trialSurveyList = new List<Trial_Survey__c>();
    public Database.QueryLocator start(Database.BatchableContext param1) {
        List<Trial_Survey__c> trialSurveys = [
            SELECT Clinical_Trial_Profile__c
            FROM Trial_Survey__c
            WHERE
                Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = TRUE
                AND Status__c = 'Active'
                AND (Active_On_Status__c != NULL
                OR (Survey_start_date__c != NULL
                AND Survey_start_date__c <= TOMORROW
                AND Survey_end_date__c != NULL
                AND Survey_end_date__c >= TODAY))
        ];

        Set<Id> ctpSet = new Set<Id>();
        for (Trial_Survey__c ts : trialSurveys) {
            ctpSet.add(ts.Clinical_Trial_Profile__c);
        }
        list<string> statuses = PEStatusState.PE_STATUS_GROUP_FAILED;
        string query;
        query = 'SELECT Id,Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.CommunityTemplate__c,Days_After_Enrolled__c, Participant_Contact__c,Days_Since_Last_Status_Change__c,Participant_Status__c FROM Participant_Enrollment__c WHERE Clinical_Trial_Profile__c IN :ctpSet AND Participant_Status__c NOT IN :statuses AND Participant_Contact__c != NULL AND Participant_Contact__c NOT IN ( SELECT ContactId FROM User  WHERE IsActive = FALSE )';

        if (Test.isRunningTest()) {
            query = query + ' limit 1 ';
        }
        return Database.getQueryLocator(query);
    }

    public void execute(
        Database.BatchableContext param1,
        List<Participant_Enrollment__c> enrollments
    ) {
        Map<Participant_Enrollment__c, Id> peContantMap = new Map<Participant_Enrollment__c, Id>();
        Map<Id, TimeZone> contactTimezone = new Map<Id, TimeZone>();
        for (Participant_Enrollment__c enroll : enrollments) {
            peContantMap.put(enroll, enroll.Participant_Contact__c);
        }
        for (User user : [
            SELECT Id, ContactId, Name, TimeZoneSidKey
            FROM User
            WHERE
                ContactId IN :peContantMap.values()
                AND IsActive = TRUE
                AND Profile.Name = :CommunityService.COMMUNITY_USER_PROFILE_NAME
        ]) {
            TimeZone userTZ = TimeZone.getTimeZone(user.TimeZoneSidKey);
            contactTimezone.put(user.ContactId, userTZ);
        }
        List<Trial_Survey__c> trialSurveys = [
            SELECT
                Id,
                Recordtype.Name,
                Clinical_Trial_Profile__c,
                Survey__c,
                Survey__r.Name,
                Is_Recurrence_Survey__c,
                Recurrence_Frequency__c,
                Next_Occurrence_Date__c,
                Next_Occurrence_Reminder__c,
                Next_Task_Due_Date__c,
                Last_Occurrence_Date__c,
                Last_Occurrence_Reminder__c,
                Active_After_Days__c,
                Active_On_Status__c,
                Number_of_occurrences__c,
                Expires_After_Days__c,
                Is_Midpoint__c,
                Reminder_Schedule__c,
                Reminder_in_days_before_the_end_date__c,
                Survey_start_date__c,
                Survey_end_date__c,
                Whose_response_needed__c
            FROM Trial_Survey__c
            WHERE
                Clinical_Trial_Profile__c IN (
                    SELECT Clinical_Trial_Profile__c
                    FROM Participant_Enrollment__c
                    WHERE Id IN :enrollments
                )
                AND Survey__r.ActiveVersionId != NULL
                AND Status__c = 'Active'
                AND (Active_On_Status__c != NULL
                OR (Survey_start_date__c != NULL
                AND Survey_start_date__c <= TOMORROW
                AND Survey_end_date__c != NULL
                AND Survey_end_date__c >= TODAY))
        ];

        Map<Id, String> trialWhoseResponse = new Map<Id, String>();
        Map<Id, List<Trial_Survey__c>> ctpToTSMap = new Map<Id, List<Trial_Survey__c>>();
        for (Trial_Survey__c t : trialSurveys) {
            trialWhoseResponse.put(t.Id, t.Whose_response_needed__c);

            List<Trial_Survey__c> tsList = ctpToTSMap.get(t.Clinical_Trial_Profile__c);
            if (tsList == null) {
                tsList = new List<Trial_Survey__c>();
                ctpToTSMap.put(t.Clinical_Trial_Profile__c, tsList);
            }
            tsList.add(t);
        }

        Map<String, Id> communitiesMap = CommunityService.getCommunityIdsMap();
        Map<Id, String> networkByPE = new Map<Id, String>();
        for (Participant_Enrollment__c pe : enrollments) {
            String communityName = CommunityTemplateService.getTemplate(
                    pe.Clinical_Trial_Profile__r.CommunityTemplate__c
                )
                .communityName;
            networkByPE.put(pe.Id, communitiesMap.get(communityName));
        }

        Map<String, List<SurveyInvitation>> invitationMap = getInvitationMap(enrollments);
        List<SurveyInvitation> newInvitations = new List<SurveyInvitation>();
        Date partDate;
        TimeZone usertz;
        for (Participant_Enrollment__c pe : enrollments) {
            if (peContantMap.get(pe) != null && contactTimezone.get(peContantMap.get(pe)) != null) {
                usertz = contactTimezone.get(peContantMap.get(pe));
                String partDateStr = Datetime.now()
                    .format('yyyy-MM-dd hh:mm a zz', usertz.toString());
                partDate = Date.valueOf(partDateStr);
            } else {
                partDate = Date.today();
            }
            List<Trial_Survey__c> surveys = ctpToTSMap.get(pe.Clinical_Trial_Profile__c);
            if (surveys != null) {
                for (Trial_Survey__c ts : surveys) {
                    if (
                        ts.Is_Midpoint__c &&
                        PEStatusState.PE_STATUS_GROUP_COMPLETE.contains(pe.Participant_Status__c)
                    )
                        continue;
                    String key = '' + pe.Id + ts.Id;
                    if (invitationMap.get(key) != null && ts.Is_Recurrence_Survey__c) {
                        List<SurveyInvitation> surveyInvLst = invitationMap.get(key);
                        Integer offsetSeconds = 0;
                        Datetime expiryDateTime = surveyInvLst[0].ExpireDateTime__c;
                        if (userTZ != null) {
                            offsetSeconds = userTZ.getOffset(expiryDateTime) / 1000;
                        }
                        expiryDateTime = expiryDateTime.addSeconds(offsetSeconds).addHours(-7);
                        Date ExpiryDate = expiryDateTime.date();
                        if (
                            (((ts.Number_of_occurrences__c != null &&
                            surveyInvLst.size() < ts.Number_of_occurrences__c) ||
                            (ts.Survey_end_date__c != null &&
                            ExpiryDate != ts.Survey_end_date__c)) &&
                            ExpiryDate.addDays(1) == partDate) ||
                            (ts.Survey_start_date__c != null &&
                            ts.Survey_start_date__c == partDate &&
                            ts.Survey_start_date__c == ts.Next_Occurrence_Date__c)
                        ) {
                            newInvitations.add(
                                SurveyService.getInstance()
                                    .generateInvitation(
                                        ts,
                                        pe.Id,
                                        networkByPE.get(pe.Id),
                                        partDate,
                                        usertz
                                    )
                            );
                        }
                    } else if (
                        (ts.Active_On_Status__c == pe.Participant_Status__c &&
                        (ts.Active_After_Days__c <= pe.Days_Since_Last_Status_Change__c ||
                        ts.Active_After_Days__c == null)) ||
                        (!ts.Is_Recurrence_Survey__c &&
                        ts.Survey_start_date__c <= partDate &&
                        ts.Survey_end_date__c >= partDate) ||
                        (ts.Is_Recurrence_Survey__c &&
                        (ts.Next_Occurrence_Date__c == partDate ||
                        ts.Last_Occurrence_Date__c == partDate))
                    ) {
                        if (invitationMap.get(key) == null) {
                            newInvitations.add(
                                SurveyService.getInstance()
                                    .generateInvitation(
                                        ts,
                                        pe.Id,
                                        networkByPE.get(pe.Id),
                                        partDate,
                                        usertz
                                    )
                            );
                        }
                    }
                }
            }
        }

        insert newInvitations;
        for (Trial_Survey__c ts : trialSurveys) {
            if (
                ts.Recordtype.Name == 'Time based' &&
                ts.Is_Recurrence_Survey__c &&
                ts.Next_Occurrence_Date__c == Date.today()
            ) {
                updateTrialSurvey(ts);
            }
        }
        Map<Id, String> invitationsVisible = new Map<Id, String>();
        for (SurveyInvitation inv : newInvitations) {
            invitationsVisible.put(inv.Id, trialWhoseResponse.get(inv.Trial_Survey__c));
        }

        TaskService.getInstance().createSurveyTasks(invitationsVisible);
    }

    private Map<String, List<SurveyInvitation>> getInvitationMap(
        List<Participant_Enrollment__c> enrollments
    ) {
        List<SurveyInvitation> surveyInvitation = [
            SELECT Id, Participant_Enrollment__c, ExpireDateTime__c, Trial_Survey__c
            FROM SurveyInvitation
            WHERE Participant_Enrollment__c IN :enrollments
            ORDER BY CreatedDate DESC
        ];

        Map<String, List<SurveyInvitation>> invitationMap = new Map<String, List<SurveyInvitation>>();
        for (SurveyInvitation inv : surveyInvitation) {
            List<SurveyInvitation> surveyInvList = invitationMap.get(
                '' +
                inv.Participant_Enrollment__c +
                inv.Trial_Survey__c
            );
            if (surveyInvList == null) {
                surveyInvList = new List<SurveyInvitation>();
                invitationMap.put(
                    '' +
                    inv.Participant_Enrollment__c +
                    inv.Trial_Survey__c,
                    surveyInvList
                );
            }
            surveyInvList.add(inv);
        }
        return invitationMap;
    }

    @TestVisible
    private void updateTrialSurvey(Trial_Survey__c ts) {
        Integer days;
        if (ts.Reminder_in_days_before_the_end_date__c != null) {
            days = Integer.valueOf(ts.Reminder_in_days_before_the_end_date__c);
        }
        Date nextendDate = ts.Next_Occurrence_Date__c;
        Date endDate = ts.Next_Task_Due_Date__c;
        ts.Last_Occurrence_Date__c = ts.Next_Occurrence_Date__c;
        ts.Last_Occurrence_Reminder__c = ts.Next_Occurrence_Reminder__c;
        if (ts.Survey_end_date__c != endDate) {
            if (ts.Recurrence_Frequency__c == 'Daily') {
                ts.Next_Occurrence_Date__c = ts.Last_Occurrence_Date__c.addDays(1);
                nextendDate = endDate.addDays(1);
            }
            if (ts.Recurrence_Frequency__c == 'Weekly') {
                ts.Next_Occurrence_Date__c = ts.Last_Occurrence_Date__c.addDays(7);
                nextendDate = endDate.addDays(7);
            }
            if (ts.Recurrence_Frequency__c == 'Monthly') {
                ts.Next_Occurrence_Date__c = ts.Last_Occurrence_Date__c.addMonths(1);
                nextendDate = endDate.addMonths(1);
            }
            if (ts.Recurrence_Frequency__c == 'Yearly') {
                ts.Next_Occurrence_Date__c = ts.Last_Occurrence_Date__c.addYears(1);
                nextendDate = endDate.addYears(1);
            }
            if (nextendDate > ts.Survey_end_date__c) {
                nextendDate = ts.Survey_end_date__c;
            }
            ts.Next_Task_Due_Date__c = nextendDate;
            if (days != null && nextendDate.addDays(-days) >= ts.Next_Occurrence_Date__c) {
                ts.Next_Occurrence_Reminder__c = nextendDate.addDays(-days);
            }
            if (!trialSurveyList.contains(ts)) {
                trialSurveyList.add(ts);
            }
        } else {
            ts.Next_Occurrence_Date__c = null;
            ts.Next_Occurrence_Reminder__c = null;
            ts.Next_Task_Due_Date__c = null;
            if (!trialSurveyList.contains(ts)) {
                trialSurveyList.add(ts);
            }
        }
    }

    public override void finalAction() {
        try {
            if (trialSurveyList.size() != 0) {
                Database.update(trialSurveyList);
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    public override Type getType() {
        return Batch_PSECreateInvitation.class;
    }

    public override String getBatchDescription() {
        return 'This job create Survey Tasks from time-based Trial Survey templates on Clinical Trial Profile';
    }

    public override String getRecommendedIntervalMode() {
        return Batch_ScheduledAbstract.INTERVAL_HOURS;
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 2;
    }
}
