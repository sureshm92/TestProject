public without sharing class SiteListPageRemote {
    public class SiteWrapper {
        @AuraEnabled
        public String ctpId;
        @AuraEnabled
        public String studyId;
        @AuraEnabled
        public String piId;
        @AuraEnabled
        public String studyName;
        @AuraEnabled
        public String siteNumber;
        @AuraEnabled
        public String siteName;
        @AuraEnabled
        public String siteCountry;
        @AuraEnabled
        public String piName;
        @AuraEnabled
        public String sitePhone;
        @AuraEnabled
        public String primaryContact;
        @AuraEnabled
        public String siteStatus;
        @AuraEnabled
        public String siteEmail;
        @AuraEnabled
        public Boolean receivePIEmail;
        @AuraEnabled
        public Boolean siteInfoComplete;
        @AuraEnabled
        public Boolean trainingComplete;


    }
    public class PaginatedSiteWrapper {
        @AuraEnabled
        public List<SiteWrapper> sites;
        @AuraEnabled
        public PaginationData paginationData;
    }
    public static final List<String> SS_TABLE_FIELDS = new List<String>{
        'Id',
        'Clinical_Trial_Profile__c',
        'Clinical_Trial_Profile__r.Study_Code_Name__c',
        'Study_Site_Number__c',
        'Name',
        'Site__r.BillingCountry',
        'Principal_Investigator__c',
        'Principal_Investigator__r.Name',
        'Study_Site_Phone__c',
        'Site_Staff__r.Site_Contact__r.Name',
        'Study_Site_Email__c',
        'Recruitment_Status__c',
        'Suppress_Study_Site_PI_Emails__c',
        'Site_Information_Form_Completed__c',
        'Completed_training__c'
    };

    public static final String DEFAULT_FILTER = 'Enable_for_Call_Center_Support__c = true AND Clinical_Trial_Profile__r.Enable_for_Call_Center_Support__c = true';

    @AuraEnabled
    public static PaginatedSiteWrapper getSearchResults(
        String searchOption,
        String searchText,
        String sortType
    ) {
        PaginatedSiteWrapper paginatedWrapper = new PaginatedSiteWrapper();
        List<Study_Site__c> siteQueryResult;
        String filterText = '';

        paginatedWrapper.paginationData = new PaginationData(100);
        paginatedWrapper.sites = new List<SiteWrapper>();

        switch on searchOption {
            when 'Principal_Investigator__r.Name' {
                filterText +=
                    DEFAULT_FILTER +
                    ' AND Principal_Investigator__r.Name LIKE ' +
                    '\'%' +
                    String.escapeSingleQuotes(searchText) +
                    '%\'';
            }
            when 'Name' {
                filterText +=
                    DEFAULT_FILTER +
                    ' AND Name LIKE ' +
                    '\'%' +
                    String.escapeSingleQuotes(searchText) +
                    '%\'';
            }
            when else {
                filterText +=
                    DEFAULT_FILTER +
                    ' AND ' +
                    searchOption +
                    ' =' +
                    String.escapeSingleQuotes(searchText);
            }
        }
        try {
            System.debug(filterText);
            //Apply pagination
            Integer recordCount = Database.countQuery(
                'SELECT COUNT() FROM Study_Site__c WHERE ' + filterText
            );

            paginatedWrapper.paginationData.setRecordsCount(recordCount);

            Integer limitvalue = paginatedWrapper.paginationData.pageRecordsCount;
            Integer currentpage = paginatedWrapper.paginationData.currentPage;
            Integer size = currentpage - 1;
            Integer offsetvalue = size * limitvalue;
            //Get query results from DatabaseService
            siteQueryResult = DatabaseService.query(
                SS_TABLE_FIELDS,
                Study_Site__c.getSObjectType(),
                filterText,
                sortType,
                limitvalue,
                offsetvalue
            );

            if (!siteQueryResult.isEmpty()) {
                //Apply translation
                TranslateHelper.translate(siteQueryResult);
                //Transform into wrapper
                paginatedWrapper.sites = wrapperTransformation(siteQueryResult);
            }
            return paginatedWrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<SiteWrapper> wrapperTransformation(List<Study_Site__c> siteList) {
        List<SiteWrapper> wrapperList = new List<SiteWrapper>();
        for (Study_Site__c site : siteList) {
            SiteWrapper wrapper = new SiteWrapper();
            wrapper.siteCountry = site.Site__r.BillingCountry;
            wrapper.sitePhone = site.Study_Site_Phone__c;
            wrapper.piName = site.Principal_Investigator__r.Name;
            wrapper.primaryContact = site.Site_Staff__r.Site_Contact__r.Name;
            wrapper.siteName = site.Name;
            wrapper.siteNumber = site.Study_Site_Number__c;
            wrapper.siteStatus = site.Recruitment_Status__c;
            wrapper.studyName = site.Clinical_Trial_Profile__r.Study_Code_Name__c;
            wrapper.studyId = site.Id;
            wrapper.ctpId = site.Clinical_Trial_Profile__c;
            wrapper.piId = site.Principal_Investigator__c;
            wrapper.receivePIEmail = !site.Suppress_Study_Site_PI_Emails__c;
            wrapper.siteInfoComplete  = site.Site_Information_Form_Completed__c;
            wrapper.trainingComplete = site.Completed_training__c;
            wrapperList.add(wrapper);
        }
        return wrapperList;
    }
}
