/**
 * Created by Dmitry Ivakhnenko on 28-Apr-20.
 */

@IsTest
private class Test_Batch_UpdateVisitResultsOptIn {

    @TestSetup
    static void init() {
        Test.startTest();
        Account participantAccount = new Account(
                Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
        );
        insert participantAccount;
        Test.stopTest();
    }

    @IsTest
    static void testDataDoesNotExist() {
        Account participantAccount = [SELECT Id FROM Account LIMIT 1];

        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(
                FirstName = 'Test_Contact',
                LastName = 'WithoutOptIn',
                AccountId = participantAccount.Id
        ));
        contacts.add(new Contact(
                FirstName = 'Test_Contact',
                LastName = 'OptInFalse',
                AccountId = participantAccount.Id,
                Visit_Results_Opt_In__c = false
        ));
        contacts.add(new Contact(
                FirstName = 'Test_Contact',
                LastName = 'OptInTrue',
                AccountId = participantAccount.Id,
                Visit_Results_Opt_In__c = true
        ));
        insert contacts;

        Test.startTest();
        Batch_UpdateVisitResultsOptIn.run();
        Test.stopTest();

        contacts = [SELECT Name, Visit_Results_Opt_In__c, Visit_Results_OptIn__c FROM Contact];
        System.assertEquals(3, contacts.size());

        checkContacts(contacts);
    }

    @IsTest
    static void testDataExists() {
        Account participantAccount = [SELECT Id FROM Account LIMIT 1];

        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(
                FirstName = 'Test_Contact',
                LastName = 'OptInFalse_NewFieldNotEmpty',
                AccountId = participantAccount.Id,
                Visit_Results_Opt_In__c = false,
                Visit_Results_OptIn__c = 'Vitals;Biomarkers'
        ));
        contacts.add(new Contact(
                FirstName = 'Test_Contact',
                LastName = 'OptInTrue_NewFieldNotEmpty',
                AccountId = participantAccount.Id,
                Visit_Results_Opt_In__c = true,
                Visit_Results_OptIn__c = 'Vitals;Biomarkers'
        ));
        insert contacts;

        try {
            Test.startTest();
            Batch_UpdateVisitResultsOptIn.run();
            Test.stopTest();

            System.assert(false, 'Existing data overwrites');
        } catch (Exception e) {
            if (!(e instanceof Batch_UpdateVisitResultsOptIn.DataExistsException)) throw e;
        }
    }

    @IsTest
    static void testOverwrite() {
        Account participantAccount = [SELECT Id FROM Account LIMIT 1];

        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(
                FirstName = 'Test_Contact',
                LastName = 'WithoutOptIn',
                AccountId = participantAccount.Id
        ));
        contacts.add(new Contact(
                FirstName = 'Test_Contact',
                LastName = 'OptInFalse',
                AccountId = participantAccount.Id,
                Visit_Results_Opt_In__c = false
        ));
        contacts.add(new Contact(
                FirstName = 'Test_Contact',
                LastName = 'OptInFalse_NewFieldNotEmpty',
                AccountId = participantAccount.Id,
                Visit_Results_Opt_In__c = false,
                Visit_Results_OptIn__c = 'Vitals;Biomarkers'
        ));
        contacts.add(new Contact(
                FirstName = 'Test_Contact',
                LastName = 'OptInTrue',
                AccountId = participantAccount.Id,
                Visit_Results_Opt_In__c = true
        ));
        contacts.add(new Contact(
                FirstName = 'Test_Contact',
                LastName = 'OptInTrue_NewFieldNotEmpty',
                AccountId = participantAccount.Id,
                Visit_Results_Opt_In__c = true,
                Visit_Results_OptIn__c = 'Vitals;Biomarkers'
        ));
        insert contacts;

        Test.startTest();
        Batch_UpdateVisitResultsOptIn.run(true);
        Test.stopTest();

        contacts = [SELECT Name, Visit_Results_Opt_In__c, Visit_Results_OptIn__c FROM Contact];
        System.assertEquals(5, contacts.size());

        checkContacts(contacts);
    }

    private static void checkContacts(List<Contact> contacts) {
        for (Contact contact : contacts) {
            String expected = contact.Visit_Results_Opt_In__c ? 'Vitals;Labs;Biomarkers' : null;
            System.assertEquals(expected,
                    contact.Visit_Results_OptIn__c,
                    'Wrong value in contact \'' + contact.Name + '\'');
        }
    }
}