trigger TelevisitAttendeeTrigger on Televisit_Attendee__c(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    TriggerHandlerExecutor.execute(TelevisitAttendeeTriggerHandler.ManageAttendees.class);
}
