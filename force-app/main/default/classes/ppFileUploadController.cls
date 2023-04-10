public with sharing class ppFileUploadController {
    public ppFileUploadController() {
        

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
    public static list<Patient_Delegate_Enrollment__c> checkifPrimary(Id perID, Id currentContactId){
    try{
       Boolean isPrimary=false;
       List<Patient_Delegate_Enrollment__c> per=[SELECT id, Status__c, Patient_Delegate__c,
                                            Participant_Enrollment__c , Patient_Delegate__r.Contact__c,
                                            Patient_Delegate__r.Contact__r.userCommunityDelegateId__c
                                            FROM Patient_Delegate_Enrollment__c
                                            WHERE 
                                            Primary_Delegate__c=true 
                                            AND 
                                            Participant_Enrollment__c =:perID
                                            AND 
                                            Patient_Delegate__r.Contact__c =: currentContactId LIMIT 1];
        if(!per.isEmpty()){
            return per;
        }
        else{
            return null;
        }
        
    }
    catch (Exception e) {
        throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        } 
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
        cl.ShareType = 'I';
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

    //method to fetch existing files
    @AuraEnabled(cacheable=false)
    public static fileUploadedWrapper fetchUploadedFiles(string perId, Integer pageNumber, Boolean isDelegate){
        try{
            Set<Id> cntDocumentIds = new Set<Id>();
            List<ContentVersion> cvList = new List<ContentVersion>();
            fileUploadedWrapper wrap= new fileUploadedWrapper();
            String filterString;
        
            List<String> uploadedByContact = new List<String>();
            String fileName ;
            String[] splittedName;

            lIST<Participant_Enrollment__c> per =[SELECT id, Participant_Contact__c FROM Participant_Enrollment__c
                                             WHERE id=: perId LIMIT 1];


            List<Patient_Delegate_Enrollment__c> pder = [SELECT id, Patient_Delegate__r.Contact__c ,
                                                  Participant_Enrollment__r.Participant_Contact__c
                                                  FROM Patient_Delegate_Enrollment__c
                                                  WHERE Participant_Enrollment__c=: perId
                                                  AND Primary_Delegate__c = TRUE LIMIT 1];

            if(!per.isEmpty()){
                uploadedByContact.add(per[0].Participant_Contact__c);
            }

            if(!pder.isEmpty()){
                uploadedByContact.add(pder[0].Patient_Delegate__r.Contact__c);
            }
           

            List<User> uploadedUser = [Select id, contactId from user where contactId in: uploadedByContact];
            List< id> useriDs=new List< id>();
            for(User u:uploadedUser ){
                useriDs.add(u.id);
            } 
            Contact cnt = new Contact();
            
             for(ContentDocumentLink cdlink : [Select Id, 
                                              LinkedEntityId, ContentDocument.CreatedById	,
                                              ContentDocumentId 
                                              FROM ContentDocumentLink 
                                              WHERE LinkedEntityId=: perId
                                              AND ContentDocument.CreatedById IN:useriDs ])
            {                                    
                cntDocumentIds.add(cdlink.ContentDocumentId);       
            }
            // cvList = [SELECT VersionData,Title, CreatedBy.Name, ContentModifiedDate, ContentUrl, ContentDocumentId, PathOnClient 
            //             FROM ContentVersion 
            //             WHERE ContentDocumentId IN : cntDocumentIds  ORDER BY createddate DESC];
            

            String queryString =
            'SELECT '+
            'id,'+
            //'VersionData,'+
            'Title,'+
            'CreatedBy.Name,'+
            'ContentModifiedDate,'+
            'ContentUrl,'+
            'CreatedDate,'+
            'ContentDocumentId,'+
            'FileType,'+
            'PathOnClient '+
            ' FROM ContentVersion WHERE '+
            'ContentDocumentId IN : cntDocumentIds';

            
            String qCountString = 'SELECT COUNT() FROM ContentVersion WHERE ContentDocumentId = :cntDocumentIds ';
            System.debug('pageNumber'+pageNumber);
            Integer offsetLimit = (pageNumber - 1) * 10;
            System.debug('offsetLimit'+offsetLimit);
            String orderByString = ' ORDER BY CreatedDate DESC '+ 'LIMIT 10 '+ ' OFFSET :offsetLimit ';
            
            queryString=queryString+orderByString;
            cvList = Database.query(queryString);
            
            if(!cvList.isEmpty()){
            for(ContentVersion cv : cvList){
                    cv.ContentUrl = '../sfc/servlet.shepherd/document/download/'+ cv.ContentDocumentId;
                    cv.Title=cv.Title.split('\\.')[0];
            }
        }
            qCountString=qCountString;
            Integer totalCount = Database.countQuery(qCountString);

           

            wrap.totalCount=totalCount;
            wrap.cvList=cvList;
         
            return wrap;
            
            //return cvList;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }    
    }
    public class fileUploadedWrapper{
        @AuraEnabled
        public Integer totalCount;
        @AuraEnabled
        public List<ContentVersion> cvList;
        @AuraEnabled
        public String fileName;
       
        
        
    }
    @AuraEnabled
    public static Boolean isUplaodAvailable(string perId){
        try{
            Boolean isUplaodAvailable=false;

            LIST<Participant_Enrollment__c> per =[SELECT id, Participant_Contact__c,Clinical_Trial_Profile__r.Document_Upload_Is_Available__c FROM Participant_Enrollment__c
                                             WHERE id=: perId LIMIT 1];

            isUplaodAvailable=per[0].Clinical_Trial_Profile__r.Document_Upload_Is_Available__c;
           return isUplaodAvailable;

                  }catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }    
    }
}