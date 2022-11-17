/**
 * Created by AlexKetch on 3/5/2019.
 */

public with sharing class ResourceTriggerHandler {
    public class ArticleResourceProcessor extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            ArticleService articleService = (ArticleService) ClassFactory.newInstance(
                ArticleService.class
            );
            articleService.addDefaultImage(newList);
            articleService.calculateExpirationDate(newList);
            articleService.validateUpdatedDate(newList);
            articleService.updateRemoveSharing(newList);
            articleService.syncContentType(newList);
            articleService.getUrlVideoFromBody(newList);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            ArticleService articleService = (ArticleService) ClassFactory.newInstance(
                ArticleService.class
            );
            articleService.addDefaultImage(newList);
            articleService.calculateExpirationDate(newList, (Map<Id, Resource__c>) oldMap);
            articleService.validateUpdatedDate(newList);
            articleService.updateRemoveSharing(newList, (Map<Id, Resource__c>) oldMap);
            articleService.syncContentType(newList);
            articleService.getUrlVideoFromBody(newList);
        }

        public override void afterInsert(List<SObject> newList) {
            List<Sobject> resourceListForBellNotification = new List<Sobject>();
            ArticleService articleService = (ArticleService) ClassFactory.newInstance(
                ArticleService.class
            );
            articleService.assignTherapeuticAreas(newList);
            for(Sobject rec : newList){
                Resource__c res = (Resource__c)rec;
                if(String.isNotEmpty(res.Resource_Visibility__c) && res.Resource_Visibility__c.containsIgnoreCase('PI')){
                    resourceListForBellNotification.add(rec);
                }

            }
            if(resourceListForBellNotification.size() > 0 ){
                notifyPIAndDelegateAboutResources(resourceListForBellNotification);
            }
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {

            ArticleService articleService = (ArticleService) ClassFactory.newInstance(
                ArticleService.class
            );
            articleService.assignTherapeuticAreas(newList, (Map<Id, Resource__c>) oldMap);
            ResourceContentClassService rCCService = (ResourceContentClassService) ClassFactory.newInstance(
                ResourceContentClassService.class
            );
            rCCService.deleteRelatedObjects(
                (List<Resource__c>) newList,
                (Map<Id, Resource__c>) oldMap
            );
            notifyPIAndDelegateAboutUpdatedResources((List<Resource__c>) newList,
            (Map<Id, Resource__c>) oldMap);
        }
    }   

// Changes for Bell Notification Upload Document -RH-9018
    private static void notifyPIAndDelegateAboutUpdatedResources(List<Resource__c> newList, Map<Id, Resource__c> oldMap) {
        List<Sobject> resourceListForBellNotification = new List<Sobject>();
        for(Sobject rec : newList){
            Resource__c res = (Resource__c)rec;
            if ((oldMap.get(res.Id).Resource_Visibility__c != res.Resource_Visibility__c) 
                && ((res.Resource_Visibility__c != null && res.Resource_Visibility__c.containsIgnoreCase('PI') && oldMap.get(res.Id).Resource_Visibility__c != null && !oldMap.get(res.Id).Resource_Visibility__c.containsIgnoreCase('PI'))
                    || (res.Resource_Visibility__c != null && res.Resource_Visibility__c.containsIgnoreCase('PI') && oldMap.get(res.Id).Resource_Visibility__c == null)) 
                ) {                    
                resourceListForBellNotification.add(rec);
            }
        }
        if(resourceListForBellNotification.size() > 0 ){
            notifyPIAndDelegateAboutResources(resourceListForBellNotification);
        }
    }    
    
    
    private static void notifyPIAndDelegateAboutResources(List<SObject> newList) {

        List<Notification__c> allNotificationList = new List<Notification__c>();
        List<Contact> resultMap = new List<Contact>();
        resultMap = BellNotificationsHelper.getContactGeneric();

        if(resultMap.size() > 0){
            Map<String,List<Contact>> contactResultMap =  new Map<String,list<Contact>>
            {'PI' => resultMap};

            List<Notification__c> notificationListForDefault= BellNotificationsHelper.createNotification
                ('BELL_Message_on_Library_Upload_Document', contactResultMap, 'Default', null, false);

            List<Notification__c> notificationListForJanssen= BellNotificationsHelper.createNotification
                ('BELL_Message_on_Library_Upload_Document', contactResultMap, 'Janssen', null, false);

            if(notificationListForDefault.size()> 0 || notificationListForJanssen.size() > 0){
                allNotificationList.addAll(notificationListForDefault);
                allNotificationList.addAll(notificationListForJanssen);
            }

            if(allNotificationList.size() > 0 && allNotificationList.size() <= 8000){
                insert allNotificationList;
            }else if(allNotificationList.size() > 0 && allNotificationList.size() > 8000){
                Batch_NotificationInsertion notifyBatch = new Batch_NotificationInsertion(allNotificationList);
                Database.executeBatch(notifyBatch);
            }
        }
    }
}