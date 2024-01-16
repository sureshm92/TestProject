public without sharing class MedicalHistryTabController {

    public class medicalHistryWrapper{
        @AuraEnabled 
        public Decimal BMI;
        @AuraEnabled 
        public Boolean Comorbidities;
        @AuraEnabled 
        public Boolean HighRisk;
        @AuraEnabled 
        public Boolean Highpriority;
        @AuraEnabled 
        public Boolean isSiteEnabledHumanAPI = false;
        @AuraEnabled  
        public  MedicalHistryTabController.MedicalHistoryWrapper citizenRecords ;  
        @AuraEnabled 
        public Boolean isContainsFile = false;
        @AuraEnabled 
        public Boolean isBiomarkerAvailable = false;
        @AuraEnabled
        public String strHumanAPIreports ; 
        @AuraEnabled 
        public HumanAPIcontroller.ReportListWrapper MedicalreportList;
        @AuraEnabled 
        public List<Participant_Enrollment__History> lstParticipantEnrollmentHstry;
        @AuraEnabled 
        public BioMarkerRecordController.bioMarkerWrapper biomarkerdata;  
        @AuraEnabled 
        public List<BioMarkerRecordController.MediaFileWrapper> lstbioMarkerMediaFiles;  
        @AuraEnabled 
        public List<BioMarkerRecordController.bioMarkerResultWrapper> lstBiomarkerResultWrapper ;  
        @AuraEnabled 
        public String strRequestMedicalReturn ; 
        @AuraEnabled 
        public Boolean booliqviaregistry ; 
        @AuraEnabled 
        public Participant_Enrollment__c selectedPER ; 
        @AuraEnabled 
        public List<Comorbidities__c> lstComorbidities ; 
        @AuraEnabled 
        public List<Comorbidities__c> lstAllComorbidities ; 
        @AuraEnabled 
        public List<Participant_PrescreenerResponse__c> surveyResponses = new List<Participant_PrescreenerResponse__c>(); 
        
    }
    /*Citizen Medical Record Wrapper */
    public class MedicalHistoryWrapper{ 
        @AuraEnabled public List<ContentDocumentAndDelete> attachments;
        @AuraEnabled public String baseURL;
        
        public MedicalHistoryWrapper( List<ContentDocumentAndDelete> attachments, String baseURL){
            this.attachments = attachments;
            this.baseURL = baseURL;
        }
    }

    public class ContentDocumentAndDelete{ 
        @AuraEnabled public ContentDocument attachment;
        @AuraEnabled public Boolean isDeleteAllowed = false;
        @AuraEnabled public Boolean hasPermission = false;
        @AuraEnabled public Boolean isNameReadOnly = true;
        @AuraEnabled public Boolean hasNameError = false;
        @AuraEnabled public Boolean isNameUpdated = false;
        @AuraEnabled public Boolean isFileFromPatientPortal = false;
        @AuraEnabled public String fileNameForEdit = '';
        @AuraEnabled public String FileErrorMsg = '';
        public ContentDocumentAndDelete(ContentDocument attachment, Boolean isDeleteAllowed, Boolean hasPermission,Boolean isNameReadOnly
                                        ,Boolean hasNameError,Boolean isNameUpdated,Boolean isFileFromPatientPortal,String fileNameForEdit,String FileErrorMsg){
            this.attachment = attachment;
            this.isDeleteAllowed = isDeleteAllowed;
            this.hasPermission = hasPermission;
            this.isNameReadOnly = isNameReadOnly;
            this.hasNameError = hasNameError;
            this.isNameUpdated = isNameUpdated;
            this.isFileFromPatientPortal = isFileFromPatientPortal;
            this.fileNameForEdit = fileNameForEdit;
            this.FileErrorMsg = FileErrorMsg;

        }
    }    

    @AuraEnabled
    public static medicalHistryWrapper getPEDetails(String peid){
        
            Boolean isSiteEnabledforHAPI = false;  
            medicalHistryWrapper objWrapper = new medicalHistryWrapper();

            Participant_Enrollment__c objPer = [SELECT ID,Participant__r.BMI__c,Comorbidities__c,HighRisk_Indicator__c,High_Priority__c,Referral_Source__c,Participant__c,Participant_Contact__c
                                                ,Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c,Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,Study_Site__c,Study_Site__r.Medical_Record_Upload__c,Study_Site__r.Study_Site_Type__c,Unique_HumanId__c
                                                from Participant_Enrollment__c where id=:peid] ;

            Id commorbidityRecordType = Schema.SObjectType.Comorbidities__c.getRecordTypeInfosByName().get('Comorbidity').getRecordTypeId();
             objWrapper.selectedPER = objPer ;
            //General Section
            objWrapper.BMI = objPer.Participant__r.BMI__c;
            objWrapper.HighRisk = (String.isNotBlank(objPer.HighRisk_Indicator__c) &&
                                     (objPer.HighRisk_Indicator__c.toLowerCase() == 'yes' ||
                                        objPer.HighRisk_Indicator__c == '1'));
            objWrapper.Highpriority = objPer.High_Priority__c;

            objWrapper.lstComorbidities = getParticipantComorbidities(objPer.Participant__c);

            objWrapper.lstAllComorbidities = [SELECT  ID,Comorbidity_Name__c from Comorbidities__c WHERE recordtypeid =: commorbidityRecordType
                                                and Id NOT IN: objWrapper.lstComorbidities];
            //General Section End

            objWrapper.booliqviaregistry = objPer.Referral_Source__c == 'IQVIA registry' ? true : false;
            
            //Citizen Requirement
            

            List<String> uploadedByContact = new List<String>();
            List<Patient_Delegate_Enrollment__c> pder = [
                SELECT
                    id,
                    Patient_Delegate__r.Contact__c,
                    Participant_Enrollment__r.Participant_Contact__c
                FROM Patient_Delegate_Enrollment__c
                WHERE Participant_Enrollment__c = :objPer.Id AND Primary_Delegate__c = TRUE
                LIMIT 1
            ];
                uploadedByContact.add(objPer.Participant_Contact__c);
            if (!pder.isEmpty()) {
                uploadedByContact.add(pder[0].Patient_Delegate__r.Contact__c);
            }
            List<User> uploadedUser = [
                SELECT id, contactId
                FROM user
                WHERE contactId IN :uploadedByContact
            ];
            List<id> useriDs = new List<id>();
            for (User u : uploadedUser) {
                useriDs.add(u.id);
            }
            

            List<ContentDocumentLink> cdls = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE (LinkedEntityId =:objPer.Participant__c 
                                                OR ( LinkedEntityId = :objPer.Id AND ContentDocument.CreatedById IN :useriDs) )];
            
              

            if(!cdls.isEmpty() ){
                objWrapper.citizenRecords  = getMedicalHistory(cdls,objPer.Participant__c,objPer.Id);
                objWrapper.isContainsFile = true;
            }
             // Human Api Check
            if(objPer.Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c){
             List<Medical_Record_Vendor__c> medicalRecordVendors = MedicalRecordVendorPanelRemote.getVendors(objPer.Study_Site__c);
             for (Medical_Record_Vendor__c item: medicalRecordVendors){
                if(item.Medical_Vendor__c == 'HumanApi'){
                   isSiteEnabledforHAPI = true;
                   break;
                }
            }

                if(isSiteEnabledforHAPI)
                {
                    objWrapper.MedicalreportList = HumanAPIcontroller.getReportList(objPer.Unique_HumanId__c);
                    objWrapper.isSiteEnabledHumanAPI = true;
                   // if(objWrapper.MedicalreportList.reportList == Null)
                   // { 
                        objWrapper.lstParticipantEnrollmentHstry = HumanAPIcontroller.getRequestHistory(objPer.id);
                  //  }
                } 
            }   
           
            //BioMarkerCheck
            objWrapper.biomarkerdata = BioMarkerRecordController.getAssessedDateForPE(objPer.Id);  
            objWrapper.lstbioMarkerMediaFiles = new List<BioMarkerRecordController.MediaFileWrapper>(); 
            if(objWrapper.biomarkerdata.dateTimeLabelValue != Null && !objWrapper.biomarkerdata.dateTimeLabelValue.isEmpty()){
                objWrapper.isBiomarkerAvailable = true;
                if(String.isNotBlank(objWrapper.biomarkerdata.InitialValue)){
                    objWrapper.lstbioMarkerMediaFiles  = BioMarkerRecordController.getRelatedMediaFiles(objPer.Id,objWrapper.biomarkerdata.InitialValue);
                }
            }
            String strParticipantId = objPer.Participant__c;
            if(String.isNotBlank(peid)) {

                String strQuerySurveyResponse = '  SELECT Id, Completed_Date__c, Screener_Response__c, PreScreener_Survey__c, PreScreener_Survey__r.MRR__c,PreScreener_Survey__r.Survey_Name__c ';
                strQuerySurveyResponse += ' ,Participant_enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c,MRR_EPR__c, MRR__c, Prescreener__c FROM Participant_PrescreenerResponse__c ';
                strQuerySurveyResponse += ' WHERE (Participant_enrollment__c = :peid ';
                if(string.isNotBlank(objPer.Participant__c))
                {
                    strQuerySurveyResponse += ' OR Participant__c = :strParticipantId' ;
                }
                strQuerySurveyResponse += ') AND (PreScreener_Survey__c != null OR Participant_enrollment__c != null) ';
                strQuerySurveyResponse += ' ORDER BY Completed_Date__c DESC LIMIT 30000';

                
                 

                objWrapper.surveyResponses =  Database.query(strQuerySurveyResponse);
              
            }
        return  objWrapper;
    }

    @AuraEnabled
    public static List<Comorbidities__c> getParticipantComorbidities(Id PartcipantId){
        try {
             
            return [SELECT ID,Comorbidity_Name__c from Comorbidities__c Where Id IN
                    (SELECT Comorbidities__c FROM Participant_Comorbidities__c Where Participant__c=:PartcipantId) order by Comorbidity_Name__c ASC];
            
        } catch (Exception e) {
            return null;
        }
    }

    //citizen requirement
    @AuraEnabled
    public static MedicalHistryTabController.MedicalHistoryWrapper getMedicalHistory(List<ContentDocumentLink> cdls , Id participantId, String perid){
        
        //If this method is called for refresh the list after add file, so they will pass participantid
        if(cdls == null || cdls.isEmpty())
        {

            List<String> uploadedByContact = new List<String>();
            List<Patient_Delegate_Enrollment__c> pder = [
                SELECT
                    id,
                    Patient_Delegate__r.Contact__c,
                    Participant_Enrollment__r.Participant_Contact__c
                FROM Patient_Delegate_Enrollment__c
                WHERE Participant_Enrollment__c = :perid AND Primary_Delegate__c = TRUE
                LIMIT 1
            ];
            if(string.isNotBlank(perid)){
            Participant_Enrollment__c objPER = [SELECT ID,Participant_Contact__c FROM Participant_Enrollment__c where id=:perid];
                uploadedByContact.add(objPer.Participant_Contact__c);
            }
            if (!pder.isEmpty()) {
                uploadedByContact.add(pder[0].Patient_Delegate__r.Contact__c);
            }
            List<User> uploadedUser = [
                SELECT id, contactId
                FROM user
                WHERE contactId IN :uploadedByContact
            ];
            List<id> useriDs = new List<id>();
            for (User u : uploadedUser) {
                useriDs.add(u.id);
            }
            

             cdls = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE (LinkedEntityId =:participantId 
                                                OR ( LinkedEntityId = :perid AND ContentDocument.CreatedById IN :useriDs) )];  
        }
        
        List<ContentDocument> entries = new List<ContentDocument>(); 
        
        Set<Id> documentIds = new Set<Id>();
        for (ContentDocumentLink cdl : cdls) {
            documentIds.add(cdl.ContentDocumentId);
        }
        List<ContentDocument> documents = [SELECT Id,OwnerId, Title,ContentSize, CreatedDate, FileExtension, ContentModifiedDate FROM ContentDocument 
                                            WHERE Id IN :documentIds ORDER BY CreatedDate DESC];
                                            
        List<ContentDocumentLink> lstHasPermission = [Select Id,LinkedEntityId,ContentDocumentId from ContentDocumentLink where LinkedEntityId=:perid];

        set<Id> setContntDocPPID = new set<Id> ();
         for(ContentVersion objCntvr : [SELECT ID,title,ContentDocumentId from ContentVersion Where ContentDocumentId IN:documentIds 
                                            AND FileStatus__c = 'Uploaded' ])
             {
                 setContntDocPPID.add(objCntvr.ContentDocumentId);

             }


        
        List<Id> lstHasPerId = new List<Id>();
        for(ContentDocumentLink cvlnk:lstHasPermission){
        lstHasPerId.add(cvlnk.ContentDocumentId);
        }                                   
        Map<Id,Boolean> docDeleteAllowed = new Map<Id,Boolean>();
        Id currentUserId = UserInfo.getUserId();
        List<ContentDocumentAndDelete> docsAndDeleteList = new List<ContentDocumentAndDelete>();
      //  attachment, isDeleteAllowed, hasPermission ,isNameReadOnly , hasNameError , isNameUpdated,isFileFromPatientPortal,fileNameForEdit
        for(ContentDocument cd : documents){
            if(!setContntDocPPID.isEmpty() && setContntDocPPID.contains(cd.Id))
            {
               docsAndDeleteList.add(new ContentDocumentAndDelete(cd,false,false,true,false,false,true,'',''));        
            }
            else {
              if(currentUserId == cd.OwnerId){
                    if(!lstHasPerId.isEmpty() && lstHasPerId.contains(cd.Id)){
                    docsAndDeleteList.add(new ContentDocumentAndDelete(cd,true,true,true,false,false,false,'',''));
                    }else{
                    docsAndDeleteList.add(new ContentDocumentAndDelete(cd,true,false,true,false,false,false,'',''));}
                }else{
                    if(!lstHasPerId.isEmpty() && lstHasPerId.contains(cd.Id)){
                    docsAndDeleteList.add(new ContentDocumentAndDelete(cd,false,true,true,false,false,false,'',''));}
                    else{
                    docsAndDeleteList.add(new ContentDocumentAndDelete(cd,false,false,true,false,false,false,'',''));
                    }
                }
            }
        }       
        String basefileUrl = URL.getSalesforceBaseUrl().toExternalForm();
        return new MedicalHistoryWrapper(docsAndDeleteList, basefileUrl);
    }

    @AuraEnabled
    public static MedicalHistryTabController.MedicalHistoryWrapper deleteFileAttachment(Id contentDocumentToDeleteId,Id participantId, String perid ,Boolean bydate,Boolean ascending){
        ContentDocument contentDocumentToDelete = new ContentDocument();
        contentDocumentToDelete.Id = contentDocumentToDeleteId;
        delete contentDocumentToDelete;
        return getMedicalHistorys(new List<ContentDocumentLink>(), participantId,perid,bydate,ascending);
    }
    
    @AuraEnabled
    public static MedicalHistryTabController.MedicalHistoryWrapper getMedicalHistorys(List<ContentDocumentLink> cdls , Id participantId, String perid,Boolean bydate,Boolean ascending){
        
        //If this method is called for refresh the list after add file, so they will pass participantid
        if(cdls == null || cdls.isEmpty())
        {

            List<String> uploadedByContact = new List<String>();
            List<Patient_Delegate_Enrollment__c> pder = [
                SELECT
                    id,
                    Patient_Delegate__r.Contact__c,
                    Participant_Enrollment__r.Participant_Contact__c
                FROM Patient_Delegate_Enrollment__c
                WHERE Participant_Enrollment__c = :perid AND Primary_Delegate__c = TRUE
                LIMIT 1
            ];
            if(string.isNotBlank(perid)){
            Participant_Enrollment__c objPER = [SELECT ID,Participant_Contact__c FROM Participant_Enrollment__c where id=:perid];
                uploadedByContact.add(objPer.Participant_Contact__c);
            }
            if (!pder.isEmpty()) {
                uploadedByContact.add(pder[0].Patient_Delegate__r.Contact__c);
            }
            List<User> uploadedUser = [
                SELECT id, contactId
                FROM user
                WHERE contactId IN :uploadedByContact
            ];
            List<id> useriDs = new List<id>();
            for (User u : uploadedUser) {
                useriDs.add(u.id);
            }
            

             cdls = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE (LinkedEntityId =:participantId 
                                                OR ( LinkedEntityId = :perid AND ContentDocument.CreatedById IN :useriDs) )];  
        }
        
        List<ContentDocument> entries = new List<ContentDocument>(); 
        
        Set<Id> documentIds = new Set<Id>();
        for (ContentDocumentLink cdl : cdls) {
            documentIds.add(cdl.ContentDocumentId);
        }
         List<ContentDocument> documents;
        if(bydate){
            if(ascending){
                 documents = [SELECT Id,OwnerId, Title,ContentSize, CreatedDate, FileExtension, ContentModifiedDate FROM ContentDocument 
                                            WHERE Id IN :documentIds ORDER BY CreatedDate ASC];
            }else{
              documents = [SELECT Id,OwnerId, Title,ContentSize, CreatedDate, FileExtension, ContentModifiedDate FROM ContentDocument 
                                            WHERE Id IN :documentIds ORDER BY CreatedDate DESC];
            }
        }else{
            if(ascending){
                 documents = [SELECT Id,OwnerId, Title,ContentSize, CreatedDate, FileExtension, ContentModifiedDate FROM ContentDocument 
                                            WHERE Id IN :documentIds ORDER BY Title ASC];
            }else{
               documents = [SELECT Id,OwnerId, Title,ContentSize, CreatedDate, FileExtension, ContentModifiedDate FROM ContentDocument 
                                            WHERE Id IN :documentIds ORDER BY Title DESC];
            }    
        }
        
                                            
        List<ContentDocumentLink> lstHasPermission = [Select Id,LinkedEntityId,ContentDocumentId from ContentDocumentLink where LinkedEntityId=:perid];

        set<Id> setContntDocPPID = new set<Id> ();
         for(ContentVersion objCntvr : [SELECT ID,title,ContentDocumentId from ContentVersion Where ContentDocumentId IN:documentIds 
                                            AND FileStatus__c = 'Uploaded' ])
             {
                 setContntDocPPID.add(objCntvr.ContentDocumentId);

             }


        
        List<Id> lstHasPerId = new List<Id>();
        for(ContentDocumentLink cvlnk:lstHasPermission){
        lstHasPerId.add(cvlnk.ContentDocumentId);
        }                                   
        Map<Id,Boolean> docDeleteAllowed = new Map<Id,Boolean>();
        Id currentUserId = UserInfo.getUserId();
        List<ContentDocumentAndDelete> docsAndDeleteList = new List<ContentDocumentAndDelete>();
      //  attachment, isDeleteAllowed, hasPermission ,isNameReadOnly , hasNameError , isNameUpdated,isFileFromPatientPortal,fileNameForEdit
        for(ContentDocument cd : documents){
            if(!setContntDocPPID.isEmpty() && setContntDocPPID.contains(cd.Id))
            {
               docsAndDeleteList.add(new ContentDocumentAndDelete(cd,false,false,true,false,false,true,'',''));        
            }
            else {
              if(currentUserId == cd.OwnerId){
                    if(!lstHasPerId.isEmpty() && lstHasPerId.contains(cd.Id)){
                    docsAndDeleteList.add(new ContentDocumentAndDelete(cd,true,true,true,false,false,false,'',''));
                    }else{
                    docsAndDeleteList.add(new ContentDocumentAndDelete(cd,true,false,true,false,false,false,'',''));}
                }else{
                    if(!lstHasPerId.isEmpty() && lstHasPerId.contains(cd.Id)){
                    docsAndDeleteList.add(new ContentDocumentAndDelete(cd,false,true,true,false,false,false,'',''));}
                    else{
                    docsAndDeleteList.add(new ContentDocumentAndDelete(cd,false,false,true,false,false,false,'',''));
                    }
                }
            }
        }       
        String basefileUrl = URL.getSalesforceBaseUrl().toExternalForm();
        return new MedicalHistoryWrapper(docsAndDeleteList, basefileUrl);
    }

    @AuraEnabled 
    public static medicalHistryWrapper fetchfilterbiomarkerResult(String strAssesDateTime , Id perId) 
    {
        medicalHistryWrapper objWrapper = new medicalHistryWrapper();
        objWrapper.lstBiomarkerResultWrapper  = BioMarkerRecordController.getFilterbiomarker(strAssesDateTime,perId);
        objWrapper.lstbioMarkerMediaFiles = BioMarkerRecordController.getRelatedMediaFiles(perId,strAssesDateTime);
        return objWrapper ;
    }
    
