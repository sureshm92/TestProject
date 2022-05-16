/**
* Created by Anitha Chavva
*/

trigger SendResultTrigger on Send_Result__c(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    
    TriggerHandlerExecutor.execute(SendResultTriggerHandler.updatewelcomeMsgflagsHandler.class);
    
    
}