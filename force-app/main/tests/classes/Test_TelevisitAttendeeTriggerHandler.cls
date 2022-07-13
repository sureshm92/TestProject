@IsTest
public class Test_TelevisitAttendeeTriggerHandler {
    @IsTest
    static void taskTest()
    {
        TestData.loadTestData();
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

        
    }
}