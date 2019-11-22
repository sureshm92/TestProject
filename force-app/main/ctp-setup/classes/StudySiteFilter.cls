/**
 * Created by Igor Malyuta on 20.11.2019.
 */

public without sharing class StudySiteFilter implements SearchFilter {

    @AuraEnabled public Id ctpId;
    @AuraEnabled public String countryCodes;
    @AuraEnabled public String selectedSSIds;
    @AuraEnabled public String pageFeatureIds;
    @AuraEnabled public String sortField;
    @AuraEnabled public String sortDirection;

    public StudySiteFilter() {
        this.countryCodes = '';
        this.selectedSSIds = '';
        this.pageFeatureIds = '';
        this.sortField = 'name';
        this.sortDirection = 'ASC';
    }

    //Interface implementation:-----------------------------------------------------------------------------------------
    public String getQueryType() {
        return SearchService.QUERY_TYPE_SOQL;
    }

    public List<String> getFields() {
        return new List<String>{
                'Id',
                'Approved_Lng__c',
                'Clinical_Trial_Profile__c',
                'Name',
                'Site__r.BillingCountry',
                'Site__r.BillingCountryCode',
                'Study_Site_Number__c'
        };
    }

    public String getFilterString() {
        return 'Clinical_Trial_Profile__c = \'' + ctpId + '\''
                + getFieldsInValues('Id', getListByString(selectedSSIds))
                + getFieldsInValues('Site__r.BillingCountryCode', getListByString(countryCodes));
    }

    public String getOrderBy() {
        String filterOrder;
        switch on sortField {
            when 'country' {
                filterOrder = 'Site__r.BillingCountry';
            }
            when 'number' {
                filterOrder = 'Study_Site_Number__c';
            }
            when else {
                filterOrder = 'Name';
            }
        }

        filterOrder += ' ' + sortDirection;
        return filterOrder;
    }

    public SObjectType getSObjectType() {
        return Study_Site__c.getSObjectType();
    }

    private String getFieldsInValues(String fieldName, List<String> values) {
        if (values.isEmpty()) return '';

        return ' AND' + DatabaseService.fieldInValues(fieldName, values);
    }

    public static List<String> getListByString(String toSplit) {
        List<String> splitted;
        if (toSplit != null && !String.isEmpty(toSplit)) splitted = toSplit.split(';');

        return splitted == null ? new List<String>() : splitted;
    }

    public class StudySiteSearchWrapper {
        @AuraEnabled public StudySiteFilter filter;
        @AuraEnabled public PaginationData pagination;
        @AuraEnabled public Boolean haveEmptyAssigment;

        public StudySiteSearchWrapper() {}

        public StudySiteSearchWrapper(StudySiteFilter filter, PaginationData pagination, Integer itemsPerPage) {
            this.filter = filter;
            this.pagination = pagination;
            this.pagination.pageRecordsCount = itemsPerPage;
        }

        public StudySiteSearchWrapper(StudySiteFilter filter, PaginationData pagination) {
            this(filter, pagination, 15);
        }
    }
}