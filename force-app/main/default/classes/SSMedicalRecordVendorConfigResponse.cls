public without sharing class SSMedicalRecordVendorConfigResponse {
    @AuraEnabled
    public PaginationData pagination;
    @AuraEnabled
    public List<StudySiteItem> studySiteItems;
    @AuraEnabled
    public List<LabelValueItem> medicalRecordVendors;
    //@AuraEnabled public Boolean haveEmptyAssigment;

    public SSMedicalRecordVendorConfigResponse(StudySiteFilter filter, PaginationData pagination) {
        this.pagination = pagination;
        List<Study_Site__c> ssList = SearchService.search(filter, this.pagination);
        medicalRecordVendors = getMedicalRecordVendors(filter.pageFeatureIds);
        studySiteItems = convertToSSItems(ssList, filter.pageFeatureIds);
    }

    private static List<LabelValueItem> getMedicalRecordVendors(String selectedVendorIdsStr) {
        Map<Id, Medical_Record_Vendor__c> tvMap = new Map<Id, Medical_Record_Vendor__c>(
            [SELECT Id, Name FROM Medical_Record_Vendor__c]
        );
        List<Id> selectedTVIds = new List<Id>(tvMap.keySet());
        if (!String.isEmpty(selectedVendorIdsStr))
            selectedTVIds = selectedVendorIdsStr.split(';');
        List<LabelValueItem> medicalVendors = new List<LabelValueItem>();
        for (Id tvId : selectedTVIds) {
            Medical_Record_Vendor__c tv = tvMap.get(tvId);
            if (tv != null)
                medicalVendors.add(new LabelValueItem(tv.Name, tv.Id));
        }
        return medicalVendors;
    }

    public static List<StudySiteItem> convertToSSItems(
        List<Study_Site__c> studySites,
        String selectedVendorIdsStr
    ) {
        List<LabelValueItem> travelVendors = getMedicalRecordVendors(selectedVendorIdsStr);
        Map<Id, List<MedicalVendorSettings__c>> ssTravelVendorsBySSIdMap = getMedicalRecordVendorsBySSIdMap(
            studySites
        );
        List<StudySiteItem> studySiteItems = new List<StudySiteItem>();
        for (Study_Site__c ss : studySites) {
            String countryName = ss.Site__r.BillingCountry;
            String countryCode = ss.Site__r.BillingCountryCode;
            StudySiteItem item = new StudySiteItem(
                new LabelValueItem(countryName, countryCode),
                ss.Name,
                ss
            );
            List<MedicalVendorSettings__c> ssTVList = ssTravelVendorsBySSIdMap.containsKey(ss.Id)
                ? ssTravelVendorsBySSIdMap.get(ss.Id)
                : new List<MedicalVendorSettings__c>();
            item.emptyAssignments = ssTVList.isEmpty();
            for (LabelValueItem tv : travelVendors) {
                Id ssVPId;
                for (MedicalVendorSettings__c ssTV : ssTVList) {
                    if (ssTV.Medical_Record_Vendor__c == tv.value) {
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

    private static Map<Id, List<MedicalVendorSettings__c>> getMedicalRecordVendorsBySSIdMap(
        List<Study_Site__c> ssList
    ) {
        List<MedicalVendorSettings__c> tvJunction = [
            SELECT Id, Medical_Record_Vendor__c	, Study_Site__c
            FROM MedicalVendorSettings__c
            WHERE Study_Site__c IN :ssList
        ];
        Map<Id, List<MedicalVendorSettings__c>> vpListBySSIdMap = new Map<Id, List<MedicalVendorSettings__c>>();
        for (MedicalVendorSettings__c ssTV : tvJunction) {
            if (!vpListBySSIdMap.containsKey(ssTV.Study_Site__c)) {
                vpListBySSIdMap.put(ssTV.Study_Site__c, new List<MedicalVendorSettings__c>());
            }
            vpListBySSIdMap.get(ssTV.Study_Site__c).add(ssTV);
        }
        return vpListBySSIdMap;
    }
}