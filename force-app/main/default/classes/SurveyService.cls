/**
 * Created by Igor Malyuta on 15.05.2019.
 */

public without sharing class SurveyService {

    public class SurveyException extends Exception {}

    public static final Map<String, String> SURVEY_VISIBLE = new Map<String, String>{
            'Patient only' => TaskService.TASK_VISIBILITY_OWNER,
            'Each Delegate' => TaskService.TASK_VISIBILITY_OWNER,
            'Patient or any Delegate' => TaskService.TASK_VISIBILITY_ALL,
            'Any Delegate' => TaskService.TASK_VISIBILITY_DELEGATES,
            'Patient and each Delegate' => TaskService.TASK_VISIBILITY_OWNER
    };

    public static List<String> getAvailableStatuses() {
        List<String> statuses = new List<String>();
        statuses.addAll(PEStatusState.PE_STATUS_GROUP_IN_PROGRESS_NOT_ON_HOLD);
        statuses.addAll(PSEService.PSE_STATUS_GROUP_ALL);

        return statuses;
    }

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
        if (instance == null) instance = new SurveyService();
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
                    invitation.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c);
        } catch (Exception e) {
            throw new SurveyService.SurveyException(e.getCause() + '\n' + e.getMessage());
        }
    }

    public SurveyInvitation generateInvitation(Trial_Survey__c ts, Id peId) {
        SurveyInvitation invitation = new SurveyInvitation(
                CommunityId = CommunityService.getCommunityId(null),
                Name = ts.Survey__r.Name + ':TS:' + ts.Id,
                Participant_Enrollment__c = peId,
                Reminder_Schedule__c = ts.Reminder_Schedule__c,
                SurveyId = ts.Survey__c,
                Survey__c = ts.Survey__c,
                Trial_Survey__c = ts.Id
        );

        if (ts.Expires_After_Days__c != null) {
            Date today = System.today().addDays((Integer) ts.Expires_After_Days__c);
            Datetime expiry = Datetime.newInstance(
                    today.year(),
                    today.month(),
                    today.day()
            );
            invitation.InviteExpiryDateTime = expiry;
        }

        return invitation;
    }

    public SurveyInvitation generateInvitation(
            Survey survey,
            Reminder_Schedule__c schedule,
            Integer expiresAfterDays,
            Id peId
    ) {
        SurveyInvitation invitation = new SurveyInvitation(
                CommunityId = CommunityService.getCommunityId(null),
                Name = survey.Name + ':PE:' + peId,
                Participant_Enrollment__c = peId,
                Reminder_Schedule__c = schedule.Id,
                SurveyId = survey.Id,
                Survey__c = survey.Id
        );

        if (expiresAfterDays != null) {
            Date today = System.today().addDays(expiresAfterDays);
            Datetime expiry = Datetime.newInstanceGmt(
                    today.year(),
                    today.month(),
                    today.day()
            );
            invitation.InviteExpiryDateTime = expiry;
        }

        return invitation;
    }

    public Id getSurveyInvitationId(String surveyId, String participantContactId) {
        List<SurveyInvitation> invitation = [
                SELECT Id
                FROM SurveyInvitation
                WHERE SurveyId = :surveyId
                AND Participant_Enrollment__r.Participant_Contact__c = :participantContactId
        ];
        if (invitation.isEmpty()) return '';

        return invitation.get(0).Id;
    }

    public Boolean isInvitationExpired(Id invitationId) {
        SurveyInvitation invitation = [SELECT InviteExpiryDateTime FROM SurveyInvitation WHERE Id = :invitationId];
        return invitation.InviteExpiryDateTime <= System.now();
    }

    public Boolean expireInvitation(List<String> invitationIds) {
        for(String invId : invitationIds){
            if(invId == null || Id.valueOf(invId).getSobjectType() != SurveyInvitation.getSObjectType()) {
                return false;
            }
        }

        List<SurveyInvitation> invitations = [
                SELECT Id, InviteExpiryDateTime FROM SurveyInvitation WHERE Id IN: invitationIds
        ];

        if(!invitations.isEmpty()) {
            for(SurveyInvitation inv : invitations) {
                if(inv.InviteExpiryDateTime != null && inv.InviteExpiryDateTime > System.now()) {
                    inv.InviteExpiryDateTime = System.now();
                }
            }
            update invitations;
            return true;
        }

        return false;
    }
}