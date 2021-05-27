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

        Map<Id, Participant_Enrollment__c> oldMap = new Map<Id, Participant_Enrollment__c>{
            testData.pe.Id => testData.pe.clone(true, true, true, true)
        };
        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_DECEASED;
        List<Participant_Enrollment__c> enrollments = new List<Participant_Enrollment__c>{
            testData.pe
        };
        List<Participant_Enrollment_Status_History__c> PEhistorty = new List<Participant_Enrollment_Status_History__c>();
        List<Participant_Enrollment_Status_History__c> PEhistortyaccepted = new List<Participant_Enrollment_Status_History__c>();
        for (Participant_Enrollment__c pe : enrollments) {
            Participant_Enrollment_Status_History__c history = new Participant_Enrollment_Status_History__c(
                Date__c = Datetime.now(),
                Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS,
                ParticipantEnrollment__c = pe.Id
            );
            PEhistorty.add(history);
        }
        insert PEhistorty;
        
        List<Id> peshIdsList=new List<Id>();
        for(Participant_Enrollment_Status_History__c obj: PEhistorty) 
            peshIdsList.add(obj.Id);

        Test.startTest();
        ParticipantEnrollmentTriggerHandler.deactivateDeceasedUsers(enrollments, oldMap);
        ParticipantEnrollmentSHTriggerHandler.updateEnrollmentStatus(PEhistorty);
        ParticipantEnrollmentSHTriggerHandler.createStudyAlerts(peshIdsList);
        for (Participant_Enrollment_Status_History__c peh : PEhistorty) {
            peh.Status__c = PEStatusState.PE_STATUS_ELIGIBILITY_PASSED;
            PEhistortyaccepted.add(peh);
        }
        update PEhistortyaccepted;
        ParticipantEnrollmentSHTriggerHandler.updateEnrollmentStatus(PEhistortyaccepted);
        Test.stopTest();

        List<User> users = [
            SELECT IsActive
            FROM User
            WHERE ContactId = :testData.pe.Participant_Contact__c
        ];
        System.assert(users.size() > 0);
        System.assertEquals(false, users[0].IsActive);
    }
}
