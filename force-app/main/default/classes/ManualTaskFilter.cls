/**
 * Created by Igor Malyuta on 07.03.2019.
 */

public with sharing class ManualTaskFilter {

    //For dynamic
    private final String SEPARATOR = '\',\'';

    @AuraEnabled
    public List<LookupSearchResult> areas = new List<LookupSearchResult>();

    @AuraEnabled
    public List<String> sponsors = new List<String>();

    @AuraEnabled
    public List<String> studies = new List<String>();

    @AuraEnabled
    public List<String> countries = new List<String>();

    @AuraEnabled
    public List<String> sites = new List<String>();

    public ManualTaskFilter() {
    }

    public String getFiltersQuery() {
        String query = '';
//        if(!areas.isEmpty())
//            query += fieldJoin(Therapeutic_Area__c.class.getName(), areas);

        if(!sponsors.isEmpty())
            query += fieldJoin(Account.class.getName(), sponsors);

        if(!studies.isEmpty())
            query += fieldJoin(Clinical_Trial_Profile__c.class.getName(), studies);

        if(!countries.isEmpty())
            query += fieldJoin(Participant__c.Country_Code__c.class.getName(), countries);

        if(!sites.isEmpty())
            query += fieldJoin(Study_Site__c.class.getName(), sites);

        return query;
    }

    private String fieldJoin(String fieldName, List<String> items) {
        return ' AND ' + fieldName + ' IN (\'' + String.join(items, SEPARATOR) + ') ';
    }
}