@IsTest(IsParallel=false)
public class Test_StudyClinicDashboardRemote {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        TestData.createTCAcceptance();
        Test.stopTest();
    }
    @IsTest
    static void basePITest2() {
        TestData testData = new TestData();
        Study_Site__c studySiteAccount = [
            SELECT Id, Site__c
            FROM Study_Site__c
            WHERE Principal_investigator__c = :testData.piContact.Id
        ];
        Participant_Enrollment__c pe = [
            SELECT Id, HCP__r.HCP_Contact__c, HCP__r.HCP_Contact__r.AccountId
            FROM participant_Enrollment__c
            WHERE Study_Site__r.Clinical_Trial_Profile__c = :testData.ctp.Id
            LIMIT 1
        ];

        Test.startTest();
        System.runAs(testData.piUser) {
            StudyClinicDashboardRemote.getInitData(
                testData.ctp.Id,
                pe.HCP__r.HCP_Contact__r.AccountId
            );
        }
        Test.stopTest();
    }
}
