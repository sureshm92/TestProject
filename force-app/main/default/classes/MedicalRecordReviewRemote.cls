/**
 * Created by Leonid Bartenev
 */

public without sharing class MedicalRecordReviewRemote {

    public class InitData{
        public HCP_Enrollment__c hcpEnrollment;
        public Map<String, StudyActions.Action> actions;
    }

    @AuraEnabled
    public static String getInitData(String trialId){
        try{
            HCP_Enrollment__c hcpEnrollment = HCPEnrollmentService.getHCPEnrollmentForHCPByTrial(trialId);
            //localize MRR
            if(hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c != null){
                hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c =
                        CommunityFacadeRemote.getLocalizedURL(hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c);
            }
            if(hcpEnrollment == null) throw new CommunityServiceException('Data not found');
            new StudyActionsHCP(hcpEnrollment).checkAction(StudyActions.ACT_MEDICAL_RECORD_REVIEW);
            StudyActions sActions = new StudyActionsHCP(hcpEnrollment);
            InitData initData = new InitData();
            initData.hcpEnrollment = hcpEnrollment;
            initData.actions = sActions.actions;
            //check accessibility;
            return JSON.serialize(initData);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }


    public class SearchPEResult{
        public Participant_Enrollment__c  pe;
        public String result;
    }

    @AuraEnabled
    public static String createParticipantEnrollment(Id trialId, String participantId, String firstName, String lastName){
        Savepoint sp = Database.setSavepoint();
        try{
            Clinical_Trial_Profile__c trial = SudyTrialService.getFullTrial(trialId);
            HCP_Enrollment__c hcpEnrollment = HCPEnrollmentService.getHCPEnrollmentForHCPByTrial(trialId);
            SearchPEResult peResult = new SearchPEResult();
            //find already created participant enrollments:
            peResult.pe = ParticipantEnrollmentService.findParticipantEnrollment(hcpEnrollment, participantId);
            //If participant is null then create new
            if (peResult.pe == null) {
                peResult.pe = ParticipantEnrollmentService.createParticipantEnrollment(trial, hcpEnrollment, participantId);
                peResult.pe.Participant_Name__c = firstName;
                peResult.pe.Participant_Surname__c = lastName;
                peResult.result = 'New';
            //} else if (peResult.pe.HCP__c != hcpeId) {
            //    peResult.result = 'Other HCP';
            } else if (peResult.pe.Participant_Status__c == ParticipantEnrollmentService.PART_STATUS_FAILED_REVIEW) {
                peResult.result = 'MRR Fail';
            } else if (peResult.pe.Participant_Status__c == ParticipantEnrollmentService.PART_STATUS_FAILED_REFERRAL) {
                if(trial.Link_to_Medical_Record_Review__c == null){
                    peResult.result = 'PES Fail';
                }else{
                    peResult.result = 'MRR Pass PES Fail';
                }
            } else if (peResult.pe.Participant_Status__c == ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL) {
                peResult.result = 'PES Pending';
            } else {
                peResult.result = 'Completed';
            }
            return JSON.serialize(peResult);
        }catch (Exception e){
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static String setMRRStatus(String peJSON, String status){
        Savepoint sp = Database.setSavepoint();
        try{
            Participant_Enrollment__c participantEnrollment = (Participant_Enrollment__c)JSON.deserialize(peJSON, Participant_Enrollment__c.class);
            participantEnrollment.Medical_Record_Review_Status__c = status;
            participantEnrollment.Medical_Record_Review_Completed_by__c = CommunityService.getUserContact().Id;
            if(status == ParticipantEnrollmentService.MRR_STATUS_PASS){
                participantEnrollment.Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL;
            }else{
                participantEnrollment.Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_FAILED_REVIEW;
            }
            System.debug('PE: ' + JSON.serialize(participantEnrollment));
            upsert participantEnrollment;
            return JSON.serialize(participantEnrollment);
        }catch (Exception e){
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }



}