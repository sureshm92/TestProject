/**
 * Created by Leonid Bartenev
 */

public without sharing class MedicalRecordReviewRemote {
    public class InitData {
        public HCP_Enrollment__c hcpEnrollment;
        public Contact hcpContact;
        public Clinical_Trial_Profile__c trial;
        public PreScreener_Survey__c preSurvey;
        public Map<String, StudyActions.Action> actions;
        public String delegateAccessLevel;
        public String hcpEnrollmentParticipantName;
        public Participant__c hcpContactParticipant;
    }

    @AuraEnabled
    public static String getInitData(String trialId, String hcpeId, String delegateId) {
        try {
            InitData initData = new InitData();
            initData.trial = StudyTrialService.getFullTrial(trialId);
            initData.delegateAccessLevel = CommunityService.getInstance()
                .getUserAccessLevel(delegateId);
            if (hcpeId != null) {
                HCP_Enrollment__c hcpEnrollment = HCPEnrollmentService.getHCPEnrollmentById(
                    hcpeId,
                    CommunityService.USER_MODE_HCP,
                    delegateId
                );
                if (hcpEnrollment == null)
                    throw new CommunityServiceException('Data not found');
                new StudyActionsHCP(hcpEnrollment, delegateId)
                    .checkAction(StudyActions.ACT_MEDICAL_RECORD_REVIEW);
                StudyActions sActions = new StudyActionsHCP(hcpEnrollment, delegateId);
                if(hcpEnrollment!=null){
                    Map<Id,String> hcpName = ParticipantWorkflowService.getPIContactSalutationAndNames(new Set<Id>{hcpEnrollment.HCP_Contact__c});
                    if(!hcpName.isEmpty()){
                        initData.hcpEnrollmentParticipantName = hcpName.get(hcpEnrollment.HCP_Contact__c);
                    }
                }
                initData.hcpEnrollment = hcpEnrollment;
                initData.actions = sActions.actions;
            } else if (
                DelegateService.DELEGATE_LEVEL_1_AND_LOW.contains(
                    DelegateService.getStudyAccessLevel(
                        null,
                        CommunityService.USER_MODE_HCP,
                        delegateId
                    )
                )
            ) {
                List<HCP_Enrollment__c> hcpEnrollments = HCPEnrollmentService.getHCPEnrollmentsForHCPByTrial(
                    trialId,
                    delegateId
                );
                if (hcpEnrollments.isEmpty())
                    throw new CommunityServiceException('Data not found');
                initData.hcpContact = hcpEnrollments[0].HCP_Contact__r;
                if(hcpEnrollments[0].HCP_Contact__c!=null){
                    Map<Id,Participant__c> hcpPartDetail=  ParticipantWorkflowService.getPIContactNameDetails(new Set<Id>{hcpEnrollments[0].HCP_Contact__c} ); 
                    if(!hcpPartDetail.isEmpty()){
                        initData.hcpContactParticipant = hcpPartDetail.get(hcpEnrollments[0].HCP_Contact__c);
                    }
                }
                StudyActions sActions = new StudyActionsHCP(hcpEnrollments[0], delegateId);
                initData.actions = sActions.actions;
            }
            initData.preSurvey = getMRRSurvey(trialId);
            //check accessibility;
            return JSON.serialize(initData);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    public class SearchPEResult {
        public Participant_Enrollment__c pe;
        public String result;
    }

    public static PreScreener_Survey__c getMRRSurvey(Id trialId){
        try {
			List<PreScreener_Survey__c> preSurveyList = [
                SELECT MRR__c, Primary__c, Link_to_Pre_screening__c, ProviderName__c, 
                    Study__c, Survey_Name__c 
                FROM PreScreener_Survey__c  
                WHERE Study__c = :trialId AND MRR__c = true
            ];
            if(!preSurveyList.isEmpty()){
                preSurveyList[0].Link_to_Pre_screening__c = CommunityFacadeRemote.getLocalizedURL(preSurveyList[0].Link_to_Pre_screening__c);
                return preSurveyList[0];
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String createParticipantEnrollmentHcpe(
        Id trialId,
        String hcpeId,
        String participantId,
        String firstName,
        String lastName,
        String delegateId
    ) {
        Savepoint sp = Database.setSavepoint();
        try {
            System.debug('createEnrollment delegateId:' + delegateId);
            Clinical_Trial_Profile__c trial = StudyTrialService.getFullTrial(trialId);
            HCP_Enrollment__c hcpEnrollment = HCPEnrollmentService.getHcpEnroll(hcpeId);
            System.debug('createEnrollment hcpEnroll:' + hcpEnrollment);
            SearchPEResult peResult = new SearchPEResult();
            //find already created participant enrollments:
            peResult.pe = ParticipantEnrollmentService.findParticipantEnrollment(
                hcpEnrollment,
                participantId
            );
            //If participant is null then create new
            if (peResult.pe == null) {
                peResult.pe = ParticipantEnrollmentService.createParticipantEnrollment(
                    trial,
                    hcpEnrollment,
                    participantId
                );
                peResult.pe.Participant_Name__c = firstName;
                peResult.pe.Participant_Surname__c = lastName;
                peResult.result = 'New';
                //} else if (peResult.pe.HCP__c != hcpeId) {
                //    peResult.result = 'Other HCP';
            } else if (
                peResult.pe.Participant_Status__c ==
                ParticipantEnrollmentService.PART_STATUS_FAILED_REVIEW
            ) {
                peResult.result = 'MRR Fail';
            } else if (
                peResult.pe.Participant_Status__c ==
                ParticipantEnrollmentService.PART_STATUS_FAILED_REFERRAL
            ) {
                PreScreener_Survey__c survey = getMRRSurvey(trialId);
                if (survey == null) {
                    peResult.result = 'PES Fail';
                } else {
                    peResult.result = 'MRR Pass PES Fail';
                }
            } else if (
                peResult.pe.Participant_Status__c ==
                ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL
            ) {
                peResult.result = 'PES Pending';
            } else {
                peResult.result = 'Completed';
            }
            return JSON.serialize(peResult);
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String createParticipantEnrollment(
        Id trialId,
        String participantId,
        String firstName,
        String lastName,
        String delegateId
    ) {
        Savepoint sp = Database.setSavepoint();
        try {
            System.debug('createEnrollment delegateId:' + delegateId);
            Clinical_Trial_Profile__c trial = StudyTrialService.getFullTrial(trialId);
            HCP_Enrollment__c hcpEnrollment = HCPEnrollmentService.getHCPEnrollmentForHCPByTrial(
                trialId,
                delegateId
            );
            System.debug('createEnrollment hcpEnroll:' + hcpEnrollment);
            SearchPEResult peResult = new SearchPEResult();
            //find already created participant enrollments:
            peResult.pe = ParticipantEnrollmentService.findParticipantEnrollment(
                hcpEnrollment,
                participantId
            );
            //If participant is null then create new
            if (peResult.pe == null) {
                peResult.pe = ParticipantEnrollmentService.createParticipantEnrollment(
                    trial,
                    hcpEnrollment,
                    participantId
                );
                peResult.pe.Participant_Name__c = firstName;
                peResult.pe.Participant_Surname__c = lastName;
                peResult.result = 'New';
                //} else if (peResult.pe.HCP__c != hcpeId) {
                //    peResult.result = 'Other HCP';
            } else if (
                peResult.pe.Participant_Status__c ==
                ParticipantEnrollmentService.PART_STATUS_FAILED_REVIEW
            ) {
                peResult.result = 'MRR Fail';
            } else if (
                peResult.pe.Participant_Status__c ==
                ParticipantEnrollmentService.PART_STATUS_FAILED_REFERRAL
            ) {
                PreScreener_Survey__c survey = getMRRSurvey(trialId);
                if (survey == null) {
                    peResult.result = 'PES Fail';
                } else {
                    peResult.result = 'MRR Pass PES Fail';
                }
            } else if (
                peResult.pe.Participant_Status__c ==
                ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL
            ) {
                peResult.result = 'PES Pending';
            } else {
                peResult.result = 'Completed';
            }
            return JSON.serialize(peResult);
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String setMRRStatus(String peJSON, String status, String surveyGizmoData,Id preSurvey) {
        Savepoint sp = Database.setSavepoint();
        try {
            Participant_Enrollment__c participantEnrollment = (Participant_Enrollment__c) JSON.deserialize(
                peJSON,
                Participant_Enrollment__c.class
            );
            if (status == ParticipantEnrollmentService.MRR_STATUS_PASS) {
                participantEnrollment.Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL;
            } else {
                participantEnrollment.Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_FAILED_REVIEW;
            }
            upsert participantEnrollment;
        
            Participant_PrescreenerResponse__c prscreenerresponse = new Participant_PrescreenerResponse__c();
            prscreenerresponse.Participant_enrollment__c = participantEnrollment.Id;
            prscreenerresponse.Status__c = status;
            prscreenerresponse.PreScreener_Survey__c = preSurvey;
            prscreenerresponse.Screener_Response__c = surveyGizmoData;
            prscreenerresponse.Completed_by__c = CommunityService.getUserContact().Id;
            prscreenerresponse.Completed_Date__c = Datetime.now();
            prscreenerresponse.MRR__c = true;
            insert prscreenerresponse;

            return JSON.serialize(participantEnrollment);
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static void updatePESurveyGizmoInfo() {
    }
}