public class SurveyResponseViewController
{
    @AuraEnabled
    public static String getSurveyResponse(Id peId){
        Form_Results__c fr = [Select Id,
                                Days_14_of_symptoms__c, 
                                Consent_to_store_info__c, 
                                Covid_19_Test_Date__c, 
                                Positive_for_COVID_19__c, 
                                Participant_Enrollment__c,
                                Referral_Org__c,
                                Other_Referral_Org__c,
                                Estimated_Date_of_first_symptom__c,
                                Estimated_date_of_last_symptom__c 
                                FROM Form_Results__c
                                WHERE Participant_Enrollment__c =:  peId]; 
        List<Attachment> entries = new List<Attachment>();


        entries = [select Id, Name, ContentType from Attachment where parentid=:fr.id];
        return JSON.serialize(new SurveyResponseWrapper(fr, entries)); 
    }
    /*  @AuraEnabled
  public static String getSurveyResponse11(Id peId){
        Form_Results__c fr = [Select Id,
                                Days_14_of_symptoms__c, 
                                Consent_to_store_info__c, 
                                Covid_19_Test_Date__c, 
                                Positive_for_COVID_19__c, 
                                Participant_Enrollment__c,
                                Other_Referral_Org__c,
                                Estimated_Date_of_first_symptom__c,
                                Estimated_date_of_last_symptom__c 
                                FROM Form_Results__c
                                WHERE Participant_Enrollment__c =:  peId]; 

        System.debug('frId--->' +fr.Id);
        List<ContentDocumentLink> cdl = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: fr.Id];         
        
        System.debug('cdl-->'+cdl);
        List<ContentDocument> entries = new List<ContentDocument>();
        
        if(cdl!=Null)
        {
            List <Id> CDIdList = new List <Id> ();
            for (ContentDocumentLink nextCDL : cdl) {
            CDIdList.add(nextCDL.ContentDocumentId); }        

            entries = [SELECT Id, Title, FileType FROM ContentDocument WHERE ContentDocument.Id IN : CDIdList];
        }
        return JSON.serialize(new SurveyResponseWrapper(fr, entries)); 
    }*/

    public class SurveyResponseWrapper{
        public Form_Results__c fr;
        public List<Attachment> entries;
        
        public SurveyResponseWrapper(Form_Results__c fr, List<Attachment> entries){
            this.fr = fr;
            this.entries = entries;
        }
    }   
}