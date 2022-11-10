public without sharing class PIR_BulkActionController {
    
    //Added for Bulk Action- Invite to PP
   @AuraEnabled
   public static void createUserForPatientProtal(List<string> peId, Boolean sendEmails) {
       try {
           List<Participant_Enrollment__c> per = [SELECT Id,
                                                  Participant_Contact__c,
                                                  Participant_Contact__r.Is_Patient_User_Created__c,
                                                  PI_Contact__c,Invited_To_PP_Date__c, 
                                                  HCP_Contact__c,HCP_Contact_HCPEnroll__c,
                                                  Clinical_Trial_Profile__r.CommunityTemplate__c 
                                                  FROM Participant_Enrollment__c 
                                                  WHERE ID IN:peId];
           
           List<Contact> lstContact = new List<Contact>();
           string communityTemplatename='';
           List<User> returnUsers = new List<User>();
           Map<Id, Id> createUsersMap = new Map<Id, Id>();
           Boolean isUpdatePE = false;
           
           for(Participant_Enrollment__c pe: per){
               if (sendEmails) {
                   Contact con = new Contact(id =pe.Participant_Contact__c,Consent_To_Inform_About_Study__c = true);
                   lstContact.add(con);           
               }
               if(communityTemplatename!=null){
                   communityTemplatename = pe.Clinical_Trial_Profile__r.CommunityTemplate__c;
               }
               if(pe.Participant_Contact__r.Is_Patient_User_Created__c == false){
                   if (pe.HCP_Contact__c == null) {
                       createUsersMap.put(pe.Participant_Contact__c,pe.PI_Contact__c);
                   }else{
                       createUsersMap.put(pe.Participant_Contact__c,pe.HCP_Contact_HCPEnroll__c);
                   }
               }
               if(pe.Invited_To_PP_Date__c == null){
                   pe.Invited_To_PP_Date__c = DateTime.now();
                   isUpdatePE = true;
               }
           }
           
           if(!lstContact.isEmpty()){
               update lstContact;
           }

           TriggerHandlerExecutor.bypassHandler(
               ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class
           );
           TriggerHandlerExecutor.bypassHandler(
               ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
           );
           TriggerHandlerExecutor.bypassHandler(
               PENotificationTriggerHandler.SendEmailIfSSWasChanged.class
           );
           TriggerHandlerExecutor.bypassHandler(
               ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
           );
           TriggerHandlerExecutor.bypassHandler(
               ParticipantEnrollmentTriggerHandler.UnenrollorCancelPer.class
           );
           TriggerHandlerExecutor.bypassHandler(
               ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
           );
           if(isUpdatePE){
               update per;
           }
           Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
           String permissionSetName = CommunityTemplateService.getTemplate(communityTemplatename).permissionSet; 
           
           if (!createUsersMap.isEmpty() && !Test.isRunningTest() ){
               ((CommunityService) ClassFactory.newInstance(CommunityService.class))
               .createParticipantUsersBulk(createUsersMap);
           }
           
           
           for(Participant_Enrollment__c p: per)
           { 
               actionAssignContactPermissions.addPermission(
                   p.Participant_Contact__c,
                   permissionSetName
               );
               
           }
           
           if(!actionAssignContactPermissions.isEmpty()) {
               ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
           }     
           
           
       } catch (Exception e) {
           throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
       }
   }

   //for send to SH
   @AuraEnabled
   public static void updateParticipantData(
       List<string> peIdList
   ) {
       try{
           String ReturnMessage;
           List<Participant_Enrollment__c> PEUpdateList = new List<Participant_Enrollment__c>();
           for (Participant_Enrollment__c pe : [
               SELECT Id, Participant_Status__c
               FROM Participant_Enrollment__c
               WHERE Id IN :peIdList
           ]) {
               
               pe.Participant_Status__c = 'Eligibility Passed';
               pe.Participant_Status_Last_Changed_Date__c = DateTime.now();
               PEUpdateList.add(pe);
           }
           TriggerHandlerExecutor.bypassHandler(
               ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class
           );
           TriggerHandlerExecutor.bypassHandler(
               ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
           );
           TriggerHandlerExecutor.bypassHandler(
               ParticipantEnrollmentSHTriggerHandler.UpdateLastChangedAdditionalNotes.class
           );
           TriggerHandlerExecutor.bypassHandler(
               ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
           );
           TriggerHandlerExecutor.bypassHandler(
               ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
           );
           TriggerHandlerExecutor.bypassHandler(
               ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
           );
           TriggerHandlerExecutor.bypassHandler(
               PENotificationTriggerHandler.SendEmailIfSSWasChanged.class
           );
           TriggerHandlerExecutor.bypassHandler(
               ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
           );
           TriggerHandlerExecutor.bypassHandler(
               ParticipantEnrollmentTriggerHandler.UnenrollorCancelPer.class
           );
           TriggerHandlerExecutor.bypassHandler(
               ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
           );
           if (PEUpdateList != null && !PEUpdateList.isEmpty()) {
               update PEUpdateList;
           }
           
       }
       catch (Exception e) {
           throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
       }
   }
   
   public class statusWrapper{
       @AuraEnabled
       public String reason;
       @AuraEnabled
       public Map<String, List<LabelValueItem>> reasonMap;
       @AuraEnabled
       public Map<String, Boolean> notesRequiredMap;
       @AuraEnabled
       public String notes;
       @AuraEnabled
       public Boolean finalConsent;
       @AuraEnabled
       public String Step;
   }
   
   //Added for export selected
   @AuraEnabled
   public static exportWrapper exportSelected(
       List<string> peIdList
   ) {
       try{
           List<Participant_Enrollment__c> PEList = new List<Participant_Enrollment__c>();
     exportWrapper wrap= new exportWrapper();
     PEList=[ 
               SELECT Id, Participant_Status__c,Clinical_Trial_Profile__r.Protocol_ID__c,
               Name,Referral_Source__c,MRN_Id__c,Patient_ID__c,
               Source_Type__c,CreatedDate,Participant__c,Participant__r.First_Name__c,
               Participant__r.Last_Name__c,Participant__r.Email__c,
               Participant__r.Phone__c,Participant__r.Phone_Type__c,
               Participant__r.Alternative_Phone_Number__c,
               Participant__r.Alternative_Phone_Type__c,
               Participant__r.Gender_Technical__c,
               Participant__r.Age__c,
               Participant__r.Ethnicity__c,
               Comorbidities__c,Participant__r.BMI__c,
               HighRisk_Indicator__c,
               Initial_visit_scheduled_date__c,Initial_visit_scheduled_time__c,
               Clinical_Trial_Profile__r.Initial_Visit_Required__c,
               Clinical_Trial_Profile__r.Promote_to_SH__c,
               Clinical_Trial_Profile__r.Study_Code_Name__c,
               Study_Site__r.Name,PI_Contact__r.Full_Name__c,
               Study_Site__r.Include_PII_on_Export__c,High_Priority__c,
               Last_Status_Changed_Notes__c,Participant_Status_Last_Changed_Date__c,
               Screening_Date__c,Non_Enrollment_Reason__c,
               Referral_Completedby_Name__c,Referred_Date__c,
               (SELECT Id, Completed_by__r.Name, Completed_Date__c, Status__c 
               FROM Participant_PrescreenerResponses__r 
               WHERE (MRR__c = true OR MRR_EPR__c = true) ORDER BY Completed_Date__c DESC LIMIT 1)
               FROM Participant_Enrollment__c
               WHERE Id IN :peIdList
           ];
           
           wrap.partList=PEList;
           return wrap;
       }
       catch (Exception e) {
           throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
       }
   }
   public class exportWrapper{
       @AuraEnabled
       public List<Participant_Enrollment__c> partList { get; set; }
       
    }
   
   //Added for export all
   @AuraEnabled
   public static CsvWrapper exportAll(
      List<Id> studies,
      List<Id> studySites,
      Integer startPos,
      Integer endPos,
      String sponsorName
   ) {
       try{
           
           if(sponsorName==null){
               sponsorName = UserContext.getCurrentUserMode()
       .template.templateName;
           }
            if (
         (studies == null || studies.isEmpty()) &&
         (studySites == null || studySites.isEmpty())
       ){
         studies = new List<Id>();
         studySites = new List<Id>();
         string janssen = CommunityTemplateService.TEMPLATE_JANSSEN;
         List<Study_Site__c> studySiteList = PIR_HomepageController.getStudySite();
         for (Study_Site__c s : studySiteList) {
           if (sponsorName == janssen) {
             if (
               s.Clinical_Trial_Profile__r.CommunityTemplate__c == sponsorName
             ) {
               studies.add(s.Clinical_Trial_Profile__c);
               studySites.add(s.Id);
             }
           } else {
             if (s.Clinical_Trial_Profile__r.CommunityTemplate__c != janssen) {
               studies.add(s.Clinical_Trial_Profile__c);
               studySites.add(s.Id);
             }
           }
         }
       }
           CsvWrapper wrap = new CsvWrapper();
       List<Participant_Enrollment__c> lstPER = new List<Participant_Enrollment__c>();
       List<Participant_Enrollment__c> lstPERs = new List<Participant_Enrollment__c>();
       String qCountString = 'SELECT COUNT() FROM Participant_Enrollment__c WHERE ';
       String queryString =
           'SELECT Id,Name,PI_Contact__c,PI_Contact__r.Full_Name__c,Non_Enrollment_Reason__c,Referral_Completedby_Name__c,PerCounter__c,Referred_Date__c,Study_Name__c,Participant_Status_Last_Changed_Date__c,Last_Status_Changed_Notes__c,Referral_Completed_by__c,Participant_Name__c,Participant_Contact__c,Referral_Source__c,MRN_Id__c,Patient_ID__c,Referral_ID__c,Study_Hub_Log__c,Study_Hub_Log__r.Response_Status_Code__c,' +
           'Participant__r.Full_Name__c,Participant__r.First_Name__c,Participant__r.Last_Name__c,Participant__r.Age__c,Participant__r.Gender_Technical__c,Participant__r.BMI__c,Study_Site__c,Study_Site__r.Name,Study_Site__r.Include_PII_on_Export__c,Clinical_Trial_Profile__c,' +
           'Clinical_Trial_Profile__r.Study_Code_Name__c,Study_Site__r.Study_Site_Type__c, Participant__r.Phone__c,Participant__r.Phone_Type__c,Participant__r.Alternative_Phone_Number__c,Participant__r.Alternative_Phone_Type__c,High_Priority__c,Clinical_Trial_Profile__r.Protocol_ID__c,Clinical_Trial_Profile__r.Promote_to_SH__c,Participant__r.Ethnicity__c,' +
           'Source_Type__c,Participant_Status__c,HighRisk_Indicator__c,CreatedDate,Referral_Source_ID__c,' +
           'Initial_visit_scheduled_flag__c,Initial_visit_scheduled_date__c,Initial_visit_scheduled_time__c,Comorbidities__c, '
           + '(SELECT Id, Completed_by__r.Name, Completed_Date__c, Status__c FROM Participant_PrescreenerResponses__r WHERE MRR__c = true OR MRR_EPR__c = true ORDER BY Completed_Date__c DESC LIMIT 1) '
           + ' FROM Participant_Enrollment__c WHERE ';

       String filter = '';
       filter =
           filter + ' Clinical_Trial_Profile__c IN : studies AND Study_Site__c IN : studySites ';
       String addCondition = '  AND Participant_Status__c  IN (\'Received\',\'Pre-review Passed\',\'In Wash Out Period\',\'Successfully Contacted\',\'Contact Attempted\',\'Eligibility Passed\',\'Screening Passed\',\'Screening In Progress\',\'Screening In Progress - Wash Out Period\',\'Ready to Screen\',\'Enrollment Success\',\'Randomization Success\',\'Pre-review Failed\',\'Unable to Reach\',\'Contacted - Not Suitable\',\'Eligibility Failed\',\'Declined Consent\',\'Unable to Screen\',\'Withdrew Consent\',\'Screening Failed\', \'Withdrew Consent After Screening\', \'Enrollment Failed\', \'Randomization Failed\', \'Participant No Show\', \'Successfully re-engaged\')';
       filter = filter + addCondition;
       String queryCount = qCountString + filter;
       String strTemp = ' AND PerCounter__c >= :startPos ' + ' AND PerCounter__c <= :endPos ';
       filter = filter + strTemp;
       String sortBy = ' ORDER BY ';
       sortBy += ' Name ASC';
       String OffsetLimit = ' LIMIT 49500';
       String Query = queryString + filter + sortBy + OffsetLimit;
       lstPER = Database.query(Query);
       Integer totalCount = Database.countQuery(queryCount);
         
       wrap.partList = lstPER;
       wrap.startPos = startPos;
       wrap.endPos = endPos;
       wrap.totalCount = totalCount;
       wrap.studies=studies;
       wrap.studySites=studySites;
       wrap.sponsorName=sponsorName;
       return wrap;

       }
       catch (Exception e) {
           throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
       }
   }
   public class CsvWrapper {
       @AuraEnabled
       public List<Participant_Enrollment__c> partList { get; set; }
       @AuraEnabled
       public List<Id> studies { get; set; }
       @AuraEnabled
       public List<Id> studySites { get; set; }
       @AuraEnabled
       public Integer startPos { get; set; }
       @AuraEnabled
       public Integer endPos { get; set; }
       @AuraEnabled
       public Integer totalCount { get; set; }
       @AuraEnabled
       public String sponsorName { get; set; }
      }
   @AuraEnabled
   public static PeDataTableWrapper fetchData(String bulkAction, List<Id> siteIdlist, string statusChangeto) {
       try {
          
           List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
     string filter = '';
           List<WrapPageWithSelection> wpws = new List<WrapPageWithSelection>();
           List<Promote_to_SH__mdt> pshList = new List<Promote_to_SH__mdt>();
           List<String> lstSourceType = new List<String>();
           List<String> lstActiveStatus = new List<String>();
           List<String> lstInactiveStatus = new List<String>();
           List<String> pshStatus = new List<String>();
           List<Study_Site__c> Studysites = new List<Study_Site__c>();
           List<Id> siteIds = new List<Id>();
           List<String> lstActive = new List<String>();
           List<String> lstinActive = new List<String>();

           Boolean isChekedSelected = false;
           Boolean isLocked = false;
           Boolean PromotetoSH = false;
           List<Boolean> PeChecklist = new List<Boolean>();
           //set<id> OrgSelectedIds = new Set<id>(FilterList[0].SelectedIds);
           //OrgSelectedIds=FilterList[0].SelectedIds;
           //Integer pSize = (Integer) FilterList[0].pageSize;
           //Integer pNumber = (Integer) FilterList[0].pageNumber;
           String participantStatus;

           //Integer offset = (pNumber - 1) * pSize;
           //Integer recordEnd = pSize * pNumber;
       String qCountString = 'SELECT COUNT() FROM Participant_Enrollment__c WHERE';
           String queryString =
               'SELECT Id,Name,PerCounter__c,Initial_visit_scheduled_time__c,Participant_Name__c,Participant_Contact__c,Referral_Source__c,MRN_Id__c,Patient_ID__c,Referral_ID__c,Participant_ID_randomized_ID__c,Screening_ID__c,Study_Hub_Log__c,Study_Hub_Log__r.Response_Status_Code__c,' +
               'Participant__r.Full_Name__c,Participant__r.Age__c,Participant__r.Gender_Technical__c,Participant__r.BMI__c,Study_Site__c,Study_Site__r.Name,Clinical_Trial_Profile__c,Participant__r.Adult__c,Participant__r.Marketing_Flag__c,Study_Site__r.Study_Site_Type__c,Permit_IQVIA_to_contact_about_study__c,Participant__r.IsCountry_NOT_Eligible_for_Emails__c,Clinical_Trial_Profile__r.CommunityTemplate__c,Study_Site__r.Suppress_Participant_Emails__c,Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,' +
               'Clinical_Trial_Profile__r.Study_Code_Name__c,Clinical_Trial_Profile__r.Initial_Visit_Required__c,Clinical_Trial_Profile__r.Promote_to_SH__c,Clinical_Trial_Profile__r.Protocol_ID__c,Participant__r.Ethnicity__c,' +
               'Source_Type__c,Participant_Status__c,HighRisk_Indicator__c,CreatedDate,Referral_Source_ID__c, Participant__r.First_Name__c, Participant__r.Last_Name__c, Participant__r.Email__c, Participant__r.Phone__c, Participant__r.Phone_Type__c, Participant__r.Alternative_Phone_Number__c, Participant__r.Alternative_Phone_Type__c,' +
               'Initial_visit_scheduled_flag__c,Initial_visit_scheduled_date__c,High_Priority__c,Comorbidities__c,(SELECT Id FROM Participant_Enrollment_Status_History__r WHERE Status__c =\'Eligibility Passed\' ORDER BY CreatedDate DESC LIMIT 1) FROM Participant_Enrollment__c WHERE  ';

           String sortBy = ' ORDER BY ';
           
               sortBy += ' Name ASC';
           

          
           
                   lstActive.add('Received');
                   lstActive.add('Pre-review Passed');
                   lstActive.add('Contact Attempted');
                   lstActive.add('Successfully Contacted');
                   lstActive.add('Screening In Progress');
                   lstActive.add('Screening In Progress - Wash Out Period');
                   lstActive.add('Screening Passed');
                   lstActive.add('Enrollment Success');
                   lstActive.add('Eligibility Passed');
                   lstActive.add('Ready to Screen');
                   lstActive.add('Randomization Success');
                
                   lstActive.add('Pre-review Failed');
                   lstActive.add('Unable to Reach');
                   lstActive.add('Contacted - Not Suitable');
                   lstActive.add('Eligibility Failed');
                   lstActive.add('Declined Consent');
                   lstActive.add('Unable to Screen');
                   lstActive.add('Withdrew Consent');
                   lstActive.add('Screening Failed');
                   lstActive.add('Withdrew Consent After Screening');
                   lstActive.add('Enrollment Failed');
                   lstActive.add('Randomization Failed');
                   lstActive.add('Declined Final Consent');
         filter += ' AND Participant_Status__c  IN: lstActive ';

                  
            
              
               filter += ' AND Study_Site__c IN: siteIds ';
           
                    
           
           
           
           
           String Query = queryString + filter + sortBy ;
           peList = Database.query(Query);
     
           
           pshList = [SELECT DeveloperName, status__c FROM Promote_to_SH__mdt];
           for (Promote_to_SH__mdt psl : pshList) {
               pshStatus.add(psl.status__c);
           }
           
           Boolean studySitePSH = false;
           Decimal pshLimit;
           pshLimit = [SELECT DeveloperName, Limit__c FROM Promote_to_SH_Limit__mdt LIMIT 1]
           .Limit__c;
           for (Participant_Enrollment__c pe : peList) {
               
                   //PeChecklist.add(false);
                   Boolean allowedForSH = ifAllowedForSH(pe,pshStatus);    
                       studySitePSH = ifAllowedForSH(pe,pshStatus); 
                       if (allowedForSH)  {
                       isChekedSelected = false;
                       isLocked = false;
                       
                   } else {
                       isChekedSelected = false;
                      if(bulkAction != Null && bulkAction == 'Invite to Patient Portal'){
                             isLocked = false;
                            }else if(bulkAction != Null && bulkAction == 'Change Participant Status'){ 
                               if((statusChangeto =='Randomization Success' || statusChangeto =='Enrollment Success' )&& pe.Screening_ID__c  ==null){
                               isLocked = true;
                              }else
                              {isLocked = false;}
                            }else{
                                isLocked = true;
                            }
                       
                   }
               
               

               String Ethnicity = '';
               if (pe.Participant__r.Ethnicity__c != null) {
                   Ethnicity = pe.Participant__r.Ethnicity__c;
                   List<String> lstString = Ethnicity.split(';');
                   string EC = '';
                   for (string s : lstString) {
                       EC += +s.left(1) + ',';
                   }
                   EC = +EC.removeEnd(',');
                   Ethnicity = EC;
               }
               String initialVisitScheduleTime = String.ValueOf(
                   pe.Initial_visit_scheduled_time__c
               );
               if (initialVisitScheduleTime != '' && initialVisitScheduleTime != null) {
                   initialVisitScheduleTime = initialVisitScheduleTime.replace('.000Z', '');
               }
               //REF-3288- Start
               if(pe.Participant_Status__c== 'Eligibility Passed' && 
                  (pe.Clinical_Trial_Profile__r.Initial_Visit_Required__c == true || pe.Clinical_Trial_Profile__r.Promote_to_SH__c  == true)){
                   pe.Participant_Status__c = 'Sent to Study Hub';
                  }else if(pe.Participant_Status__c== 'Eligibility Passed'){
                      pe.Participant_Status__c= 'Eligibility Passed';
                  }
               //REF-3288- End
               wpws.add(
                   new WrapPageWithSelection(
                       pe,
                       isChekedSelected,
                       isLocked,
                       Ethnicity,
                       initialVisitScheduleTime
                   )
               );
               PromotetoSH = pe.Clinical_Trial_Profile__r.Promote_to_SH__c;
           }
            PeDataTableWrapper objDT = new PeDataTableWrapper();
           objDT.bulkStatusUpdate = false;
           
           //objDT.isChecked =PeChecklist;
           objDT.IsPromoteToSH = PromotetoSH;
           objDT.enableSH = PromotetoSH && studySitePSH ? true : false;
           //objDT.OrginalidSelected = OrgSelectedIds;
           //objDT.FilterImpacts = wpws;
           objDT.IsPromoteToSHLimit = pshLimit;
           //objDT.retainFilter = FilterList[0];

           return objDT;
       } 
   catch (Exception e) {
           throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
       }
   }
  @TestVisible   
   private static Boolean ifAllowedForSH(  
       Participant_Enrollment__c pe,   
       List<String> pshStatus  
   ){  
       return ifAllowedForSH(pe, pshStatus, false);    
   }   
       
   public static Boolean ifAllowedForSH(   
       Participant_Enrollment__c pe,   
       List<String> pshStatus,Boolean eligibilityStatusPresent 
   ){  
       Boolean isAllowedForSH = false; 
       if(pe!=null){
       Boolean logNotPresentOrFailed = (pe.Study_Hub_Log__c == null    
                                       || (pe.Study_Hub_Log__c != null &&  
                                       pe.Study_Hub_Log__r.Response_Status_Code__c != 201));   
       Boolean eligibilyPassedStatusPresent = (eligibilityStatusPresent== true)?true:pe.Participant_Enrollment_Status_History__r!=null &&  
           !pe.Participant_Enrollment_Status_History__r.isEmpty(); 

       if(pe.Clinical_Trial_Profile__r.Promote_to_SH__c == true && (pe.Study_Site__r.Study_Site_Type__c == 'Hybrid' || pe.Study_Site__r.Study_Site_Type__c == 'Virtual') && pshStatus.contains(pe.Participant_Status__c)         
          && ((pe.Participant_Status__c!='Eligibility Passed' && !eligibilyPassedStatusPresent) || 
              (pe.Participant_Status__c!='Eligibility Passed' && eligibilyPassedStatusPresent && logNotPresentOrFailed))){ 
                  isAllowedForSH = true;   
              }    
       }
       return isAllowedForSH;  
   }
 public class ListWrapper {
       @AuraEnabled
       public String Status { get; set; }
       @AuraEnabled
       public String Study { get; set; }
       @AuraEnabled
       public String StudySites { get; set; }
       @AuraEnabled
       public String Source { get; set; }
       @AuraEnabled
       public String Sortby { get; set; }
       @AuraEnabled
       public String ParticipantStatus { get; set; }
       @AuraEnabled
       public String isHighRiskOccupation { get; set; }
       @AuraEnabled
       public String isComorbidities { get; set; }
       @AuraEnabled
       public String isInitialVisitScheduled { get; set; }
       @AuraEnabled
       public String AgeFrom { get; set; }
       @AuraEnabled
       public String AgeTo { get; set; }
       @AuraEnabled
       public String Ethnicity { get; set; }
       @AuraEnabled
       public String Sex { get; set; }
       @AuraEnabled
       public Decimal pageNumber { get; set; }
       @AuraEnabled
       public Decimal pageSize { get; set; }
       @AuraEnabled
       public List<id> SelectedIds { get; set; }
       @AuraEnabled
       public List<id> DeselectedIds { get; set; }
       @AuraEnabled
       public List<id> highPrioritySelected_YesIds { get; set; }
       @AuraEnabled
       public List<id> highPrioritySelected_NoIds { get; set; }
       @AuraEnabled
       public String isExport { get; set; }
       @AuraEnabled
       public Integer startPos { get; set; }
       @AuraEnabled
       public Integer endPos { get; set; }
       @AuraEnabled
       public Integer perRecordCount { get; set; }
   }

   public class PeDataTableWrapper {

       @AuraEnabled
       public Integer pageSize { get; set; }
       @AuraEnabled
       public Integer pageNumber { get; set; }
       @AuraEnabled
       public Integer totalRecords { get; set; }
       @AuraEnabled
       public Integer recordStart { get; set; }
       @AuraEnabled
       public Integer recordEnd { get; set; }
       @AuraEnabled
       public List<Boolean> isChecked { get; set; }
       @AuraEnabled
       public Boolean IsPromoteToSH { get; set; }
       @AuraEnabled
       public set<id> OrginalidSelected { get; set; }
       @AuraEnabled
       public List<WrapPageWithSelection> FilterImpacts { get; set; }
       @AuraEnabled
       public Decimal IsPromoteToSHLimit { get; set; }
       @AuraEnabled
       public ListWrapper retainFilter { get; set; }
       @AuraEnabled
       public Boolean enableSH { get; set; }
       @AuraEnabled
       public Boolean enablePP { get; set; }
       @AuraEnabled
       public Boolean bulkStatusUpdate { get; set; }
   }
 public class WrapPageWithSelection {
       @AuraEnabled
       public Participant_Enrollment__c pe { get; set; }
       @AuraEnabled
       public String initialVisitScheduleTime { get; set; }
       @AuraEnabled
       public Boolean isCheckedlatest { get; set; }
       @AuraEnabled
       public Boolean selectionlock { get; set; }
       @AuraEnabled
       public String priorityReferral { get; set; }
       @AuraEnabled
       public String Ethnicity { get; set; }
       public WrapPageWithSelection(
           Participant_Enrollment__c pe,
           Boolean isCheckedlatest,
           Boolean selectionlock,
           String Ethnicity,
           String initialVisitScheduleTime
       ) {
           this.pe = pe;
           this.isCheckedlatest = isCheckedlatest;
           this.selectionlock = selectionlock;
           this.Ethnicity = Ethnicity;
           this.initialVisitScheduleTime = initialVisitScheduleTime;
       }
   }


}