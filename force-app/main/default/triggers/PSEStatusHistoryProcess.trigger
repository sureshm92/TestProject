/**
 * Created by Leonid Bartenev
 */

trigger PSEStatusHistoryProcess on PSE_Status_History__c (after insert, after update) {
    PSEStatusHistoryTriggerHandler.updatePSEStatuses();
}