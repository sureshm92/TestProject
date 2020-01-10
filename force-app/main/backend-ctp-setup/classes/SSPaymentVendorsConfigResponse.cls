/**
 * Created by Nargiz Mamedova on 1/9/2020.
 */

public with sharing class SSPaymentVendorsConfigResponse {
    @AuraEnabled public PaginationData pagination;
    @AuraEnabled public List<StudySiteItem> studySiteItems;
    @AuraEnabled public List<LabelValueItem> paymentVendors;
    //@AuraEnabled public Boolean haveEmptyAssigment;

    public SSPaymentVendorsConfigResponse(StudySiteFilter filter, PaginationData pagination){
        this.pagination = pagination;
        List<Study_Site__c> ssList = SearchService.search(filter, this.pagination);
        paymentVendors = getPaymentVendors(filter.pageFeatureIds);
        studySiteItems = convertToSSItems(ssList, filter.pageFeatureIds);
    }

    private static List<LabelValueItem> getPaymentVendors(String selectedVendorIdsStr){
        Map<Id, Payment_Vendor__c> pvMap = new Map<Id, Payment_Vendor__c>([SELECT Id, Name FROM Payment_Vendor__c]);
        List<Id> selectedPVIds = new List<Id>(pvMap.keySet());
        if(!String.isEmpty(selectedVendorIdsStr)) selectedPVIds = selectedVendorIdsStr.split(';');
        List<LabelValueItem> paymentVendors = new List<LabelValueItem>();
        for(Id tvId : selectedPVIds) {
            Payment_Vendor__c tv = pvMap.get(tvId);
            if(tv != null) paymentVendors.add(new LabelValueItem(tv.Name, tv.Id));
        }
        return paymentVendors;

    }

    public static List<StudySiteItem> convertToSSItems(List<Study_Site__c> studySites, String selectedVendorIdsStr) {
        List<LabelValueItem> paymentVendors = getPaymentVendors(selectedVendorIdsStr);
        Map<Id, List<PaymentVendorSettings__c>> ssPaymentVendorsBySSIdMap = getPaymentVendorsBySSIdMap(studySites);
        List<StudySiteItem> studySiteItems = new List<StudySiteItem>();
        for (Study_Site__c ss : studySites) {
            String countryName = ss.Site__r.BillingCountry;
            String countryCode = ss.Site__r.BillingCountryCode;
            StudySiteItem item = new StudySiteItem(new LabelValueItem(countryName, countryCode), ss.Name, ss);
            List<PaymentVendorSettings__c> ssPVList = ssPaymentVendorsBySSIdMap.containsKey(ss.Id) ? ssPaymentVendorsBySSIdMap.get(ss.Id) : new List<PaymentVendorSettings__c>();
            item.emptyAssignments = ssPVList.isEmpty();
            for (LabelValueItem pv : paymentVendors) {
                Id ssVPId;
                for(PaymentVendorSettings__c ssPV : ssPVList){
                    if(ssPV.Payment_Vendor__c == pv.value){
                        ssVPId = ssPV.Id;
                        break;
                    }
                }
                item.assignments.add(new ValueStateItem(pv.value, ssVPId));
            }
            studySiteItems.add(item);
        }
        return studySiteItems;
    }

    private static Map<Id, List<PaymentVendorSettings__c>> getPaymentVendorsBySSIdMap(List<Study_Site__c> ssList) {
        List<PaymentVendorSettings__c> pvJunction = [
                SELECT Id, Payment_Vendor__c, Study_Site__c
                FROM PaymentVendorSettings__c
                WHERE Study_Site__c IN: ssList
        ];
        Map<Id, List<PaymentVendorSettings__c>> vpListBySSIdMap = new Map<Id, List<PaymentVendorSettings__c>>();
        for (PaymentVendorSettings__c ssPV : pvJunction) {
            if (!vpListBySSIdMap.containsKey(ssPV.Study_Site__c)) {
                vpListBySSIdMap.put(ssPV.Study_Site__c, new List<PaymentVendorSettings__c>());
            }
            vpListBySSIdMap.get(ssPV.Study_Site__c).add(ssPV);
        }
        return vpListBySSIdMap;
    }
}