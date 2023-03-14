public without sharing class PPUpdatesController {
    public static String OBJECT_TYPE_STD_RESOURCE = 'res_study__c';
    public static String OBJECT_TYPE_PT_RESOURCE = 'resource__c';
    @AuraEnabled
    public static List<UpdateWrapper> getSendResultUpdates(){
        List<UpdateWrapper> updateWrapperlist = new List<UpdateWrapper>();
        List<Id> resourceIds = new List<Id>();
        List<Id> stdResIds = new List<Id>();
        List<Id> platformResIds = new List<Id>();
        ParticipantService.ParticipantState ps = ParticipantService.getInstance().getState();
        String email = ps.Participant.Email__c;
        System.debug('ps : '+email);
        List<Send_Result__c> sendResults = [SELECT Id,Notification__c,Notification__r.Target_Record_Id__c,Is_Active__c, Is_Read__c, Link_to_Related_Event_or_Object__c,Status__c, Target_Type__c,Notification__r.Recipient__r.email FROM Send_Result__c WHERE Target_Type__c='Updates' AND Notification__r.Recipient__r.email=:email order by createdDate desc ];
        for(Send_Result__c sr : sendResults){
            Id targetId = (Id)sr.Notification__r.Target_Record_Id__c;
            String targetType = targetId.getSObjectType().getDescribe().getName().toLowerCase();
            System.debug('targetType : '+targetType);
            if(targetType == OBJECT_TYPE_STD_RESOURCE){
                stdResIds.add(sr.Notification__r.Target_Record_Id__c);
            }else if(targetType == OBJECT_TYPE_PT_RESOURCE){
                platformResIds.add(sr.Notification__r.Target_Record_Id__c);
            }
        }
        System.debug('stdResIds : '+stdResIds);
        System.debug('platformResIds : '+platformResIds);
        Map<Id,Id> stdResPtResMap = new Map<Id,Id>();
        List<Id> platformResforStdResIds = new List<Id>(); 
        Map<Id,Res_study__c> ResStdMap = new Map<Id,Res_study__c>();
        List<Res_study__c> studyResources = [SELECT id,RecordType.name,Resource__c,Resource__r.Content_Type__c,Resource__r.Title__c,Resource__r.Image__c,Resource__r.Posting_Date__c,Resource__r.Version_Date__c FROM Res_study__c where id in : stdResIds];
        for(Res_study__c stdRes : studyResources){
            ResStdMap.put(stdRes.Id,stdRes);
            System.debug(stdRes.Resource__r.Content_Type__c);
            if(stdRes.Resource__r.Content_Type__c == 'Study_Document'){
                stdResPtResMap.put(stdRes.Id,stdRes.Resource__c);
                platformResforStdResIds.add(stdRes.Resource__c);
            }
        }
        System.debug('stdResPtResMap : '+stdResPtResMap);
        System.debug('platformResforStdResIds : '+platformResforStdResIds);
        List<Resource__c> platformResources = [SELECT Id,recordType.Name,Content_Type__c,Title__c,Image__c,Posting_Date__c,Version_Date__c FROM Resource__c WHERE Id in : platformResIds];
        Map<Id,Resource__c> PlatformResMap = new Map<Id,Resource__c>();
        for(Resource__c res : platformResources){
            PlatformResMap.put(res.Id,res);
        }
        platformResIds.addAll(platformResforStdResIds);
        System.debug('platformResIds : '+platformResIds);
        List<ContentDocumentLink> contentDocLinks = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in :platformResIds];
        Map<Id,Id> resDocMap = new Map<Id,Id>();
        for(ContentDocumentLink cd : contentDocLinks){
            resDocMap.put(cd.LinkedEntityId,cd.ContentDocumentId);
        }

        for(Send_Result__c sr : sendResults){
            Id targetId = (Id)sr.Notification__r.Target_Record_Id__c;
            String targetType = targetId.getSObjectType().getDescribe().getName().toLowerCase();
            UpdateWrapper wrp = new UpdateWrapper();
            if(targetType == OBJECT_TYPE_STD_RESOURCE){
                wrp.Title = ResStdMap.get(targetId).Resource__r.Title__c;
                wrp.recId = ResStdMap.get(targetId).Resource__c;
                wrp.contentType = ResStdMap.get(targetId).Resource__r.Content_Type__c;
                wrp.updateType = 'Resource';
                if(ResStdMap.get(targetId).Resource__r.Content_Type__c == 'Study_Document'){
                    wrp.thumbnailDocId = resDocMap.get(stdResPtResMap.get(targetId));
                }
                
            }else if(targetType == OBJECT_TYPE_PT_RESOURCE){
                wrp.Title = PlatformResMap.get(targetId).Title__c;
                wrp.recId = targetId;
                wrp.contentType = PlatformResMap.get(targetId).Content_Type__c;
                wrp.updateType = 'Resource';
                if(PlatformResMap.get(targetId).Content_Type__c == 'Study_Document'){
                    wrp.thumbnailDocId = resDocMap.get(targetId);
                }
            }
            updateWrapperlist.add(wrp);
        }
        System.debug('updateWrapperlist : '+updateWrapperlist);
        return updateWrapperlist;
    }
    @AuraEnabled
    public static String getSendResultCount(){
        ParticipantService.ParticipantState ps = ParticipantService.getInstance().getState();
        Integer updateCount = [SELECT count() FROM Send_Result__c where Target_Type__c='Updates' AND Status__c='In Progress' AND Notification__r.Recipient__r.email=:ps.Participant.Email__c];
        if(updateCount>99){
            return '99+';
        }else{
            return String.valueOf(updateCount);
        }
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
        public String redirectLink;
        @AuraEnabled
        public Date versionDate;
        @AuraEnabled
        public String updateType;
        @AuraEnabled
        public String contentType;
        @AuraEnabled
        public String linkType;
    }
}