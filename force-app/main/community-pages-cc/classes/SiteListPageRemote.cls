public without sharing class SiteListPageRemote {
    public class SiteWrapper {
        public String studyName;
        public String siteNumber;
        public String siteName;
        public String country;
        public String piName;
        public String phoneNumber;
        public String primaryContact;
        public String siteStatus;
    }
    public static final List<String> SS_TABLE_FIELDS = new List<String>{
        'Clinical_Trial_Profile__r.Name',
        'Study_Site_Number__c',
        'Name',
        'Site_Staff__r.Site_Contact__r.MailingCountry',
        'Principal_Investigator__r.Name',
        'Site_Staff__r.Site_Contact__r.Phone',
        'Site_Staff__r.Site_Contact__r.Name',
        'Recruitment_Status__c'
    };
    public static final String DEFAULT_FILTER = 'Clinical_Trial_Profile__r.Enable_for_Call_Center_Support__c = true';

    @AuraEnabled
    public static List<SiteWrapper> getSearchResults(
        String searchOption,
        String searchText,
        String sortType
    ) {
        List<SiteWrapper> siteWrapperList = new List<SiteWrapper>();
        List<Study_Site__c> siteQueryResult;
        String filterText = '';
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
            siteQueryResult = DatabaseService.query(
                SS_TABLE_FIELDS,
                Study_Site__c.getSObjectType(),
                filterText,
                sortType,
                10000,
                0
            );
            return siteWrapperList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
