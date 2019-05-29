/**
 * Created by Igor Malyuta on 28.05.2019.
 */

public with sharing class ParticipantSurveyService {

    private static ParticipantSurveyService instance;

    public static ParticipantSurveyService getInstance() {
        if(instance == null) instance = new ParticipantSurveyService();
        return instance;
    }

    public static void setMock(StubProvider mock) {
        instance = (ParticipantSurveyService) Test.createStub(ParticipantSurveyService.class, mock);
    }

    public Participant_Survey__c createParticipantSurvey(Participant_Study_Enrollment__c pse, Trial_Survey__c ts) {
        Participant_Survey__c ps = new Participant_Survey__c();
        ps.Participant_Study_Enrollment__c = pse.Id;
        ps.Participant_Contact__c = pse.Participant_Contact__c;
        ps.Visible_To_Delegates__c = ts.Visible_To_Delegates__c;
        ps.Survey__c = ts.Survey__c;

        Date showDate = System.today();
        if (ts.Active_After_Days__c != null) showDate = showDate.addDays((Integer) ts.Active_After_Days__c);
        ps.Show_Date__c = showDate;

        if (ts.Expires_After_Days__c != null) {
            ps.Expiration_Date__c = showDate.addDays((Integer) ts.Expires_After_Days__c);
        }

        return ps;
    }
}