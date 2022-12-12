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
        testData.pe.Subject_GUID__c= 'text';
        testData.pe.Initial_visit_scheduled_date__c= system.today();
        testData.pe.Permit_Voice_Text_contact_for_this_study__c=true;
        testData.pe.Permit_Mail_Email_contact_for_this_study__c=true;
          
        testData.pe.Study_Artificial_Voice_Consent_Time__c= system.today();
        testData.pe.Study_Assisted_Dialing_Consent_Time__c= system.today();
        testData.pe.Study_Direct_Mail_Consent_Time__c= system.today();
        testData.pe.Study_Email_Consent_Time__c= system.today();
        testData.pe.Study_Phone_Consent_Time__c= system.today();
        testData.pe.Study_PI_Storage_Consent_Time__c= system.today();
                 
        Time myTime = Time.newInstance(1, 2, 3, 0);
        testData.pe.Initial_visit_scheduled_time__c= myTime;
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
        ParticipantEnrollmentTriggerHandler.updateStudyConsentTimestamps(enrollments, oldMap);
        ParticipantEnrollmentTriggerHandler.updateStudyConsentTimestamps(enrollments);
        ParticipantEnrollmentTriggerHandler.sendtoAPIafterInsert(enrollments);
        ParticipantEnrollmentTriggerHandler.patientConsentUpdate(enrollments, oldMap);
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