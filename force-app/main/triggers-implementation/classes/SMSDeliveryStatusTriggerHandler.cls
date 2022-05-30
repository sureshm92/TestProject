public with sharing class SMSDeliveryStatusTriggerHandler {
    public static final String INVALID = 'INVALID';
    public static final String DELIVERED = 'DELIVERED';

    public class processDeliveryReciptforSMS extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            processDeliveryReceipt((List<SMS_Delivery_Status__e>) newList);
        }
    }

    /**
     * @description: This Method will process the invlaid number at contact.
     *
     * @author: Krishna Mahto
     * @param: ssmDeliveryStatus
     * @return:
     **/
    @TestVisible
    private static void processDeliveryReceipt(List<SMS_Delivery_Status__e> ssmDeliveryStatus) {
        //Set<String> messageIdSet = new Set<String>();
        List<Send_Result__c> sendResultList = new List<Send_Result__c>();
        Set<Id> contactIdSet = new Set<Id>();
        Map<String, String> messageIdStatusMap = new Map<String, String>();
        Map<Id, String> notificationIdStatusMap = new Map<Id, String>();
        set<Id> notificationIdSet = new Set<Id>();

        List<IntegrationLog__c> listIL = new List<IntegrationLog__c>();
        //Get the List of messageId from platform event record.
        for (SMS_Delivery_Status__e dr : ssmDeliveryStatus) {
            if (dr.Record_Status__c.equalsIgnoreCase(INVALID)) {
                //If the delivery Receipt  status is INVALID.
                messageIdStatusMap.put(dr.Message_id__c, INVALID);
            } else if (dr.Record_Status__c.equalsIgnoreCase(DELIVERED)) {
                //If the delivery Receipt  status is DELEVERED.
                messageIdStatusMap.put(dr.Message_id__c, DELIVERED);
            }
            //create Integration Log
            listIL.add(SMSDeliveryStatusService.createIntegrationLog(dr));
        }

        //Insert Integration Log.
        if (listIL != null && !listIL.isEmpty()) {
            insert listIL;
        }

        //Get the Send result records.
        sendResultList = SMSOptOutService.getSendResults(messageIdStatusMap.keySet());

        //Get The Recipient Ids for the notifications associated with the Send result record for the INVALID Delivery Status.
        for (Send_Result__c sr : sendResultList) {
            //If Delivery Status is INVALID for message Id.
            if (messageIdStatusMap.get(sr.Msg_Id__c).equalsIgnoreCase(INVALID)) {
                contactIdSet.Add(sr.Notification__r.Recipient__c);
            }
            //If Notification Type is Welcome Message
            if (
                NotificationService.welcomemsgNoticationtypes.contains(
                    sr.Notification__r.Notification_Type__c
                )
            ) {
                if (messageIdStatusMap.get(sr.Msg_Id__c).equalsIgnoreCase(INVALID)) {
                    //If the delivery Receipt  status is INVALID.
                    notificationIdStatusMap.put(sr.Notification__c, INVALID);
                } else if (messageIdStatusMap.get(sr.Msg_Id__c).equalsIgnoreCase(DELIVERED)) {
                    //If the delivery Receipt  status is DELEVERED.
                    notificationIdStatusMap.put(sr.Notification__c, DELIVERED);
                }
            }
        }

        //Update the is Invalid Number to true for contact.
        if (
            contactIdSet != null &&
            !contactIdSet.isEmpty() &&
            !System.isBatch() &&
            !System.isFuture()
        ) {
            SMSDeliveryStatusService.updateGlobalFlag(contactIdSet);
        }

        //Update the Delivery Status Flag at contact/PER.
        if (notificationIdStatusMap != null && !notificationIdStatusMap.isEmpty()) {
            SMSDeliveryStatusService.updateDeliveryStatusFlag(notificationIdStatusMap);
        }
    }
}
