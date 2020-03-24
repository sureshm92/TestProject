/**
 * Created by Igor Iosifov on 2020-03-23.
 */

@IsTest
public with sharing class Test_CollectionUtil {

    @TestSetup
    static void testSetup() {
        List<Contact> contacts = new List<Contact>();
        contacts.add (new Contact(
                FirstName = 'Contact 1',
                LastName = 'Contact 1',
                Trials_in_Last_12_Months__c = 10,
                Birthdate = Date.today().addDays(1).addYears(-50)
        ));
        contacts.add (new Contact(
                FirstName = 'Contact 3',
                LastName = 'Contact 3',
                Trials_in_Last_12_Months__c = 30,
                Birthdate = Date.today().addDays(3).addYears(-50)
        ));
        contacts.add (new Contact(
                FirstName = 'Contact 2',
                LastName = 'Contact 2',
                Trials_in_Last_12_Months__c = 20,
                Birthdate = Date.today().addDays(2).addYears(-50)
        ));
        insert contacts;
    }

    @IsTest
    static void splitTest() {
        List<String> splitStrings = CollectionUtil.split('Hello World!', ' ');
        System.assertEquals(2, splitStrings.size());
    }

    @IsTest
    static void getObjectIdsTest() {
        List<Contact> contacts = [
                SELECT Id
                FROM Contact
        ];

        List<Id> sobjectsIds = CollectionUtil.getObjectIds(contacts);
        System.assertEquals(sobjectsIds.size(), contacts.size());
    }

    @IsTest
    static void getSObjectMapTest() {
        List<Contact> contacts = [
                SELECT Id
                FROM Contact
        ];
        Map<String, SObject> mapAccountIds = (Map<String, SObject>) CollectionUtil.getSObjectMap(contacts, 'Id');
        System.assertEquals(mapAccountIds.keySet().size(), contacts.size());
    }

    @IsTest
    static void sortByFieldTest() {
        List<Contact> contacts = [
                SELECT Id,
                        FirstName,
                        Trials_in_Last_12_Months__c,
                        Birthdate
                FROM Contact
        ];

        CollectionUtil.sortByField(contacts, 'FirstName', false);
        System.assertEquals('Contact 2', contacts.get(1).FirstName);
        CollectionUtil.sortByField(contacts, 'FirstName', true);
        System.assertEquals('Contact 3', contacts.get(0).FirstName);
        CollectionUtil.sortByField(contacts, 'Trials_in_Last_12_Months__c', true);
        System.assertEquals('Contact 1', contacts.get(2).FirstName);
        CollectionUtil.sortByField(contacts, 'Birthdate', true);
        System.assertEquals('Contact 1', contacts.get(2).FirstName);
    }

}