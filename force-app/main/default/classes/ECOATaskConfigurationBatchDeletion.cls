global class ECOATaskConfigurationBatchDeletion implements Database.Batchable<sObject>, Database.Stateful {
    private String ctpId;
    private Boolean isStudyToDelete = false;
    private Set<Id> taskConfigIds = new Set<Id>();
    
    global ECOATaskConfigurationBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global ECOATaskConfigurationBatchDeletion(String ctpId, Boolean isStudyToDelete){
        this.ctpId = ctpId;
        this.isStudyToDelete = isStudyToDelete;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'SELECT Id FROM Participant_Enrollment__c ';
        if(String.isNotBlank(ctpId)) {
            query += 'WHERE Clinical_Trial_Profile__c = :ctpId';
        } else {
            query += 'LIMIT 0';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Participant_Enrollment__c> enrollmentList){
        
        if(isStudyToDelete) {
        
            delete [SELECT Id FROM Ecoa_Task_Configuration__c WHERE Participant_Enrollment__c IN :enrollmentList];
        } else {
            
            taskConfigIds.addAll((new Map<Id,Ecoa_Task_Configuration__c>(
                [SELECT Id FROM Ecoa_Task_Configuration__c WHERE Participant_Enrollment__c IN :enrollmentList]
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
                    ctpId, 'Ecoa Task Configuration', taskConfigIds
                ));
                
                Batch_SCParticipantEnrollment.insertContentVersions(studyClosureProcessList[0].Id, contentVersions);
            }
        }
    }
}