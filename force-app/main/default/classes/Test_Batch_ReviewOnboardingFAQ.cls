/**
 * Created by Igor Malyuta on 04.04.2019.
 */

@IsTest(IsParallel=true)
private class Test_Batch_ReviewOnboardingFAQ {

    @TestSetup
    static void setup() {
        Contact testContact = new Contact(LastName = 'TestBatch');
        insert testContact;

        testContact.userCommunity_ShowTour__c = '';
        update testContact;
    }

    @IsTest
    static void testAll() {
        Test.startTest();
        Batch_ReviewOnboardingFAQ.runAll();
        Test.stopTest();

        Contact contact = [
                SELECT Id, userCommunity_ShowTour__c
                FROM Contact
                WHERE LastName = 'TestBatch'
        ];
        System.assertEquals(Batch_ReviewOnboardingFAQ.SHOW_ALL, contact.userCommunity_ShowTour__c);
    }

    @IsTest
    static void testPI() {
        Test.startTest();
        Batch_ReviewOnboardingFAQ.runPI();
        Test.stopTest();

        Contact contact = [
                SELECT Id, userCommunity_ShowTour__c
                FROM Contact
                WHERE LastName = 'TestBatch'
        ];
        System.assertEquals(Batch_ReviewOnboardingFAQ.SHOW_PI, contact.userCommunity_ShowTour__c);
    }

    @IsTest
    static void testHCP() {
        Test.startTest();
        Batch_ReviewOnboardingFAQ.runHCP();
        Test.stopTest();

        Contact contact = [
                SELECT Id, userCommunity_ShowTour__c
                FROM Contact
                WHERE LastName = 'TestBatch'
        ];
        System.assertEquals(Batch_ReviewOnboardingFAQ.SHOW_HCP, contact.userCommunity_ShowTour__c);
    }

    @IsTest
    static void testParticipant() {
        Test.startTest();
        Batch_ReviewOnboardingFAQ.runParticipant();
        Test.stopTest();

        Contact contact = [
                SELECT Id, userCommunity_ShowTour__c
                FROM Contact
                WHERE LastName = 'TestBatch'
        ];
        System.assertEquals(Batch_ReviewOnboardingFAQ.SHOW_PARTICIPANT, contact.userCommunity_ShowTour__c);
    }

    @IsTest
    static void testFail() {
        Test.startTest();
        Batch_ReviewOnboardingFAQ.runAll();
        Test.stopTest();

        Contact contact = [
                SELECT Id, userCommunity_ShowTour__c
                FROM Contact
                WHERE LastName = 'TestBatch'
        ];
        System.assertNotEquals(Batch_ReviewOnboardingFAQ.SHOW_HCP, contact.userCommunity_ShowTour__c);
    }
}