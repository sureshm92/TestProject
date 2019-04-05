/**
 * Created by Igor Malyuta on 04.04.2019.
 */

@IsTest
private class Test_Batch_ReviewOnboardingFAQ {
    @IsTest
    static void testBehavior() {

        Contact testContact = new Contact(
                FirstName='Igor',
                LastName = 'Malyuta'

        );
        insert testContact;

        testContact.userCommunity_ShowTour__c = 'PI';
        update testContact;

        Test.startTest();
        Batch_ReviewOnboardingFAQ.run('HCP;Participant');
        Test.stopTest();

        Contact contact = [
                SELECT Id, userCommunity_ShowTour__c
                FROM Contact
                WHERE Id = :testContact.Id
        ].get(0);
        System.assertEquals(Batch_ReviewOnboardingFAQ.DEFAULT_FIELD_VALUE, contact.userCommunity_ShowTour__c);
    }
}