public without sharing class ppFileUploadController {
    public ppFileUploadController() {
    }

    public class fileId{
        public string filecontentversion;
        public string FileContentDocId;
        public string prevUrl;
    }

    @AuraEnabled
    public static String saveTheChunkFile(
        Id parentId,
        String fileName,
        String base64Data,
        // String completeFile,
        String contentType,
        String fileId,
        String strfileContentDocumentId,
        Boolean isDeleted,
        Boolean isRetry,
        String Progress,
        Boolean isCancelButtonClicked
    ) {

        ppFileUploadController.fileId objWrapper = new ppFileUploadController.fileId();
        objWrapper.filecontentversion = fileId;
        objWrapper.FileContentDocId = strfileContentDocumentId;

        if(isCancelButtonClicked)
        {
            objWrapper.filecontentversion = '';
            objWrapper.FileContentDocId = '';
            return JSON.serialize(objWrapper);
        }


        if(isDeleted)
        {
            if(String.isNotBlank(fileId)){
                deleteFile(fileId);
            }
            objWrapper.filecontentversion = '';
            objWrapper.FileContentDocId = '';
            return JSON.serialize(objWrapper);

        }
        system.debug('>>isRetry>>'+isRetry);
        system.debug('>>isRetry>>'+fileId);
        if(isRetry && string.isNotBlank(fileId)){
            deleteFile(fileId);  
            fileId = '';
            strfileContentDocumentId='';
            system.debug('>>fileidd>>'+fileId);
        }

        
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        // base64Data = EncodingUtil.urlDecode(completeFile, 'UTF-8');
        if (String.isBlank(fileId)) {
            system.debug('>>inside save>>'+isRetry);
            objWrapper = saveFiles(parentId, fileName, base64Data,Progress); 
        } else {
            system.debug('>>inside apend>>'+isRetry);
            if(String.isBlank(objWrapper.prevUrl)){
                ContentDistribution  ctDistrId = [SELECT Id,DistributionPublicUrl FROM ContentDistribution WHERE ContentVersionId =: objWrapper.filecontentversion];
                objWrapper.prevUrl = ctDistrId.DistributionPublicUrl;
            }
            appendToFile(fileId, base64Data,Progress);
        }

        // return Id.valueOf(fileId);
        return JSON.serialize(objWrapper);
    }
    @AuraEnabled
    public static list<Patient_Delegate_Enrollment__c> checkifPrimary(
        Id perID,
        Id currentContactId
    ) {
        try {
            Boolean isPrimary = false;
            List<Patient_Delegate_Enrollment__c> per = [
                SELECT
                    id,
                    Status__c,
                    Patient_Delegate__c,
                    Participant_Enrollment__c,
                    Patient_Delegate__r.Contact__c,
                    Patient_Delegate__r.Contact__r.userCommunityDelegateId__c
                FROM Patient_Delegate_Enrollment__c
                WHERE
                    Primary_Delegate__c = TRUE
                    AND Participant_Enrollment__c = :perID
                    AND Patient_Delegate__r.Contact__c = :currentContactId
                LIMIT 1
            ];
            if (!per.isEmpty()) {
                return per;
            } else {
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static ppFileUploadController.fileId saveFiles(Id recordId, String fileName, String base64Data,String Progress) {
        ContentVersion contentToInsert = new ContentVersion();
        contentToInsert.Title = fileName;
        contentToInsert.VersionData = EncodingUtil.base64Decode(base64Data);
        contentToInsert.PathOnClient = '/' + fileName;
        contentToInsert.IsMajorVersion = false;
        contentToInsert.FileStatus__c = 'Draft';
        contentToInsert.progress__c = Progress;
        insert contentToInsert;
        system.debug('>>contentToInsert>>'+contentToInsert);
        contentToInsert = [
            SELECT id, ContentDocumentId, Title
            FROM ContentVersion
            WHERE Id = :contentToInsert.Id
        ];
        ContentDocumentLink cl = new ContentDocumentLink();
        cl.ContentDocumentId = contentToInsert.ContentDocumentId;
        cl.LinkedEntityId = recordId;
        cl.ShareType = 'I';
        cl.Visibility = 'AllUsers';
        insert cl;
        string fileNamewoExt = contentToInsert.Title;
        Integer intIndex = fileNamewoExt.lastindexOf('.');
        String fileTitle = fileNamewoExt.left(intIndex);
        
        String sizeStringFileName = fileTitle;
        Integer maxSize = 96;
        if(sizeStringFileName.length() > maxSize ){
        sizeStringFileName = sizeStringFileName.substring(0, maxSize);
        sizeStringFileName = sizeStringFileName+'...'; 
        }
        
        ContentDistribution ctDistrId = new ContentDistribution(
            ContentVersionId = contentToInsert.Id,
            Name = sizeStringFileName,
            PreferencesNotifyOnVisit = false,
            PreferencesAllowPDFDownload = false
        );
        Insert ctDistrId;
        ctDistrId = [SELECT Id,DistributionPublicUrl FROM ContentDistribution WHERE ContentVersionId =: contentToInsert.Id];
        ppFileUploadController.fileId objWrapper = new ppFileUploadController.fileId();
        objWrapper.filecontentversion = contentToInsert.Id;
        objWrapper.FileContentDocId = contentToInsert.ContentDocumentId;
        objWrapper.prevUrl = ctDistrId.DistributionPublicUrl;
        // return contentToInsert.id;
        
        return objWrapper;
    }

    @AuraEnabled
    public static void appendToFile(Id contentDocumentId, String base64Data,String Progress) {
        //base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        ContentVersion versionData = [
            SELECT Id, VersionData, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :contentDocumentId
        ];

        String existingBody = EncodingUtil.base64Encode(versionData.VersionData);
        versionData.VersionData = EncodingUtil.base64Decode(existingBody + base64Data);
        versionData.progress__c = Progress;
        system.debug('>>progress>>'+versionData);
        update versionData;
    }
    @AuraEnabled
    public static void deleteFile(String fileId) {
        ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion WHERE id = :fileId];
        contentdocument cd = new contentdocument(id = cv.contentDocumentId);
        delete cd;
    }

    //method to fetch existing error files
    @AuraEnabled(cacheable=false)
    public static List<ContentVersion> fetchFiles(string delegateId) {
        Set<Id> cntDocumentIds = new Set<Id>();
        List<ContentVersion> errcvList = new List<ContentVersion>();
        try {
            Contact cnt = new Contact();
            if (delegateId == null) {
                cnt.id = [SELECT contactId FROM user WHERE Id = :userInfo.getUserId()].contactId;
            } else {
                cnt.id = delegateId;
            }
            for (ContentDocumentLink cdlink : [
                SELECT Id, LinkedEntityId, ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :cnt.id
            ]) {
                cntDocumentIds.add(cdlink.ContentDocumentId);
            }

            errcvList = [
                SELECT
                    VersionData,
                    Title,
                    CreatedBy.Name,
                    ContentModifiedDate,
                    ContentUrl,
                    Initial_Total_Records__c,
                    Accepted__c,
                    Rejected_Records__c,
                    ContentDocumentId,
                    PathOnClient
                FROM ContentVersion
                WHERE
                    IsLatest = TRUE
                    AND ContentDocumentId IN :cntDocumentIds
                    AND FileExtension = 'csv'
                    AND Initial_Total_Records__c != NULL
                ORDER BY createddate DESC
            ];

            for (ContentVersion cv : errcvList) {
                if (cv.Rejected_Records__c != 0)
                    cv.ContentUrl =
                        '/sfc/servlet.shepherd/document/download/' + cv.ContentDocumentId;
                else
                    cv.ContentUrl = null;
            }

            return errcvList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    //method to fetch existing files
    @AuraEnabled(cacheable=false)
    public static fileUploadedWrapper fetchUploadedFiles(
        string perId,
        Integer pageNumber,
        Boolean isDelegate,
        String sortOn, 
        String sortType, 
        Boolean isInitial, 
        Boolean firstClick
    ) {
        try {
            Set<Id> cntDocumentIds = new Set<Id>();
            List<ContentVersion> cvList = new List<ContentVersion>();
            fileUploadedWrapper wrap = new fileUploadedWrapper();
            String filterString;

            List<String> uploadedByContact = new List<String>();
            String fileName;
            String[] splittedName;

            lIST<Participant_Enrollment__c> per = [
                SELECT id, Participant_Contact__c
                FROM Participant_Enrollment__c
                WHERE id = :perId
                LIMIT 1
            ];

            List<Patient_Delegate_Enrollment__c> pder = [
                SELECT
                    id,
                    Patient_Delegate__r.Contact__c,
                    Participant_Enrollment__r.Participant_Contact__c
                FROM Patient_Delegate_Enrollment__c
                WHERE Participant_Enrollment__c = :perId AND Primary_Delegate__c = TRUE
                LIMIT 1
            ];

            if (!per.isEmpty()) {
                uploadedByContact.add(per[0].Participant_Contact__c);
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
            Contact cnt = new Contact();

            for (ContentDocumentLink cdlink : [
                SELECT Id, LinkedEntityId, ContentDocument.CreatedById, ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :perId AND ContentDocument.CreatedById IN :useriDs
            ]) {
                cntDocumentIds.add(cdlink.ContentDocumentId);
            }
            // cvList = [SELECT VersionData,Title, CreatedBy.Name, ContentModifiedDate, ContentUrl, ContentDocumentId, PathOnClient
            //             FROM ContentVersion
            //             WHERE ContentDocumentId IN : cntDocumentIds  ORDER BY createddate DESC];

            String queryString =
                'SELECT ' +
                'id,' +
                //'VersionData,'+
                'Title,' +
                'CreatedBy.Name,' +
                'ContentModifiedDate,' +
                'ContentUrl,' +
                'CreatedDate,' +
                'ContentDocumentId,' +
                'FileType,' +
                'PathOnClient ' +
                ' FROM ContentVersion WHERE ' +
                'ContentDocumentId IN : cntDocumentIds '+
                'AND FileStatus__c = \'Uploaded\'';

            String qCountString = 'SELECT COUNT() FROM ContentVersion WHERE ContentDocumentId = :cntDocumentIds AND FileStatus__c = \'Uploaded\'';
            System.debug('pageNumber' + pageNumber);
            Integer offsetLimit = (pageNumber - 1) * 10;
            String orderByString;
            if(isInitial){
                orderByString =
                    ' ORDER BY CreatedDate DESC ' +
                    'LIMIT 10 ' +
                    ' OFFSET :offsetLimit ';
            }
            else{
                sortType= firstClick ? 'ASC' : 'DESC';
                orderByString = ' ORDER BY ' + sortOn +' '+ sortType + ' LIMIT 10 '+  ' OFFSET :offsetLimit ';
            }

            queryString = queryString + orderByString;
            cvList = Database.query(queryString);

            if (!cvList.isEmpty()) {
                Map<Id,String> conDistLink = new Map<Id,String>();
                List<Id> cdId = new List<Id>();
              
                for (ContentVersion cv : cvList) {
                    cv.ContentUrl =
                        '../sfc/servlet.shepherd/document/download/' + cv.ContentDocumentId;
                    //String test=cv.Title.lastIndexOf('.');
                    integer index = cv.Title.lastIndexOf('.');
                    List<string> res = new List<String>();
                    res.add(cv.Title.substring(0, index));
                    res.add(cv.Title.substring(++index));
                    cv.Title =res[0];
                    cdId.add(cv.ContentDocumentId);
                }
                List<ContentDistribution> lstContDist = new List<ContentDistribution>();
                lstContDist = [Select ContentDocumentId,DistributionPublicUrl from ContentDistribution where ContentDocumentId IN:cdId];   
                for(ContentDistribution cd:lstContDist){
                      conDistLink.put(cd.ContentDocumentId,cd.DistributionPublicUrl);
                }
                wrap.previewLinks = conDistLink;
               
            }
            qCountString = qCountString;
            Integer totalCount = Database.countQuery(qCountString);

            wrap.totalCount = totalCount;
            wrap.cvList = cvList;

            return wrap;

            //return cvList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    //method to fetch message files
    @AuraEnabled(cacheable=false)
    public static fileMessageWrapper fetchMessageFiles(
        string perId,
        Integer pageNumber,
        String sortOn, 
        String sortType, 
        Boolean isInitial, 
        Boolean firstClick
    ) {
        try {
            Set<Id> cntDocumentIds = new Set<Id>();
            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
            fileMessageWrapper wrap = new fileMessageWrapper();
            String filterString;

            List<String> uploadedByContact = new List<String>();
            String fileName;
            String[] splittedName;
            
         List<Conversation__c> conv = new  List<Conversation__c>();
         List<Conversation__c> sharedConversations = ConversationService.getSharedConversations(
                UserInfo.getUserId()
            );
          if (sharedConversations != null) {
                    for (Conversation__c con : sharedConversations) {
                        if (perId.contains(con.Participant_Enrollment__c)){
                            conv.add(con);
                        }
                    }
           }
            if(!conv.isEmpty() && conv !=null){
                String convId = conv[0].Id;  
            
                   String queryString =
                    'SELECT ' +
                    'id,' +
                    'ContentDocumentId,' +
                    'ContentDocument.CreatedDate,' +
                    'ContentDocument.CreatedById,' +
                    'ContentDocument.Title,' +
                    'ContentDocument.FileExtension,' +
                    'ContentDocument.LatestPublishedVersionId,' +
                    'LinkedEntityId ' +
                    ' FROM ContentDocumentLink WHERE ' +
                    'LinkedEntityId =: convId';
                    
                 
                String qCountString = 'SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :convId ';
                System.debug('pageNumber' + pageNumber);
                Integer offsetLimit = (pageNumber - 1) * 10;
                String orderByString;
                if(isInitial){
                    orderByString =
                        ' ORDER BY ContentDocument.CreatedDate DESC ' +
                        'LIMIT 10 ' +
                        ' OFFSET :offsetLimit ';
                }
                else{
                    sortType= firstClick ? 'ASC' : 'DESC';
                    orderByString = ' ORDER BY ' + sortOn +' '+ sortType + ' LIMIT 10 '+  ' OFFSET :offsetLimit ';
                }
    
                queryString = queryString + orderByString;
                cdlList = Database.query(queryString);
    
                
                qCountString = qCountString;
                Integer totalCount = Database.countQuery(qCountString);
                
                if(!cdlList.isEmpty()){
                 Map<Id,String> conDistLink = new Map<Id,String>();
                 List<Id> cdId = new List<Id>();
                 for(ContentDocumentLink cdl:cdlList){
                        cdId.add(cdl.ContentDocumentId);
                 }
                 List<ContentDistribution> lstContDist = new List<ContentDistribution>();
                 lstContDist = [Select ContentDocumentId,DistributionPublicUrl from ContentDistribution where ContentDocumentId IN:cdId];   
                 for(ContentDistribution cd:lstContDist){
                       conDistLink.put(cd.ContentDocumentId,cd.DistributionPublicUrl);
                 }
                  wrap.previewLinks = conDistLink;
                }
                wrap.totalCount = totalCount;
                wrap.cdlList = cdlList; 
            }else{
                wrap.totalCount = 0;
                wrap.cdlList = null; 
            } 
           

            return wrap;
          
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    public class fileUploadedWrapper {
        @AuraEnabled
        public Integer totalCount;
        @AuraEnabled
        public List<ContentVersion> cvList;
        @AuraEnabled
        public String fileName;
        @AuraEnabled
        public Map<Id,String> previewLinks;
    }
     public class fileMessageWrapper {
        @AuraEnabled
        public Integer totalCount;
        @AuraEnabled
        public List<ContentDocumentLink> cdlList;
        @AuraEnabled
        public String fileName;
        @AuraEnabled
        public Map<Id,String> previewLinks;
    }
    @AuraEnabled
    public static DraftFileWrapper isUplaodAvailable(string perId) {
        try {
            Boolean isUplaodAvailable = false;
            Set<Id> cntDocumentIds = new Set<Id>();

            LIST<Participant_Enrollment__c> per = [
                SELECT
                    id,
                    Participant_Contact__c,
                    Clinical_Trial_Profile__r.Document_Upload_Is_Available__c
                FROM Participant_Enrollment__c
                WHERE id = :perId
                LIMIT 1
            ];

            for (ContentDocumentLink cdlink : [  SELECT Id, LinkedEntityId, ContentDocument.CreatedById, ContentDocumentId
                                                 FROM ContentDocumentLink   WHERE LinkedEntityId = :perId  
                                                 AND ContentDocument.CreatedById =: userinfo.getUserId()]) {
                cntDocumentIds.add(cdlink.ContentDocumentId);
            }
            Set<id> draftDocumnetIds=new  Set<id>();
            for( ContentVersion lstConversationDraft : [SELECT Id,OwnerId, Title,ContentSize,ContentDocumentId, CreatedDate, FileExtension, ContentModifiedDate FROM ContentVersion
                                                WHERE ContentDocumentId IN : cntDocumentIds AND FileStatus__c = 'Draft']) {
                draftDocumnetIds.add(lstConversationDraft.ContentDocumentId);
            }

            isUplaodAvailable = per[0].Clinical_Trial_Profile__r.Document_Upload_Is_Available__c;
            DraftFileWrapper objWrapper = new DraftFileWrapper();

            objWrapper.isUplaodAvailable = isUplaodAvailable;
            // objWrapper.lstContentVersion = lstConversationDraft.isEmpty() ? null : lstConversationDraft;
            objWrapper.lstContentVersion =  null ;

            

            if( !draftDocumnetIds.isEmpty()){
                deletDraftFiles(draftDocumnetIds);
            }


            return objWrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    @Future
    public static void deletDraftFiles(Set<id> cntDocumentIds) {
        try {
           // List< ContentVersion> cvDelete= new  List< ContentVersion>();
            List< contentdocument> cdDelete= new  List< contentdocument>();
            for( Id cdId: cntDocumentIds){
                contentdocument cd = new contentdocument(id = cdId);
                cdDelete.add(cd);

            }
            delete cdDelete;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    public class DraftFileWrapper {
        @AuraEnabled
        public List<ContentVersion> lstContentVersion;
        @AuraEnabled
        public Boolean isUplaodAvailable;
    }


    @AuraEnabled 
    public static void uploadFiles(String strFileData, String perId){
        list<uploadFileWrapper> lstWrapper = (List<uploadFileWrapper>)JSON.deserialize(strFileData, list<uploadFileWrapper>.class);
        List<ContentVersion> lstCV = new list<ContentVersion> ();
        List<string> lstCVToDelete = new list<string> ();
        
        for(uploadFileWrapper objWrapper : lstWrapper){
            if(!objWrapper.error && !objWrapper.isDeleted && String.isNotBlank(objWrapper.fileContentVerId)){
               ContentVersion objCv = new ContentVersion();
               objCv.FileStatus__c = 'Uploaded';
               objCv.Id=objWrapper.fileContentVerId;
               objCv.Title = objWrapper.fileName;
               lstCV.add(objCv);
            }
            if(String.isNotBlank(objWrapper.fileContentVerId) && (objWrapper.error || objWrapper.isDeleted))
            {
                lstCVToDelete.add(objWrapper.fileContentVerId);
            }    
            
        }
        update lstCV;
        deleteFilewithlist(lstCVToDelete,perId);

    }
    @AuraEnabled
    public static void deleteFilewithlist(list<string>  lstCVToDelete,String perId) {
        list<contentdocument> lstContentDocId = new list<contentdocument> ();
        set<Id> cntDocumentIds = new set<Id> ();
        for (ContentDocumentLink cdlink : [  SELECT Id, LinkedEntityId, ContentDocument.CreatedById, ContentDocumentId
                                                 FROM ContentDocumentLink   WHERE LinkedEntityId = :perId  
                                                 AND ContentDocument.CreatedById =: userinfo.getUserId()]) {
                cntDocumentIds.add(cdlink.ContentDocumentId);
            }
           
        for(ContentVersion cv : [SELECT ContentDocumentId FROM ContentVersion WHERE (ContentDocumentId IN : cntDocumentIds or id IN: lstCVToDelete) 
                                 AND FileStatus__c = 'Draft'])
        {
            contentdocument cd = new contentdocument(id = cv.contentDocumentId);
            lstContentDocId.add(cd);
        }
        database.delete(lstContentDocId, false);
        
    }

    @AuraEnabled 
   @Future
    public static void DeleteAlldraftFiles(String perId)
    {
       try{
            set<Id> cntDocumentIds = new set<Id> ();
            list<contentdocument> lstContentDocId = new list<contentdocument> ();
            for (ContentDocumentLink cdlink : [SELECT Id, LinkedEntityId, ContentDocument.CreatedById, ContentDocumentId
                                            FROM ContentDocumentLink   WHERE LinkedEntityId = :perId  
                                            AND ContentDocument.CreatedById =: userinfo.getUserId()]) {
                    cntDocumentIds.add(cdlink.ContentDocumentId);
            }
            for(ContentVersion cv : [SELECT ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN : cntDocumentIds 
                                    AND FileStatus__c = 'Draft'])
            {
                contentdocument cd = new contentdocument(id = cv.contentDocumentId);
                lstContentDocId.add(cd);
            }
            database.delete(lstContentDocId, false);
        }  
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }

    }

    public class uploadFileWrapper{
        public Integer index;
        public string fileContentVerId;
        public Boolean isDeleted;
        public Boolean error;
        public string fileName;
    }
}