public class Batch_CreateScreenerResponse implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(
            [
                SELECT Id, Clinical_Trial_Profile__c, Medical_Record_Review_Completed_by__c, Medical_Record_Review_Completed_Date__c, 
                    Medical_Record_Review_Status__c, MRR_Survey_Results_URL__c, Pre_Screener_Completed_by__c,
                    Pre_Screener_Completed_Date__c, Pre_Screener_Survey_Response__c, Pre_screening_Status__c, Referral_ID__c,
                    Clinical_Trial_Profile__r.Study_Code_Name__c
                FROM Participant_Enrollment__c 
                WHERE Medical_Record_Review_Completed_Date__c != null OR Pre_Screener_Completed_Date__c != null
            ]
        );
    }
    
    public void execute(Database.BatchableContext bc, List<Participant_Enrollment__c> enrollmentRecords) {
        
        Map<Id, Id> ctpMRRSurveyIdsMap = new Map<Id, Id>();
        Map<Id, Id> ctpScreenerSurveyIdsMap = new Map<Id, Id>();
        Set<Id> trailIds = new Set<Id>();

        for(Participant_Enrollment__c peRecord : enrollmentRecords) {

            trailIds.add(peRecord.Clinical_Trial_Profile__c);
        }

        for(PreScreener_Survey__c surveyRecord : [
            SELECT Id, MRR__c, Prescreener__c, Study__c 
            FROM PreScreener_Survey__c 
            WHERE Study__c IN :trailIds]) {

            if(surveyRecord.MRR__c) {
                ctpMRRSurveyIdsMap.put(surveyRecord.Study__c, surveyRecord.Id);
            } else if(surveyRecord.Prescreener__c) {
                ctpScreenerSurveyIdsMap.put(surveyRecord.Study__c, surveyRecord.Id);
            }
        }

        List<Participant_PrescreenerResponse__c> responseRecords = new List<Participant_PrescreenerResponse__c>();
        for(Participant_Enrollment__c peRecord : enrollmentRecords) {

            if(String.isNotBlank(peRecord.MRR_Survey_Results_URL__c)) {

                Participant_PrescreenerResponse__c mrrResponse = new Participant_PrescreenerResponse__c(
                    Completed_Date__c = peRecord.Medical_Record_Review_Completed_Date__c,
                    Participant_enrollment__c = peRecord.Id,
                    Screener_Response__c = peRecord.MRR_Survey_Results_URL__c
                );

                if(String.isBlank(peRecord.Referral_ID__c)) {
                    mrrResponse.Completed_by__c = peRecord.Medical_Record_Review_Completed_by__c;
                    mrrResponse.Status__c = peRecord.Medical_Record_Review_Status__c;
                    mrrResponse.MRR__c = true;
                    if(ctpMRRSurveyIdsMap.containsKey(peRecord.Clinical_Trial_Profile__c)) {
                        mrrResponse.PreScreener_Survey__c = ctpMRRSurveyIdsMap.get(peRecord.Clinical_Trial_Profile__c);
                    } 
                } else {
                    mrrResponse.Status__c = 'Pass';
                    mrrResponse.MRR_EPR__c = true;
                    mrrResponse.Completed_by__c = peRecord.Medical_Record_Review_Completed_by__c;
                }
                responseRecords.add(mrrResponse);
            }
            
            if(String.isNotBlank(peRecord.Pre_Screener_Survey_Response__c)) {

                Participant_PrescreenerResponse__c screenerResponse = new Participant_PrescreenerResponse__c(
                    Completed_by__c = peRecord.Pre_Screener_Completed_by__c,
                    Completed_Date__c = peRecord.Pre_Screener_Completed_Date__c,
                    Participant_enrollment__c = peRecord.Id,
                    Screener_Response__c = peRecord.Pre_Screener_Survey_Response__c,
                    Status__c = peRecord.Pre_screening_Status__c,
                    Prescreener__c = true
                );
                if(ctpScreenerSurveyIdsMap.containsKey(peRecord.Clinical_Trial_Profile__c)) {
                    screenerResponse.PreScreener_Survey__c = ctpScreenerSurveyIdsMap.get(peRecord.Clinical_Trial_Profile__c);
                }
                responseRecords.add(screenerResponse);
            }
        }
        
        TriggerHandlerExecutor.bypassHandler(ScreenerResponseTriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(
            ScreenerResponseTriggerHandler.CheckReimbursableActivities.class
        );

        List<Database.SaveResult> saveResults = Database.insert(responseRecords, false);
      
    }
    
    public void finish(Database.BatchableContext bc){
         // execute any post-processing operations
        system.debug('Batch for Creating Screener Responses successfully  completed');
        
    } 

  
}