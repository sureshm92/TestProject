public without sharing class PIR_BulkImportController {
    public static Set<Id> OldMapdata=new Set<id>();
   public class StudyStudySiteWrapper {
     @AuraEnabled
     public Map<String, Id> ctpMap;
     @AuraEnabled
     public Map<Id, List<Study_Site__c>> studySiteMap;
     @AuraEnabled
     public List<Id> ctpNoAccess;
     @AuraEnabled
     public Map<Id, String> siteAccessLevels;
     @AuraEnabled
     public Map<Id, Boolean> studyToPrmoteDCT;
     @AuraEnabled
     public Map<Id, String> studyToFinalStep;
   }
   @AuraEnabled(cacheable=true)
   public static StudyStudySiteWrapper getStudyStudySiteDetails() {
     StudyStudySiteWrapper sswrap = new StudyStudySiteWrapper();
     try {
       String sponsorName = UserContext.getCurrentUserMode()
         .template.templateName;
       String janssen = CommunityTemplateService.TEMPLATE_JANSSEN;
       List<Study_Site__c> studySiteList = getStudySiteDetails();
 
       Map<String, Id> studyMap = new Map<String, Id>();
       Map<Id, List<Study_Site__c>> studySiteMap = new Map<Id, List<Study_Site__c>>();
       for (Study_Site__c s : studySiteList) {
         if (sponsorName == janssen) {
           if (s.Clinical_Trial_Profile__r.CommunityTemplate__c == sponsorName) {
             studyMap.put(
               s.Clinical_Trial_Profile__r.Study_Code_Name__c,
               s.Clinical_Trial_Profile__r.Id
             );
             if (!studySiteMap.containsKey(s.Clinical_Trial_Profile__r.Id)) {
               List<Study_Site__c> stList = new List<Study_Site__c>();
               stList.add(s);
               studySiteMap.put(s.Clinical_Trial_Profile__r.Id, stList);
             } else {
               List<Study_Site__c> stList = studySiteMap.get(
                 s.Clinical_Trial_Profile__r.Id
               );
               stList.add(s);
               studySiteMap.put(s.Clinical_Trial_Profile__r.Id, stList);
             }
           }
         } else {
           if (s.Clinical_Trial_Profile__r.CommunityTemplate__c != janssen) {
             studyMap.put(
               s.Clinical_Trial_Profile__r.Study_Code_Name__c,
               s.Clinical_Trial_Profile__r.Id
             );
             if (!studySiteMap.containsKey(s.Clinical_Trial_Profile__r.Id)) {
               List<Study_Site__c> stList = new List<Study_Site__c>();
               stList.add(s);
               studySiteMap.put(s.Clinical_Trial_Profile__r.Id, stList);
             } else {
               List<Study_Site__c> stList = studySiteMap.get(
                 s.Clinical_Trial_Profile__r.Id
               );
               stList.add(s);
               studySiteMap.put(s.Clinical_Trial_Profile__r.Id, stList);
             }
           }
         }
       }
       Map<Id, String> piStudiesAccessLevel = new Map<Id, String>();
       List<Site_Staff__c> piStaffs = [
         SELECT
           Id,
           Study_Site__c,
           Study_Site__r.Principal_Investigator__c,
           Study_Site__r.Clinical_Trial_Profile__c,
           Delegate_Level__c,
           clinical_Trial_Profile__c,
           Site_Contact__c,
           is_Invited__c
         FROM Site_Staff__c
         WHERE
           (Site_Contact__c = :CommunityService.getUserContact().Id
           OR Study_Site__r.Principal_Investigator__c = :CommunityService.getUserContact()
             .Id)
           AND is_Invited__c = TRUE
       ];
       for (Site_Staff__c siteStaff : piStaffs) {
         if (siteStaff.Site_Contact__c == CommunityService.getUserContact().Id) {
           piStudiesAccessLevel.put(
             siteStaff.Study_Site__c,
             siteStaff.Delegate_Level__c
           );
         }
       }
       sswrap.siteAccessLevels = piStudiesAccessLevel;
       sswrap.ctpMap = studyMap;
       sswrap.studySiteMap = studySiteMap;
       sswrap.ctpNoAccess = getStudyAccess(studySiteMap.keyset());
       return sswrap;
     } catch (Exception e) {
       throw new AuraHandledException(e.getMessage());
     }
   }
 
   public static List<Id> getStudyAccess(Set<Id> ctpIds) {
     List<Clinical_Trial_Profile__c> ctp = new List<Clinical_Trial_Profile__c>();
     map<Id, Id> tc = new Map<Id, Id>();
     map<Id, Id> tcUsr = new Map<Id, Id>();
     List<Id> ctpNoAccess = new List<Id>();
     List<Terms_And_Conditions_Acceptance__c> termsConditions = new List<Terms_And_Conditions_Acceptance__c>();
     ctp = [
       SELECT Id, Terms_And_Conditions_ID__c
       FROM Clinical_Trial_Profile__c
       WHERE Id IN :ctpIds AND Terms_And_Conditions_ID__c != NULL
     ];
     String UserId = UserInfo.getUserId();
     //String UserId = UserContext.getUserId();
     for (Clinical_Trial_Profile__c c : ctp) {
       tc.put(c.Terms_And_Conditions_ID__c, c.Id);
     }
     termsConditions = [
       SELECT Id, Terms_And_Conditions__c, User__c
       FROM Terms_And_Conditions_Acceptance__c
       WHERE User__c = :UserId
     ];
     for (Terms_And_Conditions_Acceptance__c tca : termsConditions) {
       tcUsr.put(tca.Terms_And_Conditions__c, tca.User__c);
     }
     for (Clinical_Trial_Profile__c c : ctp) {
       if (!tcUsr.containsKey(c.Terms_And_Conditions_ID__c)) {
         ctpNoAccess.add(tc.get(c.Terms_And_Conditions_ID__c));
       }
     }
     return ctpNoAccess;
   }
   @AuraEnabled
   public static List<Study_Site__c> getStudySiteDetails() {
     Id piContactId = CommunityService.getUserContact().Id;
     List<String> acceptedSites = new List<String>();
     acceptedSites.add('Accepted');
     acceptedSites.add('Accepted (Admin)');
     List<Study_Site__c> studySiteList = [
       SELECT
         Id,
         Name,
         Site__c,
         Override_PI_Referral_Status__c,
         Site__r.Name,
         Clinical_Trial_Profile__c,
         Clinical_Trial_Profile__r.Study_Code_Name__c,
         Clinical_Trial_Profile__r.CommunityTemplate__c,
         Principal_Investigator__c
       FROM Study_Site__c
       WHERE
         Override_PI_Referral_Status__c IN :acceptedSites
         AND (Principal_Investigator__c = :piContactId
         OR ID IN :DelegateService.getDelegatedStudySiteIds())
     ];
 
     return studySiteList;
   }
 
   
   // Main method to get all records
   @AuraEnabled
   public static bulkImportHistoryWrapper getBulkImportHistoryCompleted(List<String> getStudySite, Integer pageNumber){
       List<Bulk_Import_History__c> bulkHistoryDataCompleted=new List<Bulk_Import_History__c>();
       Set<String> studies = new Set<String>();
       Set<String> sites = new Set<String>();
       
       bulkImportHistoryWrapper wrap= new bulkImportHistoryWrapper();
         List<Site_Staff__c> getAccess=new List<Site_Staff__c>();
       List<id> getAllSiteStaff=new List<id>();
       String getUserContact=UserContext.getUserContactId();
               
       String filterString;
       
       
       String sponsorName = UserContext.getCurrentUserMode().template.templateName;
       String janssen = CommunityTemplateService.TEMPLATE_JANSSEN;
       
       if(getStudySite==null|| getStudySite.isEmpty()){
           List<Study_Site__c> studySiteList = PIR_HomepageController.getStudySite();
           for (Study_Site__c s : studySiteList) {
               if (sponsorName == janssen) {
                   if (s.Clinical_Trial_Profile__r.CommunityTemplate__c == sponsorName) {
                       studies.add(s.Clinical_Trial_Profile__c);
                       sites.add(s.Id);
                   }
               } else {
                   if (s.Clinical_Trial_Profile__r.CommunityTemplate__c != janssen) {
                       studies.add(s.Clinical_Trial_Profile__c);
                       sites.add(s.Id);
                   }
               }
           }
           filterString=' AND Study_Site__c in: sites';
           getAccess=[select id, Study_Site__c,Delegate_Level__c, Site_Contact__c,Study_Site__r.Principal_Investigator__c 
                      from Site_Staff__c
                     where Study_Site__c in: sites and Delegate_Level__c=:'Level 1' ];
       }
       
       else{
           filterString=' AND Study_Site__c in: getStudySite';
           getAccess=[select id, Study_Site__c,Delegate_Level__c,Site_Contact__c, Study_Site__r.Principal_Investigator__c 
                      from Site_Staff__c
                     where Study_Site__c in: getStudySite and Delegate_Level__c=:'Level 1' ];
       }
       
       if(!getAccess.isEmpty()){
        for(Site_Staff__c s:getAccess){
            getAllSiteStaff.add(s.Study_Site__r.Principal_Investigator__c );
            getAllSiteStaff.add(s.Site_Contact__c );
        }
    }
    else{
        getAllSiteStaff.add(getUserContact);
    }
       
       
       String queryString =
           'SELECT ' +
           'Id,' +
           'File_Name__c,' +
           'Import_Status__c,' +
           'Import_Type__c,' +
           'Initial_Total_Records__c,' +
           'Study_Site__c,' +
           'Uploaded_By__c,' +
           'Accepted_Records__c,' +
           'Rejected_Records__c,' +
           'CreatedDate,' +
           'Download_URL__c,'+
           'Uploaded_By__r.Full_Name__c ' + 
           ' FROM Bulk_Import_History__c WHERE '+
           'Uploaded_By__c in :getAllSiteStaff '+
           'AND Import_Status__c = \'Completed\'';

       String qCountString = 'SELECT COUNT() FROM Bulk_Import_History__c WHERE Uploaded_By__c in :getAllSiteStaff AND Import_Status__c = \'Completed\'';

       
       Integer offsetLimit = (pageNumber - 1) * 10;
       String orderByString = ' ORDER BY CreatedDate DESC '+ 'LIMIT 10 ' + ' OFFSET :offsetLimit ';
       
       queryString=queryString+filterString+orderByString;
       
       bulkHistoryDataCompleted = Database.query(queryString);
       qCountString=qCountString+filterString;
       //SendEmailDebug.sendEmail('qCountString#####'+qCountString);
       Integer totalCount = Database.countQuery(qCountString);
       //SendEmailDebug.sendEmail('totalCount#####'+totalCount);
       wrap.totalCount=totalCount;
       wrap.bulkHistoryDataCompleted=bulkHistoryDataCompleted;
    
       return wrap;
   }
      @auraEnabled
   public static void getShowInstructValue(boolean flag)
   {
       Contact cnt = new Contact();
       cnt.id = [Select contactId from user where Id =: userInfo.getUserId()].contactId;
       cnt.Not_Show_Bulk_Instruction__c = flag;
       update cnt;
   }
   public class bulkImportHistoryWrapper{
       @AuraEnabled
       public Integer totalCount;
       @AuraEnabled
       public List<Bulk_Import_History__c> bulkHistoryDataCompleted;
       @AuraEnabled
       public List<Bulk_Import_History__c> bulkHistoryData;
       @AuraEnabled
       public List<Bulk_Import_History__c> bulkHistoryDataInProgress;
       @AuraEnabled
       public Boolean showInstructions;
       
       
   }
   @AuraEnabled
   public static List<Bulk_Import_History__c> getBulkImportHistoryInProgress(List<String> getStudySite){
       List<Bulk_Import_History__c> bulkHistoryDataInProgress=new List<Bulk_Import_History__c>();
       Set<String> studies = new Set<String>();
       Set<String> sites = new Set<String>();
       List<Site_Staff__c> getAccess=new List<Site_Staff__c>();
       List<id> getAllSiteStaff=new List<id>();
       
       String getUserContact=UserContext.getUserContactId();
       
       
       String filterString;
       
       
       String sponsorName = UserContext.getCurrentUserMode().template.templateName;
       String janssen = CommunityTemplateService.TEMPLATE_JANSSEN;
       
       if(getStudySite==null|| getStudySite.isEmpty()){
           List<Study_Site__c> studySiteList = PIR_HomepageController.getStudySite();
           for (Study_Site__c s : studySiteList) {
               if (sponsorName == janssen) {
                   if (s.Clinical_Trial_Profile__r.CommunityTemplate__c == sponsorName) {
                       studies.add(s.Clinical_Trial_Profile__c);
                       sites.add(s.Id);
                   }
               } else {
                   if (s.Clinical_Trial_Profile__r.CommunityTemplate__c != janssen) {
                       studies.add(s.Clinical_Trial_Profile__c);
                       sites.add(s.Id);
                   }
               }
           }
           filterString=' AND Study_Site__c in: sites';
           getAccess=[select id, Study_Site__c,Delegate_Level__c, Site_Contact__c,Study_Site__r.Principal_Investigator__c 
                      from Site_Staff__c
                     where Study_Site__c in: sites and Delegate_Level__c=:'Level 1' ];
       }
       
       else{
           filterString=' AND Study_Site__c in: getStudySite';
           getAccess=[select id, Study_Site__c,Delegate_Level__c, Site_Contact__c,Study_Site__r.Principal_Investigator__c 
                      from Site_Staff__c
                     where Study_Site__c in: getStudySite and Delegate_Level__c=:'Level 1' ];
       }
       if(!getAccess.isEmpty()){
        for(Site_Staff__c s:getAccess){
            getAllSiteStaff.add(s.Study_Site__r.Principal_Investigator__c );
            getAllSiteStaff.add(s.Site_Contact__c );
        }
    }
    else{
        getAllSiteStaff.add(getUserContact);
    }
       
        String orderByString = ' ORDER BY CreatedDate DESC ';
       String queryString =
           'SELECT ' +
           'Id,' +
           'File_Name__c,' +
           'Import_Status__c,' +
           'Import_Type__c,' +
           'Initial_Total_Records__c,' +
           'Study_Site__c,' +
           'Uploaded_By__c,' +
           'Accepted_Records__c,' +
           'Rejected_Records__c,' +
           'CreatedDate,' +
           'Download_URL__c,'+
           'Uploaded_By__r.Full_Name__c ' + 
           ' FROM Bulk_Import_History__c WHERE '+
           'Uploaded_By__c in :getAllSiteStaff '+
           'AND Import_Status__c = \'In Progress\'';
       queryString=queryString+filterString+orderByString;
       
       bulkHistoryDataInProgress = Database.query(queryString);
       //SendEmailDebug.sendEmail('qCountString#####'+qCountString);
       for(Bulk_Import_History__c bih: bulkHistoryDataInProgress){
           OldMapdata.add(bih.Id);
       }
       //SendEmailDebug.sendEmail('OldMapdata#####'+OldMapdata);
       
       return bulkHistoryDataInProgress;
   }
     @AuraEnabled
   public static Boolean getInstruction(){
       Boolean showInstructions;
       String getUserContact=UserContext.getUserContactId();
       Contact cnt = [Select Id, Not_Show_Bulk_Instruction__c from Contact where Id =: getUserContact];
       showInstructions=cnt.Not_Show_Bulk_Instruction__c;
          return showInstructions;
   }
  
   
}