/*Site Media request functionality */
    @AuraEnabled 
    public static medicalHistryWrapper requestAuthorizeMedicalRecords(Id perid){
        medicalHistryWrapper objWrapper = new medicalHistryWrapper();
        Id participantId = [SELECT ID,Participant__c FROM Participant_Enrollment__c WHERE ID=:perid].Participant__c; 
        objWrapper.strRequestMedicalReturn = HumanAPIcontroller.requestMedicalRecords(perid,participantId);
        return objWrapper;  
    }

    @AuraEnabled 
    public static List<Participant_Enrollment__History> getEnrollmentRequestHistory(Id perid){

        return HumanAPIcontroller.getRequestHistory(perid);

    } 

    @AuraEnabled 
    public static String getSurveyResponsecovid(Id perid)
    {
        return SurveyResponseViewController.getSurveyResponse(perid);
    }
    public class attachmentNameWrapper {
        public string cntnDocId;
        public String title; 
    } 

    
/*Method to save the particiapnt enrollment,comorbiditiesa anad participant */
    @AuraEnabled 
    public static medicalHistryWrapper saveParticipantData(String strBMI, Boolean boolHighRisk, Boolean boolHighPrority, String strComorbityToInsert,
                                              String strComorbiditiestoDelete,  String PerId, String addPermission, String revokePermission, String UpdateNamelist){
            try{
                List<Comorbidities__c> lstCommordtoInsert = (List<Comorbidities__c>) JSON.deserialize(strComorbityToInsert,List<Comorbidities__c>.class); 
                List<Comorbidities__c> lstCommordtoDelete= (List<Comorbidities__c>) JSON.deserialize(strComorbiditiestoDelete,List<Comorbidities__c>.class);
                
                Set<Id> lstAddPermission = (Set<Id>) JSON.deserialize(addPermission,Set<Id>.class);
                List<Id> lstRevokePermission = (List<Id>) JSON.deserialize(revokePermission,List<Id>.class);

                list<attachmentNameWrapper> lstAttachmentNameWrapper = (list<attachmentNameWrapper>)JSON.deserialize(UpdateNamelist,list<attachmentNameWrapper>.class);
                 list<ContentVersion> lstCntVersionToUpdate = new List<ContentVersion> ();
                 Map<Id,String> mapCntDocIdToName = new Map<Id,String> ();
                 set<Id> setCntnDocId = new Set<Id> ();

                for(attachmentNameWrapper objWrapper : lstAttachmentNameWrapper)
                {
                    setCntnDocId.add(objWrapper.cntnDocId);
                    mapCntDocIdToName.put(objWrapper.cntnDocId,objWrapper.title);

                }
                 
                Participant__c objParticipant = new Participant__c();

                medicalHistryWrapper objwrapper = new medicalHistryWrapper();

                Participant_Enrollment__c objOldPer = [SELECT HighRisk_Indicator__c,High_Priority__c,Participant__r.BMI__c,Participant__c from Participant_Enrollment__c
                                                        Where id=:PerId ];
                 Id commorbidityRecordType = Schema.SObjectType.Comorbidities__c.getRecordTypeInfosByName().get('Comorbidity').getRecordTypeId();
                Boolean boolHighRiskold = (String.isNotBlank(objOldPer.HighRisk_Indicator__c) &&
                                        (objOldPer.HighRisk_Indicator__c.toLowerCase() == 'yes' ||
                                        objOldPer.HighRisk_Indicator__c == '1'));
                if(boolHighRisk != boolHighRiskold || boolHighPrority != objOldPer.High_Priority__c)
                {
                    objOldPer.High_Priority__c = boolHighPrority;
                    objOldPer.HighRisk_Indicator__c = boolHighRisk ? 'Yes' : 'No';
                }
                update objOldPer;

                if(String.isNotBlank(strBMI) && objOldPer.Participant__r.BMI__c != Decimal.valueOf(strBMI))
                {
                    objParticipant.id = objOldPer.Participant__c;
                    objParticipant.BMI__c = Decimal.valueOf(strBMI);  
                    Update   objParticipant;
                }
                else if(String.isBlank(strBMI) && objOldPer.Participant__r.BMI__c != null)
                {
                    objParticipant.BMI__c = null;   
                    objParticipant.id = objOldPer.Participant__c;
                    Update  objParticipant;
                }
                List<Participant_Comorbidities__c> lstPartCommorToDelete = new List<Participant_Comorbidities__c> ();
                List<Participant_Comorbidities__c> lstPartComToInsert = new List<Participant_Comorbidities__c> ();

                if(!lstCommordtoDelete.isEmpty()){
                    for(Participant_Comorbidities__c objPartCom : [SELECT ID FROM Participant_Comorbidities__c Where Comorbidities__c IN:lstCommordtoDelete ])
                    {
                        lstPartCommorToDelete.add(objPartCom);
                    }
                    Delete lstPartCommorToDelete;  
                }
                if(!lstCommordtoInsert.isEmpty()){
                for(Comorbidities__c objCom : lstCommordtoInsert){
                    Participant_Comorbidities__c objPart = new Participant_Comorbidities__c(Comorbidities__c = objCom.id,
                                                                                            Participant__c=objOldPer.Participant__c);
                    lstPartComToInsert.add(objPart);
                }
                Insert lstPartComToInsert; 
            }
            
            Set<Id> lstCdIds = new Set<Id>();
            if(!lstAddPermission.isEmpty()){ //SendEmailDebug.sendEmail('cd ');
                lstCdIds.addall(lstAddPermission);
            }
            if(!setCntnDocId.isEmpty()){
                lstCdIds.addall(setCntnDocId);
            }
            
            if(!lstCdIds.isEmpty()){
               
                List<ContentVersion> contentToInsert = [select id, ContentDocumentId,title from ContentVersion WHERE ContentDocumentId IN:lstCdIds];
                List<ContentDocumentLink> lstConDocLnk = new List<ContentDocumentLink>();
               //SendEmailDebug.sendEmail('cd +');
                list<ContentDistribution> lstCntDstrblst = new list<ContentDistribution> ();
                for(ContentVersion cv:contentToInsert){
                    //creation of contentDocumentlink for PER   
                    if(lstAddPermission.contains(cv.ContentDocumentId)){
                    ContentDocumentLink cl = new ContentDocumentLink();
                    cl.ContentDocumentId = cv.ContentDocumentId;
                    cl.LinkedEntityId = PerId; 
                    cl.ShareType = 'V';
                    cl.Visibility = 'AllUsers';
                    
                    lstConDocLnk.add(cl);
                    
                    //creation of comtentDistributonLink
                        string fileName = cv.title;
                        Integer intIndex = fileName.lastindexOf('.');
                        String fileTitle = fileName.left(intIndex);
                        
                        String sizeStringFileName = fileTitle;
                        Integer maxSize = 96;
                        if(sizeStringFileName.length() > maxSize ){
                        sizeStringFileName = sizeStringFileName.substring(0, maxSize);
                        sizeStringFileName = sizeStringFileName+'...'; 
                        }
                    ContentDistribution objCntv = new ContentDistribution();
                    objCntv.ContentVersionId = cv.Id;
                    objCntv.Name = sizeStringFileName;
                    objCntv.PreferencesNotifyOnVisit = false;
                    objCntv.PreferencesAllowPDFDownload = false;
                    lstCntDstrblst.add(objCntv);
                    }
                    
                    

                    
                    if(setCntnDocId.contains(cv.ContentDocumentId)){
                    //Updation of custom field for the contentVersion
                        if(mapCntDocIdToName.containskey(cv.ContentDocumentId)){
                            //ContentVersion objCntvr = new ContentVersion();
                            //objCntvr.id = objcnvrsn.Id;
                            cv.title = mapCntDocIdToName.get(cv.ContentDocumentId);
                            cv.FileSharedbyPI__c = true;
                            //lstCntVersionToUpdate.add(objCntvr);
                            lstCntVersionToUpdate.add(cv);
                        }
                    }else{
                        cv.FileSharedbyPI__c = true;
                        lstCntVersionToUpdate.add(cv);
                    }
                     
                }
                Insert lstConDocLnk;
                if(!lstCntVersionToUpdate.isEmpty())
                    update lstCntVersionToUpdate;
                if(!lstCntDstrblst.isEmpty())
                    insert lstCntDstrblst;
            }
            if(!lstRevokePermission.isEmpty()){
                List<ContentDocumentLink> conDcLnk = [select id, ContentDocumentId,LinkedEntityId  from ContentDocumentLink WHERE ContentDocumentId IN:lstRevokePermission and LinkedEntityId=:PerId];
                Delete conDcLnk;
            }

            objWrapper.lstComorbidities = getParticipantComorbidities(objOldPer.Participant__c);

            objWrapper.lstAllComorbidities = [SELECT  ID,Comorbidity_Name__c from Comorbidities__c WHERE recordtypeid =: commorbidityRecordType
                                                and Id NOT IN: objWrapper.lstComorbidities];
            if(String.isNotBlank(strBMI)){
                objwrapper.BMI = Decimal.valueOf(strBMI);
            }
            objwrapper.HighRisk = boolHighRisk;
            objwrapper.Highpriority = boolHighPrority; 

            return objwrapper ; 
        }
        catch (Exception e) {

            throw new AuraHandledException(
      
              e.getMessage() +
      
              '\n' +
      
              e.getStackTraceString()
      
            );
      
          }
    }


    @AuraEnabled 
    public static medicalHistryWrapper saveAttachmentPermission(String PerId, String addPermission, String revokePermission, String UpdateNamelist){

      // try{  
                Set<Id> lstAddPermission = (Set<Id>) JSON.deserialize(addPermission,Set<Id>.class);
                List<Id> lstRevokePermission = (List<Id>) JSON.deserialize(revokePermission,List<Id>.class);

                list<attachmentNameWrapper> lstAttachmentNameWrapper = (list<attachmentNameWrapper>)JSON.deserialize(UpdateNamelist,list<attachmentNameWrapper>.class);
                 list<ContentVersion> lstCntVersionToUpdate = new List<ContentVersion> ();
                 Map<Id,String> mapCntDocIdToName = new Map<Id,String> ();
                 set<Id> setCntnDocId = new Set<Id> ();

                for(attachmentNameWrapper objWrapper : lstAttachmentNameWrapper)
                {
                    setCntnDocId.add(objWrapper.cntnDocId);
                    mapCntDocIdToName.put(objWrapper.cntnDocId,objWrapper.title);

                }
                 
                Participant__c objParticipant = new Participant__c();

                medicalHistryWrapper objwrapper = new medicalHistryWrapper();

                Participant_Enrollment__c objOldPer = [SELECT HighRisk_Indicator__c,High_Priority__c,Participant__r.BMI__c,Participant__c from Participant_Enrollment__c
                                                        Where id=:PerId ];
              
            
            Set<Id> lstCdIds = new Set<Id>();
            if(!lstAddPermission.isEmpty()){ //SendEmailDebug.sendEmail('cd ');
                lstCdIds.addall(lstAddPermission);
            }
            if(!setCntnDocId.isEmpty()){
                lstCdIds.addall(setCntnDocId);
            }
            
            if(!lstCdIds.isEmpty()){
               
                List<ContentVersion> contentToInsert = [select id, ContentDocumentId,title from ContentVersion WHERE ContentDocumentId IN:lstCdIds];
                List<ContentDocumentLink> lstConDocLnk = new List<ContentDocumentLink>();
               //SendEmailDebug.sendEmail('cd +');
                list<ContentDistribution> lstCntDstrblst = new list<ContentDistribution> ();
                for(ContentVersion cv:contentToInsert){
                    //creation of contentDocumentlink for PER   
                    if(lstAddPermission.contains(cv.ContentDocumentId)){
                    ContentDocumentLink cl = new ContentDocumentLink();
                    cl.ContentDocumentId = cv.ContentDocumentId;
                    cl.LinkedEntityId = PerId; 
                    cl.ShareType = 'V';
                    cl.Visibility = 'AllUsers';
                    
                    lstConDocLnk.add(cl);
                    
                    //creation of comtentDistributonLink
                        string fileName = cv.title;
                        Integer intIndex = fileName.lastindexOf('.');
                        String fileTitle = fileName.left(intIndex);
                        
                        String sizeStringFileName = fileTitle;
                        Integer maxSize = 96;
                        if(sizeStringFileName.length() > maxSize ){
                        sizeStringFileName = sizeStringFileName.substring(0, maxSize);
                        sizeStringFileName = sizeStringFileName+'...'; 
                        }
                    ContentDistribution objCntv = new ContentDistribution();
                    objCntv.ContentVersionId = cv.Id;
                    objCntv.Name = sizeStringFileName;
                    objCntv.PreferencesNotifyOnVisit = false;
                    objCntv.PreferencesAllowPDFDownload = false;
                    lstCntDstrblst.add(objCntv);
                    }
                    
                    if(setCntnDocId.contains(cv.ContentDocumentId)){
                    //Updation of custom field for the contentVersion
                        if(mapCntDocIdToName.containskey(cv.ContentDocumentId)){
                            //ContentVersion objCntvr = new ContentVersion();
                            //objCntvr.id = objcnvrsn.Id;
                            cv.title = mapCntDocIdToName.get(cv.ContentDocumentId);
                            cv.FileSharedbyPI__c = true;
                            //lstCntVersionToUpdate.add(objCntvr);
                            lstCntVersionToUpdate.add(cv);
                        }
                    }else{
                        cv.FileSharedbyPI__c = true;
                        lstCntVersionToUpdate.add(cv);
                    }
                     
                }
                Insert lstConDocLnk;
                if(!lstCntVersionToUpdate.isEmpty())
                    update lstCntVersionToUpdate;
                if(!lstCntDstrblst.isEmpty())
                    insert lstCntDstrblst;
            }
            if(!lstRevokePermission.isEmpty()){
                List<ContentDocumentLink> conDcLnk = [select id, ContentDocumentId,LinkedEntityId  from ContentDocumentLink WHERE ContentDocumentId IN:lstRevokePermission and LinkedEntityId=:PerId];
                Delete conDcLnk;
            }

            return objwrapper ; 
       // }
        // catch (Exception e) {

        //     throw new AuraHandledException(
      
        //       e.getMessage() +
      
        //       '\n' +
      
        //       e.getStackTraceString()
      
        //     );
      
        //   }

    }
           








}