// show warning message study site detail page when pi  country and staff country not same
public with sharing class StudySiteCountryWarning {
    
    @AuraEnabled(cacheable=true)
    public static boolean siteCountry(String recId) {
        Integer limitRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
        Id sid = recId;
        
        List<Study_Site__c> studySiteList = [SELECT Site__r.BillingCountry, Principal_Investigator__r.MailingCountry FROM Study_Site__c 
                                             WHERE id =: recId  AND Principal_Investigator__c != null LIMIT: limitRows];
        if(!studySiteList.isEmpty()) {
            for(Study_Site__c s: studySiteList) {
                if(s.Site__r.BillingCountry != s.Principal_Investigator__r.MailingCountry)
                    return true;
            }
        }
        List<Site_Staff__c> siteStaffList = [SELECT Study_Site__r.site__r.BillingCountry,Site_Contact__r.MailingCountry FROM
                                              Site_Staff__c WHERE Study_Site__c =: recId LIMIT: limitRows];
        if(!siteStaffList.isEmpty()) {
            for(Site_Staff__c s:siteStaffList) {
                if(s.Site_Contact__r.MailingCountry != s.Study_Site__r.site__r.BillingCountry)
                    return true;
            }
        }
        
        return false;
    } 
    }