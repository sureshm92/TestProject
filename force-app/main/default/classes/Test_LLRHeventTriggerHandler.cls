@isTest
public with sharing class Test_LLRHeventTriggerHandler {

    @TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

   @isTest
    public static void sendtoAPIafterInsert_Test(){
        TestData testData = new TestData();

        Map<Id, Participant_Enrollment__c> oldMap = new Map<Id, Participant_Enrollment__c>{
            testData.pe.Id => testData.pe.clone(true, true, true, true)
        };
        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_DECEASED;
        List<Participant_Enrollment__c> enrollments = new List<Participant_Enrollment__c>{
            testData.pe
        };
        Date d = Date.today();
        Datetime dt = DateTime.newInstance(2004, 1, 27, 4, 1, 2);
        Time t = dt.time();
        test.startTest();
        LL_RH_event__e llrhEvent = new LL_RH_event__e();
        llrhEvent.ParticipantEnrollment_ID__c = testData.pe.Id;
        llrhEvent.Status__c = 'Ready to Contact';
        llrhEvent.OldAppointmentDate__c = String.valueOf(d);
        llrhEvent.OldAppointmentTime__c = String.valueOf(t);
        llrhEvent.Appointment_Id__c = 'Test12345' +d;
        EventBus.publish(llrhEvent);
        Test.setMock(HttpCalloutMock.class, new Mock_LLRHeventTriggerHandler());  
        test.stopTest();
    }
}