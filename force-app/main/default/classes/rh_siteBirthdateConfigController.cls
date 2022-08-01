public without sharing class rh_siteBirthdateConfigController {
    @AuraEnabled
    public static List<Study_Site__c> fetchSites(String studyId,String sortOrder, String sortBy){
        String query = 'select id, Site__r.BillingCountry, Name, Study_Site_Number__c, Participant_DOB_format__c'
        +' from Study_Site__c where Clinical_Trial_Profile__c =\''+ studyId+'\' order by ';
        if(String.isNotEmpty(sortBy)){
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