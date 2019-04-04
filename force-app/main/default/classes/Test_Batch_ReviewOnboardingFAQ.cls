/**
 * Created by Igor Malyuta on 04.04.2019.
 */

@IsTest
private class Test_Batch_ReviewOnboardingFAQ {
    @IsTest
    static void testBehavior() {

        Test.startTest();
        Contact testContact = new Contact(
                FirstName='Igor',
                LastName = 'Malyuta',
                Email = 'email@mail.com',
                Phone = '888-999-808',
                Language__c='en_US'
        );
        insert testContact;

        testContact.userCommunity_ShowTour__c = 'PI';
        update testContact;

        Batch_ReviewOnboardingFAQ.run('HCP;Participant');

        Test.stopTest();
        System.assertEquals(Batch_ReviewOnboardingFAQ.DEFAULT_FIELD_VALUE, testContact.userCommunity_ShowTour__c);
    }
}