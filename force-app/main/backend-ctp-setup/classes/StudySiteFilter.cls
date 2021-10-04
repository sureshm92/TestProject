/**
 * Created by Igor Malyuta on 20.11.2019.
 */

public without sharing class StudySiteFilter implements SearchFilter {
    @AuraEnabled
    public Id ctpId;
    @AuraEnabled
    public String countryCodes;
    @AuraEnabled
    public String selectedSSIds;
    @AuraEnabled
    public String pageFeatureIds;
    @AuraEnabled
    public String sortField;
    @AuraEnabled
    public String sortDirection;

    public StudySiteFilter(Id ctpId) {
        this.ctpId = ctpId;
        this.countryCodes = '';
        this.selectedSSIds = '';
        //this.pageFeatureIds = '';
        this.sortField = 'name';
        this.sortDirection = 'ASC';
    }

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
        String filterString = 'Clinical_Trial_Profile__c = \'' + ctpId + '\'';
        if (!String.isEmpty(selectedSSIds))
            filterString += ' AND' + DatabaseService.fieldInValues('Id', selectedSSIds.split(';'));
        if (!String.isEmpty(countryCodes))
            filterString +=
                ' AND' +
                DatabaseService.fieldInValues(
                    'Site__r.BillingCountryCode',
                    countryCodes.split(';')
                );
        return filterString;
    }

    public String getOrderBy() {
        String filterOrder = 'Name';
        if (sortField == 'country')
            filterOrder = 'Site__r.BillingCountry';
        if (sortField == 'number')
            filterOrder = 'Study_Site_Number__c';
        return filterOrder + ' ' + sortDirection;
    }

    public SObjectType getSObjectType() {
        return Study_Site__c.getSObjectType();
    }
}
