/* Created By
 * Velu */
public without sharing class GetNotes {
    public class NoteData {
        @AuraEnabled
        public list<ContentDocument> CD;
    }

    @AuraEnabled
    public static string getNotesdata(Id MediaRecordId) {
        try {
            List<ID> cdid = new List<Id>();
            List<ContentDocumentLink> CDLink = new List<ContentDocumentLink>();
            CDLink = [
                SELECT ContentDocumentId, LinkedEntityId, Visibility
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :MediaRecordId
            ];
            for (ContentDocumentLink cd : CDLink) {
                cdid.add(cd.ContentDocumentId);
            }
            List<ContentDocument> lstCD = new List<ContentDocument>();
            lstCD = [
                SELECT id, Title, CreatedDate
                FROM ContentDocument
                WHERE id IN :cdid
                ORDER BY CreatedDate DESC
            ];
            NoteData ND = new NoteData();
            ND.CD = lstCD;

            return JSON.serialize(ND);
        } catch (Exception e) {
            return (string) AuraHelper.throwException(e);
        }
    }
    @AuraEnabled
    public static void UpdateNotes(Id MediaRecordId, string notes) {
        try {
            if (String.isNotBlank(notes)) {
                ContentNote cnt = new ContentNote();
                cnt.Title = notes;
                insert cnt;

                ContentDocumentLink clnk = new ContentDocumentLink();
                clnk.LinkedEntityId = MediaRecordId;
                clnk.ContentDocumentId = cnt.Id;
                clnk.ShareType = 'V';
                clnk.Visibility = 'AllUsers';
                insert clnk;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static List<ContentNote> getNotesdatarp(Id RecordId) {
        try {
          
            List<ID> cdid = new List<Id>();
            List<ContentDocumentLink> CDLink = new List<ContentDocumentLink>();
            CDLink = [
                SELECT ContentDocumentId, LinkedEntityId, Visibility
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :RecordId
            ];
            for (ContentDocumentLink cd : CDLink) {
                cdid.add(cd.ContentDocumentId);
            }
            List<ContentNote> lstCD = new List<ContentNote>();
            lstCD =[SELECT Id,LastModifiedById,LastModifiedDate,Title,LastModifiedBy.Name,CreatedDate,CreatedBy.Name FROM ContentNote where Id IN:cdid 
                    ORDER BY LastModifieddate DESC];
            

            return lstCD;
        } catch (Exception e) {
          throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
     @AuraEnabled
    public static void CreateNotes(Id RecordId, string notes) {
        try {
            if (String.isNotBlank(notes)) {
                ContentNote cnt = new ContentNote();
                cnt.Title = notes;
                insert cnt;

                ContentDocumentLink clnk = new ContentDocumentLink();
                clnk.LinkedEntityId = RecordId;
                clnk.ContentDocumentId = cnt.Id;
                clnk.ShareType = 'V';
                clnk.Visibility = 'AllUsers';
                insert clnk;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    @AuraEnabled
    public static void UpdNotesSection(Id RecordId, string notes) {
        try {
             boolean profilechk = GetNotes.checkCurrentusrProfile();
                if(profilechk){
                    if (String.isNotBlank(notes)) {
                        ContentNote cnt = new ContentNote();
                        cnt.id = RecordId;
                        cnt.Title = notes;
                        update cnt;
                    }
                }else{
                   throw new AuraHandledException('You dont have permission to perform the operation.');
                }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    @AuraEnabled
    public static void deleteNotes (Id RecordId) {
        try {
                boolean profilechk = GetNotes.checkCurrentusrProfile();
                if(profilechk){
                    ContentNote cnt = new ContentNote();
                    cnt.id = RecordId;
                    delete cnt;
                }else{
                   throw new AuraHandledException('You dont have permission to perform the operation.');
                }
               
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    public static boolean checkCurrentusrProfile(){
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        if(profileName == 'Business Administrator' || profileName == 'System Administrator' ){
           return true;
        }else{
           return false;
        }
    }
}