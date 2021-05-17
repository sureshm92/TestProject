/**
 * Created by Igor Malyuta on 29.05.2019.
 */

public without sharing class Batch_PSECreateInvitation extends Batch_ScheduledAbstract {
    public Database.QueryLocator start(Database.BatchableContext param1) {
        List<Trial_Survey__c> trialSurveys = [
            SELECT Active_After_Days__c
            FROM Trial_Survey__c
            WHERE
                Clinical_Trial_Profile__r.Override_Recruitment_Status__c = :TrialService.STATUS_ACTIVELY_ENROLLING
                AND Active_After_Days__c != NULL
        ];

        Set<Decimal> daysSet = new Set<Decimal>();
        for (Trial_Survey__c ts : trialSurveys)
            daysSet.add(ts.Active_After_Days__c);

        return Database.getQueryLocator(
            [
                SELECT
                    Id,
                    Clinical_Trial_Profile__c,
                    Clinical_Trial_Profile__r.CommunityTemplate__c,
                    Days_After_Enrolled__c,
                    Participant_Contact__c,
                    Participant_Status__c
                FROM Participant_Enrollment__c
                WHERE
                    Participant_Status__c IN :PEStatusState.PE_STATUS_GROUP_PARTICIPANT
                    AND Days_After_Enrolled__c IN :daysSet
            ]
        );
    }

    public void execute(
        Database.BatchableContext param1,
        List<Participant_Enrollment__c> enrollments
    ) {
        /***** Changes for Minor Participant's Delegate Starts *****/
        //Removed the user filter from the query in QueryLocator in start method as minor participant dont have user
        //Removing the participant Enrollment record if it came in the enrollments for inActive user.
        Set<id> contId = new Set<id>();
        for (Participant_Enrollment__c pe : enrollments) {
            contId.add(pe.Participant_Contact__c);
        }
        Set<id> contIdToBypass = new Set<id>();
        for(User u: [Select Id, contactId from user where contactId in : contId and IsActive = FALSE]){
            contIdToBypass.add(u.contactId);
        }

        Integer ListSize = enrollments.Size();
        //Remove the inactive users PER from list. 
        for (Integer i = ListSize-1; i >= 0; i--) {
            if(contIdToBypass.contains(enrollments[i].Participant_Contact__c)){
                enrollments.Remove(i);
            }
        }
         /***** Changes for Minor Participant's Delegate ends *****/
        List<Trial_Survey__c> trialSurveys = [
            SELECT
                Id,
                Clinical_Trial_Profile__c,
                Survey__c,
                Survey__r.Name,
                Active_After_Days__c,
                Expires_After_Days__c,
                Is_Midpoint__c,
                Reminder_Schedule__c,
                Whose_response_needed__c
            FROM Trial_Survey__c
            WHERE
                Clinical_Trial_Profile__c IN (
                    SELECT Clinical_Trial_Profile__c
                    FROM Participant_Enrollment__c
                    WHERE Id IN :enrollments
                )
                AND Survey__r.ActiveVersionId != NULL
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

        Map<String, SurveyInvitation> invitationMap = getInvitationMap(enrollments);
        List<SurveyInvitation> newInvitations = new List<SurveyInvitation>();
        for (Participant_Enrollment__c pe : enrollments) {
            List<Trial_Survey__c> surveys = ctpToTSMap.get(pe.Clinical_Trial_Profile__c);
            if (surveys != null) {
                for (Trial_Survey__c ts : surveys) {
                    if (ts.Active_After_Days__c == pe.Days_After_Enrolled__c) {
                        if (
                            ts.Is_Midpoint__c &&
                            PEStatusState.PE_STATUS_GROUP_COMPLETE.contains(
                                pe.Participant_Status__c
                            )
                        )
                            continue;
                        String key = '' + pe.Id + ts.Id;
                        if (invitationMap.get(key) == null) {
                            newInvitations.add(
                                SurveyService.getInstance()
                                    .generateInvitation(ts, pe.Id, networkByPE.get(pe.Id))
                            );
                        }
                    }
                }
            }
        }

        insert newInvitations;
        Map<Id, String> invitationsVisible = new Map<Id, String>();
        for (SurveyInvitation inv : newInvitations) {
            invitationsVisible.put(inv.Id, trialWhoseResponse.get(inv.Trial_Survey__c));
        }

        TaskService.getInstance().createSurveyTasks(invitationsVisible);
    }

    private Map<String, SurveyInvitation> getInvitationMap(
        List<Participant_Enrollment__c> enrollments
    ) {
        List<SurveyInvitation> surveyInvitation = [
            SELECT Id, Participant_Enrollment__c, Trial_Survey__c
            FROM SurveyInvitation
            WHERE Participant_Enrollment__c IN :enrollments
        ];

        Map<String, SurveyInvitation> invitationMap = new Map<String, SurveyInvitation>();
        for (SurveyInvitation inv : surveyInvitation) {
            invitationMap.put('' + inv.Participant_Enrollment__c + inv.Trial_Survey__c, inv);
        }
        return invitationMap;
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
