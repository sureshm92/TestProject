public without sharing class PPUpdatesController {
    public static String OBJECT_TYPE_RESOURCE = 'res_study__c';
    @AuraEnabled
    public static void getSendResultUpdates(){
        List<UpdateWrapper> updateWrapperlist = new List<UpdateWrapper>();
        List<Id> resourceIds = new List<Id>();
        ParticipantService.ParticipantState ps = ParticipantService.getInstance().getState();
        System.debug('ps : '+ps.Participant.Email__c);
        String email = ps.Participant.Email__c;
        List<Send_Result__c> sendResults = [SELECT Id,Notification__c,Notification__r.Target_Record_Id__c,Is_Active__c, Is_Read__c, Link_to_Related_Event_or_Object__c,Status__c, Target_Type__c,Notification__r.Recipient__r.email FROM Send_Result__c WHERE Target_Type__c='Updates' AND Notification__r.Recipient__r.email=:email order by createdDate desc ];
        for(Send_Result__c sr : sendResults){
            if(((Id)sr.Notification__r.Target_Record_Id__c).getSObjectType().getDescribe().getName() == OBJECT_TYPE_RESOURCE){
                resourceIds.add(sr.Notification__r.Target_Record_Id__c);
            }
        }
        List<Id> docIds = new List<Id>(); 
        List<Res_study__c> studyResources = [SELECT id,RecordType.name,Resource__c,Resource__r.Content_Type__c,Resource__r.Title__c,Resource__r.Image__c,Resource__r.Posting_Date__c,Resource__r.Version_Date__c	 FROM Res_study__c where id in : resourceIds];
        for(Res_study__c stdRes : studyResources){
            if(stdRes.RecordType.name == 'Document'){
                docIds.add(stdRes.Resource__c);
            }
        }
        List<ContentDocumentLink> contentDocLinks = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in : docIds];
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
        public String Title;
        @AuraEnabled
        public String thumbnailImage;
        @AuraEnabled
        public String thumbnailDoc;
        @AuraEnabled
        public Id recId;
        @AuraEnabled
        public String redirectLink;
        @AuraEnabled
        public Date dt;
    }
}