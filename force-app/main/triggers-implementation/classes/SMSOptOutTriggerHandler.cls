public without sharing class SMSOptOutTriggerHandler {
    public class optOutSMS extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            optOutForSMS((List<SMS_Opt_Out__e>) newList);
        }
    }

    /**
     * @description: This Method will process the OPT Out for SMS.
     *
     * @author: Krishna Mahto
     * @param: smsOptOutPEventList
     * @return:
     **/
    @TestVisible
    private static void optOutForSMS(List<SMS_Opt_Out__e> smsOptOutPEventList) {
        Set<String> messageIdSet = new Set<String>();
        //Get the List of PreviousPublishedMessageId__c from platform event record.
        for (SMS_Opt_Out__e smsOptOut : smsOptOutPEventList) {
            if (smsOptOut.optout__c) {
                messageIdSet.Add(smsOptOut.PreviousPublishedMessageId__c);
            }
        }
        //Process Opt out for SMS.
        SMSOptOutService.processOptOUTForSMS(messageIdSet);
    }
}
