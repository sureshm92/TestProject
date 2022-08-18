global class PresetFilterBatchDeletion implements Database.Batchable<sObject>, Database.Stateful {
    
    private String ctpId;
    private Boolean isStudyToDelete = false;
    private Set<Id> deletePresetFilterIds = new Set<Id>();
    private Set<Id> updatePresetFilterIds = new Set<Id>();
    private Set<Id> studySiteIds = new Set<Id>();
    
    global PresetFilterBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global PresetFilterBatchDeletion(String ctpId, Boolean isStudyToDelete){
        this.ctpId = ctpId;
        this.isStudyToDelete = isStudyToDelete;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        
        String query = 'SELECT Id, StudyId__c, Study_Site_Id__c FROM Preset_Filter__c ';
        if(String.isNotBlank(ctpId)) {
        
            studySiteIds.addAll((new Map<Id,Study_Site__c>(
                [SELECT Id FROM Study_Site__c WHERE Clinical_Trial_Profile__c =:ctpId]
            )).keySet());
        } else {
        
            query += 'LIMIT 0';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Preset_Filter__c> presetFilterList){
        
        
        List<Preset_Filter__c> presetToBeDeleted = new List<Preset_Filter__c>();
        List<Preset_Filter__c> presetToBeUpdated = new List<Preset_Filter__c>();
        
        for(Preset_Filter__c preset: presetFilterList) {
        
            List<String> studiesList = new List<String>();
            List<String> studySiteList = new List<String>();
            studiesList = preset.StudyId__c.split(';');
            studySiteList = preset.Study_Site_Id__c.split(';');
            
            if(studiesList.contains(ctpId) && studiesList.size() == 1) {//if only one study in the list delete
                //delete preset record
                presetToBeDeleted.add(preset);
                
            } else if(studiesList.contains(ctpId) && studiesList.size() > 1) {// if more than one study, check for study sites
                //Logic to remove study sites & Study Ids & update preset record
                studiesList.remove(studiesList.indexOf(ctpId)); // Remove study Id from study List
                
                if(studySiteIds.size() > 0) {
                    for(Id siteId : studySiteIds) {
                        if(studySiteList.contains(siteId)) {
                            studySiteList.remove(studySiteList.indexOf(siteId));
                        }
                    }
                }
                preset.StudyId__c = string.join(studiesList,';');
                preset.Study_Site_Id__c = string.join(studySiteList,';');
                presetToBeUpdated.add(preset);
            }
            
        }
        
        if(isStudyToDelete) {
        
            delete presetToBeDeleted;
            update presetToBeUpdated;
            
        } else {
            
            deletePresetFilterIds.addAll((new Map<Id,Preset_Filter__c>(presetToBeDeleted)).keySet());
            updatePresetFilterIds.addAll((new Map<Id,Preset_Filter__c>(presetToBeUpdated)).keySet());
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
                    ctpId, 'Preset Filter Update', updatePresetFilterIds
                ));
                contentVersions.add(Batch_SCParticipantEnrollment.constructCsvFile(
                    ctpId, 'Preset Filter Delete', deletePresetFilterIds
                ));
                
                Batch_SCParticipantEnrollment.insertContentVersions(studyClosureProcessList[0].Id, contentVersions);
            }
        }
    }
}