/**
 * purpose : provide econsent related dependency and data
 * Initial Release : 10th May 2023
 * */

public without sharing class CreateParticipantController {
    
    @AuraEnabled
    public static String getAccessToken(){
        return MulesoftIntegrationApi.getAccessToken('Mulesoft Access Token eConsent');
    }
    
    
    //method to fetch document collection from eConsent
    @AuraEnabled
    public static List<LabelValueItem> getDocumentCollections(Id perId,String access_token){
        List<LabelValueItem> docCollectionList = new List<LabelValueItem>();
        Participant_Enrollment__c pe = [Select Id,ParticipantGUID__c,SenttoCompleteConsent__c,Clinical_Trial_Profile__r.StudyGUID__c,
                                        Study_Site__c,Study_Site__r.SiteGuid__c,Clinical_Trial_Profile__r.E_Consent_Configuration__c,Study_Site__r.E_Consent_Vendor__c,Study_Site__r.E_Consent_Vendor__r.Name from Participant_Enrollment__c where Id=: perId];
        
        List<CreateConsentIntegration.DocumentCollection> docCollections = new List<CreateConsentIntegration.DocumentCollection>();
        
        if (pe.Clinical_Trial_Profile__r.StudyGUID__c != null && pe.Study_Site__r.SiteGuid__c != null) {
            docCollections = CreateConsentIntegration.documentCollectionResponse(pe.Clinical_Trial_Profile__r.StudyGUID__c,pe.Study_Site__r.SiteGuid__c,access_token);
        }
        
        if(docCollections != null && !docCollections .isEmpty()){
           for(CreateConsentIntegration.DocumentCollection docCollection : docCollections){
            String label = docCollection.title + '(' + docCollection.name + ')';
            docCollectionList.add(new LabelValueItem(label,docCollection.id));
          }
        } 
       
        return docCollectionList;
    }
    
    
    //method to create participant in eConsent
    @AuraEnabled
    public static Consentdetails participantCreationOnEconsent(Id perId,String accesstoken,String documentCollection){

       try{
          Consentdetails details = new Consentdetails();
          List<CreateConsentIntegration.statusInfo> statusInfo = new List<CreateConsentIntegration.statusInfo>();
          Map<Id,LabelValueItem> docMap;
          if(documentCollection != null){
            docMap = (Map<Id,LabelValueItem>)JSON.deserialize(documentCollection, Map<Id,LabelValueItem>.class);
          }
           Participant_Enrollment__c pe = [Select Id,Name,ParticipantGUID__c,SenttoCompleteConsent__c,DocumentCollectionId__c,Clinical_Trial_Profile__r.StudyGUID__c,
                                        Study_Site__c,Study_Site__r.SiteGuid__c,Clinical_Trial_Profile__r.E_Consent_Configuration__c,Study_Site__r.E_Consent_Vendor__c,Study_Site__r.E_Consent_Vendor__r.Name from Participant_Enrollment__c where Id=: perId];

           if(docMap != null && docMap.containsKey(pe.id)){
               pe.DocumentCollectionId__c = docMap.get(pe.id).value;
               String label  = docMap.get(pe.id).label;
               pe.DocumentCollectionTitle__c = label.subString(0,label.indexOf('('));
               pe.DocumentCollectionName__c = label.substring(label.indexOf('(')+1, label.indexOf(')'));
 
           }
           if(accesstoken != null){   
                 List<CreateConsentIntegration.statusInfo> info = CreateConsentIntegration.createParticipant(new List<Participant_Enrollment__c>{pe},accesstoken).values();
            	 //details = getCreateConsentParams(perId);
                 details.statusdetails = info;
                
            }  
           return details;
         }
         catch(Exception ex){
            system.debug('Exception in create Participant:'+ex.getMessage()+'/'+ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage()+'/'+ex.getStackTraceString());
        }
    }
    
    
    
    @AuraEnabled
    public static Boolean isCreateConsentEnabled(Participant_Enrollment__c pe){
        if(	 pe.Clinical_Trial_Profile__r.E_Consent_Configuration__c 
           && pe.Study_Site__r.E_Consent_Vendor__c != null
           && pe.Study_Site__r.E_Consent_Vendor__r.Name == 'Complete Consent'
           && pe.Study_Site__r.SiteGuid__c != null
           && pe.Clinical_Trial_Profile__r.StudyGUID__c != null){
               return true;
           }
        
        return false;
    }
    
    @AuraEnabled
    public static Boolean isCreateConsentDisabled(Participant_Enrollment__c pe){
        system.debug('participant enroll in check:'+ pe.Clinical_Trial_Profile__r.StudyGUID__c );
        if(	 pe.Clinical_Trial_Profile__r.E_Consent_Configuration__c 
           && pe.Study_Site__r.E_Consent_Vendor__c != null
           && pe.Study_Site__r.E_Consent_Vendor__r.Name == 'Complete Consent'
           && pe.Study_Site__r.SiteGuid__c != null
           && pe.Clinical_Trial_Profile__r.StudyGUID__c != null
           && pe.ParticipantGUID__c != null){
               return true;
           }
        
        return false;
    }
    
    
    @AuraEnabled
    public static Boolean isConsentVerificationApplicable(Participant_Enrollment__c pe){
        
        if(	  pe.Clinical_Trial_Profile__r.E_Consent_Configuration__c 
           && pe.Clinical_Trial_Profile__r.StudyGUID__c != null
           && pe.Study_Site__r.E_Consent_Vendor__c != null
           && pe.Study_Site__r.E_Consent_Vendor__r.Name == 'Complete Consent'
           && pe.Study_Site__r.SiteGuid__c != null
           && pe.ParticipantGUID__c != null
           && (!pe.Informed_Consent__c || pe.Re_consent__c))
        {
            return true;
        }
        return false;
    }
    
    
    public static Boolean isConsentDisabled(Participant_Enrollment__c pe){
        
        if(pe.Clinical_Trial_Profile__r.E_Consent_Configuration__c 
           && pe.Clinical_Trial_Profile__r.StudyGUID__c != null
           && pe.Study_Site__r.E_Consent_Vendor__c != null
           && pe.Study_Site__r.E_Consent_Vendor__r.Name == 'Complete Consent'
           && pe.Study_Site__r.SiteGuid__c != null
           && (pe.Informed_Consent__c && !pe.Re_consent__c))
        {
            return true;
        }
        return false;
    }
    
    //loads create consent card in referral hub screen
    @AuraEnabled(cacheable=true)
    public static Consentdetails getCreateConsentParams(Id perId){
       Participant_Enrollment__c pe = [Select Id,ParticipantGUID__c,SenttoCompleteConsent__c,Clinical_Trial_Profile__r.StudyGUID__c,
                                        Study_Site__c,Study_Site__r.SiteGuid__c,Clinical_Trial_Profile__r.E_Consent_Configuration__c,Study_Site__r.E_Consent_Vendor__c,Study_Site__r.E_Consent_Vendor__r.Name from Participant_Enrollment__c where Id=: perId ];
	   Consentdetails details = new Consentdetails();
       details.isEnabled = iscreateConsentEnabled(pe);
       details.isDisabled = isCreateConsentDisabled(pe);
       details.consentDate  = pe.SenttoCompleteConsent__c;
       
        return details;
    }
    
    //loads consent verification card in patient portal
    @AuraEnabled
    public static Consentdetails getConsentParams(){       
        Consentdetails details = new Consentdetails();
        try{
            //fetching contactId for running user
            Id contactId = [Select Id,contactId from user where Id =: userInfo.getUserId() ].contactId;
            //fetching contact for running user
            Contact userContact = [Select id,userCommunityDelegateId__c,Current_Participant_Enrollment__c from Contact where id =:contactId];
            Id perId = userContact.Current_Participant_Enrollment__c;
            Boolean secondryDelegate = false;
            //check if running user is secondary delegate
            if(userContact.userCommunityDelegateId__c != null && perId != null){
                List<Patient_Delegate_Enrollment__c> pde= [SELECT Id, Participant_Enrollment__c,Primary_Delegate__c 
                                                           FROM Patient_Delegate_Enrollment__c where 
                                                           Participant_Enrollment__c = :perId
                                                           and Participant_Enrollment__r.Participant_Contact__c = : userContact.userCommunityDelegateId__c
                                                           AND Patient_Delegate__r.Contact__c = : userContact.id];
                if(!pde.isEmpty()){
                    secondryDelegate = (pde[0].Primary_Delegate__c) ? false : true;
                }
            }
            if(perId != null && !secondryDelegate){
                Participant_Enrollment__c pe = [Select Id,ParticipantGUID__c,SenttoCompleteConsent__c,Clinical_Trial_Profile__r.StudyGUID__c,
                                                Study_Site__c,Study_Site__r.SiteGuid__c,Clinical_Trial_Profile__r.E_Consent_Configuration__c,
                                                Informed_Consent__c,Re_consent__c,Study_Site__r.E_Consent_Vendor__c,Study_Site__r.E_Consent_Vendor__r.Name from Participant_Enrollment__c where Id=: perId ];
                
                details.isEnabled = isConsentVerificationApplicable(pe);
                details.isDisabled = isConsentDisabled(pe);
                CompleteConsent__c config =  CompleteConsent__c.getInstance();
                if(config.Base_Url__c != null && config.Relative_Url__c != null){
                    String finalurl = config.Base_Url__c+config.Relative_Url__c;
                    if(details.isEnabled){
                    	finalurl = finalurl.replace('{SiteGuid}',pe.Study_Site__r.SiteGuid__c);
                        if(pe.ParticipantGUID__c != null){
                           finalurl = finalurl.replace('{ParticipantGuid}',pe.ParticipantGUID__c);   
                        }
                          
                    }
                    details.consentUrl = finalurl;
                }
                else{
                    details.warningMessage = 'Complete Consent URL configuration is missing,Please reach out to Admin Support';
                }
            } 
        }
        catch(Exception ex){
            throw new AuraHandledException('exception details:'+ex.getMessage()+'/'+ex.getStackTraceString());
        }
        return details;
    }
    
    public Class Consentdetails{
        @AuraEnabled
        public String consentUrl;
        @AuraEnabled
        public Boolean isEnabled = false;
        @AuraEnabled
        public String warningMessage;
        @AuraEnabled
        public Boolean isDisabled = false;
        @AuraEnabled
        public DateTime consentDate;
        @AuraEnabled
        public String consentMessage;
        @AuraEnabled
        public List<CreateConsentIntegration.statusInfo> statusdetails;        
    }
    
    public class ResponseWrapper {
        public String id;
        public String title;
        public String name;
    }
    
}