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

    static public String NOTIFICATION_TARGET_TYPE_EMAIL = 'Email';
    static public String NOTIFICATION_TARGET_TYPE_SMS = 'SMS';
    static public String NOTIFICATION_TARGET_TYPE_PUSH = 'Push';

    static public String NOTIFICATION_RECIPIENT_TYPE_PARTICIPANT = 'Participant';
    static public String NOTIFICATION_RECIPIENT_TYPE_HCP = 'HCP';
    static public String NOTIFICATION_RECIPIENT_TYPE_PI = 'PI';
    static public String NOTIFICATION_RECIPIENT_TYPE_EXTERNAL_EMAIL = 'External Email';

    private static Map<String, Notification_Type__mdt> notificationTypeByDevNameMap = new Map<String, Notification_Type__mdt>();

    static {
        List<Notification_Type__mdt> notifTypes = [
                SELECT Id, DeveloperName, Recipient_Type__c,(
                        SELECT Id, Email_Template__c, Email_Template_Delegate__c, Target_Type__c,
                                Message_Body__c
                        FROM Notification_Targets__r)
                FROM Notification_Type__mdt
        ];
        for(Notification_Type__mdt noType: notifTypes) notificationTypeByDevNameMap.put(noType.DeveloperName, noType);
    }


    public static Notification_Type__mdt getNotificationType(String notificationType){
        return notificationTypeByDevNameMap.get(notificationType);
    }

    public static Notification_Target__mdt getTargetByNotification (String notificationType, String notificationTarget){
        Notification_Type__mdt notificationTypeMDT = notificationTypeByDevNameMap.get(notificationType);
        if(notificationTypeMDT != null) {
            for (Notification_Target__mdt nt: notificationTypeMDT.Notification_Targets__r) {
                if (nt.Target_Type__c == notificationTarget) return nt;
            }
        }
        return null;
    }

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

    public static Topic__c getTopicOrCreateNew(Id ctpId) {
        List<Topic__c> topicList = [SELECT Id, TopicId__c FROM Topic__c WHERE TopicId__c =: ctpId];
        if (topicList.isEmpty()){
            topicList.add(new Topic__c(TopicId__c = ctpId));
            try {
                insert topicList;
            } catch (DmlException e) {
            }
        }
        return topicList[0];
    }

    public static List<Topic__c> getTopicListOrCreateNewByCOI(List<Therapeutic_Area_Patient__c> cois) {
        List<Id> taIds = new List<Id>();
        for(Therapeutic_Area_Patient__c ta: cois) taIds.add(ta.Therapeutic_Area__c);
        List<Topic__c> topicList = [SELECT Id, TopicId__c FROM Topic__c WHERE TopicId__c =: taIds];
        List<Id> topicIds = new List<Id>();
        for(Topic__c t: topicList) topicIds.add(t.TopicId__c);
        for (Therapeutic_Area_Patient__c tap: cois){
            if (!topicIds.contains(tap.Therapeutic_Area__c)) topicList.add(new Topic__c(TopicId__c = tap.Therapeutic_Area__c));
        }
        try {
            insert topicList;
        } catch (DmlException e) {
        }
        return topicList;
    }

    public static List<Topic__c> getTopicListOrCreateNew(List<Clinical_Trial_Profile__c> ctpList) {
        List<Id> taIds = new List<Id>();

        for (Clinical_Trial_Profile__c ctp: ctpList) taIds.add(ctp.Therapeutic_Area__c);

        List<Topic__c> topics = [SELECT Id, TopicId__c FROM Topic__c WHERE TopicId__c =: taIds];
        List<Id> topIds = new List<Id>();

        for (Topic__c top: topics) topIds.add(top.TopicId__c);

        List<Topic__c> newTopics = new List<Topic__c>();

        for (Clinical_Trial_Profile__c ctp: ctpList) {
            if (ctp.Therapeutic_Area__c != null && !topIds.contains(ctp.Therapeutic_Area__c)){
                newTopics.add(new Topic__c(TopicId__c = ctp.Therapeutic_Area__c));
            }
        }
        try {
            insert newTopics;
            topics.addAll(newTopics);
        } catch (DmlException e) {
        }

        return topics;
    }

    public static List<Topic__c> getTopicListOrCreateNewByCTPId(List<Clinical_Trial_Profile__c> ctpList) {
        List<Id> ctpIds = new List<Id>();

        for (Clinical_Trial_Profile__c ctp: ctpList) ctpIds.add(ctp.Id);

        List<Topic__c> topics = [SELECT Id, TopicId__c FROM Topic__c WHERE TopicId__c =:ctpIds];
        List<Id> topIds = new List<Id>();

        for (Topic__c top: topics) topIds.add(top.TopicId__c);

        List<Topic__c> newTopics = new List<Topic__c>();

        for (Clinical_Trial_Profile__c ctp: ctpList) {
            if (!topIds.contains(ctp.Id)){
                newTopics.add(new Topic__c(TopicId__c = ctp.Id));
            }
        }
        try {
            insert newTopics;
            topics.addAll(newTopics);
        } catch (DmlException e) {
        }

        return topics;
    }

}