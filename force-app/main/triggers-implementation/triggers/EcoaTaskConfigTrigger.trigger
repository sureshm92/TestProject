/**
* Created by Ranjit R on  4/25/2022 for PEH-4149.
*/
trigger EcoaTaskConfigTrigger on Ecoa_Task_Configuration__c (before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete) {
    
    TriggerHandlerExecutor.execute(
        EcoaTaskConfigTriggerHandler.MarkEcoaTaskCompleted.class
    );

}