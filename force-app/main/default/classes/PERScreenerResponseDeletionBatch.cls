global class PERScreenerResponseDeletionBatch implements Database.Batchable<sObject>, Database.Stateful{
    private String ctpId;
    private Boolean isStudyToDelete = false;
    private Set<Id> perScreenerResponseId = new Set<Id>();
    
    global PERScreenerResponseDeletionBatch(String ctpId){
        this.ctpId = ctpId;
    }
    global PERScreenerResponseDeletionBatch(String ctpId, Boolean isStudyToDelete){
        this.ctpId = ctpId;
        this.isStudyToDelete = isStudyToDelete;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'SELECT ID FROM Participant_PrescreenerResponse__c ';
        if(String.isNotBlank(ctpId)) {
            query += 'WHERE Participant_enrollment__r.Clinical_Trial_Profile__c = :ctpId ';
        } else {
            query += 'LIMIT 0';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Participant_PrescreenerResponse__c> lstScrreenerResponse){

        Set<Id> setResponseId = new Set<Id>(); 

        for(Participant_PrescreenerResponse__c objResponse :lstScrreenerResponse) {
            
            setResponseId.add(objResponse.Id);
        }
        
         if(isStudyToDelete) {
            delete [SELECT Id FROM Participant_PrescreenerResponse__c WHERE Id IN :setResponseId];
        } else {
            
            perScreenerResponseId.addAll((new Map<Id,Participant_PrescreenerResponse__c>(
                [SELECT Id FROM Participant_PrescreenerResponse__c WHERE Id IN :setResponseId]
            )).keySet());
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
        if(isStudyToDelete == false) {
        
            List<Study_Closure__c> studyClosureProcessList = [
                SELECT Id FROM Study_Closure__c WHERE Clinical_Trial_Profile_Id__c = :ctpId LIMIT 1
            ];
            if(studyClosureProcessList.isEmpty() == false) {
                
                List<ContentVersion> contentVersions =new List<ContentVersion>();
                contentVersions.add(Batch_SCParticipantEnrollment.constructCsvFile(
                    ctpId, 'Screener Response', perScreenerResponseId
                ));
                
                Batch_SCParticipantEnrollment.insertContentVersions(studyClosureProcessList[0].Id, contentVersions);
            }
        }
    }
}