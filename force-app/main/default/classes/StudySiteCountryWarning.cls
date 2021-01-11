public with sharing class StudySiteCountryWarning {

 @AuraEnabled(cacheable=true)
    public static boolean getInitData(String recId) {
        
        Id sid = recId;
        String sobjectType = sId.getSObjectType().getDescribe().getName();
      
        if('Study_Site__c' == sobjectType) {
            
            for(Study_Site__c s: [SELECT Site__r.BillingCountry, Principal_Investigator__r.MailingCountry FROM Study_Site__c 
                                WHERE id =: recId  AND Principal_Investigator__c != null LIMIT 1])                    
                if(s.Site__r.BillingCountry != s.Principal_Investigator__r.MailingCountry)
                    return true;
            for(Site_Staff__c s: [SELECT Study_Site__r.site__r.BillingCountry,Site_Contact__r.MailingCountry FROM Site_Staff__c WHERE Study_Site__c =: recId])
                if(s.Site_Contact__r.MailingCountry != s.Study_Site__r.site__r.BillingCountry)
                    return true;
        } 
        
        return false;
    }

}