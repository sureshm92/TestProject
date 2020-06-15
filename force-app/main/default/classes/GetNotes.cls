/* Created By
* Velu */
public Without sharing class GetNotes {
    
    Public class NoteData{
        @AuraEnabled
        public list<ContentDocument> CD;
    }
    
    @AuraEnabled
    public static string getNotesdata(Id MediaRecordId) {
        
        try {
            List < ID > cdid = new list < Id > ();
            List < ContentDocumentLink > CDLink = new List < ContentDocumentLink > ();
            CDLink = [SELECT ContentDocumentId, LinkedEntityId, Visibility FROM ContentDocumentLink WHERE LinkedEntityId =: MediaRecordId];
            for (ContentDocumentLink cd: CDLink) {
                cdid.add(cd.ContentDocumentId);
            }
            List < ContentDocument > lstCD = new list < ContentDocument > ();
            lstCD = [select id, Title, CreatedDate from ContentDocument where id IN: cdid Order By CreatedDate DESC];
            NoteData ND = new NoteData();
            ND.CD=lstCD ;
            
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
}