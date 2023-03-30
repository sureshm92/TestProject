public without sharing class PPUpdatesController {
    @AuraEnabled
    public static List<UpdateService.UpdateWrapper> getSendResultUpdates(Integer offsets,Integer limits){
        List<UpdateService.UpdateWrapper> updateWrapperlist = new List<UpdateService.UpdateWrapper>();
        List<Id> resStudyIds = new List<Id>();
        List<Id> resPlatformIds = new List<Id>();
        List<Send_Result__c> sendResults = UpdateService.getSendResultRecords(resStudyIds,resPlatformIds,offsets,limits);
        Map<Id,Res_study__c> resStudyMap = UpdateService.getResStudy(resStudyIds);
        Map<Id,Resource__c> resPlatformMap = UpdateService.getResPlatform(resPlatformIds);
        Map<Id,Id> resIdContentVersionIdMap = UpdateService.getContentVersionForStdDoc(resStudyMap,resPlatformMap);
        UpdateService.createWrapper(sendResults,resStudyMap,resPlatformMap,resIdContentVersionIdMap,updateWrapperlist);
        return updateWrapperlist; 
    } 
    
    @AuraEnabled
    public static Integer getSendResultCount(){
            UpdateService.ResourceFilter resFilter = UpdateService.getSendResultFilter();
            Integer updateCount = [SELECT count() FROM Send_Result__c where Notification__r.Target_Record_Ids__c!=null 
                                   AND Target_Type__c=:UpdateService.SR_TARGET_TYPE_UPDATES AND Status__c=:UpdateService.SR_STATUS_IN_PROGRESS
                                   AND Notification__r.Recipient__c=:resFilter.participantContactId AND 
                                   ((Notification__r.whatId__c in : resFilter.peList AND Notification__r.Target_Record_Ids__c in : resFilter.resStudyIdVisToPt)
                                    OR Notification__r.whatId__c=:resFilter.currentParticipantId)];
            return updateCount;
    }
    @AuraEnabled
    public static void removeUpdateCard(String targetRecordId){
        targetRecordId = '%'+targetRecordId+'%';
        List<Send_Result__c> sendResultList = [SELECT id,Status__c FROM Send_Result__c WHERE Notification__r.Target_Record_Ids__c like : targetRecordId];
        for(Send_Result__c sr : sendResultList){
            sr.Status__c = 'Sent';
        }
        update sendResultList;
    }
}