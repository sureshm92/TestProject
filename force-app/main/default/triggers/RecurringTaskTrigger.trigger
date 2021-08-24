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