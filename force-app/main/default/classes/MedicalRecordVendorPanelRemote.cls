public with sharing class MedicalRecordVendorPanelRemote {
    public static final String FEATURE_MEDICAL_VENDOR = 'Medical_Vendors';
    public static final String MEDICAL_VENDOR_SETUP_FILTER = 'MedicalVendorSetupFilter';

    public class InitData {
        @AuraEnabled
        public String viewMode = GetPermissions.getViewMode(FEATURE_MEDICAL_VENDOR);
        @AuraEnabled
        public StudySiteFilter filter;
        @AuraEnabled
        public SSMedicalRecordVendorConfigResponse searchResponse;
    }

    public class VendorItem {
        @AuraEnabled
        public Study_Site__c studySite;
        @AuraEnabled
        public List<MedicalVendorSettings__c> vendorSettings;

        public VendorItem(Study_Site__c ss) {
            this.studySite = ss;
            this.vendorSettings = new List<MedicalVendorSettings__c>();
        }
    }

    @AuraEnabled
    public static InitData getInitData(Id ctpId) {
        try {
            InitData initData = new InitData();
            StudySiteFilter filter = (StudySiteFilter) SettingStoreService.getOrgDefault(
                MEDICAL_VENDOR_SETUP_FILTER + ctpId
            );
            if (filter == null)
                filter = new StudySiteFilter(ctpId);
            initData.filter = filter;
            initData.searchResponse = new SSMedicalRecordVendorConfigResponse(
                initData.filter,
                new PaginationData(15)
            );
            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static SSMedicalRecordVendorConfigResponse getItems(
        String ssItemsJSON,
        String filterJSON,
        String paginationJSON
    ) {
        try {
            StudySiteFilter filter = (StudySiteFilter) JSON.deserialize(
                filterJSON,
                StudySiteFilter.class
            );
            PaginationData pagination = (PaginationData) JSON.deserialize(
                paginationJSON,
                PaginationData.class
            );
            save(ssItemsJSON);
            saveFilter(filter);
            return new SSMedicalRecordVendorConfigResponse(filter, pagination);
        } catch (Exception e) {
            return (SSMedicalRecordVendorConfigResponse) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static SSMedicalRecordVendorConfigResponse selectAllInColumn(
        String travelVendorId,
        Boolean state,
        String filterJSON,
        String paginationJSON,
        String ssItemsJSON
    ) {
        try {
            save(ssItemsJSON);
            StudySiteFilter filter = (StudySiteFilter) JSON.deserialize(
                filterJSON,
                StudySiteFilter.class
            );
            saveFilter(filter);
            PaginationData pagination = (PaginationData) JSON.deserialize(
                paginationJSON,
                PaginationData.class
            );
            List<StudySiteItem> allSSItems = SSMedicalRecordVendorConfigResponse.convertToSSItems(
                SearchService.search(filter),
                travelVendorId
            );
            for (StudySiteItem ssItem : allSSItems) {
                for (ValueStateItem assigment : ssItem.assignments)
                    assigment.state = state;
            }
            save(allSSItems);
            return new SSMedicalRecordVendorConfigResponse(filter, pagination);
        } catch (Exception e) {
            return (SSMedicalRecordVendorConfigResponse) AuraHelper.throwException(e);
        }
    }

    private static void save(String ssItemsJSON) {
        if (String.isEmpty(ssItemsJSON))
            return;
        List<StudySiteItem> studySiteItems = (List<StudySiteItem>) JSON.deserialize(
            ssItemsJSON,
            List<StudySiteItem>.class
        );
        save(studySiteItems);
    }

    private static void save(List<StudySiteItem> studySiteItems) {
        List<MedicalVendorSettings__c> toDelete = new List<MedicalVendorSettings__c>();
        List<MedicalVendorSettings__c> toInsert = new List<MedicalVendorSettings__c>();
        for (StudySiteItem ssItem : studySiteItems) {
            for (ValueStateItem assigment : ssItem.assignments) {
                if (assigment.sourceId != null && !assigment.state) {
                    toDelete.add(new MedicalVendorSettings__c(Id = assigment.sourceId));
                } else if (assigment.sourceId == null && assigment.state) {
                    toInsert.add(
                        new MedicalVendorSettings__c(
                            Study_Site__c = ssItem.ss.Id,
                            Medical_Record_Vendor__c = assigment.value
                        )
                    );
                }
            }
        }
        delete toDelete;
        insert toInsert;
    }

    private static void saveFilter(StudySiteFilter filter) {
        SettingStoreService.saveOrgDefault(
            MEDICAL_VENDOR_SETUP_FILTER + filter.ctpId,
            filter,
            StudySiteFilter.class
        );
    }
}