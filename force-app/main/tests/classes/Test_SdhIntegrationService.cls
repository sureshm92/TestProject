@isTest
public class Test_SdhIntegrationService {
@TestSetup
    static void init(){
        TestData.loadTestData();
    }
    @isTest
    static void getPeList() {
       
        Test.startTest();
        TestData testData = new TestData();

        Clinical_Trial_Profile__c clinical = new Clinical_Trial_Profile__c(
            Protocol_ID__c = 'tt12345276490',
            Override_Recruitment_Status__c = 'Actively Enrolling',
            NCT_Number__c = 'NCT00000072',
            Link_to_Pre_screening__c = 'some link',
            Study_Title__c = 'Some Title',
            Study_Code_Name__c = 'Some Code Name',
            Suppress_Participant_Emails__c = false
        );
        insert clinical;
        Account studySiteAccount = new Account(
            Name = 'Study Site Account',
            BillingLatitude = 41.766594,
            BillingLongitude = -74.991509,
            BillingCountry = 'United States'
        );
        insert studySiteAccount;
        Study_Site__c studySite = new Study_Site__c(
            Principal_Investigator__c = testData.piContact.Id,
            Clinical_Trial_Profile__c = clinical.Id,
            Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
            Site__c = studySiteAccount.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false,
            Study_Site_Number__c = 'SS1',
            Billable_Code_CRM_Number__c = 'Test_Billable_Code'
        );
        insert studySite;
        Set<String> protocolIds = new Set<String>();
        protocolIds.add(clinical.Protocol_ID__c);
        Set<String> siteNumbers = new Set<String>();
        siteNumbers.add(studySite.Study_Site_Number__c);
        Set<String> subjectIds = new Set<String>();
        subjectIds.add(testData.pe.Screening_ID__c);
        List<Participant_Enrollment__c> enrollments = [
            SELECT
                Id,
                Clinical_Trial_Profile__r.Protocol_ID__c,
                Participant_Status__c,
                Study_Site__r.Study_Site_Number__c,
                Screening_ID__c
            FROM Participant_Enrollment__c
            WHERE
                Clinical_Trial_Profile__r.Protocol_ID__c IN :protocolIds
                AND Study_Site__r.Study_Site_Number__c IN :siteNumbers
                AND Screening_ID__c IN :subjectIds
            LIMIT 10000
        ];
        SdhIntegrationService.getPEList(enrollments);
        Test.stopTest();
    }
}