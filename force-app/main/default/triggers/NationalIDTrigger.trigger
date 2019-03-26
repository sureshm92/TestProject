trigger NationalIDTrigger on National_ID__c (before insert, before update, after insert, after update) {
    NationalIdTriggerHandler.prepareCityStateFieldsBeforeInsertOrUpdate();
}