/**
 * Created by Igor Malyuta on 15.05.2019.
 */

public with sharing class SurveyService {

    public class SurveyException extends Exception {}

    public class SurveyWrapper{
        public String name;
        public String url;
        public String studyCodeName;

        public SurveyWrapper(String name, String url, String studyCodeName){
            this.name = name;
            this.url = url;
            this.studyCodeName = studyCodeName;
        }
    }

    private static SurveyService instance;

    public static SurveyService getInstance() {
        if(instance == null) instance = new SurveyService();
        return instance;
    }

    public static void setMock(StubProvider mock) {
        instance = (SurveyService) Test.createStub(SurveyService.class, mock);
    }

    public SurveyWrapper getSurveyWrapper(Id invitationId){
        try {
            SurveyInvitation invitation = [
                    SELECT
                            InvitationLink,
                            Survey.Name,
                            Participant_Study_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c
                    FROM SurveyInvitation
                    WHERE Id = :invitationId
            ];

            return new SurveyWrapper(
                    invitation.Survey.Name,
                    invitation.InvitationLink,
                    invitation.Participant_Study_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c);
        } catch (Exception e) {
            throw new SurveyException(e.getCause() + '\n' + e.getMessage());
        }
    }

    public SurveyInvitation generateInvitation(Trial_Survey__c ts, Participant_Study_Enrollment__c pse) {
        SurveyInvitation invitation = new SurveyInvitation();
        invitation.CommunityId = CommunityService.getCommunityId(null);
        invitation.Name = ts.Survey__r.Name + ':TS:' + ts.Id;
        invitation.ParticipantId = pse.Participant_Contact__c;
        invitation.Participant_Study_Enrollment__c = pse.Id;
        invitation.SurveyId = ts.Survey__c;
        invitation.Survey__c = ts.Survey__c;
        invitation.Trial_Survey__c = ts.Id;

        if(ts.Expires_After_Days__c != null) {
            Date today = System.today().addDays((Integer) ts.Expires_After_Days__c);
            Datetime expiry = Datetime.newInstanceGmt(
                    today.year(),
                    today.month(),
                    today.day()
            );

            invitation.InviteExpiryDateTime = expiry;
        }

        return invitation;
    }
}