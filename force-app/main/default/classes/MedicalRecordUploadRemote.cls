public with sharing class MedicalRecordUploadRemote {
    public static final String FEATURE_MEDICAL_VENDOR = 'Medical_Doc_Upload';
    public static final String MEDICAL_UPLOAD_SETUP_FILTER = 'MedicalUploadSetupFilter';

    public class InitData {
        @AuraEnabled
        public String viewMode = GetPermissions.getViewMode(FEATURE_MEDICAL_VENDOR);
        @AuraEnabled
        public StudySiteFilter filter;
        @AuraEnabled
        public SSMedicalRecordUploadConfigResponse searchResponse;
    }

    public class VendorItem {
        @AuraEnabled
        public Study_Site__c studySite;

        public VendorItem(Study_Site__c ss) {
            this.studySite = ss;
        }
    }

    @AuraEnabled
    public static InitData getInitData(Id ctpId) {
        try {
            InitData initData = new InitData();
            StudySiteFilter filter = (StudySiteFilter) SettingStoreService.getOrgDefault(
                MEDICAL_UPLOAD_SETUP_FILTER + ctpId
            );
            if (filter == null)
                filter = new StudySiteFilter(ctpId);
            initData.filter = filter;
            initData.searchResponse = new SSMedicalRecordUploadConfigResponse(
                initData.filter,
                new PaginationData(15)
            );
            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static SSMedicalRecordUploadConfigResponse getItems(
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
            return new SSMedicalRecordUploadConfigResponse(filter, pagination);
        } catch (Exception e) {
            return (SSMedicalRecordUploadConfigResponse) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static SSMedicalRecordUploadConfigResponse selectAllInColumn(
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
            List<StudySiteItem> allSSItems = SSMedicalRecordUploadConfigResponse.convertToSSItems(
                SearchService.search(filter),
                travelVendorId
            );
            for (StudySiteItem ssItem : allSSItems) {
                for (ValueStateItem assigment : ssItem.assignments)
                    assigment.state = state;
            }
            save(allSSItems);
            return new SSMedicalRecordUploadConfigResponse(filter, pagination);
        } catch (Exception e) {
            return (SSMedicalRecordUploadConfigResponse) AuraHelper.throwException(e);
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

        List<Study_Site__c> toUpdate = new List<Study_Site__c>();
        for (StudySiteItem ssItem : studySiteItems) {
            for (ValueStateItem assigment : ssItem.assignments) {
                    toUpdate.add(
                        new Study_Site__c(
                            Id = ssItem.ss.Id,
                            Medical_Record_Upload__c = assigment.state
                        )
                    );
            }
        }
        update toUpdate;
    }

    private static void saveFilter(StudySiteFilter filter) {
        SettingStoreService.saveOrgDefault(
            MEDICAL_UPLOAD_SETUP_FILTER + filter.ctpId,
            filter,
            StudySiteFilter.class
        );
    }

}