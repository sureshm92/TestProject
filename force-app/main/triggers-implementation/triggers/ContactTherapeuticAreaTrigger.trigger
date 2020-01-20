/**
 * Created by RAMukhamadeev on 2019-04-18.
 */

trigger ContactTherapeuticAreaTrigger on Contact_Therapeutic_Area__c (after insert, after delete) {
    TriggerHandlerExecutor.execute(ContactTherapeuticAreaTriggerHandler.SyncContactInterestedTopics.class);
}