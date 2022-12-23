public without sharing class nonReferedBulkUpload {
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
    public static List<ContentVersion> fetchFiles(string delegateId){
        Set<Id> cntDocumentIds = new Set<Id>();
        List<ContentVersion> errcvList = new List<ContentVersion>();
        try{
            Contact cnt = new Contact();
            if(delegateId==null){
                cnt.id = [Select contactId from user where Id =: userInfo.getUserId()].contactId;
            }
            else{
                cnt.id = delegateId;
            }
            for(ContentDocumentLink cdlink : [Select Id, 
                                              LinkedEntityId, 
                                              ContentDocumentId 
                                              FROM ContentDocumentLink 
                                              WHERE LinkedEntityId=: cnt.id])
            {                                    
                cntDocumentIds.add(cdlink.ContentDocumentId);       
            }
            
            errcvList = [SELECT VersionData,Title, CreatedBy.Name, ContentModifiedDate, ContentUrl, Initial_Total_Records__c, Accepted__c, Rejected_Records__c, ContentDocumentId, PathOnClient FROM ContentVersion WHERE IsLatest = true AND ContentDocumentId IN : cntDocumentIds and FileExtension = 'csv' AND Initial_Total_Records__c != null  ORDER BY createddate DESC];
            
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
    public static void processvalidateFile(string fileID,string studyID,string rpState,string rpCountry, string csvData, string delegateId){
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
            
            integer currentYear= system.now().year();
            
            Map<String, Integer> yearByCountryStateCode = new Map<String, Integer>();
            Map<String, Age_of_Majority__mdt> mapAgeM = Age_of_Majority__mdt.getAll();
            for(String ageOfMajority : mapAgeM.keySet()){ 
                if (mapAgeM.get(ageOfMajority).Age__c != null) {
                    yearByCountryStateCode.put(
                        mapAgeM.get(ageOfMajority).DeveloperName,
                        currentYear-mapAgeM.get(ageOfMajority).Age__c.intValue()
                    );
                }
            }
            if(delegateId==null)
            delegateId = CommunityService.getInstance().getCurrentContactId();
            String HCPid = [select id from HCP_Enrollment__c where Study_Site__c =: studyID and HCP_Contact__c =: delegateId limit 1].id;
            
            ContentVersion cv = [SELECT VersionData,Title, ContentDocumentId, PathOnClient FROM ContentVersion WHERE id = :fileId AND IsLatest = true];
            string fileBody = csvData;
            list<String> rows= fileBody.split('\n');
            map<string,Participant_Enrollment__c> peList = new map<string,Participant_Enrollment__c>();
            map<string,string> errRowsCSV = new map<string,string>();
            String errCSVFile ='';
            map<string,string> rowsCSV = new map<string,string>();
            map<string,string> IndexPatientMap = new map<string,string>();
            list<String> pIds= new list<String>();            
            map<string,string> prRowIndexMap = new map<string,string>();
            list<Integer> mandatoryIndexes =  new list<Integer>{0};            
            list<Integer> emailIndexes =  new list<Integer>{5,17};    
            list<Integer> yobIndexes =  new list<Integer>{6,20};   
            list<Integer> legalIndexes =  new list<Integer>{7,21};
            list<Integer> phoneTypeIndexes =  new list<Integer>{12,14,19};
            set<string> pidset = new set<string>();
            integer totalRow = 0;
            string errStr = '';
            map<integer,string> errMap = getErrMessages();
            boolean hasErrRow = false;
            
            for(Integer i=2; i < rows.size(); i++){
                boolean hasPatientErrRow = false;
                boolean hasDelErrRow = false;
                list<Integer> delegateIndexes =  new list<Integer>{15,16,17,18,19,20,21}; 
                String[] rec = rows[i].split(',');
                if(rec.size()==0){
                    continue;
                }
                totalRow ++;
                if(rec.size()<22){
                    rows[i] =  rows[i] + '#*';
                    rec = rows[i].split(',');
                    rec[21] = rec[21].replace('#*','');
                    rows[i] =  rows[i].replace('#*','');                    
                }
                if(rec.size()==23){
                    hasErrRow = true;
                    rec.remove(22);
                }
                rows[i] = String.join( rec, ',' );
                rec[21]=rec[21].trim();
                try{
                    mandatoryIndexes = new list<Integer>{0};
                        errStr = '';
                    if(!pidset.contains(rec[0]) && rec[0]!=''){
                        pidset.add(rec[0]);
                    } 
                    else if(rec[0]!=''){
                        errStr += 'Duplicate Patient ID in sheet.;';
                        hasPatientErrRow = true;
                    }                   
                    pIds.add(rec[0]);
                    if(rec[0] !='' && errStr==''){
                        rowsCSV.put(i+'_index',rows[i]);
                        IndexPatientMap.put(rec[0],i+'_index');
                    }
                    else{
                        rowsCSV.put(i+'_index',rows[i]);
                    }
                    
                    //mandatory field validations
                    if(rec[7]=='No'){  // if participant is a minor then delegate info is mandatory
                        mandatoryIndexes =  new list<Integer>{0,15,16,17,18,19,20,21};
                            //Legal Status of Primary Delegate should be Yes 
                            if(rec[21]=='No'){
                                errStr += 'Legal Status of Primary Delegate should be Yes.;';
                                hasDelErrRow = true;
                            }
                    }
                    else{
                        //if any delgate info is present all delegate fields are mandatory
                        if(!(rec[15]==''&&rec[16]==''&&rec[17]==''&&rec[18]==''&&rec[19]==''&&rec[20]==''&&rec[21]=='')){
                            mandatoryIndexes =  new list<Integer>{0,15,16,17,18,19,20,21};
                        }
                        //Legal Status of Primary Delegate should be Yes 
                        if(rec[21]=='No'){
                            errStr += 'Legal Status of Primary Delegate should be Yes.;';
                            hasDelErrRow = true;
                        }
                    }
                    //if(!(rec[1]==''&&rec[5]==''&&rec[3]==''&&rec[11]=='')){ //if personal info entered YOB and Patient Auth is mandatory
                    if(!(rec[5]==''&&rec[11]==''&&rec[13]==''&&rec[12]==''&&rec[14]=='')){ //if contact info entered YOB is mandatory
                        mandatoryIndexes.add(6); 
                    }
                    //if personal info entered Patient Auth is mandatory
                    if(!(rec[1]==''&&rec[2]==''&&rec[3]==''&&rec[5]==''&&rec[11]==''&&rec[13]==''&&rec[12]==''&&rec[14]=='')){ 
                        mandatoryIndexes.add(8);                     
                    }

                    for(integer j : mandatoryIndexes){
                        if(rec[j]==''){
                            errStr += errMap.get(j);
                            if(delegateIndexes.contains(j)){
                                hasDelErrRow = true;
                            }
                            else{
                                hasPatientErrRow = true;
                            }

                        }
                    }
                    
                    //email field validations
                    for(integer j : emailIndexes){
                        if(rec[j]!=''){
                            if(!Pattern.matches('[a-zA-Z0-9.+_-]+@[a-zA-Z0-9]+.[a-zA-Z]{2,4}', rec[j])){
                                errStr += errMap.get(j*100);
                                if(delegateIndexes.contains(j)){
                                    hasDelErrRow = true;
                                }
                                else{
                                    hasPatientErrRow = true;
                                }
                            }
                        }   
                    }
                    
                    //YOB validation
                    string isMajorPatient = '';
                    string isMajorDelegate = '';
                    string stateCode='';
                    string countryCode = '';
                    if(rec[9]!='' && !CountryStateUtil.COUNTRY_CODE_BY_NAME_MAP_Mdt.containsKey(rec[9])){
                        errStr += 'Invalid Country;';                        
                        hasPatientErrRow = true;
                    }
                    else if(rec[9]!=''){
                        if(CountryStateUtil.COUNTRY_CODE_BY_NAME_MAP_Mdt.containsKey(rec[9])) countryCode= CountryStateUtil.COUNTRY_CODE_BY_NAME_MAP_Mdt.get(rec[9]);
                    }
                    else{
                        if(CountryStateUtil.COUNTRY_CODE_BY_NAME_MAP_Mdt.containsKey(rpCountry)) countryCode= CountryStateUtil.COUNTRY_CODE_BY_NAME_MAP_Mdt.get(rpCountry);
                    }
                    
                    if(countryCode != '' && CountryStateUtil.STATES_CODE_BY_NAME_MAP_Mdt.containsKey(countryCode)){
                        if(rec[10]!='' && !CountryStateUtil.STATES_CODE_BY_NAME_MAP_Mdt.get(countryCode).containsKey(rec[10])){
                            errStr += 'Invalid State;';
                            hasPatientErrRow = true;
                        }
                        else if(rec[10]!=''){
                            if(CountryStateUtil.STATES_CODE_BY_NAME_MAP_Mdt.get(countryCode).containsKey(rec[10])) stateCode= CountryStateUtil.STATES_CODE_BY_NAME_MAP_Mdt.get(countryCode).get(rec[10]);
                        }
                        else{
                            if(CountryStateUtil.STATES_CODE_BY_NAME_MAP_Mdt.get(countryCode).containsKey(rpState)) stateCode= CountryStateUtil.STATES_CODE_BY_NAME_MAP_Mdt.get(countryCode).get(rpState);
                        }
                    }
                    
                    for(integer j : yobIndexes){
                        if(rec[j]!=''){
                            if(!Pattern.matches('[0-9]{4}', rec[j])){
                                errStr += errMap.get(j*100);
                                if(delegateIndexes.contains(j)){
                                    hasDelErrRow = true;
                                }
                                else{
                                    hasPatientErrRow = true;
                                }
                            }
                            else if(!(stateCode=='' || countryCode =='')){  
                                string isMajor ='';
                                if (yearByCountryStateCode.containsKey(countryCode +'_' +stateCode)) {
                                    if(integer.valueOf(rec[j])>yearByCountryStateCode.get(countryCode +'_' +stateCode)){
                                        isMajor = 'No';
                                    }
                                    else{
                                        isMajor = 'Yes';
                                    }
                                } else if (yearByCountryStateCode.containsKey(countryCode)) {
                                    if(integer.valueOf(rec[j])>yearByCountryStateCode.get(countryCode)){
                                        isMajor = 'No';
                                    }
                                    else{
                                        isMajor = 'Yes';
                                    }
                                } else {
                                    if(18>currentYear-integer.valueOf(rec[j])){
                                        isMajor = 'No';
                                    }
                                    else{
                                        isMajor = 'Yes';
                                    }
                                }    
                                if(j==6){  
                                    isMajorPatient=isMajor;
                                }                     
                                else if(j==20){
                                    isMajorDelegate=isMajor;
                                }                                
                            }                            
                        }
                    }
                    
                    //Legal Status validation
                    if(isMajorDelegate=='No'){
                        errStr = errStr + 'Primary Delegate YOB is not over the age of legal majority.;';
                    }
                    
                    for(integer j : legalIndexes){
                        if(rec[j]!='' && rec[j]!='Yes' && rec[j]!='No'){
                            errStr += errMap.get(j*100);
                            if(delegateIndexes.contains(j)){
                                hasDelErrRow = true;
                            }
                            else{
                                hasPatientErrRow = true;
                            }                        
                        }
                        else{
                            if(j==7){
                                if(rec[j] !='' && isMajorPatient != rec[j] && isMajorPatient!=''){
                                    errStr = errStr + 'Legal Status of Patient does not match the Patient YOB.;' ;                                    
                                    hasPatientErrRow = true;
                                }
                            }
                            else if(j==21){
                                if(rec[j] !='' && isMajorDelegate != rec[j] && isMajorDelegate!=''){
                                    errStr = errStr + 'Legal Status of Primary Delegate does not match the Primary Delegate YOB.;' ;
                                    hasDelErrRow = true;
                                }
                            }
                        }
                    }
                    
                    //Phone type validation
                    for(integer j : phoneTypeIndexes){
                        if(rec[j]!='' && rec[j]!='Home' && rec[j]!='Work' && rec[j]!='Mobile'){
                            errStr += errMap.get(j*100);   
                            if(delegateIndexes.contains(j)){
                                hasDelErrRow = true;
                            }
                            else{
                                hasPatientErrRow = true;
                            }                     
                        }
                    }
                    
                    //Patient sex validation
                    if(rec[4]!='' && rec[4]!='Male' && rec[4]!='Female' ){
                        errStr += errMap.get(4*100);  
                        hasPatientErrRow = true;                      
                    }      
                    
                    //Patient Auth validation
                    if(rec[8]!='' && rec[8]!='Yes' && rec[8]!='No'){
                        errStr += errMap.get(800);   
                        hasPatientErrRow = true;                     
                    }
                    else if(rec[8]=='No'){
                        errStr += 'Patient Auth if entered should be Yes.;';   
                        hasPatientErrRow = true;                     
                    } 
                    if(errStr == ''){
                    
                        //REF-4881
                        String dlgAltPhone = '';

                        //Empty Patient Phone,email if Minor
                        if(rec[7]=='No' || isMajorPatient=='No'){
                            dlgAltPhone =  rec[11]; 
                            rec[14]='' ;   
                            rec[12]='' ;   
                            rec[13]='' ;   
                            rec[11]='' ;   
                            rec[5] = '';                 
                        }
                        
                        //fill country and state if empty
                        if(rec[9]=='') rec[9]=rpCountry;
                        if(rec[10]=='') rec[10]=rpState;
                        
                        Participant_Enrollment__c peRec = new Participant_Enrollment__c() ;
                        peRec.HCP_Contact_HCPEnroll__c = delegateId;
                        peRec.Participant_Status__c = 'Pending Referral';
                        peRec.HCP__c = HCPid;
                        peRec.Referral_Source__c = 'HCP';
                        
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
                        if(peRec.Patient_Auth__c == 'Yes'){
                            peRec.Permit_IQVIA_to_contact_about_study__c = true;
                            peRec.Permit_Mail_Email_contact_for_this_study__c = true;
                            peRec.Permit_SMS_Text_for_this_study__c = true;
                            peRec.Permit_Voice_Text_contact_for_this_study__c = true;
                            peRec.Study_Artificial_Voice_Consent__c = true;
                            peRec.Study_Assisted_Dialing_Consent__c = true;
                            peRec.Study_Direct_Mail_Consent__c = true;
                            peRec.Study_Pre_recorded_Voice_Consent__c = true;
                        }
                        peRec.mailing_country_code__c= countryCode;
                        peRec.mailing_state_code__c= stateCode;
                        peRec.Phone__c=rec[11];
                        peRec.Patient_Phone_Type__c = (rec[11] != '' && rec[12] == '') ? 'Home' : rec[12];
                        peRec.Participant_Alternative_Phone__c=rec[13];
                        peRec.Participant_Alt_Phone_Type__c=rec[14];
                        if(!hasDelErrRow){
                            if(dlgAltPhone !=''){
                                peRec.Primary_Delegate_s_Alt_Phone__c=dlgAltPhone;
                                peRec.Primary_Delegate_s_Alt_Phone_Type__c = 'Home';
                            }
                            peRec.Primary_Delegate_First_Name__c=rec[15];
                            peRec.Primary_Delegate_Last_Name__c=rec[16];
                            peRec.Primary_Delegate_Email__c=rec[17];
                            peRec.Primary_Delegate_Phone_Number__c=rec[18];
                            peRec.Primary_Delegate_Phone_Type__c=rec[19];
                            peRec.Primary_Delegate_YOB__c=rec[20];
                            peRec.Legal_Status_of_Primary_Delegate__c=rec[21];
                            if(rec[21] == 'Yes' || rec[21] == 'yes'){
                              peRec.Is_Delegate_Certify__c = true;
                            }
                        }
                        peList.put(rec[0],peRec);
                        prRowIndexMap.put(rec[0],i+'_index');
                    }                    
                    if(errStr != '' ){
                        rec.add(errStr);
                        prRowIndexMap.put(rec[0],i+'_index');
                        errRowsCSV.put(i+'_index',String.join( rec, ',' ));
                    }
                }
                catch (Exception e) {
                    rec.add(e.getMessage());
                    errRowsCSV.put(i+'_index',String.join( rec, ',' ));
                }
            }
            for(Participant_Enrollment__c pe : [select id,Patient_ID__c from Participant_Enrollment__c where Patient_ID__c in :pIds ]){
                string errKey = prRowIndexMap.get(pe.Patient_ID__c);
                if(peList.containsKey(pe.Patient_ID__c)){
                    
                     string row = rowsCSV.get(IndexPatientMap.get(pe.Patient_ID__c));
                    row = row.trim() + ',Duplicate Patient Record.;';
                    errRowsCSV.put(pe.Patient_ID__c,row);  
                    peList.remove(pe.Patient_ID__c);
                }
                else if(errRowsCSV.containsKey(errKey)){
                    string row = errRowsCSV.get(errKey);
                    row  = row.trim() + 'Duplicate Patient Record.;';
                    errRowsCSV.put(errKey,row);
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
                    string row = rowsCSV.get(IndexPatientMap.get(pe.Patient_ID__c));
                    row = row.trim() + ','+errMSG;
                    errRowsCSV.put(pe.Patient_ID__c,row); 
                }
            }
            
            // if(!errRowsCSV.isEmpty()){
            if(!hasErrRow){
                errCSVFile = rows[0].trim()+',Validation Errors'+ '\n';
                errCSVFile = errCSVFile +rows[1].trim()+','+ '\n';
            }
            else{
                errCSVFile = rows[0].trim()+ '\n';
                errCSVFile = errCSVFile +rows[1].trim()+ '\n';
            }
            if(!errRowsCSV.isEmpty()){
                for(String k : errRowsCSV.keyset()){
                    errCSVFile = errCSVFile + errRowsCSV.get(k) + '\n';
                }
            }
            Blob csvBlob = blob.valueOf(errCSVFile);
            string errFileName = 'error.csv';
            if( cv.Title.contains('.csv')){
                if(cv.Title.contains('_errors.csv')){
                    errFileName = cv.Title;
                }
                else{
                    errFileName  = cv.Title.split('.csv')[0]+'_errors.csv';
                }
            }
            else if( cv.Title.contains('.xlsx'))errFileName  = cv.Title.split('.xlsx')[0]+'_errors.csv';
            else if( cv.Title.contains('.xls'))errFileName  = cv.Title.split('.xls')[0]+'_errors.csv';
            ContentVersion contentToInsert =new ContentVersion(); 
            contentToInsert.Title =errFileName; 
            contentToInsert.VersionData=csvBlob;
            contentToInsert.ContentDocumentId = cv.ContentDocumentId;
            contentToInsert.PathOnClient='/'+errFileName;
            contentToInsert.IsMajorVersion = false;
            contentToInsert.Initial_Total_Records__c = totalRow;
            contentToInsert.Accepted__c = totalRow-errRowsCSV.size();
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
        errMap.put(8,'Mandatory field- Patient Auth. is missing.;');
        errMap.put(15,'Mandatory field-Delegate First Name is missing.;');
        errMap.put(16,'Mandatory field-Delegate Last Name is missing.;');
        errMap.put(17,'Mandatory field-Delegate Email address is missing.;');
        errMap.put(18,'Mandatory field-Primary Delegate Phone Number is missing.;');
        errMap.put(19,'Mandatory field-Primary Delegate Phone Type is missing.;');
        errMap.put(20,'Mandatory field-Primary Delegate YOB is missing.;');
        errMap.put(21,'Mandatory field-Legal Status of Primary Delegate is missing.;');
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