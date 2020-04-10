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
        System.runAs(testData.participantUser) {
            Id ctpId = testData.ctp.Id;
            Id delegateId = PatientDelegateService.getInstance().getPDelegates().get(0).Id;
            String userMode = CommunityService.USER_MODE_PARTICIPANT;
            String status = ParticipantEnrollmentService.PART_STATUS_RECEIVED;
            String reason = ParticipantEnrollmentService.NON_REF_REASON_STATUS_NOT_INTERESTED;

            ParticipantEnrollmentService.getPEnrolmentsCount(new List<Id> {ctpId}, userMode, new List<String> {status});
            ParticipantEnrollmentService.getPEnrolmentsCount(new List<Id> {ctpId}, userMode, new List<String> {status}, delegateId);
            ParticipantEnrollmentService.getPEnrolmentsCount(userMode, status);
            ParticipantEnrollmentService.getPEnrolmentsCount(userMode, new List<String> {status});
            ParticipantEnrollmentService.getPEnrolmentsCount(new List<Id> {ctpId}, userMode, status, reason);
            ParticipantEnrollmentService.getPEnrolmentsCount(new List<Id> {ctpId}, userMode, status, reason, delegateId);
            ParticipantEnrollmentService.getPEnrolmentsCount(new List<Id> {ctpId}, userMode, new List<String> {status}, new List<String> {reason});

            ParticipantEnrollmentService.PEFilterData filterData =
                    ParticipantEnrollmentService.getPEFilterData(ctpId, userMode, false);
            ParticipantEnrollmentService.PEFilter filter = new ParticipantEnrollmentService.PEFilter(filterData);
            ParticipantEnrollmentService.getParticipantEnrollments(filter, delegateId);

            filter.searchFields = new List<String> {'Participant__r.Email__c', 'Screening_ID__c'};
            filter.searchText = 'PESCR1';
            filter.sortType = 'Alphabetical_DESC';
            ParticipantEnrollmentService.getParticipantEnrollments(filter, delegateId);

            ParticipantEnrollmentService.getPendingParticipantEnrollments(ctpId, testData.hcpEnrollment.Id);
            ParticipantEnrollmentService.updateParticipantStateById(new List<Id> {testData.participant.Id});
        }
        Test.stopTest();
    }

}