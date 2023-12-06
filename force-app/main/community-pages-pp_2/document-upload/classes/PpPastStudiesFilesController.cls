public with sharing class PpPastStudiesFilesController {
    public PpPastStudiesFilesController() {
    }
    @AuraEnabled
    public static List<Participant_Enrollment__c> getStudyList(Id contID, Boolean isDelegate) {
        Set<id> perIDs = new Set<id>();
        Set<id> studyIDs = new Set<id>();
        String getUserContact = UserContext.getUserContactId();
        List<Patient_Delegate_Enrollment__c> pder = new List<Patient_Delegate_Enrollment__c>();
        set<Id> setPrimaryPER = new set<Id> ();
        pastStudyFileWrapper wrap = new pastStudyFileWrapper();
        List<Participant_Enrollment__c> alumiPerList =  new List<Participant_Enrollment__c>();
        List<Participant_Enrollment__c> PrimaryalumniPERList = new List<Participant_Enrollment__c> ();

        for(Participant_Enrollment__c objPER :  [
            SELECT
                id,
                Participant_Status__c,
                Clinical_Trial_Profile__c,
                Clinical_Trial_Profile__r.Study_Code_Name__c,
                Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,
                Invited_To_PP_Date__c 
            FROM Participant_Enrollment__c
            WHERE
                Participant_Status__c IN :PEStatusState.PE_STATUS_GROUP_ALUMNI
                AND Participant_Contact__c = :contID
                AND Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = true            
            LIMIT 10000 ])
        {
            perIDs.add(objPER.id);
            studyIDs.add(objPER.Clinical_Trial_Profile__c);
            alumiPerList.add(objPER);
        }
       
        if (isDelegate) {
            for(Patient_Delegate_Enrollment__c objPDER : [SELECT id, Participant_Enrollment__c,Participant_Enrollment__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c
                FROM Patient_Delegate_Enrollment__c
                WHERE
                    Participant_Enrollment__c IN :perIDs
                    AND Patient_Delegate__r.Contact__c = :getUserContact
                    AND Primary_Delegate__c = TRUE
                    AND Participant_Enrollment__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = true
                    AND Status__c = 'Active'
                LIMIT 10000])
            {
                    setPrimaryPER.add(objPDER.Participant_Enrollment__c);
                    pder.add(objPDER);

            } 
            for(Participant_Enrollment__c objPER : alumiPerList){
                    if(setPrimaryPER.contains(objPER.Id))
                    {
                        PrimaryalumniPERList.add(objPER);
                    }

            }     
        }else{
            Integer indexOfElement = 0;
            for(Participant_Enrollment__c objPER : (new List<Participant_Enrollment__c>(alumiPerList))){
                if(objPER.Invited_To_PP_Date__c == null){
                    alumiPerList.remove(indexOfElement); // Remove the study if it is not invited to particiapnt.
                }
                indexOfElement += 1;
            }
        }


        if(!PrimaryalumniPERList.isEmpty()){
            return PrimaryalumniPERList;
        } 
        else{
            return alumiPerList;
        }
        
    }
    @AuraEnabled
    public static pastStudyFileWrapper fetchUploadedFiles(string contID, Integer pageNumber, String selectedStudyId, String sortOn, String sortType, Boolean isInitial, Boolean firstClick) {
        Set<Id> cntDocumentIds = new Set<Id>();
        List<ContentVersion> cvList = new List<ContentVersion>();
        pastStudyFileWrapper wrap= new pastStudyFileWrapper();
        String filterString;
        String getUserContact = UserContext.getUserContactId();
        //Boolean isInitial=false;
    
        List<String> uploadedByContact = new List<String>();
        String fileName ;
        String[] splittedName;

        Set<id> perIDs= new Set<id>();
        Set<id> studyIDs= new Set<id>();

        List<Participant_Enrollment__c> alumiPerList = [
            SELECT
                id,
                Participant_Status__c,
                Clinical_Trial_Profile__c,
                Clinical_Trial_Profile__r.Study_Code_Name__c,
                Participant_Contact__c
            FROM Participant_Enrollment__c
            WHERE
                Participant_Status__c IN :PEStatusState.PE_STATUS_GROUP_ALUMNI
                AND Participant_Contact__c = :contID
                AND Clinical_Trial_Profile__c =: selectedStudyId
            LIMIT 10000
        ];
        //logged in contact ka per alumi more thn 1 meaning ki multiple studies alumi hai.

        for (Participant_Enrollment__c per : alumiPerList) {
            perIDs.add(per.id);
            studyIDs.add(per.Clinical_Trial_Profile__c);
            uploadedByContact.add(per.Participant_Contact__c);
        }

        List<Patient_Delegate_Enrollment__c> pder = [
                SELECT id, Participant_Enrollment__c,
                Patient_Delegate__r.Contact__c
                FROM Patient_Delegate_Enrollment__c
                WHERE
                    Participant_Enrollment__c IN :perIDs
                    AND Patient_Delegate__r.Contact__c = :getUserContact
                    AND Primary_Delegate__c = TRUE
                LIMIT 10000
            ];
        
            for( Patient_Delegate_Enrollment__c pd : pder){
                uploadedByContact.add(pd.Patient_Delegate__r.Contact__c);
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
                                              WHERE LinkedEntityId IN: perIDs
                                              AND ContentDocument.CreatedById IN:useriDs ])
            {                                    
                cntDocumentIds.add(cdlink.ContentDocumentId);       
            }
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
            'ContentDocumentId IN : cntDocumentIds '+
            'AND FileStatus__c = \'Uploaded\'';

           

            String orderByString ;
            String qCountString = 'SELECT COUNT() FROM ContentVersion WHERE ContentDocumentId = :cntDocumentIds AND FileStatus__c = \'Uploaded\'';
            Integer offsetLimit = (pageNumber - 1) * 10;
            if(isInitial){
                 orderByString = ' ORDER BY CreatedDate DESC '+ 'LIMIT 10 '+ ' OFFSET :offsetLimit ';
            }
            else{
                sortType= firstClick ? 'ASC' : 'DESC';
                System.debug('sortOn ORDER BY '  + sortOn +' '+ sortType );
                 orderByString = ' ORDER BY ' + sortOn +' '+ sortType + ' LIMIT 10 '+  ' OFFSET :offsetLimit ';
            }
            //String orderByString = ' ORDER BY  ' + sortOn + sortType + 'LIMIT 10 '+ ' OFFSET :offsetLimit ';
            
            queryString=queryString+orderByString;
            System.debug('queryString@@ '  + queryString );
            cvList = Database.query(queryString);
            
            if(!cvList.isEmpty()){
                Map<Id,String> conDistLink = new Map<Id,String>();
                List<Id> cdId = new List<Id>();
            for(ContentVersion cv : cvList){
                    cv.ContentUrl = '../sfc/servlet.shepherd/document/download/'+ cv.ContentDocumentId;
                    // fileName=cv.Title;
                    // splittedName = fileName.split('\\.');
                    // wrap.fileName=splittedName[0];
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
            qCountString=qCountString;
            Integer totalCount = Database.countQuery(qCountString);

           

            wrap.totalCount=totalCount;
            wrap.cvList=cvList;
         
            return wrap;  
    }


    public class pastStudyFileWrapper{
        @AuraEnabled
        public Integer totalCount;
        @AuraEnabled
        public List<ContentVersion> cvList;
        @AuraEnabled
        public String fileName;
        @AuraEnabled
        public Map<Id,String> previewLinks;
       
    }

    @AuraEnabled
    public static void deleteFile( String fileID){
        ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion WHERE id = :fileID];
        contentdocument cd = new contentdocument(id = cv.contentDocumentId);
        delete cd;
    } 

}