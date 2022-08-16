global class IntegrationBioMarkerBatchDeletion implements Database.Batchable<sObject>, Database.Stateful{
    private String ctpId;
    private Boolean isStudyToDelete = false;
    private Set<Id> allIntegrationBiomarkerIds = new Set<Id>();
    
    global IntegrationBioMarkerBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
     global IntegrationBioMarkerBatchDeletion(String ctpId, Boolean isStudyToDelete){
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
        
        Set<Id> integrationBioMarkerIds = new Set<Id>();
        
        for(RH_Biomarker__c bioMarker : [
            SELECT Id, Integration_Biomarker__c 
            FROM RH_Biomarker__c 
            WHERE Participant_Enrollment__c IN :enrollmentList AND Integration_Biomarker__c != null
        ]) {
            
            integrationBioMarkerIds.add(bioMarker.Integration_Biomarker__c);
        }
        
        if(isStudyToDelete) {
            delete [SELECT Id FROM Integration_Biomarker__c WHERE Id IN :integrationBioMarkerIds];
        } else {
        
           allIntegrationBiomarkerIds.addAll((new Map<Id, Integration_Biomarker__c>(
               [SELECT Id FROM Integration_Biomarker__c WHERE Id IN :integrationBioMarkerIds]
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
                    ctpId, 'Integration BioMarker', allIntegrationBiomarkerIds
                ));
                
                Batch_SCParticipantEnrollment.insertContentVersions(studyClosureProcessList[0].Id, contentVersions);
            }
        }   

    }
}