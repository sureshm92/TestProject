/**
 * @description       : This class will do Opt Out for SMS if requested by Participants/Patient Delegates.
 * @author            : Krishna Mahto
 * @group             : IQVIA Patient Portal
 * @created on        : 03-29-2022
 * @created by        : Krishna Mahto
 **/
public without sharing class SMSOptOutService {
    public static Map<Id, Map<Id, String>> notIdMapOfPartContactSponsorMap = new Map<Id, Map<Id, String>>();
    public static Boolean isPlatFormEvent = false;
    /**
     * @description: This Method will mark the SMS Optin flag to false at Contact level for Platform Level SMS Optout and SMS optin Flag at PER
     *               level for Study level SMS Opt Out recieved by Participant/patient Delegates.
     * @author: Krishna Mahto
     * @param: messageIdSet
     * @return:
     **/
    public static void processOptOUTForSMS(Set<String> messageIdSet) {
        Set<Id> platformLevelSMSRecipientIdSet = new Set<Id>();
        Map<Id, String> participantContactSponsorMap = new Map<Id, String>();
        Map<Id, Notification__c> notificationMap = new Map<Id, Notification__c>();
        set<Id> notificationIdSet = new Set<Id>();

        //Get Send Results
        for (Send_Result__c sr : getSendResults(messageIdSet)) {
            notificationIdSet.Add(sr.Notification__c);
        }
        if (notificationIdSet != null && !notificationIdSet.isEmpty()) {
            //Get notification records
            notificationMap = getNotifications(notificationIdSet);

            //Check if notification is Platform level or Study Level.
            isPlatFormEvent = true;
            Action_SendSMS actionSendSMSobj = new Action_SendSMS(notificationMap.Values());
            for (Notification__c n : notificationMap.Values()) {
                if (NotificationService.platfomLevelSMSSet.contains(n.Id)) {
                    //if Platform level SMS
                    platformLevelSMSRecipientIdSet.Add(n.Recipient__c);
                } else if (notIdMapOfPartContactSponsorMap.containsKey(n.id)) {
                    //if Study level SMS
                    participantContactSponsorMap = notIdMapOfPartContactSponsorMap.get(n.Id);
                }
            }

            //Opt out SMS for Platform Level SMS
            if (
                platformLevelSMSRecipientIdSet != null && !platformLevelSMSRecipientIdSet.isEmpty()
            ) {
                processPlatFormLevelOptOut(platformLevelSMSRecipientIdSet);
            }
            //Opt out SMS for Study Level SNMS
            if (participantContactSponsorMap != null && !participantContactSponsorMap.isEmpty()) {
                processStudyLevelOptOut(participantContactSponsorMap);
            }
        }
    }

    /**
     * @description: This method will return the list of Send Result record for given Message ids.
     * @author: Krishna Mahto
     * @param:  messageIdSet
     * @return: sendResultList
     **/
    public static List<Send_Result__c> getSendResults(Set<String> messageIdSet) {
        List<Send_Result__c> sendResultList = new List<Send_Result__c>();
        //Query the Send Result record based on matching message Id field
        sendResultList = [
            SELECT
                Id,
                Msg_Id__c,
                Notification__c,
                Notification__r.Recipient__c,
                Notification__r.Notification_Type__c
            FROM Send_Result__c
            WHERE Msg_Id__c IN :messageIdSet
        ];
        return sendResultList;
    }

    /**
     * @description: This method will return the Notification record for given notification ids.
     * @author: Krishna Mahto
     * @param:  notificationIdSet
     * @return: notificationMap
     **/
    public static Map<Id, Notification__c> getNotifications(Set<Id> notificationIdSet) {
        //Query notification records based on the notificationIdSet and create a map of Notification Id vs Notification.
        Map<Id, Notification__c> notificationMap = new Map<Id, Notification__c>(
            [
                SELECT Id, WhatId__c, Recipient__c, Notification_Type__c, Task_Id__c
                FROM Notification__c
                WHERE Id IN :notificationIdSet
            ]
        );
        return notificationMap;
    }

    /**
     * @description: This method will opt out for the platform level SMS.
     * @author: Krishna Mahto
     * @param: recipientId
     * @return:
     **/
    public static void processPlatFormLevelOptOut(Set<Id> recipientId) {
        List<Contact> contactToUpdate = [
            SELECT
                Id,
                Participant_Opt_In_Status_SMS__c,
                Welcome_Message_Sent__c,
                Welcome_Message_Delivered__c
            FROM Contact
            WHERE Id IN :recipientId
        ];
        for (Contact con : contactToUpdate) {
            con.Participant_Opt_In_Status_SMS__c = false;
            con.Welcome_Message_Sent__c = false;
            con.Welcome_Message_Delivered__c = false;
        }

        //Update SMS Opt In Flag to False at the Contact.
        if (contactToUpdate != null && !contactToUpdate.isEmpty()) {
            update contactToUpdate;
        }
    }

    /**
     * @description: This method will opt out for the Study level SMS for all the PERs for the Participants corresponding to the same study
     *               Sponsor for which SMS Opt out request is sent.
     * @author: Krishna Mahto
     * @param: participantContactSponsorMap
     * @return:
     **/
    public static void processStudyLevelOptOut(Map<Id, String> participantContactSponsorMap) {
        List<Participant_Enrollment__c> perToUpdate = new List<Participant_Enrollment__c>();
        //Query PER record for Participant Contacts
        List<Participant_Enrollment__c> perList = [
            SELECT
                Id,
                Participant_contact__c,
                Permit_SMS_Text_for_this_study__c,
                Welcome_Message_Sent__c,
                Welcome_Message_Delivered__c,
                Clinical_Trial_Profile__r.Study_Sponsor__c
            FROM Participant_Enrollment__c
            WHERE Participant_contact__c IN :participantContactSponsorMap.keySet()
        ];

        //Filter the PER for the Participant contact corresponding to the Matching Study Sponsor for Opted out SMS.
        for (Participant_Enrollment__c per : perList) {
            if (
                per.Clinical_Trial_Profile__r.Study_Sponsor__c ==
                participantContactSponsorMap.get(per.Participant_contact__c)
            ) {
                per.Permit_SMS_Text_for_this_study__c = false;
                per.Welcome_Message_Sent__c = false;
                per.Welcome_Message_Delivered__c = false;
                perToUpdate.Add(per);
            }
        }
        //Update SMS Opt In Flag to False at the PERs.
        if (perToUpdate != null && !perToUpdate.isEmpty()) {
            update perToUpdate;
        }
    }

    public static IntegrationLog__c createIntegrationLog(SMS_Opt_Out__e smsOptOut) {
        IntegrationLog__c IL = new IntegrationLog__c();
        IL.Function_Name__c = 'SMS Opt Out';
        IL.Http_Method__c = 'InBound';
        IL.Request_Time__c = DateTime.now();
        IL.Request_Body__c = JSON.serialize(smsOptOut);
        return IL;
    }
}
