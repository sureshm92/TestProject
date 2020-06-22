/**
* Created by Akanksha on 18.06.20
*/

trigger CCStaffTrigger on CC_Staff__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	TriggerHandlerExecutor.execute(CCStaffTriggerHandler.UpdateContactOnStatusChange.class);
}