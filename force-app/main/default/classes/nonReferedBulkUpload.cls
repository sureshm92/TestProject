public with sharing class nonReferedBulkUpload {
    public nonReferedBulkUpload() {

    }
    @AuraEnabled                            
    public static Id saveTheChunkFile(Id parentId, String fileName, String base64Data, String contentType, String fileId){
        
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        if ( String.isBlank(fileId) ) {
            fileId = saveFiles(parentId, fileName, base64Data );
        } else {
            appendToFile(fileId, base64Data);
        }

        return Id.valueOf(fileId);
    }

    @AuraEnabled
    public static Id saveFiles(Id recordId, String fileName, String base64Data )  { 
        
        ContentVersion contentToInsert =new ContentVersion(); 
        contentToInsert.Title =fileName; 
        contentToInsert.VersionData=EncodingUtil.base64Decode(base64Data);
        contentToInsert.PathOnClient='/' + fileName ;
        contentToInsert.IsMajorVersion = false;
        insert contentToInsert; 
        
        contentToInsert = [select id, ContentDocumentId from ContentVersion WHERE Id =: contentToInsert.Id];
        ContentDocumentLink cl = new ContentDocumentLink();
        cl.ContentDocumentId = contentToInsert.ContentDocumentId;
        cl.LinkedEntityId = recordId; 
        cl.ShareType = 'V';
        cl.Visibility = 'AllUsers';
        insert cl;
        
        return contentToInsert.id;

    }


    @AuraEnabled
    public static void appendToFile(Id contentDocumentId, String base64Data) {
        //base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        ContentVersion versionData = [
            SELECT Id, VersionData,ContentDocumentId
            FROM ContentVersion
            WHERE Id = :contentDocumentId
        ];

        String existingBody     = EncodingUtil.base64Encode(versionData.VersionData);
        versionData.VersionData = EncodingUtil.base64Decode(existingBody + base64Data); 

        update versionData;
    }
    @AuraEnabled
    public static void deleteFile(String fileId)  { 
        ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion WHERE id = :fileId];
        contentdocument cd = new contentdocument(id = cv.contentDocumentId);
        delete cd;
    }
    
    //method to fetch existing error files
    @AuraEnabled(cacheable=false)
    public static List<ContentVersion> fetchFiles(){
        Set<Id> cntDocumentIds = new Set<Id>();
        List<ContentVersion> errcvList = new List<ContentVersion>();
        try{
            Contact cnt = new Contact();
            cnt.id = [Select contactId from user where Id =: userInfo.getUserId()].contactId;
            for(ContentDocumentLink cdlink : [Select Id, 
                                                LinkedEntityId, 
                                                ContentDocumentId 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId=: cnt.id])
            {                                    
                cntDocumentIds.add(cdlink.ContentDocumentId);       
            }

        	errcvList = [SELECT VersionData,Title, CreatedBy.Name, ContentModifiedDate, ContentUrl, Initial_Total_Records__c, Accepted__c, Rejected_Records__c, ContentDocumentId, PathOnClient FROM ContentVersion WHERE IsLatest = true AND ContentDocumentId IN : cntDocumentIds ORDER BY createddate DESC];
			
            for(ContentVersion cv : errcvList){
                if(cv.Rejected_Records__c != 0)
                    cv.ContentUrl = '/sfc/servlet.shepherd/document/download/'+ cv.ContentDocumentId;
                else
                    cv.ContentUrl = null;
            }
            
            return errcvList;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }    
    }
    
    @AuraEnabled
    public static void processvalidateFile(string fileID,string studyID,string rpState,string rpCountry){
        try {
           
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.SendFOVtoAPI.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class
            );
            /*
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
            );
			*/
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class
            );
            
            string usrContId = CommunityService.getInstance().getCurrentContactId();
            String HCPid = [select id from HCP_Enrollment__c where Study_Site__c =: studyID and HCP_Contact__c =: usrContId limit 1].id;

            ContentVersion cv = [SELECT VersionData,Title, ContentDocumentId, PathOnClient FROM ContentVersion WHERE id = :fileId AND IsLatest = true];
            string fileBody = cv.versionData.toString();
            list<String> rows= fileBody.split('\n');
            map<string,Participant_Enrollment__c> peList = new map<string,Participant_Enrollment__c>();
            map<string,string> errRowsCSV = new map<string,string>();
            String errCSVFile ='';
            map<string,string> rowsCSV = new map<string,string>();
            list<String> pIds= new list<String>();
            list<Integer> mandatoryIndexes =  new list<Integer>{0};            
            list<Integer> emailIndexes =  new list<Integer>{5,17};    
            list<Integer> yobIndexes =  new list<Integer>{6,20};   
            list<Integer> legalIndexes =  new list<Integer>{7,8,21};
            list<Integer> phoneTypeIndexes =  new list<Integer>{12,14,19};
            string errStr = '';
            map<integer,string> errMap = getErrMessages();
            
            //Generate Counrty Code and state code
            map<string,string> ccMap = new map<string,string>();
            map<string,string> scMap = new map<string,string>();
            Schema.DescribeFieldResult country_field = Participant_Enrollment__c.Country__c.getDescribe(); 
            Schema.DescribeFieldResult state_field = Participant_Enrollment__c.State__c.getDescribe(); 
            List<Schema.PicklistEntry> country_values = country_field.getPicklistValues(); 
            List<Schema.PicklistEntry> state_values = state_field.getPicklistValues(); 
            for( Schema.PicklistEntry v : country_values) { 
                ccMap.put(v.getLabel(), v.getValue()); 
            }
            for( Schema.PicklistEntry v : state_values) { 
                scMap.put(v.getLabel(), v.getValue()); 
            }
            
            
            for(Integer i=2; i < rows.size(); i++){
                String[] rec = rows[i].split(',');
                rec[21]=rec[21].trim();
                try{
                    mandatoryIndexes = new list<Integer>{0};
                    errStr = '';
                    pIds.add(rec[0]);
                    rowsCSV.put(rec[0],rows[i]);
                    

                    //mandatory field validations
                    if(rec[5]=='No'){  // if participant is a minor then delegate info is mandatory
                        mandatoryIndexes =  new list<Integer>{0,15,16,17,21};
                        //Legal Status of Primary Delegate should be Yes 
                        if(rec[21]=='No'){
                            errStr += 'Delegate is not over the age of legal majority - Legal Status of Primary Delegate should be Yes.';
                        }
                    }
                    if(!(rec[1]==''&&rec[5]==''&&rec[3]==''&&rec[11]=='')){ //if personal info entered YOB and Patient Auth is mandatory
                        mandatoryIndexes.add(6); 
                        mandatoryIndexes.add(8); 
                    }
                    for(integer j : mandatoryIndexes){
                        system.debug(j +'>>' + rec[j]+'<<' );
                        if(rec[j]==''){
                            errStr += errMap.get(j);
                        }
                    }

                    //email field validations
                    for(integer j : emailIndexes){
                        if(rec[j]!=''){
                            if(!Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z0-9]+.[a-zA-Z]{2,4}', rec[j])){
                                errStr += errMap.get(j*100);
                            }
                        }   
                    }

                    //YOB validation
                    for(integer j : yobIndexes){
                        if(rec[j]!=''){
                            if(!Pattern.matches('[0-9]{4}', rec[j])){
                                errStr += errMap.get(j*100);
                            }
                        }
                    }

                    //Legal Status validation
                    for(integer j : legalIndexes){
                        if(rec[j]!='' && rec[j]!='Yes' && rec[j]!='No'){
                            errStr += errMap.get(j*100);                        
                        }
                    }

                    //Phone type validation
                    for(integer j : phoneTypeIndexes){
                        if(rec[j]!='' && rec[j]!='Home' && rec[j]!='Work' && rec[j]!='Mobile'){
                            errStr += errMap.get(j*100);                        
                        }
                    }
                    
                    //Patient sex validation
                    if(rec[4]!='' && rec[4]!='Male' && rec[4]!='Female' ){
                        errStr += errMap.get(4*100);                        
                    }

                    //Empty Patient Phone if Minor
                    if(rec[7]=='No'){
                        rec[11]='' ;                       
                    }

                    if(rec[9]!='' && !ccMap.containsKey(rec[9])){
                        errStr += 'Invalid Country;';
                    }

                    if(rec[10]!='' && !scMap.containsKey(rec[10])){
                        errStr += 'Invalid State;';
                    }
                    
                    if(errStr == ''){
                        //fill country and state if empty
                        if(rec[9]=='') rec[9]=rpCountry;
                        if(rec[10]=='') rec[10]=rpState;
                        
                        Participant_Enrollment__c peRec = new Participant_Enrollment__c() ;
                        peRec.HCP_Contact_HCPEnroll__c = usrContId;
                        peRec.Participant_Status__c = 'Pending Referral';
                        peRec.HCP__c = HCPid;

                        peRec.Study_Site__c = studyID;
                        peRec.Patient_ID__c=rec[0];
                        peRec.Participant_Name__c=rec[1];
                        peRec.Patient_Middle_Name_Initial__c=rec[2];
                        peRec.Participant_Surname__c=rec[3];
                        peRec.Patient_Sex__c=rec[4];
                        peRec.Email__c=rec[5];
                        peRec.YOB__c=rec[6];
                        peRec.Legal_Status__c=rec[7];
                        peRec.Patient_Auth__c=rec[8];
                        if(ccMap.containsKey(rec[9])) peRec.Country__c= ccMap.get(rec[9]);
                        if(ccMap.containsKey(rec[10])) peRec.State__c= scMap.get(rec[10]);
                        peRec.Phone__c=rec[11];
                        peRec.Patient_Phone_Type__c=rec[12];
                        peRec.Participant_Alternative_Phone__c=rec[13];
                        peRec.Participant_Alt_Phone_Type__c=rec[14];
                        peRec.Primary_Delegate_First_Name__c=rec[15];
                        peRec.Primary_Delegate_Last_Name__c=rec[16];
                        peRec.Primary_Delegate_Email__c=rec[17];
                        peRec.Primary_Delegate_Phone_Number__c=rec[18];
                        peRec.Primary_Delegate_Phone_Type__c=rec[19];
                        peRec.Primary_Delegate_YOB__c=rec[20];
                        peRec.Legal_Status_of_Primary_Delegate__c=rec[21];
                        peList.put(rec[0],peRec);
                    }
                    else{
                        rec.add(errStr);
                        errRowsCSV.put(rec[0],String.join( rec, ',' ));
                    }
                }
                catch (Exception e) {
                    rec.add(e.getMessage());
                    errRowsCSV.put(rec[0],String.join( rec, ',' ));
                }
            }
            for(Participant_Enrollment__c pe : [select id,Patient_ID__c from Participant_Enrollment__c where Patient_ID__c in :pIds ]){
                if(peList.containsKey(pe.Patient_ID__c)){
                    string row = rowsCSV.get(pe.Patient_ID__c);
                    row = row.trim() + ',Duplicate Patient Record.;';
                    errRowsCSV.put(pe.Patient_ID__c,row);
                    peList.remove(pe.Patient_ID__c);
                }
                else if(errRowsCSV.containsKey(pe.Patient_ID__c)){
                    string row = errRowsCSV.get(pe.Patient_ID__c);
                    row  = row.trim() + 'Duplicate Patient Record.;';
                    errRowsCSV.put(pe.Patient_ID__c,row);
                }
            }
           
            List<Database.SaveResult> saveResults = Database.insert(peList.values(), false);
            for (Integer i = 0; i < saveResults.size(); i++) {
                if(!saveResults[i].isSuccess()){
                    Participant_Enrollment__c pe = peList.values()[i];
                    string errMSG='';
                    for(Database.Error err : saveResults[i].getErrors()) {
                        errMSG = errMSG + err.getMessage() +';';
                    }
                    string row = rowsCSV.get(pe.Patient_ID__c);
                    row = row.trim() + ','+errMSG;
                    errRowsCSV.put(pe.Patient_ID__c,row); 
                }
            }
            
            // if(!errRowsCSV.isEmpty()){
            errCSVFile = rows[0].trim()+',Error'+ '\n';
            errCSVFile = errCSVFile +rows[1].trim()+','+ '\n';
            if(!errRowsCSV.isEmpty()){
                for(String k : errRowsCSV.keyset()){
                    errCSVFile = errCSVFile + errRowsCSV.get(k) + '\n';
                    system.debug(errRowsCSV.get(k));
                }
            }
            system.debug(errCSVFile);
            Blob csvBlob = blob.valueOf(errCSVFile);
            string errFileName  = cv.Title.split('.csv')[0]+'_err.csv';
            ContentVersion contentToInsert =new ContentVersion(); 
            contentToInsert.Title =errFileName; 
            contentToInsert.VersionData=csvBlob;
            contentToInsert.ContentDocumentId = cv.ContentDocumentId;
            contentToInsert.PathOnClient='/'+errFileName;
            contentToInsert.IsMajorVersion = false;
            contentToInsert.Initial_Total_Records__c = rows.size()-2;
            contentToInsert.Accepted__c = rows.size()-2-errRowsCSV.size();
            contentToInsert.Rejected_Records__c = errRowsCSV.size();
            insert contentToInsert; 
            // }


        } catch (Exception e) {
            system.debug(e.getMessage());
            system.debug(e.getStackTraceString());
        }
    }
    public static map<integer,string> getErrMessages(){
        map<integer,string> errMap = new map<integer,string>();
        errMap.put(0,'Mandatory field- Patient ID is missing.;');
        errMap.put(6,'Mandatory field- Patient YOB is missing.;');
        errMap.put(8,'Mandatory field- Patient Auth. Is missing.;');
        errMap.put(15,'Mandatory field-Delegate’s First Name is missing.;');
        errMap.put(16,'Mandatory field-Delegate’s Last Name is missing.;');
        errMap.put(17,'Mandatory field-Delegate’s Email address is missing.;');
        errMap.put(21,'Mandatory field-Delegate’s Legal Status is missing.;');
        errMap.put(500,'Invalid email-Patient Email Address is invalid.;');
        errMap.put(1700,'Invalid email-Primary Delegate Email Address is invalid.;');
        errMap.put(600,'Invalid YOB-Patient YOB is invalid.;');
        errMap.put(2000,'Invalid YOB-Primary Delegate YOB is invalid.;');
        errMap.put(700,'Invalid Legal Status-Patient Legal Status is invalid.;');
        errMap.put(2100,'Invalid Legal Status-Legal Status of Primary Delegate is invalid.;');
        errMap.put(800,'Patient Auth. is invalid.;');
        errMap.put(1400,'Invalid Phone Type-Primary Delegate Phone Type is invalid.;');
        errMap.put(1900,'Invalid Phone Type-Participant Alt. Phone Type is invalid.;');
        errMap.put(1200,'Invalid Phone Type-Patient Phone Type is invalid.;');
        errMap.put(400,'Patient Sex is invalid.;');
        return errMap;
    }
}