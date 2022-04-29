public with sharing class SMSDeliveryStatusTriggerHandler {
    public class processDeliveryReciptforSMS extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            processDeliveryRecipt((List<SMS_Delivery_Status__e>) newList);
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
    private static void processDeliveryRecipt(List<SMS_Delivery_Status__e> ssmDeliveryStatus) {
        Set<String> messageIdSet = new Set<String>();
        List<Send_Result__c> sendResultList = new List<Send_Result__c>();
        Set<String> contactIdSet = new Set<String>();
        List<contact> conToUpdate = new List<Contact>();
        //Get the List of messageId from platform event record.
        for (SMS_Delivery_Status__e dr : ssmDeliveryStatus) {
            // if the delivery recipt status is INVALID.
            if (dr.Record_Status__c.equalsIgnoreCase('INVALID')) {
                messageIdSet.Add(dr.Message_id__c);
            }
        }
        //Get the Send result records.
        sendResultList = SMSOptOutService.getSendResults(messageIdSet);

        //Get The Recipient Ids for the notifications associated with the Send result record.
        for (Send_Result__c sr : sendResultList) {
            contactIdSet.Add(sr.Notification__r.Recipient__c);
        }

        //Update the is Invalid Number to true for contact.
        for (contact con : [
            SELECT id, Is_Invalid_Number__c
            FROM contact
            WHERE Id IN :contactIdSet
        ]) {
            con.Is_Invalid_Number__c = true;
            conToUpdate.Add(con);
        }
        if (conToUpdate != null && !conToUpdate.isEmpty()) {
            update conToUpdate;
        }
    }
}
