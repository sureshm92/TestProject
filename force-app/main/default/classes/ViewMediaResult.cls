/* Created By
 * Akanksha */

public Without sharing class ViewMediaResult {
    
     public  static Id studyContactId;
    
    public class InitData{
        @AuraEnabled
        public MediaOutreachServices.moFilter moFilter;
        public MediaOutreachServices.moFilterData moFilterData;
        public List<Media_Outreach__c> currentPageList;
        public PaginationData paginationData;
        public List<Clinical_Trial_Profile__c>clinicalList;
    }
     public class CommunityPreferred {
       @AuraEnabled public Boolean MOEmail;
       @AuraEnabled public Boolean MOPhone;
       @AuraEnabled public Boolean Other;
       @AuraEnabled public string MO_Phonenumber;
       @AuraEnabled public string MO_Email;
       @AuraEnabled  Public List<ContentDocument> lstnotes;
       @AuraEnabled  Public string MO_AlternateValue;
       
    public CommunityPreferred(){
        }  
    }  
     
    //init data
    @AuraEnabled
    public static string getInitData(Id trialId,Id siteId, String mode, String btnFilter, String userMode, String delegateId){
        
        
        InitData initData = new InitData();
        initData.paginationData = new PaginationData();
        initData.moFilterData = MediaOutreachServices.getMOFilterData(trialId, mode, true, delegateId);
        
        initData.moFilter = new MediaOutreachServices.moFilter(initData.moFilterData);
        
        initData.moFilter.study = trialId;
        
        MediaOutreachServices.moFilter filterCopy = (MediaOutreachServices.moFilter) JSON.deserialize(JSON.serialize(initData.moFilter), MediaOutreachServices.moFilter.class);
        
        List<Media_Outreach__c> mList = MediaOutreachServices.getMediaOutreach(filterCopy, delegateId);
        List<LabelValueItem> trialFilterData = new  List<LabelValueItem>{new LabelValueItem(Label.PG_MRRL_L_All_studies, null)};
            Map<String,Map<String,String>> fieldMap = MediaOutreachServices.FILTER_FIELD_MAP;
        if(!mList.isEmpty()) {
            Map<String, List<LabelValueItem>> filterData = getInterdependentFilterData(mList, fieldMap);
            trialFilterData.addAll(filterData.get(MediaOutreachServices.STUDIES_FILTER_DATA_FIELD));
            
        }
        
        try{
        initData.currentPageList = mList;
        initData.clinicalList = checkMediaProvider();
        initData.moFilterData.studies = trialFilterData;
        return JSON.serialize(initData);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
        @AuraEnabled
      public static List<Clinical_Trial_Profile__c> checkMediaProvider() {
        Integer limitRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
        Id studyContactId;
        List<Clinical_Trial_Profile__c> clinicalTrialLst = new List<Clinical_Trial_Profile__c>(); 
        List<Study_Site__c> studylst = new List<Study_Site__c>(); 
        List<Site_Staff__c> siteStaff = new List<Site_Staff__c>();
        Contact con;
        set<Id> ctpIds = new set<Id>();
        Contact userContact = CommunityService.getUserContact();
        
        studyContactId = userContact.Id;
        system.System.debug('studyContactId??'+studyContactId);
        con =[SELECT id,UserCommunityIsDelegate__c FROM Contact WHERE Id =:studyContactId LIMIT 1];
       
        if(studyContactId != null && con.UserCommunityIsDelegate__c == false){
        studylst =[SELECT id,Name,Clinical_Trial_Profile__r.Media_outreach_Provider__c,Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.Study_Code_Name__c,Principal_Investigator__c FROM Study_Site__c WHERE Principal_Investigator__c =:studyContactId AND Clinical_Trial_Profile__r.Media_outreach_Provider__c != null LIMIT :limitRows];
        }

        if(studyContactId != null && con.UserCommunityIsDelegate__c == true ){
       siteStaff =[SELECT id,Delegate_Level__c,Study_Site__r.Clinical_Trial_Profile__c,Study_Site__r.Clinical_Trial_Profile__r.Media_outreach_Provider__c,Study_Site__c,Site_Contact__c FROM Site_Staff__c where Site_Contact__c =:studyContactId AND Study_Site__r.Clinical_Trial_Profile__r.Media_outreach_Provider__c != null LIMIT :limitRows];
        }

        if(studylst.size()>0){
          for(Study_Site__c st: studylst){
              ctpIds.add(st.Clinical_Trial_Profile__c);
          }
        }
        if(siteStaff.size()>0){
          for(Site_Staff__c ss: siteStaff){
              ctpIds.add(ss.Study_Site__r.Clinical_Trial_Profile__c);
          }
        }
        if(!ctpIds.isEmpty()){
           clinicalTrialLst =[SELECT id,Study_Code_Name__c,Name from Clinical_Trial_Profile__c WHERE Id =:ctpIds LIMIT :limitRows];
        }
        
        return clinicalTrialLst;
        
    }
     @AuraEnabled
    public static string PreferredContactsandNotes(Id studysiteId,Id MediaRecordId) {
      try{  
        Boolean Phone = false;
        Boolean Email = false;
        string studysitephonenumber ='';
        string contactemail ='';
        string UserMailId ='';
        string Newvalue ='';
        Boolean result = false;
        string PreferredContMethod ='';
        string AlternateEmailPhone ='';
       
        
          CommunityPreferred commm = new CommunityPreferred();
          Media_Outreach__c MediaOutreachObj =[select id,Preferred_contact_method__c,Alternate_Email_Phone_Number__c,CreatedById from Media_Outreach__c where id=:MediaRecordId limit 1];
          
          PreferredContMethod=MediaOutreachObj.Preferred_contact_method__c;
          AlternateEmailPhone=MediaOutreachObj.Alternate_Email_Phone_Number__c;
          
           if(string.isNotBlank(PreferredContMethod))
           {
                result=PreferredContMethod.contains('@');
                if(result)
                {
                   Email = true;
                }else{
                   Phone = true;
                }
                if(Phone)
                {
                       commm.MOEmail=false;
                       commm.MOPhone=true;
                       commm.Other=false;
                       if(string.isNotBlank(studysiteId))
                       {
                         studysitephonenumber =[SELECT id,Name,Study_Site_Phone__c from Study_Site__c where Id =:studysiteId LIMIT 1].Study_Site_Phone__c;  
                       }
                         UserMailId = [select id,Email from user where id=:MediaOutreachObj.CreatedById LIMIT 1].Email;
                        
                        if(string.isNotBlank(studysitephonenumber))
                        {
                          commm.MO_Phonenumber=studysitephonenumber;
                        }else{commm.MO_Phonenumber='null';}
                        if(string.isNotBlank(UserMailId))
                        {
                          commm.MO_Email=UserMailId;
                        }else{commm.MO_Email='null';}
                        commm.MO_AlternateValue='';
                }
                if(Email)
                {
                       commm.MOEmail=true;
                       commm.MOPhone=false;
                       commm.Other=false;
                       if(string.isNotBlank(studysiteId))
                       {
                         studysitephonenumber =[SELECT id,Name,Study_Site_Phone__c from Study_Site__c where Id =:studysiteId LIMIT 1].Study_Site_Phone__c;  
                       }
                        
                        if(string.isNotBlank(studysitephonenumber))
                        {
                          commm.MO_Phonenumber=studysitephonenumber;
                        }else{commm.MO_Phonenumber='null';}
                        if(string.isNotBlank(PreferredContMethod))
                        {
                          commm.MO_Email=PreferredContMethod;
                        }else{commm.MO_Email='null';}
                        commm.MO_AlternateValue='';
                }
           }else
           {   
                result=AlternateEmailPhone.contains('@');
                if(result)
                {
                   Email = true;
                }else{
                   Phone = true;
                }
                if(Phone)
                {
                       commm.MOEmail=false;
                       commm.MOPhone=true;
                       commm.Other=true;
                       if(string.isNotBlank(studysiteId))
                       {
                         studysitephonenumber =[SELECT id,Name,Study_Site_Phone__c from Study_Site__c where Id =:studysiteId LIMIT 1].Study_Site_Phone__c;  
                       }
                        
                        UserMailId = [select id,Email from user where id=:MediaOutreachObj.CreatedById LIMIT 1].Email;
                        if(string.isNotBlank(studysitephonenumber))
                        {
                          commm.MO_Phonenumber=studysitephonenumber;
                        }else{commm.MO_Phonenumber='null';}
                        if(string.isNotBlank(UserMailId))
                        {
                          commm.MO_Email=UserMailId;
                        }else{commm.MO_Email='null';}
                        commm.MO_AlternateValue=AlternateEmailPhone;
                }
                if(Email)
                {
                       commm.MOEmail=true;
                       commm.MOPhone=false;
                       commm.Other=true;
                       if(string.isNotBlank(studysiteId))
                       {
                         studysitephonenumber =[SELECT id,Name,Study_Site_Phone__c from Study_Site__c where Id =:studysiteId LIMIT 1].Study_Site_Phone__c;  
                       }
                        
                        UserMailId = [select id,Email from user where id=:MediaOutreachObj.CreatedById LIMIT 1].Email;
                        if(string.isNotBlank(studysitephonenumber))
                        {
                          commm.MO_Phonenumber=studysitephonenumber;
                        }else{commm.MO_Phonenumber='null';}
                        if(string.isNotBlank(UserMailId))
                        {
                          commm.MO_Email=UserMailId;
                        }else{commm.MO_Email='null';}
                        commm.MO_AlternateValue=AlternateEmailPhone;
                }      
              
           }
          
          
            List<ID> cdid = new list<Id>();
            List<ContentDocumentLink> CDLink = new List<ContentDocumentLink>();
            List<string> lstofCN = new list<string>();
            CDLink = [SELECT ContentDocumentId,LinkedEntityId,Visibility FROM ContentDocumentLink WHERE LinkedEntityId =:MediaRecordId];
            for(ContentDocumentLink cd:CDLink)
            {
                cdid.add(cd.ContentDocumentId);
            }
            List<ContentDocument> lstCD = new list<ContentDocument>();
            lstCD =[select id,Title,CreatedDate from ContentDocument where id IN:cdid Order By CreatedDate DESC];
            commm.lstnotes = lstCD; 
            
            
            return JSON.serialize(commm);
      }
          catch(Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
   
    
    
    //To update the existing records 
    @AuraEnabled
    public static void UpdateRecord(Id MediaRecordId,string notes,Boolean Cancelrequest,Boolean updateval,string newval,Boolean other){
        try{
            if(Cancelrequest){
                Media_Outreach__c MediaOutreach = new Media_Outreach__c();
                MediaOutreach.Id=MediaRecordId;
                MediaOutreach.Status__c='Cancelled';
                
                update MediaOutreach;
            }
            
            if(String.isNotBlank(notes)) {
                
 
                ContentNote cnt = new ContentNote();
                cnt.Title = notes;
                insert cnt;
                 
                ContentDocumentLink clnk = new ContentDocumentLink();
                clnk.LinkedEntityId = MediaRecordId;
                clnk.ContentDocumentId = cnt.Id;
                clnk.ShareType = 'V';
                insert clnk; 
            }
            if(updateval)
            {
                if(string.isNotBlank(newval))
                {
                Media_Outreach__c MediaOutreach = new Media_Outreach__c();
                MediaOutreach.Id=MediaRecordId;
                if(other)
                {
                   MediaOutreach.Alternate_Email_Phone_Number__c=newval;
                   MediaOutreach.Preferred_contact_method__c='';
                }else
                {
                   MediaOutreach.Preferred_contact_method__c=newval;
                   MediaOutreach.Alternate_Email_Phone_Number__c='';
                }
                update MediaOutreach;  
                }                
            }
            
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
        
    }
    
    class SearchResult{
        List<Media_Outreach__c> peList;
        PaginationData paginationData;
        public MediaOutreachServices.moFilter moFilter;
        public MediaOutreachServices.moFilterData moFilterData;
    }
    
    //To fetch the records when filter is changed
    @AuraEnabled
    public static String getRecords(Id trialId, String filterJSON, String paginationJSON, String piBtnFilter, String userMode, Boolean studyChanged, String delegateId){
        //Added for getting all the filter options 
        SearchResult result = new SearchResult();
        result.moFilterData = MediaOutreachServices.getMOFilterData(trialId, userMode, true, delegateId);
        
        result.moFilter = new MediaOutreachServices.moFilter(result.moFilterData);
        MediaOutreachServices.moFilter filterCopy = (MediaOutreachServices.moFilter) JSON.deserialize(JSON.serialize(result.moFilter), MediaOutreachServices.moFilter.class);
        
        List<Media_Outreach__c> moList = MediaOutreachServices.getMediaOutreach(filterCopy, delegateId);
        List<LabelValueItem> trialFilterData = new  List<LabelValueItem>{new LabelValueItem(Label.PG_MRRL_L_All_studies, null)};
            if(!moList.isEmpty()) {
                Map<String,Map<String,String>> fieldMap = MediaOutreachServices.FILTER_FIELD_MAP;
                Map<String, List<LabelValueItem>> filterData = getInterdependentFilterData(moList, fieldMap);
                trialFilterData.addAll(filterData.get(MediaOutreachServices.STUDIES_FILTER_DATA_FIELD));
            }
        //
        
        //for the filter results
        MediaOutreachServices.moFilter filter = (MediaOutreachServices.moFilter)JSON.deserialize(filterJSON, MediaOutreachServices.moFilter.class);
        result.moFilterData = MediaOutreachServices.getMOFilterData(filter.study, userMode, true, delegateId);
        
        PaginationData pagination = (PaginationData)JSON.deserialize(paginationJSON, PaginationData.class);
        try {
            result.paginationData = pagination;
            
            
            List<Media_Outreach__c> mList = MediaOutreachServices.getMediaOutreach(filter, delegateId);
            
            result.moFilterData.studies = trialFilterData;
            result.peList = mList;
            result.moFilter = filter;
            return JSON.serialize(result);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    
    
    public static Map<String, List<LabelValueItem>> getInterdependentFilterData(List<SObject> recordsList, Map<String, Map<String, String>> fieldMapping) {
        try {
            Map<String, Map<String, String>> filterData = new Map<String, Map<String, String>>();
            for (SObject obj : recordsList) {
                for (String key : fieldMapping.keySet()) {
                    String fieldLabelValue;
                    String fieldValue;
                    Map<String, String> fields = fieldMapping.get(key);
                    String valueKey = new List<String>(fields.keySet()).get(0);
                    String labelKey = fields.get(valueKey);
                    List<String> fieldsForValues = valueKey.split('\\.');
                    List<String> fieldsForLabels = labelKey.split('\\.');
                    SObject valuesObject = obj;
                    SObject labelObject = obj;
                    for (Integer i = 0, j = fieldsForValues.size(); i < j; i++) {
                        if (i + 1 != j) {
                            valuesObject = valuesObject.getSObject(fieldsForValues[i]);
                        } else {
                            fieldValue = String.valueOf(valuesObject.get(fieldsForValues[i]));
                        }
                    }
                    for (Integer x = 0, y = fieldsForLabels.size(); x < y; x++) {
                        if (x + 1 != y) {
                            labelObject = labelObject.getSObject(fieldsForLabels[x]);
                        } else {
                            fieldLabelValue = String.valueOf(labelObject.get(fieldsForLabels[x]));
                        }
                    }
                    if (filterData.containsKey(key)) {
                        filterData.get(key).put(fieldValue, fieldLabelValue);
                    } else {
                        filterData.put(key, new Map<String, String>{
                            fieldValue => fieldLabelValue
                                });
                    }
                }
            }
            Map<String, List<LabelValueItem>> finalfilterData = new Map<String, List<LabelValueItem>>();
            for (String key : filterData.keySet()) {
                Map<String, String> data = filterData.get(key);
                List<LabelValueItem> dataItems = new List<LabelValueItem>();
                for (String dataKey : data.keySet()) {
                    dataItems.add(new LabelValueItem(data.get(dataKey), dataKey));
                }
                finalfilterData.put(key, dataItems);
            }
            return finalfilterData;
        } catch (Exception e) {
            return (Map<String, List<LabelValueItem>>) AuraHelper.throwException(e);
        }
    }
    
}