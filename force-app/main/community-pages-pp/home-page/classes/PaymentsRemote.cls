/**
 * Created by Olga Skrynnikova on 12/20/2019.
 */

public without sharing class PaymentsRemote {
    public class InitData{
        @AuraEnabled public Participant__c participant;
        @AuraEnabled public String pendingPayments;
        @AuraEnabled public String href;
        @AuraEnabled public Boolean informationAvailable;
    }

    @AuraEnabled
    public static InitData getPaymentData() {
        try {
            InitData initData = new InitData();
            ParticipantService.ParticipantState ps = ParticipantService.getInstance().getState();
            initData.participant = ps.participant;
            initData.informationAvailable = true;

            if(String.isEmpty(initData.participant.Pending_Payments__c)) initData.pendingPayments = '0.00';
            else initData.pendingPayments = initData.participant.Pending_Payments__c;

            List<PaymentVendorSettings__c> pvs = [
                    SELECT Id, Study_Site__c, Payment_Vendor__r.Link_Vendor__c
                    FROM PaymentVendorSettings__c
                    WHERE Study_Site__c =: ps.pe.Study_Site__c
            ];
            if(String.isEmpty(initData.participant.Status__c)) initData.informationAvailable = false;

            if(!pvs.isEmpty()) initData.href = pvs[0].Payment_Vendor__r.Link_Vendor__c;
            else initData.href = 'none';

            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }
}