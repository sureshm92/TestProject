/**
 * Created by Vitalii Aheienko on 8/29/2019.
 */

public with sharing class TravelVendorPanelRemote {

    public static final String FEATURE_TRAVEL_VENDOR = 'Travel_Vendors';
    
    public class InitData {
        @AuraEnabled public String viewMode = GetPermissions.getViewMode(FEATURE_TRAVEL_VENDOR);
        @AuraEnabled public StudySiteFilter filter;
        @AuraEnabled public SSTravelVendorsConfigResponse searchResponse;
    }
    
    public class VendorItem {
        @AuraEnabled public Study_Site__c studySite;
        @AuraEnabled public List<TravelVendorSettings__c> vendorSettings;
        
        public VendorItem(Study_Site__c ss) {
            this.studySite = ss;
            this.vendorSettings = new List<TravelVendorSettings__c>();
        }
    }
    
    @AuraEnabled
    public static InitData getInitData(Id ctpId) {
        try {
            InitData initData = new InitData();
            initData.filter = new StudySiteFilter(ctpId);
            initData.searchResponse = new SSTravelVendorsConfigResponse(initData.filter, new PaginationData(15));
            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }
    
    @AuraEnabled
    public static SSTravelVendorsConfigResponse getItems(String ssItemsJSON, String filterJSON, String paginationJSON) {
        try {
            StudySiteFilter filter = (StudySiteFilter) JSON.deserialize(filterJSON, StudySiteFilter.class);
            PaginationData pagination = (PaginationData) JSON.deserialize(paginationJSON, PaginationData.class);
            save(ssItemsJSON);
            return new SSTravelVendorsConfigResponse(filter, pagination);
        } catch (Exception e) {
            return (SSTravelVendorsConfigResponse) AuraHelper.throwException(e);
        }
    }
    
    @AuraEnabled
    public static SSTravelVendorsConfigResponse selectAllInColumn(String travelVendorId, Boolean state, String filterJSON,
            String paginationJSON, String ssItemsJSON) {
        try {
            save(ssItemsJSON);
            StudySiteFilter filter = (StudySiteFilter) JSON.deserialize(filterJSON, StudySiteFilter.class);
            PaginationData pagination = (PaginationData) JSON.deserialize(paginationJSON, PaginationData.class);
            List<StudySiteItem> allSSItems = SSTravelVendorsConfigResponse.convertToSSItems(getCtpStudySites(filter), travelVendorId);
            for(StudySiteItem ssItem : allSSItems){
                for (ValueStateItem assigment : ssItem.assignments) assigment.state = state;
            }
            save(allSSItems);
            return new SSTravelVendorsConfigResponse(filter, pagination);
        } catch (Exception e) {
            return (SSTravelVendorsConfigResponse) AuraHelper.throwException(e);
        }
    }
    
    private static void save(String ssItemsJSON) {
        if(String.isEmpty(ssItemsJSON)) return;
        List<StudySiteItem> studySiteItems = (List<StudySiteItem>) JSON.deserialize(ssItemsJSON, List<StudySiteItem>.class);
        save(studySiteItems);
    }
    
    private static void save(List<StudySiteItem> studySiteItems) {
        List<TravelVendorSettings__c> toDelete = new List<TravelVendorSettings__c>();
        List<TravelVendorSettings__c> toInsert = new List<TravelVendorSettings__c>();
        for (StudySiteItem ssItem : studySiteItems) {
            for (ValueStateItem assigment : ssItem.assignments) {
                if (assigment.sourceId != null && !assigment.state) {
                    toDelete.add(new TravelVendorSettings__c(Id = assigment.sourceId));
                }else if(assigment.sourceId == null && assigment.state){
                    toInsert.add(new TravelVendorSettings__c(
                            Study_Site__c = ssItem.ss.Id,
                            TravelVendor__c = assigment.value
                    ));
                }
            }
        }
        delete toDelete;
        insert toInsert;
    }
    
    public static List<Study_Site__c> getCtpStudySites(StudySiteFilter filter) {
        List<Study_Site__c> ctpStudySites = (List<Study_Site__c>) DatabaseService.query(
                filter.getFields(),
                filter.getSObjectType(),
                filter.getFilterString());
        return ctpStudySites;
    }

}