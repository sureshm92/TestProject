public  without sharing class ConsentManagerController {
    public class consentReturnWrapper{
    @AuraEnabled
    public Study_Site__c site;
    @AuraEnabled
    public Boolean consentPref;
    }
    @AuraEnabled
    public static Study_Site__c fetchStudySite(String studySiteId){
        Study_Site__c studySite = new Study_Site__c();
        try {
            studySite = [select Id,Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.IQVIA_Outreach__c,
            Site__r.BillingCountryCode,
            Clinical_Trial_Profile__r.CommunityTemplate__c,
            Clinical_Trial_Profile__r.PPTemplate__c
            from  Study_Site__c 
            where Id=:studySiteId];
        
            return studySite;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable = false)
    public static consentReturnWrapper getConsentPreferences(String sourcePage, Id recordID){
    String referralSource;
    list<Restricted_Source_Config__c> restrictedRecrd = new list<Restricted_Source_Config__c>();
    list<Participant_Enrollment__c> lstPer = new list<Participant_Enrollment__c>();
    String[] restrictedlst;
    consentReturnWrapper cwrap = new consentReturnWrapper();
         
   
     if(sourcePage == 'AddPart' || sourcePage == 'ImportPart'){
        referralSource='PI';
        cwrap.site = [select Id,Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.IQVIA_Outreach__c,
            Site__r.BillingCountryCode,
            Clinical_Trial_Profile__r.CommunityTemplate__c,
            Clinical_Trial_Profile__r.PPTemplate__c
            from  Study_Site__c 
            where Id=:recordID];  
        restrictedRecrd = [SELECT Id,Study__c,Study__r.IQVIA_Outreach__c,Study__r.CommunityTemplate__c,Study__r.PPTemplate__c,Referral_Resource__c FROM Restricted_Source_Config__c WHERE Study__c =:cwrap.site.Clinical_Trial_Profile__c limit 1];
          if(cwrap.site.Clinical_Trial_Profile__r.CommunityTemplate__c != 'PatientPortal' && (cwrap.site.Clinical_Trial_Profile__r.CommunityTemplate__c != 'Janssen' || cwrap.site.Clinical_Trial_Profile__r.PPTemplate__c != 'PP 2.0')){
              if(cwrap.site.Clinical_Trial_Profile__r.IQVIA_Outreach__c){
                   cwrap.consentPref =  false; 
              }
              else{
                   cwrap.consentPref =  true; 
              }
          }
          else{
            if(cwrap.site.Clinical_Trial_Profile__r.IQVIA_Outreach__c){
                if(cwrap.site.Clinical_Trial_Profile__r.CommunityTemplate__c != 'PatientPortal' && (cwrap.site.Clinical_Trial_Profile__r.CommunityTemplate__c != 'Janssen' || cwrap.site.Clinical_Trial_Profile__r.PPTemplate__c != 'PP 2.0')){
                    cwrap.consentPref =  false;}
                else{
                if(restrictedRecrd != null && !restrictedRecrd.isEmpty()){
                restrictedlst = restrictedRecrd[0].Referral_Resource__c != null ? restrictedRecrd[0].Referral_Resource__c.split(';') : null;
                    if(restrictedlst != null && !restrictedlst.isEmpty()){
                    if(restrictedlst.contains(referralSource)){
                        cwrap.consentPref =  true;
                    }else{
                        cwrap.consentPref =  false;
                    }
                    }else{
                        cwrap.consentPref =  true;
                    }
            }else{ cwrap.consentPref =  false;} 
            }}else{ 
            cwrap.consentPref =  true;}
        }
        
    }
  
     return cwrap;
    }
}