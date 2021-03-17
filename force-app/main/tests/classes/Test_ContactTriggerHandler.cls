/*
Test Class for ContactTriggerHandler
*/
@IsTest
public class Test_ContactTriggerHandler {
    @isTest
    private static void test(){ 
        Contact partContact = new Contact(
            FirstName = 'PITD',
            LastName = 'PITD',
            Email = 'pi@emil.com',
            MailingCountry = 'United States'
        );
        insert partContact;
        Participant__c participant = new Participant__c(
            First_Name__c = 'ParticipantTD',
            Last_Name__c = 'ParticipantTD',
            Phone__c = '55313535',
            Email__c = 'part1@email.com',
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'AL',
            Mailing_Zip_Postal_Code__c = '2733',
            Adult__c = true,
            Contact__c = partContact.Id
        );
        insert participant;
        Test.startTest();
        partContact.MailingStateCode = null;
        partContact.MailingState = null;
        partContact.MailingPostalCode = '3733';
        update partContact;
        Participant__c newValPart = [SELECT Id,Mailing_Zip_Postal_Code__c FROM Participant__c WHERE Id =:participant.Id];
        Test.stopTest();
        system.assertEquals(newValPart.Mailing_Zip_Postal_Code__c, partContact.MailingPostalCode);
    }
}