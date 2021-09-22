/*
Test Class for ContactTriggerHandler
*/
@IsTest
public class Test_ContactTriggerHandler {
    @isTest
    private static void test(){ 
        List<Contact> contactList = new List<Contact>();
         Map<Id, Contact> contactOldMap = new  Map<Id, Contact>();
        Contact partContact = new Contact(
            FirstName = 'PITD',
            LastName = 'PITD',
            Email = 'pi@emil.com',
            Language__c = 'en_US',
            MailingCountry = 'United States'
        );
        contactList.add(partContact);
        insert partContact;
        Participant__c participant = new Participant__c(
            First_Name__c = 'ParticipantTD',
            Last_Name__c = 'ParticipantTD',
            Phone__c = '55313535',
            Email__c = 'pi@emil.com',
            Preferred_Language__c = 'en_US',
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
        partContact.Language__c = 'ru';
        update partContact;
        contactOldMap.put(partContact.Id,partContact);
        Participant__c newValPart = [SELECT Id,Mailing_Zip_Postal_Code__c FROM Participant__c WHERE Id =:participant.Id];
        ContactTriggerHandler.updateParticipantAndUserEmailsOnEmailChange(contactList,contactOldMap);
        Test.stopTest();
        system.assertEquals(newValPart.Mailing_Zip_Postal_Code__c, partContact.MailingPostalCode);
        //system.assertNOtEquals(contactOldMap.Mailing_Zip_Postal_Code__c, partContact.MailingPostalCode);
    }
}