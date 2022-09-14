public without sharing class rh_siteBirthdateConfigController {
    @AuraEnabled
    public static List<Study_Site__c> fetchSites(String studyId,String sortOrder, String sortBy, List<String> studySiteIds, List<String> countryNames, List<String> dateFormats){
        String query = 'select id, Site__r.BillingCountry, Name, Study_Site_Number__c, Participant_DOB_format__c'
        +' from Study_Site__c where Clinical_Trial_Profile__c =\''+ studyId+'\'';
        
        if(studySiteIds.size()>0){
            System.debug('studySiteIds :: '+studySiteIds);
            query += ' and Id IN: studySiteIds ';
        }
        if(countryNames.size()>0){
            System.debug('countryNames :: '+countryNames);
            query += ' and Site__r.BillingCountry IN: countryNames ';
        }
        if(dateFormats.size()>0){
            System.debug('dateFormats :: '+dateFormats);
            query += ' and Participant_DOB_format__c IN: dateFormats ';
        }
        if(String.isNotEmpty(sortBy)){
            query += ' order by ';
            query += (sortBy == 'Country'? 'Site__r.BillingCountry' : sortBy == 'SSName' ? 'Name' : sortBy == 'SSNumber' ? 'Study_Site_Number__c' : 'Name');
        }
        if(String.isNotEmpty(sortOrder)){
            query += ' '+sortOrder;
        }
        return Database.query(query);
    }

    @AuraEnabled
    public static void updateDobOnSites(List<Study_Site__c> updateSites){
        update updateSites;
    }
}