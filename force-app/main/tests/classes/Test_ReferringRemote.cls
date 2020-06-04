/**
 * Created by Denis on 15.04.2019.
 */

@IsTest
private without sharing class Test_ReferringRemote {
    
    @IsTest
    static void saveParticipant() {
        TestData.loadTestData();
        Test.startTest();
        TestData testDataInstance = new TestData();
        System.runAs(testDataInstance.hcpUser){
            Participant_Enrollment__c pe = new Participant_Enrollment__c(
                    HCP__c = testDataInstance.hcpEnrollment.Id,
                    Study_Site__c = testDataInstance.ss.Id,
                    Patient_ID__c = 'SomePatientId1',
                    Referral_Source__c = 'HCP',
                    Screening_ID__c = 'TestScrId12345'
            );
            Participant__c participant = new Participant__c(
                    First_Name__c = 'PTest',
                    Last_Name__c = 'PTest',
                    Phone__c = '13413223',
                    Date_of_Birth__c = '1990-11-11',
                    Email__c = 'partTest@email.com',
                    Mailing_Country_Code__c = 'US',
                    Mailing_State_Code__c = 'AL'
            );
            Participant__c participantDelegate = new Participant__c(
                    First_Name__c = 'PTestDelegate',
                    Last_Name__c = 'PTestDelegate',
                    Phone__c = '13413123',
                    Email__c = 'PTestDelegate@email.com',
                    Mailing_Country_Code__c = 'US',
                    Mailing_State_Code__c = 'AL'
            );
            ReferringRemote.checkNeedsGuardian(JSON.serialize(participant));
            ReferringRemote.saveParticipant(testDataInstance.hcpEnrollment.Id, JSON.serialize(pe), JSON.serialize(participant), JSON.serialize(participantDelegate), null, null);
            ReferringRemote.setfailedReferral(JSON.serialize(pe), ParticipantEnrollmentService.NON_REF_REASON_STATUS_FAILED_PE_SCREENING);
        }
        Test.stopTest();
    }
    
    @IsTest
    static void getInitData() {
        TestData.loadTestData();
        Test.startTest();
        TestData testDataInstance = new TestData();
        System.runAs(testDataInstance.hcpUser){
            String initDataStr = ReferringRemote.getInitData(testDataInstance.ctp.Id, testDataInstance.pe.Id, testDataInstance.hcpEnrollment.Id, CommunityService.USER_MODE_HCP, null);
        }
        Test.stopTest();
    }

}