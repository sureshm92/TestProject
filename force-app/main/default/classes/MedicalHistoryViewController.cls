public class MedicalHistoryViewController
{
    @AuraEnabled
    public static String getMedicalHistory(Id peId){
        
        Participant_Enrollment__c pe = [SELECT Id, 
                                        Participant__c
                                        FROM Participant_Enrollment__c
                                        WHERE Id = : peId];
        
        List<ContentDocument> entries = new List<ContentDocument>();
		
        List<ContentDocumentLink> cdls = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: pe.Participant__c];
		
        Set<Id> documentIds = new Set<Id>();
        for (ContentDocumentLink cdl : cdls) {
            documentIds.add(cdl.ContentDocumentId);
        }
        List<ContentDocument> documents = [SELECT Id, Title, CreatedDate, FileExtension, ContentModifiedDate FROM ContentDocument WHERE Id IN :documentIds 
                                           ORDER BY CreatedDate DESC LIMIT 1];
               
        String basefileUrl = URL.getSalesforceBaseUrl().toExternalForm();
        return JSON.serialize(new MedicalHistoryWrapper(pe, documents, basefileUrl));
    }

    public class MedicalHistoryWrapper{
        @AuraEnabled public Participant_Enrollment__c pe;
        @AuraEnabled public List<ContentDocument> attachments;
        @AuraEnabled public String baseURL;
        
        public MedicalHistoryWrapper(Participant_Enrollment__c pe, List<ContentDocument> attachments, String baseURL){
            this.pe = pe;
            this.attachments = attachments;
            this.baseURL = baseURL;
        }
    } 

}