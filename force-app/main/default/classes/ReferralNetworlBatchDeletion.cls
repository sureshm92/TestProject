global class ReferralNetworlBatchDeletion implements Database.Batchable<sObject>, Database.Stateful{
    private String ctpId;
    private Boolean isStudyToDelete = false;
    private Set<Id> referralNetworkIds = new Set<Id>();
    
    global ReferralNetworlBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global ReferralNetworlBatchDeletion(String ctpId, Boolean isStudyToDelete){
        this.ctpId = ctpId;
        this.isStudyToDelete = isStudyToDelete;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query='SELECT Id, Name,ReferralNetworkId__c FROM Study_Site__c where Clinical_Trial_Profile__c = :ctpId';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Study_Site__c> studySiteLst){
        Map<Id,Referral_Network__c> refNetworkIdMap = new Map<Id,Referral_Network__c>();
        for(Study_Site__c ss : studySiteLst){
            if(ss.ReferralNetworkId__c!= null && !refNetworkIdMap.containsKey(ss.ReferralNetworkId__c)){
                refNetworkIdMap.put(ss.ReferralNetworkId__c,new Referral_Network__c(Id=ss.ReferralNetworkId__c));
            }
        }
        for(Study_Site__c site: [SELECT Id, Name,ReferralNetworkId__c FROM Study_Site__c WHERE Clinical_Trial_Profile__c !=:ctpId and Id not IN :studySiteLst and ReferralNetworkId__c IN:refNetworkIdMap.keySet()]){
            if(refNetworkIdMap.containsKey(site.ReferralNetworkId__c)){
                refNetworkIdMap.remove(site.ReferralNetworkId__c);
            }
        }
        if(isStudyToDelete) {
            if(!refNetworkIdMap.isEmpty()){
                delete refNetworkIdMap.values();
            }
        } else {
            referralNetworkIds.addAll(refNetworkIdMap.keyset());
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
                    ctpId, 'Referral Network', referralNetworkIds
                ));
                
                Batch_SCParticipantEnrollment.insertContentVersions(studyClosureProcessList[0].Id, contentVersions);
            }
        }
    }
}