/** Created by Leonid Bartenev */
trigger CommunityUserOnStudySite on Study_Site__c (before delete, after insert, after update) {

    if (Trigger.isBefore) {

        if (Trigger.isDelete) {

            StudySiteTriggerHandler.onBeforeDelete(Trigger.oldMap);
        }
    }

    if(Trigger.isAfter){

        if(Trigger.isInsert){

            StudySiteTriggerHandler.onAfterinsert(Trigger.new);
        } else if(Trigger.isUpdate) {

            StudySiteTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}