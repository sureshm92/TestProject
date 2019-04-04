/**
 * Created by AlexKetch on 3/5/2019.
 */

public with sharing class ResourceTriggerHandler extends TriggerHandler {

    public override void beforeInsert(List<SObject> newList) {
        ArticleService articleService = (ArticleService) ClassFactory.newInstance(ArticleService.class);
        articleService.addDefaultImage(newList);
        articleService.calculateExpirationDateBeforeInsert(newList);
    }

    public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        ArticleService articleService = (ArticleService) ClassFactory.newInstance(ArticleService.class);
        articleService.addDefaultImage(newList);
        articleService.calculateExpirationDateBeforeUpdate(newList, (Map<Id, Resource__c>) oldMap);
    }

    public override void afterInsert(List<SObject> newList) {
        ArticleService articleService = (ArticleService) ClassFactory.newInstance(ArticleService.class);
        articleService.processTherapeuticAreasAfterInsert(newList);
    }

    public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        ArticleService articleService = (ArticleService) ClassFactory.newInstance(ArticleService.class);
        articleService.processTherapeuticAreasAfterUpdate(newList, (Map<Id, Resource__c>) oldMap);
    }
}