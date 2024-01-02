global class IntegrationBioMarkerFileBatchDeletion implements Database.Batchable<sObject>, Database.Stateful{
    private String ctpId;
    private Boolean isStudyToDelete = false;
    private Set<Id> contentDocumentIds = new Set<Id>();
    private Set<String> RefIds = new Set<String>();
    private Boolean onlySelectedPart = false;
    
    global IntegrationBioMarkerFileBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global IntegrationBioMarkerFileBatchDeletion(String ctpId, Boolean isStudyToDelete){
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
        String query = 'SELECT Id FROM Participant_Enrollment__c ';
        if(String.isNotBlank(ctpId)) {
            query += 'WHERE Clinical_Trial_Profile__c = :ctpId';
             if(onlySelectedPart){
                     query += ' AND Name IN:RefIds';
                }
        } else {
            query += 'LIMIT 0';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Participant_Enrollment__c> enrollmentList){
    
        Set<Id> integrationBioMarkerIds = new Set<Id>();
        List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
        List<Id> cdIds = new List<Id>();
        for(RH_Biomarker__c bioMarker : [
            SELECT Id, Integration_Biomarker__c 
            FROM RH_Biomarker__c 
            WHERE Participant_Enrollment__c IN :enrollmentList AND Integration_Biomarker__c != null
        ]){
            
            integrationBioMarkerIds.add(bioMarker.Integration_Biomarker__c);
        }
        cdl = [SELECT ContentDocumentId,Id,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN:integrationBioMarkerIds];
        
        if(cdl.isEmpty() == false){
            for(ContentDocumentLink  cd:cdl){
                cdIds.add(cd.ContentDocumentId);
            } 
         } 
        if(isStudyToDelete) {
            delete [SELECT Id FROM ContentDocument WHERE ID IN : cdIds];
        } else {
        
           contentDocumentIds.addAll((new Map<Id, ContentDocument>(
               [SELECT Id FROM ContentDocument WHERE ID IN : cdIds]
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
                    ctpId, 'Integration BioMarker Files', contentDocumentIds
                ));
                
                Batch_SCParticipantEnrollment.insertContentVersions(studyClosureProcessList[0].Id, contentVersions);
            }
        }   
    }
}