/**
 * Created by Nargiz Mamedova on 1/9/2020.
 */

public with sharing class PaymentVendorPanelRemote {
    public static final String FEATURE_PAYMENT_VENDOR = 'Payment_Vendors';
    public static final String PAYMENT_VENDOR_SETUP_FILTER = 'PaymentVendorSetupFilter';

    public class InitData {
        @AuraEnabled public String viewMode = GetPermissions.getViewMode(FEATURE_PAYMENT_VENDOR);
        @AuraEnabled public StudySiteFilter filter;
        @AuraEnabled public SSPaymentVendorsConfigResponse searchResponse;
    }

    public class VendorItem {
        @AuraEnabled public Study_Site__c studySite;
        @AuraEnabled public List<PaymentVendorSettings__c> vendorSettings;

        public VendorItem(Study_Site__c ss) {
            this.studySite = ss;
            this.vendorSettings = new List<PaymentVendorSettings__c>();
        }
    }

    @AuraEnabled
    public static InitData getInitData(Id ctpId) {
        try {
            InitData initData = new InitData();
            StudySiteFilter filter = (StudySiteFilter) SettingStoreService.getOrgDefault(PAYMENT_VENDOR_SETUP_FILTER + ctpId);
            if(filter == null) filter = new StudySiteFilter(ctpId);
            initData.filter = filter;
            initData.searchResponse = new SSPaymentVendorsConfigResponse(initData.filter, new PaginationData(15));
            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static SSPaymentVendorsConfigResponse getItems(String ssItemsJSON, String filterJSON, String paginationJSON) {
        try {
            StudySiteFilter filter = (StudySiteFilter) JSON.deserialize(filterJSON, StudySiteFilter.class);
            PaginationData pagination = (PaginationData) JSON.deserialize(paginationJSON, PaginationData.class);
            save(ssItemsJSON);
            saveFilter(filter);
            return new SSPaymentVendorsConfigResponse(filter, pagination);
        } catch (Exception e) {
            return (SSPaymentVendorsConfigResponse) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static SSPaymentVendorsConfigResponse selectAllInColumn(String paymentVendorId, Boolean state, String filterJSON,
            String paginationJSON, String ssItemsJSON) {
        try {
            save(ssItemsJSON);
            StudySiteFilter filter = (StudySiteFilter) JSON.deserialize(filterJSON, StudySiteFilter.class);
            saveFilter(filter);
            PaginationData pagination = (PaginationData) JSON.deserialize(paginationJSON, PaginationData.class);
            List<StudySiteItem> allSSItems = SSPaymentVendorsConfigResponse.convertToSSItems(SearchService.search(filter), paymentVendorId);
            for(StudySiteItem ssItem : allSSItems){
                for (ValueStateItem assigment : ssItem.assignments) assigment.state = state;
            }
            save(allSSItems);
            return new SSPaymentVendorsConfigResponse(filter, pagination);
        } catch (Exception e) {
            return (SSPaymentVendorsConfigResponse) AuraHelper.throwException(e);
        }
    }

    private static void save(String ssItemsJSON) {
        if(String.isEmpty(ssItemsJSON)) return;
        List<StudySiteItem> studySiteItems = (List<StudySiteItem>) JSON.deserialize(ssItemsJSON, List<StudySiteItem>.class);
        save(studySiteItems);
    }

    private static void save(List<StudySiteItem> studySiteItems) {
        List<PaymentVendorSettings__c> toDelete = new List<PaymentVendorSettings__c>();
        List<PaymentVendorSettings__c> toInsert = new List<PaymentVendorSettings__c>();
        for (StudySiteItem ssItem : studySiteItems) {
            for (ValueStateItem assigment : ssItem.assignments) {
                if (assigment.sourceId != null && !assigment.state) {
                    toDelete.add(new PaymentVendorSettings__c(Id = assigment.sourceId));
                }else if(assigment.sourceId == null && assigment.state){
                    toInsert.add(new PaymentVendorSettings__c(
                            Study_Site__c = ssItem.ss.Id,
                            Payment_Vendor__c = assigment.value
                    ));
                }
            }
        }
        delete toDelete;
        insert toInsert;
    }

    private static void saveFilter( StudySiteFilter filter){
        SettingStoreService.saveOrgDefault(PAYMENT_VENDOR_SETUP_FILTER + filter.ctpId, filter, StudySiteFilter.class);
    }
}