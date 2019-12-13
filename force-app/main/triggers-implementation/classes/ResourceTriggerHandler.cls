/**
 * Created by AlexKetch on 3/5/2019.
 */

public with sharing class ResourceTriggerHandler {

    public class ArticleResourceProcessor extends TriggerHandler {

        public override void beforeInsert(List<SObject> newList) {
            ArticleService articleService = (ArticleService) ClassFactory.newInstance(ArticleService.class);
            articleService.addDefaultImage(newList);
            articleService.calculateExpirationDate(newList);
            articleService.validateUpdatedDate(newList);
            articleService.updateRemoveSharing(newList);
            articleService.syncContentType(newList);
            articleService.getUrlVideoFromBody(newList);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            ArticleService articleService = (ArticleService) ClassFactory.newInstance(ArticleService.class);
            articleService.addDefaultImage(newList);
            articleService.calculateExpirationDate(newList, (Map<Id, Resource__c>) oldMap);
            articleService.validateUpdatedDate(newList);
            articleService.updateRemoveSharing(newList, (Map<Id, Resource__c>) oldMap);
            articleService.syncContentType(newList);
            articleService.getUrlVideoFromBody(newList);
        }

        public override void afterInsert(List<SObject> newList) {
            ArticleService articleService = (ArticleService) ClassFactory.newInstance(ArticleService.class);
            articleService.assignTherapeuticAreas(newList);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            ArticleService articleService = (ArticleService) ClassFactory.newInstance(ArticleService.class);
            articleService.assignTherapeuticAreas(newList, (Map<Id, Resource__c>) oldMap);
            ResourceContentClassService rCCService = (ResourceContentClassService) ClassFactory.newInstance(ResourceContentClassService.class);
            rCCService.deleteRelatedObjects((List<Resource__c>) newList, (Map<Id, Resource__c>) oldMap);
        }
    }

}