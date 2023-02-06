global class IntegrationCalloutLogBatchDeletion implements Database.Batchable<sObject>, Database.Stateful{
    private String ctpId;
    private Boolean isStudyToDelete = false;
    private Set<Id> integrationCallOutLogIds = new Set<Id>();
    
    global IntegrationCalloutLogBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global IntegrationCalloutLogBatchDeletion (String ctpId, Boolean isStudyToDelete){
        this.ctpId = ctpId;
        this.isStudyToDelete = isStudyToDelete;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
       
        String query = 'SELECT Id,Name FROM Participant_Enrollment__c ';
        if(String.isNotBlank(ctpId)) {
            query += 'WHERE Clinical_Trial_Profile__c = :ctpId';
        } else {
            query += 'LIMIT 0';
        }
        return Database.getQueryLocator(query);
     
    }
    
    global void execute(Database.BatchableContext BC, List<Participant_Enrollment__c> partEnrollLst){
        List<String> perRefid = new List<String>();
        
        for(Participant_Enrollment__c per:partEnrollLst){
                perRefid.add(per.Name);    
        }
        if(isStudyToDelete) {
            if(!perRefid.isEmpty()){
                 delete [SELECT Id, Name, Reference_Id__c FROM Integration_Callout_Log__c
                                         WHERE Reference_Id__c IN :perRefid];
             }
        } else {
            
            if(!perRefid.isEmpty()){
                                     
                integrationCallOutLogIds.addAll((new Map<Id,Integration_Callout_Log__c>(
                   [SELECT Id, Name, Reference_Id__c FROM Integration_Callout_Log__c
                                             WHERE Reference_Id__c IN :perRefid]
                )).keySet());
                 
            }
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
                    ctpId, 'IntegrationCallOut Log', integrationCallOutLogIds
                ));
                
                Batch_SCParticipantEnrollment.insertContentVersions(studyClosureProcessList[0].Id, contentVersions);
            }
        }
        
    }
}