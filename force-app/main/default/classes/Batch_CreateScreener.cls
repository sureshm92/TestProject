public class Batch_CreateScreener implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(
            [
                SELECT Id, Study_Code_Name__c, Link_to_Medical_Record_Review__c, Link_to_Pre_screening__c
                FROM Clinical_Trial_Profile__c 
                WHERE Link_to_Medical_Record_Review__c != null OR Link_to_Pre_screening__c != null
            ]
        );
    }
    
    public void execute(Database.BatchableContext bc, List<Clinical_Trial_Profile__c> ctpRecords) {
        
        
        List<PreScreener_Survey__c> surveyRecords = new List<PreScreener_Survey__c>();
        for(Clinical_Trial_Profile__c trailRecord : ctpRecords) {

            if(String.isNotBlank(trailRecord.Link_to_Medical_Record_Review__c)) {
                surveyRecords.add(
                    new PreScreener_Survey__c(
                        
                        Link_to_Pre_screening__c = trailRecord.Link_to_Medical_Record_Review__c,
                        MRR__c = true,
                        ProviderName__c = 'surveygizmo',
                        Study__c = trailRecord.Id,
                        Survey_Name__c = (String.isNotBlank(trailRecord.Study_Code_Name__c) ? trailRecord.Study_Code_Name__c + '_' : '')
                            + 'Medical Record Review'
                    )
                );
            }
            
            if(String.isNotBlank(trailRecord.Link_to_Pre_screening__c)) {
                surveyRecords.add(
                    new PreScreener_Survey__c(
                         
                        Link_to_Pre_screening__c = trailRecord.Link_to_Pre_screening__c,
                        Prescreener__c = true,
                        ProviderName__c = 'surveygizmo',
                        Study__c = trailRecord.Id,
                        Survey_Name__c = (String.isNotBlank(trailRecord.Study_Code_Name__c) ? trailRecord.Study_Code_Name__c + '_' : '')
                            + 'Prescreener'
                    )
                );
            }
        }
        
        List<Database.SaveResult> saveResults = Database.insert(surveyRecords, false);
       
    }
    
    public void finish(Database.BatchableContext bc){
        
        system.debug('Batch Create Screener is completed');
    }

   
}