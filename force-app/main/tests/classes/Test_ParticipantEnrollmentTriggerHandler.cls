/**
 * Created by Dmitry Ivakhnenko on 17-Mar-20.
 */

@IsTest
public class Test_ParticipantEnrollmentTriggerHandler {

    @TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void testDeactivateDeceasedUsers() {
        TestData testData = new TestData();

        Map<Id, Participant_Enrollment__c> oldMap = new Map<Id, Participant_Enrollment__c> {
                testData.pe.Id => testData.pe.clone(true, true, true, true)
        };
        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_DECEASED;
        List<Participant_Enrollment__c> enrollments = new List<Participant_Enrollment__c> {testData.pe};

        Test.startTest();
        ParticipantEnrollmentTriggerHandler.deactivateDeceasedUsers(enrollments, oldMap);
        Test.stopTest();

        List<User> users = [SELECT IsActive FROM User WHERE ContactId = :testData.pe.Participant_Contact__c];
        System.assert(users.size() > 0);
        System.assertEquals(false, users[0].IsActive);
    }
}