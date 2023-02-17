/**
 * Created by Igor Malyuta on 15.05.2019.
 */

public without sharing class SurveyService {
    public class SurveyException extends Exception {
    }

    public static final String SURVEY_RESPONSE_PATIENT_ONLY = 'Patient only';
    public static final String SURVEY_RESPONSE_EACH_DELEGATE = 'Each Delegate';
    public static final String SURVEY_RESPONSE_PATIENT_ANY_DELEGATE = 'Patient or any Delegate';
    public static final String SURVEY_RESPONSE_ANY_DELEGATE = 'Any Delegate';
    public static final String SURVEY_RESPONSE_PATIENT_EACH_DELEGATE = 'Patient and each Delegate';

    public static final Map<String, String> SURVEY_VISIBLE = new Map<String, String>{
        SURVEY_RESPONSE_PATIENT_ONLY => TaskService.TASK_VISIBILITY_OWNER,
        SURVEY_RESPONSE_EACH_DELEGATE => TaskService.TASK_VISIBILITY_OWNER,
        SURVEY_RESPONSE_PATIENT_ANY_DELEGATE => TaskService.TASK_VISIBILITY_ALL,
        SURVEY_RESPONSE_ANY_DELEGATE => TaskService.TASK_VISIBILITY_DELEGATES,
        SURVEY_RESPONSE_PATIENT_EACH_DELEGATE => TaskService.TASK_VISIBILITY_OWNER
    };

    public class SurveyWrapper {
        public String name;
        public String url;
        public String studyCodeName;

        public SurveyWrapper(String name, String url, String studyCodeName) {
            this.name = name;
            this.url = url;
            this.studyCodeName = studyCodeName;
        }
    }

    private static SurveyService instance;

    public static SurveyService getInstance() {
        if (instance == null)
            instance = new SurveyService();
        return instance;
    }

    public static void setMock(StubProvider mock) {
        instance = (SurveyService) Test.createStub(SurveyService.class, mock);
    }

    public SurveyWrapper getSurveyWrapper(Id invitationId) {
        try {
            SurveyInvitation invitation = [
                SELECT
                    InvitationLink,
                    Survey.Name,
                    Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c
                FROM SurveyInvitation
                WHERE Id = :invitationId
            ];

            return new SurveyWrapper(
                invitation.Survey.Name,
                invitation.InvitationLink,
                invitation.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c
            );
        } catch (Exception e) {
            throw new SurveyService.SurveyException(e.getCause() + '\n' + e.getMessage());
        }
    }

    public SurveyInvitation generateInvitation(
        Trial_Survey__c ts,
        Id peId,
        Id communityId,
        Date partDate,
        TimeZone usertz
    ) {
        SurveyInvitation invitation = new SurveyInvitation(
            CommunityId = communityId,
            Is_Midpoint__c = ts.Is_Midpoint__c,
            Name = ts.Survey__r.Name + ':TS:' + ts.Id,
            Participant_Enrollment__c = peId,
            Reminder_Schedule__c = ts.Reminder_Schedule__c,
            SurveyId = ts.Survey__c,
            Survey__c = ts.Survey__c,
            Trial_Survey__c = ts.Id,
            IsTrialSurvey__c = true,
            Is_End_Date_Visible__c = ts.Display_in_UI__c
        );

        Date today;
        if (partDate != null) {
            today = partDate;
        } else {
            today = System.today();
        }
        Date endDate = today;
        Time eodTime = Time.newInstance(23, 59, 0, 0);
        if (ts.Is_Recurrence_Survey__c) {
            if (ts.Recurrence_Frequency__c == 'Weekly') {
                endDate = today.addDays(6);
            } else if (ts.Recurrence_Frequency__c == 'Monthly') {
                endDate = today.addMonths(1).addDays(-1);
            } else if (ts.Recurrence_Frequency__c == 'Yearly') {
                endDate = today.addYears(1).addDays(-1);
            }
            if (ts.Survey_end_date__c != null && endDate > ts.Survey_end_date__c) {
                endDate = ts.Survey_end_date__c;
            }
        } else {
            if (ts.Expires_After_Days__c != null) {
                endDate = today.addDays((Integer) ts.Expires_After_Days__c);
            } else {
                endDate = ts.Survey_end_date__c;
            }
        }
        Integer days;
        Date reminderDate;
        Time remTime;
        if (ts.Reminder_in_days_before_the_end_date__c != null) {
            days = Integer.valueOf(ts.Reminder_in_days_before_the_end_date__c);
            reminderDate = endDate.addDays(-days);
            remTime = Time.newInstance(9, 30, 0, 0);
        }

        Integer offsetSeconds = 0;
        if (userTZ != null) {
            offsetSeconds = userTZ.getOffset(endDate) / 1000;
        }
        Datetime expiry = Datetime.newInstanceGmt(endDate, eodTime).addSeconds(-offsetSeconds);
        invitation.ExpireDateTime__c = expiry;
        if (reminderDate != null && reminderDate >= today) {
            Datetime reminderDatetime = Datetime.newInstanceGmt(reminderDate, remTime)
                .addSeconds(-offsetSeconds);
            invitation.ReminderDateTime__c = reminderDatetime;
        }

        return invitation;
    }

    public SurveyInvitation generateInvitation(
        Survey survey,
        Reminder_Schedule__c schedule,
        Integer expiresAfterDays,
        Boolean isMidpoint,
        Id peId,
        Id communityId
    ) {
        SurveyInvitation invitation = new SurveyInvitation(
            CommunityId = communityId,
            Is_Midpoint__c = isMidpoint,
            Name = survey.Name + ':PE:' + peId,
            Participant_Enrollment__c = peId,
            SurveyId = survey.Id,
            Survey__c = survey.Id
        );

        if (schedule != null)
            invitation.Reminder_Schedule__c = schedule.Id;

        if (expiresAfterDays != null) {
            Date today = System.today().addDays(expiresAfterDays);
            Datetime expiry = Datetime.newInstance(today.year(), today.month(), today.day());
            invitation.ExpireDateTime__c = expiry;
        }

        return invitation;
    }

    public Id getSurveyInvitationId(String surveyId, String participantContactId) {
        List<SurveyInvitation> invitation = [
            SELECT Id
            FROM SurveyInvitation
            WHERE
                SurveyId = :surveyId
                AND Participant_Enrollment__r.Participant_Contact__c = :participantContactId
        ];
        if (invitation.isEmpty())
            return '';

        return invitation.get(0).Id;
    }

    public Boolean isInvitationExpired(Id invitationId) {
        return isInvitationsExpired(new List<Id>{ invitationId }).get(invitationId);
    }

    public Map<Id, Boolean> isInvitationsExpired(List<Id> invitationIds) {
        List<SurveyInvitation> invitations = [
            SELECT ExpireDateTime__c, Is_Expired__c
            FROM SurveyInvitation
            WHERE Id IN :invitationIds
        ];
        Map<Id, Boolean> invitationStateById = new Map<Id, Boolean>();
        for (SurveyInvitation inv : invitations) {
            invitationStateById.put(
                inv.Id,
                (inv.Is_Expired__c || inv.ExpireDateTime__c <= Datetime.now())
            );
        }
        return invitationStateById;
    }

    public Boolean expireInvitation(List<Id> invitationIds) {
        for (Id invId : invitationIds) {
            if (invId == null || invId.getSobjectType() != SurveyInvitation.getSObjectType()) {
                return false;
            }
        }

        List<SurveyInvitation> invitations = [
            SELECT Id, Is_Expired__c, InviteExpiryDateTime
            FROM SurveyInvitation
            WHERE Id IN :invitationIds
        ];

        if (!invitations.isEmpty()) {
            for (SurveyInvitation inv : invitations) {
                inv.Is_Expired__c = true;
                if (inv.InviteExpiryDateTime != null)
                    inv.InviteExpiryDateTime = null;
            }

            update invitations;

            List<Task> tasksForExpire = [
                SELECT Id, Status
                FROM Task
                WHERE Survey_Invitation__c IN :invitationIds
            ];
            for (Task t : tasksForExpire)
                t.Status = TaskService.TASK_STATUS_EXPIRED;

            update tasksForExpire;

            return true;
        }

        return false;
    }
}
