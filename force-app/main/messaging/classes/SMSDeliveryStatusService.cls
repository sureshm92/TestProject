public with sharing class SMSDeliveryStatusService {
    public static Map<Id, Id> StudyLevelnotIdPEIdMap = new Map<Id, Id>();
    /**
     * @description: This method will update the invalid Number global flag to true at contact.
     * @author: Krishna Mahto
     * @param: contactIdSet
     * @return:
     **/
    @future
    public static void updateGlobalFlag(Set<Id> contactIdSet) {
        List<contact> conToUpdate = new List<Contact>();
        for (contact con : [
            SELECT id, Is_Invalid_Number__c
            FROM contact
            WHERE Id IN :contactIdSet
        ]) {
            con.Is_Invalid_Number__c = true;
            conToUpdate.Add(con);
        }
        update conToUpdate;
    }

    /**
     * @description: This method will update the Delivery Receipt  flag at contact/PER depending upon the Platform/Study level SMS and the Delivery Status.
     * @author: Krishna Mahto
     * @param: notificationIdStatusMap
     * @return:
     **/
    public static void updateDeliveryStatusFlag(Map<Id, String> notificationIdStatusMap) {
        Map<Id, Boolean> pfLevelSMSContIdDelStatusMap = new Map<Id, Boolean>();
        Map<Id, Boolean> studyLevelSMSPERIdDelStatusMap = new Map<Id, Boolean>();
        Map<Id, Boolean> studyLevelSMSPERIdDelStatusForPDMap = new Map<Id, Boolean>();
        Map<Id, Notification__c> notificationMap = new Map<Id, Notification__c>();
        List<Id> perIdSetForDel = new List<Id>();
        Set<Id> recipientIdSetForDel = new Set<Id>();

        //Get Welcome Message notification records
        notificationMap = SMSOptOutService.getNotifications(notificationIdStatusMap.keySet());

        //Check if Welcome Message notification is Platform level or Study Level. Call Action_SendSMS class.
        SMSOptOutService.isPlatFormEvent = true;
        Action_SendSMS actionSendSMSobj = new Action_SendSMS(notificationMap.Values());
        for (Notification__c n : notificationMap.Values()) {
            if (NotificationService.platfomLevelSMSSet.contains(n.Id)) {
                //if Platform level Welcome SMS
                if (
                    notificationIdStatusMap.get(n.id)
                        .equalsIgnoreCase(SMSDeliveryStatusTriggerHandler.DELIVERED)
                ) {
                    //If Delivery Receipt  status is DELIVERED
                    pfLevelSMSContIdDelStatusMap.put(n.Recipient__c, true);
                } else if (
                    notificationIdStatusMap.get(n.id)
                        .equalsIgnoreCase(SMSDeliveryStatusTriggerHandler.INVALID)
                ) {
                    //If Delivery Receipt  status is INVALID
                    pfLevelSMSContIdDelStatusMap.put(n.Recipient__c, false);
                }
            } else if (StudyLevelnotIdPEIdMap.containsKey(n.id)) {
                //if Study level Welcome SMS
                //If Study level Welome message SMS is for Patient Delegate.
                if (
                    n.Notification_Type__c ==
                    NotificationCatalog.MSG_TO_DELEGATE_STUDY_LEVEL_WELCOME_MSG
                ) {
                    perIdSetForDel.Add(n.WhatId__c);
                    recipientIdSetForDel.Add(n.recipient__c);
                    //studyLevelSMSPERIdDelStatusForPDMap
                    if (
                        notificationIdStatusMap.get(n.id)
                            .equalsIgnoreCase(SMSDeliveryStatusTriggerHandler.DELIVERED)
                    ) {
                        //If Delivery Receipt  status is DELIVERED
                        studyLevelSMSPERIdDelStatusForPDMap.put(
                            StudyLevelnotIdPEIdMap.get(n.Id),
                            true
                        );
                    } else if (
                        notificationIdStatusMap.get(n.id)
                            .equalsIgnoreCase(SMSDeliveryStatusTriggerHandler.INVALID)
                    ) {
                        //If Delivery Receipt  status is INVALID
                        studyLevelSMSPERIdDelStatusForPDMap.put(
                            StudyLevelnotIdPEIdMap.get(n.Id),
                            false
                        );
                    }
                } else {
                    if (
                        notificationIdStatusMap.get(n.id)
                            .equalsIgnoreCase(SMSDeliveryStatusTriggerHandler.DELIVERED)
                    ) {
                        //If Delivery Receipt  status is DELIVERED
                        studyLevelSMSPERIdDelStatusMap.put(StudyLevelnotIdPEIdMap.get(n.Id), true);
                    } else if (
                        notificationIdStatusMap.get(n.id)
                            .equalsIgnoreCase(SMSDeliveryStatusTriggerHandler.INVALID)
                    ) {
                        //If Delivery Receipt  status is INVALID
                        studyLevelSMSPERIdDelStatusMap.put(StudyLevelnotIdPEIdMap.get(n.Id), false);
                    }
                }
            }
        }

        //Update Delivery Receipt  Flag for Platform Level SMS
        if (pfLevelSMSContIdDelStatusMap != null && !pfLevelSMSContIdDelStatusMap.isEmpty()) {
            updatePlatFormLevelDelRecFlag(pfLevelSMSContIdDelStatusMap);
        }
        //Update Delivery Receipt  Flag for Study Level SMS for Participants
        if (studyLevelSMSPERIdDelStatusMap != null && !studyLevelSMSPERIdDelStatusMap.isEmpty()) {
            updateStudyLevelDelRecFlag(studyLevelSMSPERIdDelStatusMap);
        }
        //Update Delivery Receipt  Flag for Study Level SMS for Patient Delegate
        if (
            perIdSetForDel != null &&
            !perIdSetForDel.isEmpty() &&
            recipientIdSetForDel != null &&
            !recipientIdSetForDel.isEmpty()
        ) {
            updateStudyLevelDelRecFlagForPD(
                perIdSetForDel,
                recipientIdSetForDel,
                studyLevelSMSPERIdDelStatusForPDMap
            );
        }
    }
    /**
     * @description: This method will update Delivery Receipt  Status at contact for the platform level SMS.
     * @author: Krishna Mahto
     * @param: pfLevelSMSContIdDelStatusMap
     * @return:
     **/
    public static void updatePlatFormLevelDelRecFlag(
        Map<Id, Boolean> pfLevelSMSContIdDelStatusMap
    ) {
        List<Contact> contactToUpdate = [
            SELECT Id, Welcome_Message_Sent__c, Welcome_Message_Delivered__c
            FROM Contact
            WHERE Id IN :pfLevelSMSContIdDelStatusMap.keySet()
        ];
        for (Contact con : contactToUpdate) {
            Boolean smsDeliveryFlag = pfLevelSMSContIdDelStatusMap.get(con.Id);
            con.Welcome_Message_Delivered__c = smsDeliveryFlag;
            //If Delivery Status is INVALID, revert the SMS Welcome Message sent Flag.
            if (!smsDeliveryFlag) {
                con.Welcome_Message_Sent__c = smsDeliveryFlag;
            }
        }

        //Update Delivery Status Flag at the Contact.
        if (contactToUpdate != null && !contactToUpdate.isEmpty()) {
            update contactToUpdate;
        }
    }

    /**
     * @description: This method will update Delivery Receipt  Status at PER for the Study level SMS.
     * @author: Krishna Mahto
     * @param: studyLevelSMSPERIdDelStatusMap
     * @return:
     **/
    public static void updateStudyLevelDelRecFlag(Map<Id, Boolean> studyLevelSMSPERIdDelStatusMap) {
        //Query PER records
        List<Participant_Enrollment__c> perToUpdate = [
            SELECT Id, Welcome_Message_Sent__c, Welcome_Message_Delivered__c
            FROM Participant_Enrollment__c
            WHERE Id IN :studyLevelSMSPERIdDelStatusMap.keySet()
        ];

        for (Participant_Enrollment__c per : perToUpdate) {
            Boolean smsDeliveryFlag = studyLevelSMSPERIdDelStatusMap.get(per.Id);
            per.Welcome_Message_Delivered__c = smsDeliveryFlag;
            //If Delivery Status is INVALID, revert the SMS Welcome Message sent Flag.
            if (!smsDeliveryFlag) {
                per.Welcome_Message_Sent__c = smsDeliveryFlag;
            }
        }
        //Update Delivery Status Flag at the PERs.
        if (perToUpdate != null && !perToUpdate.isEmpty()) {
            update perToUpdate;
        }
    }

    /**
     * @description: This method will update Delivery Receipt  Status at PER for the Study level SMS.
     * @author: Krishna Mahto
     * @param: perIdSetForDel
     * @param: recipientIdSetForDel
     * @param: studyLevelSMSPERIdDelStatusMap
     * @return:
     **/
    public static void updateStudyLevelDelRecFlagForPD(
        List<Id> perIdSetForDel,
        Set<Id> recipientIdSetForDel,
        Map<Id, Boolean> studyLevelSMSPERIdDelStatusForPDMap
    ) {
        //Get list of ParticipantEnrollmentPatientDelJunction records
        List<Patient_Delegate_Enrollment__c> perDelJunctionRecList = Action_SendSMS.getPERPatientDelJunctionRecords(
            perIdSetForDel,
            recipientIdSetForDel
        );

        for (Patient_Delegate_Enrollment__c perPDJunRec : perDelJunctionRecList) {
            Boolean smsDeliveryFlag = studyLevelSMSPERIdDelStatusForPDMap.get(
                perPDJunRec.Participant_Enrollment__c
            );
            perPDJunRec.Welcome_Message_Delivered__c = smsDeliveryFlag;
            //If Delivery Status is INVALID, revert the SMS Welcome Message sent Flag.
            if (!smsDeliveryFlag) {
                perPDJunRec.Welcome_Message_Sent__c = smsDeliveryFlag;
            }
        }
        //Update Delivery Status Flag at Participant Enrollment and Patient Delegate contact junction record.
        if (perDelJunctionRecList != null && !perDelJunctionRecList.isEmpty()) {
            update perDelJunctionRecList;
        }
    }

    /**
     * @description: This method will return the integration log for each Delivery Receipt.
     * @author: Krishna Mahto
     * @param: delReceipt
     * @return:
     **/
    public static IntegrationLog__c createIntegrationLog(SMS_Delivery_Status__e delReceipt) {
        IntegrationLog__c IL = new IntegrationLog__c();
        IL.Function_Name__c = 'SMS Delivery Receipt ';
        IL.Http_Method__c = 'InBound';
        IL.Request_Time__c = DateTime.now();
        IL.Request_Body__c = JSON.serialize(delReceipt);
        return IL;
    }
}