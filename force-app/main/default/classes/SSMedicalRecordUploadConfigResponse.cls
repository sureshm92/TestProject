public without sharing class SSMedicalRecordUploadConfigResponse {
    @AuraEnabled
    public PaginationData pagination;
    @AuraEnabled
    public List<StudySiteItem> studySiteItems;
    @AuraEnabled
    public List<LabelValueItem> medicalRecordUploads;
    //@AuraEnabled public Boolean haveEmptyAssigment;

    public SSMedicalRecordUploadConfigResponse(StudySiteFilter filter, PaginationData pagination) {
        this.pagination = pagination;
        List<Study_Site__c> ssList = SearchService.search(filter, this.pagination);
        medicalRecordUploads = getMedicalRecordUploads(filter.pageFeatureIds);
        studySiteItems = convertToSSItems(ssList, filter.pageFeatureIds);
    }

    private static List<LabelValueItem> getMedicalRecordUploads(String selectedVendorIdsStr) {
        List<LabelValueItem> medicalVendors = new List<LabelValueItem>();
        medicalVendors.add(new LabelValueItem('Upload Medical Records', 'UMR'));
        return medicalVendors;
    }

    public static List<StudySiteItem> convertToSSItems(
        List<Study_Site__c> studySites,
        String selectedVendorIdsStr
    ) {
        List<StudySiteItem> studySiteItems = new List<StudySiteItem>();
        for (Study_Site__c ss : studySites) {
            String countryName = ss.Site__r.BillingCountry;
            String countryCode = ss.Site__r.BillingCountryCode;
            StudySiteItem item = new StudySiteItem(
                new LabelValueItem(countryName, countryCode),
                ss.Name,
                ss
            );
            item.assignments.add(new ValueStateItem(ss.Id,ss.Medical_Record_Upload__c));
            studySiteItems.add(item);
        }
        return studySiteItems;
    }

}