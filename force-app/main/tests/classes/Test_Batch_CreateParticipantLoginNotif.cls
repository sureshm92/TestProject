/**
 * Created by Igor Iosifov on 2020-03-03.
 */

@IsTest
public with sharing class Test_Batch_CreateParticipantLoginNotif {

    @TestSetup
    static void setup() {

        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void test() {
        TestData testData = new TestData();
        Contact contact = new Contact(
                FirstName = 'newContact',
                LastName = 'newContact',
                Next_Notify_Date__c = Datetime.now().dateGmt().addDays(-1),
                Current_Participant_Enrollment__c = testData.pe.Id
        );
        insert contact;

        testData.participant = [SELECT Id, Contact__c, Status__c FROM Participant__c];
        testData.participant.Contact__c = contact.Id;
        testData.participant.Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS;
        update testData.participant;
        update testData.pe;

        testData.ctp = [SELECT Id, Logged_Out_Days_Notification__c FROM Clinical_Trial_Profile__c];
        testData.ctp.Logged_Out_Days_Notification__c = 1;
        update testData.ctp;

        delete [SELECT Id FROM Notification__c];

        Test.startTest();
        Database.executeBatch(new Batch_CreateParticipantLoginNotification());
        Test.stopTest();

        List<Notification__c> notifications = [SELECT Id FROM Notification__c];
        System.assertEquals(1, notifications.size());
    }
}