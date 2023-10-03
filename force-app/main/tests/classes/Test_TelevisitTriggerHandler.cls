@isTest
public with sharing class Test_TelevisitTriggerHandler {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @isTest
    static void saveChanges() {
        Test.startTest();
        List<Televisit__c> televisits = new List<Televisit__c>();
        Map<Id, Televisit__c> oldMap = new Map<Id, Televisit__c>();
        Set<Id> televisitIds = new Set<Id>();
        List<SObject> newList = new List<SObject>();
        TelevisitTriggerHandler.alertAttendees(televisits, oldMap);
        TelevisitTriggerHandler.checkForTelevisitEventCreation(newList);
        TelevisitTriggerHandler.checkForTelevisitEventCreation(newList, oldMap);
        TelevisitTriggerHandler.createTelevisitEvent();
        TelevisitTriggerHandler.createTelevisitEvent(televisitIds);
        Test.stopTest();
    }
    @isTest
    static void taskTest() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        TestData testData = new TestData();
        
        Televisit_Record_Vendor__c trv = new Televisit_Record_Vendor__c(API_Key__c = 'test',API_Secret__c='test1', Clinical_Trial_Profile__c=testData.ctp.id);
        insert trv;
        TelevisitVendorSettings__c tvs = new TelevisitVendorSettings__c(Study_Site__c = testData.ss.id,isEnable__c=True, Televisit_Record_Vendor__c=trv.id);
        insert tvs;
        
        Televisit_Attendee__c taObj = new Televisit_Attendee__c();
        Televisit_Attendee__c taObj1 = new Televisit_Attendee__c();

        Televisit__c televisitRecord = new Televisit__c();
        televisitRecord.Title__c = 'title';
        televisitRecord.Duration__c = '15 minutes';
        televisitRecord.Status__c = 'Scheduled';
        televisitRecord.Participant_Enrollment__c = testData.pe.Id;
        televisitRecord.Visit_Date_Time__c = Datetime.now();
        televisitRecord.Meeting_URL__c = 'jjjj';

        insert televisitRecord;
        taObj.Attendee_Type__c = 'Participant';
        taObj.Televisit__c = televisitRecord.Id;
        taObj.Contact__c = testData.pe.Participant_Contact__c;
        insert taObj;
        taObj1.Attendee_Type__c = 'PI';
        taObj1.Televisit__c = televisitRecord.Id;
        taObj1.Contact__c = testData.pe.Participant_Contact__c;
        insert taObj1;
        Televisit_Attendee__c taObj2 = new Televisit_Attendee__c();
        taObj2.Attendee_Type__c = 'PI';
        taObj2.Televisit__c = televisitRecord.Id;
        taObj2.Contact__c = testData.pe.Participant_Contact__c;
        insert taObj2;
        delete taObj2;
        televisitRecord.Visit_Date_Time__c = Datetime.now().addMinutes(15);
        update televisitRecord;
        televisitRecord.Status__c = 'Cancelled';
        update televisitRecord;
        Test.stopTest();
    }
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('[{"session_id":"test"}]');
            res.setStatusCode(200);
            return res;
        }
    }
}