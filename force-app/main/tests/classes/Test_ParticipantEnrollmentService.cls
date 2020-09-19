/**
 * Created by Dmitry Ivakhnenko on 16-Mar-20.
 */

@IsTest
public class Test_ParticipantEnrollmentService {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void testImproveCoverage() {
        /* Increasing test coverage */
        TestData testData = new TestData();
        testData.createPatientDelegate();

        Test.startTest();
        Id ctpId = testData.ctp.Id;
        String userMode = CommunityService.USER_MODE_PARTICIPANT;
        String status = ParticipantEnrollmentService.PART_STATUS_RECEIVED;
        String reason = ParticipantEnrollmentService.NON_REF_REASON_STATUS_NOT_INTERESTED;
        String sponsorName = 'Janssen';
        Id delegateId;
        System.runAs(testData.participantUser) {
            delegateId = PatientDelegateService.getInstance().getPDelegates().get(0).Id;
        }
        System.assertEquals(1, ParticipantEnrollmentService.getPEnrolmentsCount(new List<Id>{ctpId}, userMode, new List<String>{status}));
        System.assertEquals(1, ParticipantEnrollmentService.getPEnrolmentsCount(new List<Id>{ctpId}, userMode, new List<String>{status}, delegateId));
        System.assertEquals(1, ParticipantEnrollmentService.getPEnrolmentsCount(userMode, status));
        System.assertEquals(1, ParticipantEnrollmentService.getPEnrolmentsCount(userMode, new List<String>{status}));
        System.assertEquals(0, ParticipantEnrollmentService.getPEnrolmentsCount(new List<Id>{ctpId}, userMode, status, reason));
        System.assertEquals(0, ParticipantEnrollmentService.getPEnrolmentsCount(new List<Id>{ctpId}, userMode, status, reason, delegateId));
        System.assertEquals(0, ParticipantEnrollmentService.getPEnrolmentsCount(new List<Id>{ctpId}, userMode, new List<String>{status}, new List<String>{reason}));

        ParticipantEnrollmentService.PEFilterData filterData = ParticipantEnrollmentService.getPEFilterData(ctpId, userMode, false);
        ParticipantEnrollmentService.PEFilter filter = new ParticipantEnrollmentService.PEFilter(filterData);
        ParticipantEnrollmentService.getParticipantEnrollments(filter, delegateId, sponsorName);

        filter.searchFields = new List<String>{'Participant__r.Email__c', 'Screening_ID__c'};
        filter.searchText = 'PESCR1';
        filter.sortType = 'Alphabetical_DESC';
        List<Participant_Enrollment__c> filterPe = ParticipantEnrollmentService.getParticipantEnrollments(filter, delegateId, sponsorName);

        List<Participant_Enrollment__c> pendingPe = ParticipantEnrollmentService.getPendingParticipantEnrollments(ctpId, testData.hcpEnrollment.Id);
        ParticipantEnrollmentService.updateParticipantStateById(new List<Id>{testData.participant.Id});
        Test.stopTest();
        System.assertEquals(new List<Id>{ctpId}, filterData.trialIds);
        System.assertEquals('Participant', filter.mode);
        System.assertEquals(new List<Id>{ctpId}, filter.trialIds);

        System.assertEquals(testData.pe.Id, filterPe[0].Id);
        System.assertEquals(0, pendingPe.size());
    }

}