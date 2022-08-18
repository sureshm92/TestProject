global class StudbyHubIntegrationLogDeletionBatch implements Database.Batchable<sObject>, Database.Stateful{
    private String ctpId;
    private Boolean isStudyToDelete = false;
    private Set<Id> integrationLogIds = new Set<Id>();
    
    global StudbyHubIntegrationLogDeletionBatch(String ctpId){
        this.ctpId = ctpId;
    }
    global StudbyHubIntegrationLogDeletionBatch(String ctpId, Boolean isStudyToDelete){
        this.ctpId = ctpId;
        this.isStudyToDelete = isStudyToDelete;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'SELECT Study_Hub_Log__c FROM Participant_Enrollment__c ';
        if(String.isNotBlank(ctpId)) {
            query += 'WHERE Clinical_Trial_Profile__c = :ctpId AND Study_Hub_Log__c != null';
        } else {
            query += 'LIMIT 0';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Participant_Enrollment__c> enrollmentList){
        
        Set<Id> integrationLogOldIds = new Set<Id>();
        
        for(Participant_Enrollment__c enrollment :enrollmentList) {
            
            integrationLogOldIds.add(enrollment.Study_Hub_Log__c);
        }
        
         if(isStudyToDelete) {
            delete [SELECT Id FROM Integration_Log__c WHERE Id IN :integrationLogOldIds];
        } else {
            
            integrationLogIds.addAll((new Map<Id,Integration_Log__c>(
                [SELECT Id FROM Integration_Log__c WHERE Id IN :integrationLogOldIds]
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
                    ctpId, 'Integration Log', integrationLogIds
                ));
                
                Batch_SCParticipantEnrollment.insertContentVersions(studyClosureProcessList[0].Id, contentVersions);
            }
        }
    }
}