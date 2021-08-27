/**
* Created by Sravani on  8/23/2021 for PEH-3721.
*/
trigger RecurringTaskTrigger on Manual_Creation_Panel_Task__c (before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete) {
    
    TriggerHandlerExecutor.execute(
        RecurringTaskTriggerHandler.UpdateRecurringTaskonEndDateChange.class
    );

}