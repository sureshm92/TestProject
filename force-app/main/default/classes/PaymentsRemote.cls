/**
 * Created by Olga Skrynnikova on 12/20/2019.
 */

public without sharing class PaymentsRemote {
    public class InitData{
        @AuraEnabled public Participant__c participant;
        @AuraEnabled public String pendingPayments;
        @AuraEnabled public String href;
    }

    @AuraEnabled
    public static InitData getPaymentData() {
        try {
            InitData initData = new InitData();
            ParticipantService.ParticipantState ps = ParticipantService.getInstance().getState();
            initData.participant = ps.participant;

            if(String.isEmpty(initData.participant.Pending_Payments__c)) initData.pendingPayments = '0.00';
            else initData.pendingPayments = initData.participant.Pending_Payments__c;

            List<TravelVendorSettings__c> tvs = [
                    SELECT Id, Study_Site__c, TravelVendor__r.Link_Vendor__c
                    FROM TravelVendorSettings__c
                    WHERE Study_Site__c =: ps.pe.Study_Site__c
            ];
            initData.href = tvs[0].TravelVendor__r.Link_Vendor__c;

            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }
}