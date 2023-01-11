global class ResourceBatchDeletion implements Database.Batchable<sObject>, Database.Stateful {

    private String ctpId;
    private Boolean isStudyToDelete = false;
    private Set<Id> studyResIds = new Set<Id>();
    private Set<Id> resourceIds = new Set<Id>();
    private Set<Id> contentDocumentIds = new Set<Id>();
    
    global ResourceBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global ResourceBatchDeletion(String ctpId, Boolean isStudyToDelete){
        this.ctpId = ctpId;
        this.isStudyToDelete = isStudyToDelete;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'SELECT Id, Resource__c FROM Res_study__c ';
        if(String.isNotBlank(ctpId)) {
            query += 'WHERE Clinical_Trial_Profile__c = :ctpId';
        } else {
            query += 'LIMIT 0';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Res_study__c> resourceStudyList){
        
        List<Id> resourcesNotToBeDeleted = new List<Id>();
        List<Id> studyResToBeDeleted = new List<Id>();
        List<Id> resourcesToBeDeleted = new List<Id>();
        List<Id> cntDocIdToBeDeleted = new List<Id>();
        
        for(Res_study__c studyRes : resourceStudyList) {// Fetch Resource records
        
            resourceIds.add(studyRes.Resource__c);
        }    
        
        //Identify Resource studies for a resource which are not related to CTP(to be deleted)
        for(Res_study__c studyRes : [
            SELECT Id, Resource__c 
            FROM Res_study__c 
            WHERE Resource__c IN :resourceIds AND Clinical_Trial_Profile__c != : ctpId
        ]) {
            resourcesNotToBeDeleted.add(studyRes.Resource__c);//Not to be deleted
            //studyResToBeDeleted.add(studyRes.Id);
        }
        
        for(Res_study__c studyRes : resourceStudyList) {
        
            if(!resourcesNotToBeDeleted.contains(studyRes.Resource__c)) {
                resourcesToBeDeleted.add(studyRes.Resource__c);
            }
            studyResToBeDeleted.add(studyRes.Id);
        }
        
        //Fetch Files to delete
         if(!resourcesToBeDeleted.isEmpty()) {
            for(ContentDocumentLink cdLink : [
                SELECT Id, ContentDocumentId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId IN :resourcesToBeDeleted
            ]){
                cntDocIdToBeDeleted.add(cdLink.ContentDocumentId);
            }
        }
        
        if(isStudyToDelete) {
        
            if(!cntDocIdToBeDeleted.isEmpty()) {
            
                Database.delete(cntDocIdToBeDeleted, false);
                Database.emptyRecycleBin(cntDocIdToBeDeleted);
            }
            
            if(!studyResToBeDeleted.isEmpty()) {
            
                Database.delete(studyResToBeDeleted,false);
            }
            
            if(!resourcesToBeDeleted.isEmpty()) {
            
                Database.delete(resourcesToBeDeleted,false);
            }
        } else {
        
            studyResIds.addAll(studyResToBeDeleted);
            resourceIds.addAll(resourcesToBeDeleted);
            contentDocumentIds.addAll(cntDocIdToBeDeleted);
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
                    ctpId, 'Study Resource', studyResIds
                ));
                contentVersions.add(Batch_SCParticipantEnrollment.constructCsvFile(
                    ctpId, 'Resource', resourceIds
                ));
                contentVersions.add(Batch_SCParticipantEnrollment.constructCsvFile(
                    ctpId, 'Study Resource Content Document', contentDocumentIds
                ));
                
                Batch_SCParticipantEnrollment.insertContentVersions(studyClosureProcessList[0].Id, contentVersions);
            }
        }
    }
}