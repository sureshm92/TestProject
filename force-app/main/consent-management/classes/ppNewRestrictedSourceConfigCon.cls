public with sharing class ppNewRestrictedSourceConfigCon {
    
    @AuraEnabled(cacheable = false)
    public static Integer getRestrictedSourceConfigData(String recordId) {
        Integer noOfConfigRecrds = 
            [SELECT COUNT() FROM Restricted_Source_Config__c WHERE Study__c =: recordId];
        return noOfConfigRecrds;
    }

    @AuraEnabled(cacheable = false)
    public static Restricted_Source_Config__c getRestrictedSourceConfigRecord(String recordId) {
        list<Restricted_Source_Config__c> restrictedRecrd = 
            [SELECT Id,Sponsor__c,Study__c,Referral_Resource__c FROM Restricted_Source_Config__c WHERE Study__c =: recordId];
        if(restrictedRecrd!=null && restrictedRecrd.size()>0){
             return restrictedRecrd[0];
        }
        return null;
    }
}