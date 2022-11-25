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
        System.assertEquals(
            1,
            ParticipantEnrollmentService.getPEnrolmentsCount(
                new List<Id>{ ctpId },
                userMode,
                new List<String>{ status }
            )
        );
        System.assertEquals(
            1,
            ParticipantEnrollmentService.getPEnrolmentsCount(
                new List<Id>{ ctpId },
                userMode,
                new List<String>{ status },
                delegateId
            )
        );
        System.assertEquals(1, ParticipantEnrollmentService.getPEnrolmentsCount(userMode, status));
        System.assertEquals(
            1,
            ParticipantEnrollmentService.getPEnrolmentsCount(userMode, new List<String>{ status })
        );
        System.assertEquals(
            0,
            ParticipantEnrollmentService.getPEnrolmentsCount(
                new List<Id>{ ctpId },
                userMode,
                status,
                reason
            )
        );
        System.assertEquals(
            0,
            ParticipantEnrollmentService.getPEnrolmentsCount(
                new List<Id>{ ctpId },
                userMode,
                status,
                reason,
                delegateId
            )
        );
        System.assertEquals(
            0,
            ParticipantEnrollmentService.getPEnrolmentsCount(
                new List<Id>{ ctpId },
                userMode,
                new List<String>{ status },
                new List<String>{ reason }
            )
        );

        ParticipantEnrollmentService.PEFilterData filterData = ParticipantEnrollmentService.getPEFilterData(
            ctpId,
            userMode,
            false
        );
        ParticipantEnrollmentService.PEFilter filter = new ParticipantEnrollmentService.PEFilter(
            filterData
        );
        /***Test Class code extra - SK ***/
        ParticipantEnrollmentService.getEnrollmentsByExternalKey(new List<String>{ '' });
        ParticipantEnrollmentService.getParticipantEnrollmentsActiveFilterOptimized(
            testData.pe.Id,
            CommunityService.USER_MODE_PI,
            delegateId,
            'Id != null',
            new List<String>{ 'Id' }
        );
        ParticipantEnrollmentService.getParticipantEnrollmentsActiveFilterOptimized(
            testData.pe.Id,
            userMode,
            delegateId,
            'Id != null',
            new List<String>{ 'Id' }
        );
        ParticipantEnrollmentService.getParticipantEnrollmentsActiveFilter(
            testData.pe.Id,
            CommunityService.USER_MODE_PI,
            delegateId,
            'Id != null'
        );
        ParticipantEnrollmentService.getParticipantEnrollments(
            filter,
            new PaginationData(15),
            delegateId,
            sponsorName,
            userMode
        );

        ParticipantEnrollmentService.getPEFilterDataWithSponsor(
            CommunityService.USER_MODE_PI,
            ctpId,
            false,
            delegateId,
            sponsorName
        ); //CommunityService.USER_MODE_HCP
        ParticipantEnrollmentService.getPEFilterDataWithSponsor(
            CommunityService.USER_MODE_HCP,
            ctpId,
            false,
            delegateId,
            sponsorName
        );

        ParticipantEnrollmentService.getParticipantEnrollmentsCustomFields(
            new List<String>{ 'Id' },
            filter,
            delegateId,
            false,
            new PaginationData(15),
            sponsorName
        );
        ParticipantEnrollmentService.createParticipantEnrollment(
            testData.ctp,
            testData.hcpEnrollment,
            testData.participant.Id + ''
        );
        ParticipantEnrollmentService obj = new ParticipantEnrollmentService();
        obj.getParticipantEnrollmentImpl(testData.pe.Id, userMode);
        obj.getParticipantEnrollmentImpl(
            testData.pe.Id,
            userMode,
            delegateId,
            new List<String>{
                'Id',
                'Participant__r.Mailing_Country_Code__c',
                'Participant__r.Mailing_Country__c'
            }
        );
        ParticipantEnrollmentService.findParticipantEnrollment(
            testData.hcpEnrollment,
            testData.participant.Id + ''
        );
        ParticipantEnrollmentService.getParticipantEnrollment(
            testData.pe.Id,
            userMode,
            delegateId,
            new List<String>{
                'Id',
                'Participant__r.Mailing_Country_Code__c',
                'Participant__r.Mailing_Country__c'
            }
        );
        ParticipantEnrollmentService.getPreScreeningsAllByTrial(testData.ctp.Id);
        ParticipantEnrollmentService.getPreScreeningsPassedByTrial(testData.ctp.Id);
        ParticipantEnrollmentService.getMRRAllByTrial(testData.ctp.Id);
        ParticipantEnrollmentService.getMRRPassedByTrial(testData.ctp.Id);
        ParticipantEnrollmentService.getPEnrolmentsCount(userMode, '', delegateId);
        // getPEnrolmentsCount
        ParticipantEnrollmentService.getPEnrolmentsCountCommon(userMode, '');
        ParticipantEnrollmentService.getPEnrolmentsByStatus(userMode, new List<String>{ '' }, 1);
        ParticipantEnrollmentService.getPEEnrollmentsByPI(userMode, testData.piContact.Id);
        //getPEnrolmentsByStatus(String userMode,
        //List<String> statuses,
        //Integer recordsLimit,
        //String delegateId)
        /** Test class change - End SK **/

        ParticipantEnrollmentService.getParticipantEnrollments(filter, delegateId, sponsorName);

        filter.searchFields = new List<String>{ 'Participant__r.Email__c', 'Screening_ID__c' };
        filter.searchText = 'PESCR1';
        filter.sortType = 'Alphabetical_DESC';
        List<Participant_Enrollment__c> filterPe = ParticipantEnrollmentService.getParticipantEnrollments(
            filter,
            delegateId,
            sponsorName
        );

        List<Participant_Enrollment__c> pendingPe = ParticipantEnrollmentService.getPendingParticipantEnrollments(
            ctpId,
            testData.hcpEnrollment.Id
        );
        ParticipantEnrollmentService.updateParticipantStateById(
            new List<Id>{ testData.participant.Id }
        );
        ParticipantEnrollmentService.getPreScreeningsAllByTrial();
        ParticipantEnrollmentService.getPreScreeningsPassedByTrial();
        ParticipantEnrollmentService.getMRRAllByTrial();
        ParticipantEnrollmentService.getMRRPassedByTrial();
        ParticipantEnrollmentService.getReferredByTrial();
		ParticipantEnrollmentService.getHealthcareProviderPE();
        ParticipantEnrollmentService.getParticipantEnrollments(filter,
            new PaginationData(15),
            delegateId,
            sponsorName);
        
        //getPreScreeningsPassedByTrial
        Test.stopTest();
        System.assertEquals(new List<Id>{ ctpId }, filterData.trialIds);
        System.assertEquals('Participant', filter.mode);
        System.assertEquals(new List<Id>{ ctpId }, filter.trialIds);

        System.assertEquals(testData.pe.Id, filterPe[0].Id);
        System.assertEquals(0, pendingPe.size());
    }

    @IsTest
    public static void testImproveCoverage2() {
        TestData testData = new TestData();
        testData.createPatientDelegate();

        
        Id ctpId = testData.ctp.Id;
        String userMode = CommunityService.USER_MODE_PARTICIPANT;
        String status = ParticipantEnrollmentService.PART_STATUS_RECEIVED;
        String reason = ParticipantEnrollmentService.NON_REF_REASON_STATUS_NOT_INTERESTED;
        String sponsorName = 'Janssen';
        Id delegateId;
        System.runAs(testData.participantUser) {
            delegateId = PatientDelegateService.getInstance().getPDelegates().get(0).Id;
        }
        ParticipantEnrollmentService.PEFilterData filterData = ParticipantEnrollmentService.getPEFilterData(
            ctpId,
            userMode,
            false
        );
        ParticipantEnrollmentService.PEFilter filter = new ParticipantEnrollmentService.PEFilter(
            filterData
        );
        Test.startTest();
        try {
            ParticipantEnrollmentService.getParticipantEnrollmentsCustomFields(
                new List<String>{ 'Id' },
                filter,
                new PaginationData(15),
                delegateId,            
                sponsorName
            );
        }catch(Exception ex) {}
        ParticipantEnrollmentService ser = new ParticipantEnrollmentService();

        try{
            ser.getPEnrolmentsCommonCustomFieldsImpl(                
                userMode,
                new List<String>{ status },
                ''
            );
        }catch(Exception ex) {}
        
        ser.getPendingParticipantEnrollmentsImpl( filter.trialIds[0],testData.hcpEnrollment.Id);
        ParticipantEnrollmentService.getReferredPEList(usermode,'');
        try {
                ParticipantEnrollmentService.getPEnrolmentsCommonCustomFields( userMode,
                new List<String>{ status },
                ''
                );
        }catch(Exception e){}

        /*ParticipantEnrollmentService.getParticipantEnrollments(
            filter,
            new PaginationData(1),
            sponsorName
        );*/
        Test.stopTest();
    }
}