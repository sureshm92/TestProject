public without sharing class SiteListPageRemote {
    public class SiteWrapper {
        @AuraEnabled
        public String ctpId;
        @AuraEnabled
        public String siteId;
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
        public String siteStaff;
        @AuraEnabled
        public Boolean receivePIEmail;
        @AuraEnabled
        public Boolean siteInfoComplete;
        @AuraEnabled
        public Boolean trainingComplete;
        @AuraEnabled
        public Boolean isStudySiteEmailValid;
        @AuraEnabled
        public Boolean isRecordUpdated;
        @AuraEnabled
        public String site;
        @AuraEnabled
        public String BillingCountryCode;
        @AuraEnabled
        public String BillingStateCode;
        @AuraEnabled
        public Boolean supressPIEmail;
        @AuraEnabled
        public Boolean optInForWarmTransfer;
    }
    public class PaginatedSiteWrapper {
        @AuraEnabled
        public List<SiteWrapper> sites;
        @AuraEnabled
        public PaginationData paginationData;
    }
    public class CSVWrapper {
        @AuraEnabled
        public List<Study_Site__c> sites;
        @AuraEnabled
        public List<String> siteIds;

        CSVWrapper() {
            this.sites = new List<Study_Site__c>();
            this.siteIds = new List<String>();
        }
    }

    public static final List<String> SS_TABLE_FIELDS = new List<String>{
        'Id',
        'Clinical_Trial_Profile__c',
        'Clinical_Trial_Profile__r.Suppress_PI_Emails__c',
        'Clinical_Trial_Profile__r.Study_Code_Name__c',
        'Study_Site_Number__c',
        'Name',
        'Site__r.BillingCountry',
        'Principal_Investigator__c',
        'Principal_Investigator__r.Name',
        'Study_Site_Phone__c',
        'Site_Staff__r.Site_Contact__r.Name',
        'Study_Site_Email__c',
        'Override_PI_Referral_Status__c',
        'Suppress_Study_Site_PI_Emails__c',
        'Site_Information_Form_Completed__c',
        'Completed_training__c',
        'CreatedDate',
        'Site_Staff__c',
        'Site__c',
        'Opt_in_for_warm_transfer__c',
        'Principal_Investigator__r.Account.BillingCountryCode',
        'Principal_Investigator__r.Account.BillingStateCode'
    };

    public static final String DEFAULT_FILTER = 'Enable_for_Call_Center_Support__c = true AND Clinical_Trial_Profile__r.Enable_for_Call_Center_Support__c = true';
    private static final String SOSL_FILTER = 'userCommunytyType__c includes (' + '\'PI\'' + ')';
    private static final Integer DOWNLOAD_QUERY_LIMIT = 49000;
    private static final Integer RECORDS_PER_PAGE = 100;

    @AuraEnabled
    public static PaginatedSiteWrapper getSearchResults(
        String searchOption,
        String searchText,
        String sortType,
        String paginationJSON
    ) {
        PaginatedSiteWrapper paginatedWrapper = new PaginatedSiteWrapper();
        List<Study_Site__c> siteQueryResult;
        String filterText = '';

        paginatedWrapper.paginationData = String.isEmpty(paginationJSON)
            ? new PaginationData(RECORDS_PER_PAGE)
            : (PaginationData) JSON.deserialize(paginationJSON, PaginationData.class);
        paginatedWrapper.sites = new List<SiteWrapper>();

        filterText = getFilterText(searchOption, searchText);
        if (!String.isEmpty(filterText)) {
            try {
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
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        return paginatedWrapper;
    }

    @AuraEnabled
    public static CSVWrapper getAllSearchResults(
        String searchOption,
        String searchText,
        List<String> siteIds,
        Integer totalItemsToDownload
    ) {
        CSVWrapper result = new CSVWrapper();
        String filterText = getFilterText(searchOption, searchText);
        if (!String.isEmpty(filterText)) {
            filterText += siteIds.isEmpty() ? '' : ' AND Id NOT IN :siteIds';
            String fields = String.join(SS_TABLE_FIELDS, ',');
            String queryString =
                'SELECT ' +
                fields +
                ' FROM Study_Site__c' +
                ' WHERE ' +
                filterText +
                ' LIMIT ' +
                DOWNLOAD_QUERY_LIMIT;
            try {
                Map<Id, Study_Site__c> siteMap = new Map<Id, Study_Site__c>(
                    (List<Study_Site__c>) Database.query(queryString)
                );
                if (totalItemsToDownload <= DOWNLOAD_QUERY_LIMIT) {
                    result.siteIds = null;
                } else {
                    result.siteIds = (List<String>) (new List<Id>(siteMap.keySet()));
                }
                result.sites = siteMap.values();
                return result;
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        return result;
    }

    private static String getFilterText(String searchOption, String searchText) {
        String filterText = '';
        switch on searchOption {
            when 'Principal_Investigator__r.Name' {
                List<Contact> piContacts = new List<Contact>();
                for (Contact con : getPIContacts(searchText)) {
                    if (con.Name.containsIgnoreCase(searchText)) {
                        piContacts.add(con);
                    }
                }
                filterText += !piContacts.isEmpty()
                    ? DEFAULT_FILTER +
                      ' AND ' +
                      DatabaseService.fieldIn('Principal_Investigator__c', piContacts)
                    : '';
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
                    ' = \'' +
                    String.escapeSingleQuotes(searchText) +
                    '\'';
            }
        }
        return filterText;
    }
    @TestVisible
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
            wrapper.siteStatus = site.Override_PI_Referral_Status__c;
            wrapper.studyName = site.Clinical_Trial_Profile__r.Study_Code_Name__c;
            wrapper.siteId = site.Id;
            wrapper.ctpId = site.Clinical_Trial_Profile__c;
            wrapper.piId = site.Principal_Investigator__c;
            wrapper.receivePIEmail = !site.Suppress_Study_Site_PI_Emails__c;
            wrapper.siteInfoComplete = site.Site_Information_Form_Completed__c;
            wrapper.trainingComplete = site.Completed_training__c;
            wrapper.siteStaff = site.Site_Staff__c;
            wrapper.siteEmail = site.Study_Site_Email__c;
            wrapper.site = site.Site__c;
            wrapper.optInForWarmTransfer = site.Opt_in_for_warm_transfer__c;
            wrapper.BillingCountryCode = site.Principal_Investigator__r.Account.BillingCountryCode;
            wrapper.BillingStateCode = site.Principal_Investigator__r.Account.BillingStateCode;
            wrapper.supressPIEmail = site.Clinical_Trial_Profile__r.Suppress_PI_Emails__c;
            wrapperList.add(wrapper);
        }
        return wrapperList;
    }

    private static List<Contact> getPIContacts(String searchText) {
        String soslSearchTerm = '\'(';
        for (String word : searchText.split(' ')) {
            soslSearchTerm += '\"' + word + '*\"' + ' AND ';
        }
        soslSearchTerm = soslSearchTerm.trim().removeEnd('AND') + ')\'';
        String soslSearchQuery =
            'FIND ' +
            soslSearchTerm +
            ' IN NAME FIELDS RETURNING Contact ( Id, Name WHERE ' +
            SOSL_FILTER +
            ' ) LIMIT 2000';
        System.debug('##soslSearchQuery: ' + soslSearchQuery);
        return Search.query(soslSearchQuery)[0];
    }
}
