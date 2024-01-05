global class IntegrationPatientReferralBatchDeletion implements Database.Batchable<sObject>, Database.Stateful{
    private String ctpId;
    private Boolean isStudyToDelete = false;
    private Set<Id> integrationLogIds = new Set<Id>();
    private Set<String> RefIds = new Set<String>();
    private Boolean onlySelectedPart = false;
    global IntegrationPatientReferralBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global IntegrationPatientReferralBatchDeletion(String ctpId, Boolean isStudyToDelete){
        this.ctpId = ctpId;
        this.isStudyToDelete = isStudyToDelete;
    }
    public class BatchControlException extends Exception{}
    global Database.QueryLocator start(Database.BatchableContext BC){
        List<Study_Closure__c> studyClosureList = [
                SELECT Id,Only_Selected_Participants__c FROM Study_Closure__c WHERE Clinical_Trial_Profile_Id__c = :ctpId LIMIT 1
            ];
        if(studyClosureList.isEmpty() == false){
              if(studyClosureList[0].Only_Selected_Participants__c){
                    onlySelectedPart = true;
                    List<Participant_Closure__c> partClosureList = [Select Name from Participant_Closure__c ];
                    for(Participant_Closure__c pc:partClosureList){
                        RefIds.add(pc.Name);
                    }
              }else{ onlySelectedPart = false;}
         }else{
                throw new BatchControlException('Please check the studyclosure record created or not for the study.');
         }
         
         
        String protocolId = [SELECT Id, Protocol_ID__c FROM Clinical_Trial_Profile__c WHERE Id = :ctpId].Protocol_ID__c;
        
        String query = 'SELECT Id,Participant_enrollment__r.Name,protocolId__c FROM Integration_Patient_Referral__c ';
        if(String.isNotBlank(protocolId)) {
             if(onlySelectedPart){
                     query += 'WHERE Participant_enrollment__r.Name IN:RefIds';
             }else{
                  query += 'WHERE protocolId__c = :protocolId';
             }
        } else {
            query += 'LIMIT 0';
        }
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Integration_Patient_Referral__c> iprLst){
        
         if(isStudyToDelete) {
            delete iprLst;
        } else {
            integrationLogIds.addAll((new Map<Id,Integration_Patient_Referral__c>(
                [SELECT Id FROM Integration_Patient_Referral__c WHERE Id IN :iprLst]
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
                    ctpId, 'Int Patient Referral', integrationLogIds
                ));
                
                Batch_SCParticipantEnrollment.insertContentVersions(studyClosureProcessList[0].Id, contentVersions);
            }
        }
    }
}