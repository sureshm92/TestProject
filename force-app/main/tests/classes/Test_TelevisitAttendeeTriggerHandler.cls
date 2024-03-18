@IsTest
public class Test_TelevisitAttendeeTriggerHandler {
    @IsTest
    static void taskTest()
    {
         TriggerHandlerExecutor.bypassHandler(NotificationTriggerHandler.UpdateNotificationHandler.class);
         Test.startTest();
        TestData.loadTestData();
        TestData testData = new TestData();
        Televisit_Record_Vendor__c trv = new Televisit_Record_Vendor__c(API_Key__c = 'test',API_Secret__c='test1', Clinical_Trial_Profile__c=testData.ctp.id);
        insert trv;
        TelevisitVendorSettings__c tvs = new TelevisitVendorSettings__c(Study_Site__c = testData.ss.id,isEnable__c=True, Televisit_Record_Vendor__c=trv.id);
        insert tvs;
        
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
        List<Id> targetIds = new List<Id>();
        TelevisitAttendeeTriggerHandler.ManageAttendees manageAttendee = new TelevisitAttendeeTriggerHandler.ManageAttendees();
        manageAttendee.afterDelete(new List<Televisit_Attendee__c>{taObj,taObj1,taObj2});
        manageAttendee.afterInsert(new List<Televisit_Attendee__c>{taObj,taObj1});
        TelevisitAttendeeTriggerHandler.TelevisitEventTrigger teTrigger = new TelevisitAttendeeTriggerHandler.TelevisitEventTrigger();
        teTrigger.afterInsert(new List<Televisit_Attendee__c>{taObj,taObj1});
        TelevisitAttendeeTriggerHandler.TelevisitAttendeeTrigger taTrigger = new TelevisitAttendeeTriggerHandler.TelevisitAttendeeTrigger();
        taTrigger.afterDelete(new List<Televisit_Attendee__c>{taObj,taObj1,taObj2});
                taTrigger.afterInsert(new List<Televisit_Attendee__c>{taObj,taObj1});
        TelevisitAttendeeTriggerHandler.gettrimmedTargetRecordIds(targetIds);
        
 Test.stopTest();
        
    }
}