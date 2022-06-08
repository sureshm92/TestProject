@isTest
public class Test_DashboardParticipantCount {
	@TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @isTest
    private static void Test_fetchStudyDetails() {
        Study_Site__c studySite = [select Id,Principal_Investigator__c,Clinical_Trial_Profile__c from Study_Site__c limit 1];
        DashboardParticipantCount.fetchStudyDetails(studySite.Clinical_Trial_Profile__c);
        DashboardParticipantCount.fetchParticipantsNotYetLogInDetails(studySite.Principal_Investigator__c,studySite.Clinical_Trial_Profile__c);
        DashboardParticipantCount.fetchParticipantsNotYetInvitedDetails(studySite.Principal_Investigator__c,studySite.Clinical_Trial_Profile__c);
    	DashboardParticipantCount.participantLoginDashboard(studySite.Principal_Investigator__c,studySite.Clinical_Trial_Profile__c);
        DashboardParticipantCount.participantInvitationDashboard(studySite.Principal_Investigator__c,studySite.Clinical_Trial_Profile__c);
        Account piAccount = [select Id from account where Name = 'PI Account' limit 1];
        Participant__c participant6 = new Participant__c(
            First_Name__c = 'ParticipantTD100',
            Last_Name__c = 'ParticipantTD100',
            Phone__c = '55313536w',
            Email__c = 'ParticipantTD100@email.com',
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'AL',
            Adult__c = true,
            Site__c = piAccount.Id
        );
        insert participant6;
        List<DashboardParticipantCount.ParticipantDetails> dashList = new List<DashboardParticipantCount.ParticipantDetails>();
        DashboardParticipantCount.ParticipantDetails pDetails = new DashboardParticipantCount.ParticipantDetails();
        pDetails.participantId = participant6.Id;
        pDetails.participantName = 'Johnny';
        pDetails.delegateId = null;
        pDetails.delegateParticipantName =null;
        pDetails.isChecked = false;
        pDetails.datasetId = null;
        dashList.add(pDetails);
        Map<String,String> result = DashboardParticipantCount.sendInviteToNotInvitedParticipants(JSON.serialize(dashList),studySite.Clinical_Trial_Profile__c);
        system.assert(result.get('message')=='Success');
    }
}