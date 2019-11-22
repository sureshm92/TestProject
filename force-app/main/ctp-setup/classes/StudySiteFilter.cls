/**
 * Created by Igor Malyuta on 20.11.2019.
 */

public without sharing class StudySiteFilter implements SearchFilter{

    @AuraEnabled public String mainFilter = 'Clinical_Trial_Profile__c = \'ctpId\'';
    @AuraEnabled public String additionalFilter = '';
    @AuraEnabled public String filterOrder = 'Name';

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
        return mainFilter + additionalFilter;
    }

    public String getOrderBy() {
        return filterOrder;
    }

    public SObjectType getSObjectType() {
        return Study_Site__c.getSObjectType();
    }

    //Sort logic:-------------------------------------------------------------------------------------------------------
    public void setSortOrder(String sortBy) {
        switch on sortBy {
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
    }

    public void setSortDirection(String sortDirection) {
        filterOrder = filterOrder.replaceFirst('ASC|DESC', '').removeEnd(' ');
        filterOrder += ' ' + sortDirection;
    }

    //Main filter logic:------------------------------------------------------------------------------------------------
    public String getMainFilter() {
        return mainFilter;
    }

    public void setCTP(Id ctpId) {
        mainFilter = mainFilter.replace('ctpId', ctpId);
    }

    public List<Study_Site__c> getStudySitesByMainFilter() {
        return (List<Study_Site__c>) DatabaseService.query(getFields(), getSObjectType(), mainFilter);
    }

    //Additional filter logic:------------------------------------------------------------------------------------------
    public void addFieldInValuesToFilter(String fieldName, List<String> values) {
        if(values.isEmpty()) return;

        additionalFilter += ' AND' + DatabaseService.fieldInValues(fieldName, values);
    }

    public void clearAdditionalFilter() {
        additionalFilter = '';
    }

    public static List<String> getListByString(String toSplit) {
        List<String> splitted;
        if (toSplit != null && !String.isEmpty(toSplit)) splitted = toSplit.split(';');

        return splitted == null ? new List<String>() : splitted;
    }

    public class StudySiteSearchWrapper {
        @AuraEnabled public StudySiteFilter filter;
        @AuraEnabled public PaginationData pagination;
        @AuraEnabled public String countryCodes;
        @AuraEnabled public String selectedSSIds;
        @AuraEnabled public String pageFeatureIds;
        @AuraEnabled public String sortField;
        @AuraEnabled public String sortDirection;
        @AuraEnabled public Boolean haveEmptyAssigment;

        public StudySiteSearchWrapper(){}

        public StudySiteSearchWrapper(StudySiteFilter filter, PaginationData pagination, Integer itemsPerPage) {
            this.filter = filter;
            this.pagination = pagination;
            this.pagination.pageRecordsCount = itemsPerPage;
            this.countryCodes = '';
            this.selectedSSIds = '';
            this.pageFeatureIds = '';
            this.sortField = 'name';
            this.sortDirection = 'ASC';
        }

        public StudySiteSearchWrapper(StudySiteFilter filter, PaginationData pagination) {
            this(filter, pagination, 15);
        }

        public void refreshFilter() {
            filter.clearAdditionalFilter();
            filter.addFieldInValuesToFilter('Id', getListByString(selectedSSIds));
            filter.addFieldInValuesToFilter('Site__r.BillingCountryCode', getListByString(countryCodes));

            filter.setSortOrder(sortField);
            filter.setSortDirection(sortDirection);
        }
    }
}