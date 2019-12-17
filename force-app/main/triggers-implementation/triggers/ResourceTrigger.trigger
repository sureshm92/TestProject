/**
 * Created by Yehor Dobrovolskyi
 */
trigger ResourceTrigger on Resource__c (before insert, before update, before delete, after insert, after update, after delete) {

    TriggerHandlerExecutor.execute(ResourceTriggerHandler.ArticleResourceProcessor.class);
}