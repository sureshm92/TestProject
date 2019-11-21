/**
 * Created by Igor Malyuta on 20.11.2019.
 */

public without sharing class StudySiteFilter implements SearchFilter{

    public String filterString;
    public String filterOrder;

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
        return filterString;
    }

    public String getOrderBy() {
        return filterOrder;
    }

    public SObjectType getSObjectType() {
        return Study_Site__c.getSObjectType();
    }
}