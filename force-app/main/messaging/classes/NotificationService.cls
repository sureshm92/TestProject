/**
 * Created by Olga Skrynnikova on 11/28/2019.
 */

public without sharing class NotificationService {
    static public List<String> participantStatusListForHCP = new List<String>{
            PEStatusState.PE_STATUS_REFERRAL_ACCEPTED,
            PEStatusState.PE_STATUS_REFERRAL_DECLINED,
            PEStatusState.PE_STATUS_REFERRAL_ON_HOLD,
            PEStatusState.PE_STATUS_REFERRAL_SENT_TO_PI,
            PEStatusState.PE_STATUS_EXCLUDED_FROM_REFERRING,
            PEStatusState.PE_STATUS_FAILED_REFERRAL,
            PEStatusState.PE_STATUS_FAILED_REVIEW
    };

    static public List<String> participantStatusListForPT = new List<String>{
            PEStatusState.PE_STATUS_REFERRAL_ACCEPTED,
            PEStatusState.PE_STATUS_REFERRAL_DECLINED,
            PEStatusState.PE_STATUS_REFERRAL_ON_HOLD,
            PEStatusState.PE_STATUS_REFERRAL_SENT_TO_PI
    };

    static public String MESSAGE_TO_HCP_PATIENT_ACCEPTED_TYPE = 'Message_to_HCP_Patient_Accepted_Type';
    static public String MESSAGE_TO_HCP_PATIENT_DECLINED_TYPE = 'Message_to_HCP_Patient_Declined_Type';
    static public String MESSAGE_TO_HCP_PATIENT_ON_HOLD_TYPE = 'Message_to_HCP_Patient_On_Hold_Type';
    static public String MESSAGE_TO_HCP_REFERRAL_STATUS_UPDATE_TYPE = 'Message_to_HCP_Ref_Status_Update_Type';
    static public String MESSAGE_TO_PT_PATIENT_DECLINED_TYPE = 'Message_to_PT_Patient_Declined_Type';
    static public String MESSAGE_TO_PT_PATIENT_ON_HOLD_TYPE = 'Message_to_PT_Patient_On_Hold_Type';
    static public String MESSAGE_TO_PT_REFERRAL_STATUS_UPDATE_TYPE = 'Message_to_PT_Ref_Status_Update_Type';
    static public String MESSAGE_TO_PT_PATIENT_DECLINED_VT_TYPE = 'Message_to_PT_Patient_Declined_VT_Type';
    static public String MESSAGE_TO_PT_PATIENT_ON_HOLD_VT_TYPE = 'Message_to_PT_Patient_On_Hold_VT_Type';
    static public String MESSAGE_TO_PT_NEW_STUDY_HCP_VT_TYPE = 'Message_to_PT_New_Study_HCP_VT_Type';
    static public String MESSAGE_TO_PT_NEW_STUDY_eRP_VT_TYPE = 'Message_to_PT_New_Study_eRP_VT_Type';
    static public String MESSAGE_TO_PT_NEW_COI_CTP_TYPE = 'Message_to_PT_New_COI_Ctp_Type';
    static public String MESSAGE_TO_PT_COI_CTP_START_ENROLL_TYPE = 'Message_to_PT_COI_Ctp_Start_Enroll_Type';

    static public String EMAIL_STATUS_SKIPPED = 'Skipped';
    static public String EMAIL_STATUS_FAILED = 'Failed';
    static public String EMAIL_STATUS_SENT = 'Sent';
    static public String EMAIL_STATUS_PENDING = 'Pending';

    public static String checkHCPNotificationType(Participant_Enrollment__c peForCheck, Boolean notContains) {
        if (notContains) return MESSAGE_TO_HCP_REFERRAL_STATUS_UPDATE_TYPE;

        if (peForCheck.Participant_Status__c == PEStatusState.PE_STATUS_REFERRAL_ACCEPTED) {
            return MESSAGE_TO_HCP_PATIENT_ACCEPTED_TYPE;
        }
        if (peForCheck.Participant_Status__c == PEStatusState.PE_STATUS_REFERRAL_DECLINED) {
            return MESSAGE_TO_HCP_PATIENT_DECLINED_TYPE;
        }
        if (peForCheck.Participant_Status__c == PEStatusState.PE_STATUS_REFERRAL_ON_HOLD) {
            return MESSAGE_TO_HCP_PATIENT_ON_HOLD_TYPE;
        }
        return null;
    }

    public static String checkPatientNotificationType(Participant_Enrollment__c peForCheck, Boolean notContains) {

        if (notContains) return MESSAGE_TO_PT_REFERRAL_STATUS_UPDATE_TYPE;

        if (peForCheck.Participant_Status__c == PEStatusState.PE_STATUS_REFERRAL_DECLINED) {
            return MESSAGE_TO_PT_PATIENT_DECLINED_TYPE;
        }
        if (peForCheck.Participant_Status__c == PEStatusState.PE_STATUS_REFERRAL_ON_HOLD) {
            return MESSAGE_TO_PT_PATIENT_ON_HOLD_TYPE;
        }
        return null;
    }

    public static String checkPatientNotificationVTType(Participant_Enrollment__c peForCheck) {
        if (peForCheck.Participant_Status__c == PEStatusState.PE_STATUS_REFERRAL_DECLINED) {
            return MESSAGE_TO_PT_PATIENT_DECLINED_VT_TYPE;
        }
        if (peForCheck.Participant_Status__c == PEStatusState.PE_STATUS_REFERRAL_ON_HOLD) {
            return MESSAGE_TO_PT_PATIENT_ON_HOLD_VT_TYPE;
        }
        if (peForCheck.Participant_Status__c == PEStatusState.PE_STATUS_REFERRAL_SENT_TO_PI
                && peForCheck.Referral_Source__c == 'HCP') {
            return MESSAGE_TO_PT_NEW_STUDY_HCP_VT_TYPE;
        }
        if (peForCheck.Referral_Source__c != 'HCP' && peForCheck.Referral_Source__c != 'PI'
                && (peForCheck.Participant_Status__c == PEStatusState.PE_STATUS_REFERRAL_SENT_TO_PI
                || (peForCheck.Participant_Status__c == PEStatusState.PE_STATUS_REFERRAL_ACCEPTED
                && peForCheck.IsAutoaccepted__c))) {
            return MESSAGE_TO_PT_NEW_STUDY_eRP_VT_TYPE;
        }
        return null;
    }
}