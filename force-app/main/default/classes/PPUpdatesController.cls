public without sharing class PPUpdatesController {
    public static String OBJECT_TYPE_STD_RESOURCE = 'res_study__c';
    public static String OBJECT_TYPE_PT_RESOURCE = 'resource__c';
    public static String OBJECT_TYPE_TELEVISIT = 'televisit__c';
    public static String OBJECT_TYPE_VISIT = 'visit__c';
    @AuraEnabled
    public static List<UpdateWrapper> getSendResultUpdates(Integer offsets,Integer limits){
        List<UpdateWrapper> updateWrapperlist = new List<UpdateWrapper>();
        List<Id> resStudyIds = new List<Id>();
        List<Id> resPlatformIds = new List<Id>();
        List<Send_Result__c> sendResults = getSendResultRecords(resStudyIds,resPlatformIds,offsets,limits);
        Map<Id,Res_study__c> resStudyMap = getResStudy(resStudyIds);
        Map<Id,Resource__c> resPlatformMap = getResPlatform(resPlatformIds);
        Map<Id,Id> resIdContentVersionIdMap = getContentVersionForStdDoc(resStudyMap,resPlatformMap);
        createWrapper(sendResults,resStudyMap,resPlatformMap,resIdContentVersionIdMap,updateWrapperlist);
        System.debug('updateWrapperlist : '+updateWrapperlist);
        return updateWrapperlist; 
    }
    public static List<Send_Result__c> getSendResultRecords(List<Id> resStudyIds,List<Id> resPlatformIds,Integer offsets, Integer limits){
        ParticipantService.ParticipantState ps = ParticipantService.getInstance().getState();
        List<Send_Result__c> sendResults = [SELECT Id,Notification__c,Notification__r.Target_Record_Id__c,Is_Active__c, Is_Read__c, Link_to_Related_Event_or_Object__c,Status__c, Target_Type__c,Notification__r.Recipient__r.email FROM Send_Result__c WHERE Status__c='In Progress' AND Notification__r.Target_Record_Id__c!=null AND Target_Type__c='Updates' AND Notification__r.Recipient__c=:ps.Participant.Contact__c order by lastModifiedDate desc LIMIT:limits OFFSET:offsets];
        for(Send_Result__c sr : sendResults){
            Id targetId = (Id)sr.Notification__r.Target_Record_Id__c;
            String targetType = targetId.getSObjectType().getDescribe().getName().toLowerCase();
            if(targetType == OBJECT_TYPE_STD_RESOURCE){
                resStudyIds.add(sr.Notification__r.Target_Record_Id__c);
            }else if(targetType == OBJECT_TYPE_PT_RESOURCE){
                resPlatformIds.add(sr.Notification__r.Target_Record_Id__c);
            }
        }
        return sendResults;
    }
    public static Map<Id,Res_study__c> getResStudy(List<Id> resStudyIds){
        Map<Id,Res_study__c> resStudyMap = new Map<Id,Res_study__c>();
        List<Res_study__c> studyResources = [SELECT id,RecordType.name,Resource__r.RecordType.DeveloperName,Resource__c,Resource__r.Content_Type__c,Resource__r.Title__c,Resource__r.Image__c,Resource__r.Posting_Date__c,Resource__r.Version_Date__c,Resource__r.URL__c,Resource__r.Type__c FROM Res_study__c where id in : resStudyIds];
        for(Res_study__c res : studyResources){
            resStudyMap.put(res.Id,res);
        }
        return resStudyMap;
    }
    public static Map<Id,Resource__c> getResPlatform(List<Id> resPlatformIds){
        List<Resource__c> platformResources = [SELECT Id,recordType.Name,RecordType.DeveloperName,Content_Type__c,Title__c,Image__c,Posting_Date__c,Version_Date__c,URL__c,Type__c FROM Resource__c WHERE Id in : resPlatformIds];
        Map<Id,Resource__c> resPlatformMap = new Map<Id,Resource__c>();
        for(Resource__c res : platformResources){
            resPlatformMap.put(res.Id,res);
        }
        return resPlatformMap;
    }
    public static Map<Id,Id> getContentVersionForStdDoc(Map<Id,Res_study__c> resStudyMap,Map<Id,Resource__c> resPlatformMap){
        List<Id> resPlatformDocumentIds = new List<Id>();
        for(Res_study__c res : resStudyMap.values()){
            if(res.resource__r.Content_Type__c == 'Study_Document'){
                resPlatformDocumentIds.add(res.resource__c);
            }
        }
        for(Resource__c res : resPlatformMap.values()){
            if(res.Content_Type__c == 'Study_Document'){
                resPlatformDocumentIds.add(res.Id);
            }
        }
        Map<Id,Id> docIdResIdMap = new Map<Id,Id>();
        if(resPlatformDocumentIds.size()>0){
        List<ContentDocumentLink> contentDocLinks = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in :resPlatformDocumentIds];
        
        for(ContentDocumentLink cd : contentDocLinks){
            docIdResIdMap.put(cd.ContentDocumentId,cd.LinkedEntityId);
        }
        }
        Map<Id,Id> resIdContentVersionId = new Map<Id,Id>();
        if(docIdResIdMap.size()>0){
        List<ContentVersion> contentVersionList = [SELECT ContentDocumentId,Id FROM ContentVersion WHERE ContentDocumentId in : docIdResIdMap.keyset()];
        for(ContentVersion cv : contentVersionList){
            resIdContentVersionId.put(docIdResIdMap.get(cv.ContentDocumentId),cv.Id);
        }
        }
        return resIdContentVersionId;
    }
    public static void createWrapper(List<Send_Result__c> sendResults,Map<Id,Res_study__c> resStudyMap,Map<Id,Resource__c> resPlatformMap,Map<Id,Id> resIdContentVersionIdMap,List<UpdateWrapper> updateWrapperlist){
        for(Send_Result__c sr : sendResults){
            Id targetId = (Id)sr.Notification__r.Target_Record_Id__c;
            String targetType = targetId.getSObjectType().getDescribe().getName().toLowerCase();
            UpdateWrapper wrp = new UpdateWrapper();
            if(targetType == OBJECT_TYPE_STD_RESOURCE || targetType == OBJECT_TYPE_PT_RESOURCE){
                wrp.updateType = 'resource';
                wrp.sendResultId = sr.Id;
                if(targetType == OBJECT_TYPE_STD_RESOURCE){
                    createResStudyWrapper(targetId,resStudyMap,wrp,resIdContentVersionIdMap);
                }else if(targetType == OBJECT_TYPE_PT_RESOURCE){
                    createResPlatformWrapper(targetId,resPlatformMap,wrp,resIdContentVersionIdMap);
                }
            }/*else if(targetType == OBJECT_TYPE_TELEVISIT){
                wrp.contentType = 'Televisit';
                wrp.title = 'New televisit(s) has been scheduled';
            }else if(targetType == OBJECT_TYPE_TELEVISIT){
                wrp.contentType = 'Visit';
                wrp.title = 'New visit has been scheduled';
            } */
            updateWrapperlist.add(wrp);
        }
    }
    public static void createResStudyWrapper(Id targetId,Map<Id,Res_study__c> resStudyMap,UpdateWrapper wrp,Map<Id,Id> resIdContentVersionIdMap){
        wrp.Title = resStudyMap.get(targetId).Resource__r.Title__c;
        wrp.targetRecordId = targetId;
        wrp.recId = resStudyMap.get(targetId).Resource__c;
        wrp.contentType = resStudyMap.get(targetId).Resource__r.Content_Type__c;
        wrp.versionDate = resStudyMap.get(targetId).Resource__r.Version_Date__c;
        wrp.resourceDevRecordType = resStudyMap.get(targetId).Resource__r.RecordType.DeveloperName;
        if(resStudyMap.get(targetId).Resource__r.Content_Type__c == 'Study_Document'){
            wrp.thumbnailDocId = resIdContentVersionIdMap.get(resStudyMap.get(targetId).Resource__c);
        }else if(resStudyMap.get(targetId).Resource__r.Content_Type__c == 'Article' ||
                 resStudyMap.get(targetId).Resource__r.Content_Type__c == 'Video' ||
                 resStudyMap.get(targetId).Resource__r.Content_Type__c == 'Multimedia'){
                     wrp.thumbnailImage = resStudyMap.get(targetId).Resource__r.Image__c;
                     wrp.versionDate = resStudyMap.get(targetId).Resource__r.Posting_Date__c;
                 }else if(resStudyMap.get(targetId).Resource__r.Content_Type__c == 'Relevant_Link'){
                     wrp.redirectLink = resStudyMap.get(targetId).Resource__r.URL__c;
                     wrp.linkType = resStudyMap.get(targetId).Resource__r.Type__c;
                 }
    }
    public static void createResPlatformWrapper(Id targetId,Map<Id,Resource__c> resPlatformMap,UpdateWrapper wrp,Map<Id,Id> resIdContentVersionIdMap){
        wrp.Title = resPlatformMap.get(targetId).Title__c;
        wrp.targetRecordId = targetId;
        wrp.recId = targetId;
        wrp.contentType = resPlatformMap.get(targetId).Content_Type__c;
        wrp.versionDate = resPlatformMap.get(targetId).Version_Date__c;
        wrp.resourceDevRecordType = resPlatformMap.get(targetId).RecordType.DeveloperName;
        if(resPlatformMap.get(targetId).Content_Type__c == 'Study_Document'){
            wrp.thumbnailDocId = resIdContentVersionIdMap.get(resPlatformMap.get(targetId).Id);
        }else if(resPlatformMap.get(targetId).Content_Type__c == 'Article' ||
                 resPlatformMap.get(targetId).Content_Type__c == 'Video' ||
                 resPlatformMap.get(targetId).Content_Type__c == 'Multimedia'){
                     wrp.thumbnailImage = resPlatformMap.get(targetId).Image__c;
                     wrp.versionDate = resPlatformMap.get(targetId).Posting_Date__c;
                 }else if(resPlatformMap.get(targetId).Content_Type__c == 'Relevant_Link'){
                     wrp.redirectLink = resPlatformMap.get(targetId).URL__c;
                     wrp.linkType = resPlatformMap.get(targetId).Type__c;
                 }
    }
    @AuraEnabled
    public static Integer getSendResultCount(){
        ParticipantService.ParticipantState ps = ParticipantService.getInstance().getState();
        Integer updateCount = [SELECT count() FROM Send_Result__c where Target_Type__c='Updates' AND Status__c='In Progress' AND Notification__r.Recipient__c=:ps.Participant.Contact__c];
        return updateCount;
    }
    @AuraEnabled
    public static void removeUpdateCard(String targetRecordId){
        targetRecordId = '%'+targetRecordId+'%';
        List<Send_Result__c> sendResultList = [SELECT id,Status__c FROM Send_Result__c WHERE Notification__r.Target_Record_Id__c like : targetRecordId];
        for(Send_Result__c sr : sendResultList){
            sr.Status__c = 'Sent';
        }
        update sendResultList;
    }
    public class UpdateWrapper{
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String thumbnailImage;
        @AuraEnabled
        public String thumbnailDocId;
        @AuraEnabled
        public Id recId;
        @AuraEnabled
        public String resourceDevRecordType;
        @AuraEnabled
        public String redirectLink;
        @AuraEnabled
        public Date versionDate;
        @AuraEnabled
        public String updateType;
        @AuraEnabled
        public String contentType;
        @AuraEnabled
        public String linkType;
        @AuraEnabled 
        public String targetRecordId;
        @AuraEnabled 
        public String sendResultId;
    }
}