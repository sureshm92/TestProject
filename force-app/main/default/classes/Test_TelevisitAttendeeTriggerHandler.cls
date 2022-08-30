@IsTest
public class Test_TelevisitAttendeeTriggerHandler {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void taskTest()
    {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        TestData testData = new TestData();
        
        Televisit_Attendee__c taObj = new Televisit_Attendee__c();
                Televisit_Attendee__c taObj1 = new Televisit_Attendee__c();

        Televisit__c televisitRecord = new Televisit__c();
        televisitRecord.Title__c = 'title';
        televisitRecord.Duration__c='15 minutes';
        televisitRecord.Status__c='Scheduled';
        televisitRecord.Participant_Enrollment__c = testData.pe.Id;
        insert televisitRecord;
        taObj.Attendee_Type__c='Participant';
        taObj.Televisit__c = televisitRecord.Id;
        taObj.Contact__c =  testData.pe.Participant_Contact__c;
        insert taObj;
        taObj1.Attendee_Type__c='PI';
        taObj1.Televisit__c = televisitRecord.Id;
        taObj1.Contact__c =  testData.pe.Participant_Contact__c;
        insert taObj1;
                        Televisit_Attendee__c taObj2 = new Televisit_Attendee__c();
         taObj2.Attendee_Type__c='PI';
        taObj2.Televisit__c = televisitRecord.Id;
        taObj2.Contact__c =  testData.pe.Participant_Contact__c;
        insert taObj2;
delete taObj2;
        TelevisitAttendeeTriggerHandler.ManageAttendees manageAttendee = new TelevisitAttendeeTriggerHandler.ManageAttendees();
        manageAttendee.afterDelete(new List<Televisit_Attendee__c>{taObj,taObj1,taObj2});
        manageAttendee.afterInsert(new List<Televisit_Attendee__c>{taObj,taObj1});
        TelevisitAttendeeTriggerHandler.TelevisitEventTrigger teTrigger = new TelevisitAttendeeTriggerHandler.TelevisitEventTrigger();
        teTrigger.afterInsert(new List<Televisit_Attendee__c>{taObj,taObj1});
        TelevisitAttendeeTriggerHandler.TelevisitAttendeeTrigger taTrigger = new TelevisitAttendeeTriggerHandler.TelevisitAttendeeTrigger();
        taTrigger.afterDelete(new List<Televisit_Attendee__c>{taObj,taObj1,taObj2});
                taTrigger.afterInsert(new List<Televisit_Attendee__c>{taObj,taObj1});
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