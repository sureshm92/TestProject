/**
 * Created by AlexKetch on 3/5/2019.
 */

public with sharing class ResourceTriggerHandler extends TriggerHandler {

    public override void beforeInsert(List<SObject> newList) {
        ArticleService.calculateExpirationDateBeforeInsert(newList);
    }

    public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        ArticleService.calculateExpirationDateBeforeUpdate(newList, (Map<Id, Resource__c>) oldMap);
    }

}