/**
*  @Name: newMediaOutReach
*  @Description - This class helps to create new media outReach and 
load the data from logged in community
*  @Author : Vicky
*  @created  2020-05-22
* @version 48.0   
*/
public without sharing class NewMediaOutReach {
    
    public static String REQUESTED_VAL = Label.Requested;
    
    public  static Id studyContactId;
    public  static String lstvalsite;
    public  static string lstvalstudy;
    public  static  List<Study_Site__c> studyDataLast;
    public class CommunityPreferred {
        @AuraEnabled public string preEmail;
        @AuraEnabled public string prePhone;
        @AuraEnabled public string preName;
        
        public CommunityPreferred(){
        }  
    }  
    /**   
* @Author: Vicky
* @name: getstudyType
* @CreateDate: 2020-05-25
* @Description: To Pass the phone from study site and email from logged in community user on component.
**/
    @AuraEnabled
    public static string getstudyType(string site) {
        List<Study_Site__c> studylst = new List<Study_Site__c>();
        Integer limitRows = Limits.getLimitQueryRows() - Limits.getQueryRows();

        Contact userContact = CommunityService.getUserContact();
        studyContactId = userContact.Id;

        if((String.isNotBlank(site))){
            Study_Site__c siteId =[SELECT id,Name,Study_Site_Phone__c FROM Study_Site__c WHERE Name =:site LIMIT 1];
            lstvalsite = siteId.Study_Site_Phone__c;
            }
            
        Contact con=[SELECT id,name,Email,Phone from Contact where Id =:studyContactId LIMIT 1];
        CommunityPreferred commm = new CommunityPreferred();
        
        commm.prePhone = lstvalsite;
        commm.preEmail = con.Email;
        
       return JSON.serialize(commm);
        
    }
    /**   
* @Author: Vicky
* @name: getstudyData
* @CreateDate: 2020-05-25
* @Description: To Pass the list of study.
**/
    
    @AuraEnabled
    public static List<Study_Site__c> getstudyData(string dataStudy) {
         Clinical_Trial_Profile__c ctpdata;
        Integer limitRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
        if((String.isNotBlank(dataStudy))){
             ctpdata =[SELECT id,Study_Code_Name__c,Name from Clinical_Trial_Profile__c WHERE Study_Code_Name__c =:dataStudy LIMIT 1];
            }
            if(ctpdata != null){
            studyDataLast =[SELECT id,Site__r.Name,Clinical_Trial_Profile__r.Study_Code_Name__c,Name from Study_Site__c WHERE Clinical_Trial_Profile__c =:ctpdata.Id LIMIT :limitRows];
            }
        return studyDataLast;
        
    }
    /**   
* @Author: Vicky
* @name: getstudyData
* @CreateDate: 2020-05-25
* @Description: To fetch the Media outreach Provider not null.
**/
    @AuraEnabled
    public static List<Clinical_Trial_Profile__c> getstudyContact() {
        Integer limitRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
        Id studyContactId;
        List<Clinical_Trial_Profile__c> clinicalTrialLst = new List<Clinical_Trial_Profile__c>(); 
        List<Study_Site__c> studylst = new List<Study_Site__c>(); 
        set<Id> ctpIds = new set<Id>();
        Contact userContact = CommunityService.getUserContact();
        
        studyContactId = userContact.Id;
        studylst =[SELECT id,Name,Clinical_Trial_Profile__r.Media_outreach_Provider__c,Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.Study_Code_Name__c,Principal_Investigator__c FROM Study_Site__c WHERE Principal_Investigator__c =:studyContactId AND Clinical_Trial_Profile__r.Media_outreach_Provider__c != null LIMIT :limitRows];
        if(studylst.size()>0){
          for(Study_Site__c st: studylst){
              ctpIds.add(st.Clinical_Trial_Profile__c);
          }
        }
        if(!ctpIds.isEmpty()){
           clinicalTrialLst =[SELECT id,Study_Code_Name__c,Name from Clinical_Trial_Profile__c WHERE Id =:ctpIds LIMIT :limitRows];
        }
        
        return clinicalTrialLst;
        
    }
    /**   
* @Author: Vicky
* @name: getPickListValues
* @CreateDate: 2020-05-29
* @Description: To fetch the Media type value from media outreach object.
**/
    
    @AuraEnabled
    public static Map<String, String> getPickListValues(String obj, String str) {
        Map<String, String> options = new Map<String, String>(); 
        Schema.DescribeFieldResult plistvalues = Schema.getGlobalDescribe().get(obj).getDescribe().fields.getMap().get(str).getDescribe();
        
        for(PicklistEntry ent:plistvalues.getpicklistvalues())
        {
            options.put(ent.getValue(),ent.getLabel());
        }
        return options;
    }
    
    /**   
* @Author: Vicky
* @name: getPickListValues
* @CreateDate: 2020-05-29
* @Description: To create media outreach data.
**/
    
    @AuraEnabled
    public static void inviteNewMedia(string study,string site,String prefferedtype,string actualemailPhone, List<String> media,string startdt,string enddt,string notes){
       try{
            Clinical_Trial_Profile__c ctpLstdata;
            Study_Site__c siteId;
            Account accLst;
            if(study != '' || study != null){
                ctpLstdata =[SELECT id,Study_Code_Name__c,Name from Clinical_Trial_Profile__c WHERE Study_Code_Name__c =:study LIMIT 1];
                }
                 if(ctpLstdata != null && (site != '' || site != null)){
                siteId =[SELECT id,Site__c,Name,Principal_Investigator__c from Study_Site__c WHERE Clinical_Trial_Profile__c =:ctpLstdata.Id AND Name =:site LIMIT 1];
                 }
            if(siteId.Site__c != null){
                accLst =[SELECT id,name FROM Account where Id =:siteId.Site__c LIMIT 1];
            }
            List<Media_Outreach__c> medialst = new List<Media_Outreach__c>();
            string typeval;
            Media_Outreach__c mediaOut = new Media_Outreach__c();
            if(media.size()>0){
                for(Integer i =0; i<media.size(); i++){
                    if(i==0){
                        typeval = media[i];
                    }
                    if(i>0){
                        typeval = typeval+';'+ media[i];  
                    }
                } 
            }
            mediaOut.Clinical_Trial_Profile__c = ctpLstdata.Study_Code_Name__c;
            mediaOut.Study_Name__c = siteId.Id;
           // mediaOut.Study_Site__c = accLst.Id;
            mediaOut.Media_Type__c =  typeval;
            mediaOut.Preferred_contact_method__c = prefferedtype;
            mediaOut.Alternate_Email_Phone_Number__c = actualemailPhone;
            mediaOut.Status__c = REQUESTED_VAL;
            if(startdt!= ''){
                mediaOut.Requested_Start_Date__c = Date.valueOf(startdt);
            }
            if(enddt!= ''){
                mediaOut.Requested_End_Date__c = Date.valueOf(enddt);
            }
            medialst.add(mediaOut);
            
            if(medialst.size()>0){
                insert medialst;
            }
            if(String.isNotBlank(notes)) {
                
                ContentNote objCntNote = new ContentNote();
                objCntNote.Title = notes;
                insert objCntNote;  
                
                ContentDocumentLink objCntDocLink = new ContentDocumentLink();
                objCntDocLink.LinkedEntityId = medialst[0].Id;
                objCntDocLink.ContentDocumentId = objCntNote.Id;
                insert objCntDocLink;
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    
}