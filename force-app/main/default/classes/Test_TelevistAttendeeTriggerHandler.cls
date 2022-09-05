@isTest
private without sharing class Test_TelevistAttendeeTriggerHandler {
    @TestSetup
    static void makeData() {
        TestData.loadTestData();
        TestData.createTelevisits();
        Test.startTest();
        TestData td = new TestData();
        Test.stopTest();
        List<Televisit__c> tVisits = [SELECT Id FROM Televisit__c LIMIT 10];
        TestData.addAttendees(
            tVisits[0].Id,
            new List<Id>{ td.piContact.Id, td.participant.Contact__c, td.piDelegateContact.Id }
        );
    }

    @isTest
    static void testAfterDelete() {
        List<Televisit__c> tVisits = [
            SELECT Id, (SELECT Id FROM Televisit_Attendee__r)
            FROM Televisit__c
            LIMIT 10
        ];
        delete tVisits;
    }
}