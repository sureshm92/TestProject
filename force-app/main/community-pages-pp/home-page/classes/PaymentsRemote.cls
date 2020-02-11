/**
 * Created by Olga Skrynnikova on 12/20/2019.
 */

public without sharing class PaymentsRemote {
    public class InitData{
        @AuraEnabled public String pendingPayments;
        @AuraEnabled public String balance;
        @AuraEnabled public String status;
        @AuraEnabled public String href;
        @AuraEnabled public Boolean informationAvailable;
    }

    @AuraEnabled
    public static InitData getPaymentData() {
        try {
            InitData initData = new InitData();
            ParticipantService.ParticipantState ps = ParticipantService.getInstance().getState();
            RemoteCall_GetCardDetails remoteCallGetCardDetails = new RemoteCall_GetCardDetails(
                    ps.pe.Clinical_Trial_Profile__r.Protocol_ID__c,
                    ps.pe.Screening_ID__c);
            RemoteCall_GetCardDetails.Card result = (RemoteCall_GetCardDetails.Card)remoteCallGetCardDetails.execute();
            initData.informationAvailable = false;
            initData.href = 'none';

            List<PaymentVendorSettings__c> pvs = [
                    SELECT Id, Study_Site__c, Payment_Vendor__r.Link_Vendor__c
                    FROM PaymentVendorSettings__c
                    WHERE Study_Site__c =: ps.pe.Study_Site__c
            ];

            if(remoteCallGetCardDetails.log.Success__c) {
                if(result.balance.substring(result.balance.length() - 2).equals('.0')) result.balance = result.balance + '0';
                result.status = result.status.substring(0, 1).toUpperCase() + result.status.substring(1).toLowerCase();
                initData.informationAvailable = true;
                initData.balance = result.balance;
                initData.status = result.status;
                initData.pendingPayments = '0.00';
            }

            if(!pvs.isEmpty()) initData.href = pvs[0].Payment_Vendor__r.Link_Vendor__c;

            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }
}