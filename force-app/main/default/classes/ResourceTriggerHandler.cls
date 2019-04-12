/**
 * Created by AlexKetch on 3/5/2019.
 */

public with sharing class ResourceTriggerHandler extends TriggerHandler {

    public override void beforeInsert(List<SObject> newList) {
        ArticleService articleService = (ArticleService) ClassFactory.newInstance(ArticleService.class);
        articleService.addDefaultImage(newList);
        articleService.calculateExpirationDate(newList);
        articleService.validateUpdatedDate(newList);
    }

    public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        ArticleService articleService = (ArticleService) ClassFactory.newInstance(ArticleService.class);
        articleService.addDefaultImage(newList);
        articleService.calculateExpirationDate(newList, (Map<Id, Resource__c>) oldMap);
        articleService.validateUpdatedDate(newList);
    }

    public override void afterInsert(List<SObject> newList) {
        ArticleService articleService = (ArticleService) ClassFactory.newInstance(ArticleService.class);
        articleService.assignTherapeuticAreas(newList);
    }

    public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        ArticleService articleService = (ArticleService) ClassFactory.newInstance(ArticleService.class);
        articleService.assignTherapeuticAreas(newList, (Map<Id, Resource__c>) oldMap);
    }
}