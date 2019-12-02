/**
 * Created by Leonid Bartenev
 */

public without sharing class SSTravelVendorsConfigResponse {
    
    @AuraEnabled public PaginationData pagination;
    @AuraEnabled public List<StudySiteItem> studySiteItems;
    @AuraEnabled public List<LabelValueItem> travelVendors;
    //@AuraEnabled public Boolean haveEmptyAssigment;
    
    public SSTravelVendorsConfigResponse(StudySiteFilter filter, PaginationData pagination){
        this.pagination = pagination;
        List<Study_Site__c> ssList = SearchService.search(filter, this.pagination);
        travelVendors = getTravelVendors(filter.pageFeatureIds);
        studySiteItems = convertToSSItems(ssList, filter.pageFeatureIds);
    }
    
    private static List<LabelValueItem> getTravelVendors(String selectedVendorIdsStr){
        Map<Id, TravelVendor__c> tvMap = new Map<Id, TravelVendor__c>([SELECT Id, Name FROM TravelVendor__c]);
        List<Id> selectedTVIds = new List<Id>(tvMap.keySet());
        if(!String.isEmpty(selectedVendorIdsStr)) selectedTVIds = selectedVendorIdsStr.split(';');
        List<LabelValueItem> travelVendors = new List<LabelValueItem>();
        for(Id tvId : selectedTVIds) {
            TravelVendor__c tv = tvMap.get(tvId);
            if(tv != null) travelVendors.add(new LabelValueItem(tv.Name, tv.Id));
        }
        return travelVendors;
    
    }
    
    public static List<StudySiteItem> convertToSSItems(List<Study_Site__c> studySites, String selectedVendorIdsStr) {
        List<LabelValueItem> travelVendors = getTravelVendors(selectedVendorIdsStr);
        Map<Id, List<TravelVendorSettings__c>> ssTravelVendorsBySSIdMap = getTravelVendorsBySSIdMap(studySites);
        List<StudySiteItem> studySiteItems = new List<StudySiteItem>();
        for (Study_Site__c ss : studySites) {
            String countryName = ss.Site__r.BillingCountry;
            String countryCode = ss.Site__r.BillingCountryCode;
            StudySiteItem item = new StudySiteItem(new LabelValueItem(countryName, countryCode), ss.Name, ss);
            List<TravelVendorSettings__c> ssTVList = ssTravelVendorsBySSIdMap.containsKey(ss.Id) ? ssTravelVendorsBySSIdMap.get(ss.Id) : new List<TravelVendorSettings__c>();
            item.emptyAssignments = ssTVList.isEmpty();
            for (LabelValueItem tv : travelVendors) {
                Id ssVPId;
                for(TravelVendorSettings__c ssTV : ssTVList){
                    if(ssTV.TravelVendor__c == tv.value){
                        ssVPId = ssTV.Id;
                        break;
                    }
                }
                item.assignments.add(new ValueStateItem(tv.value, ssVPId));
            }
            studySiteItems.add(item);
        }
        return studySiteItems;
    }
    
    private static Map<Id, List<TravelVendorSettings__c>> getTravelVendorsBySSIdMap(List<Study_Site__c> ssList) {
        List<TravelVendorSettings__c> tvJunction = [
                SELECT Id, TravelVendor__c, Study_Site__c
                FROM TravelVendorSettings__c
                WHERE Study_Site__c IN: ssList
        ];
        Map<Id, List<TravelVendorSettings__c>> vpListBySSIdMap = new Map<Id, List<TravelVendorSettings__c>>();
        for (TravelVendorSettings__c ssTV : tvJunction) {
            if (!vpListBySSIdMap.containsKey(ssTV.Study_Site__c)) {
                vpListBySSIdMap.put(ssTV.Study_Site__c, new List<TravelVendorSettings__c>());
            }
            vpListBySSIdMap.get(ssTV.Study_Site__c).add(ssTV);
        }
        return vpListBySSIdMap;
    }

}