/**
 * Created by Leonid Bartenev
 */

@IsTest
private class Test_AddPatientByPIRemote {
    
    @IsTest
    static void testGetInitData() {
        TestData.loadTestData();
        Test.startTest();
        TestData testData = new TestData();
        System.runAs(testData.piUser){
            AddPatientByPIRemote.getInitData(testData.ctp.Id);
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testSaveParticipant() {
        TestData.loadTestData();
        Test.startTest();
        TestData testData = new TestData();
        System.debug('CTP: ' + testData.ctp);
        System.debug('PARTICIPANTS: ' + [SELECT Name FROM Participant__c]);
        System.runAs(testData.piUser){
            Participant__c participant = new Participant__c(
                    First_Name__c = 'NewP',
                    Last_Name__c = 'NewP',
                    Phone__c = '11213232',
                    Email__c = 'NewP@email.com',
                    Mailing_Country_Code__c = 'US',
                    Mailing_State_Code__c = 'NY'

            );
            Participant_Enrollment__c pe = new Participant_Enrollment__c(
                    Study_Site__c = testData.ss.Id,
                    Patient_ID__c = '12345678',
                    Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS
            );
            AddPatientByPIRemote.saveParticipant(JSON.serialize(participant), JSON.serialize(pe));
        }
        Test.stopTest();
    }
}