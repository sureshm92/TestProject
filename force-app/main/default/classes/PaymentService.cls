/**
 * Created by Olga Skrynnikova on 6/29/2020.
 */

public without sharing class PaymentService {

    public static String getPaymentVendorLink(Id studyId){
        List<PaymentVendorSettings__c> pvs = [
                SELECT Id, Study_Site__c, Payment_Vendor__r.Link_Vendor__c
                FROM PaymentVendorSettings__c
                WHERE Study_Site__c =: studyId
        ];

        return !pvs.isEmpty() ? pvs[0].Payment_Vendor__r.Link_Vendor__c : null;
    }
}