global class HCPEnrollmentBatchDeletion implements Database.Batchable<sObject>, Database.Stateful{
    private String ctpId;
    private Boolean isStudyToDelete = false;
    private Set<Id> hcpEnrollmentIds = new Set<Id>();
    
    global HCPEnrollmentBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global HCPEnrollmentBatchDeletion(String ctpId, Boolean isStudyToDelete){
        this.ctpId = ctpId;
        this.isStudyToDelete = isStudyToDelete;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query='SELECT Id, Name from HCP_Enrollment__c where Clinical_Trial_Profile__c = :ctpId';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<HCP_Enrollment__c> hcpEnrollLst){
    
        if(isStudyToDelete) {
            delete hcpEnrollLst;
        } else {
        
           hcpEnrollmentIds.addAll((new Map<Id, HCP_Enrollment__c>(
               hcpEnrollLst
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
                    ctpId, 'HCP Enrollment', hcpEnrollmentIds
                ));
                
                Batch_SCParticipantEnrollment.insertContentVersions(studyClosureProcessList[0].Id, contentVersions);
            }
        }   
    }
}