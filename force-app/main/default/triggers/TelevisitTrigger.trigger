trigger TelevisitTrigger on Televisit__c(after insert, after update) {
    /** if(Trigger.isInsert && Trigger.isAfter){
        List<Id> televisitRecordIdsSet = new List<Id>();
        for(Televisit__c televisitRecord : Trigger.New){
            televisitRecordIdsSet.add(televisitRecord.Id);
        }
        TelevisitTriggerHandler.SendRequestToVonageAPI(televisitRecordIdsSet );
    }  */
    TriggerHandlerExecutor.execute(TelevisitTriggerHandler.NotifyAttendees.class);
    TriggerHandlerExecutor.execute(TelevisitTriggerHandler.TelevisitEventTrigger.class);
    TriggerHandlerExecutor.execute(TelevisitTriggerHandler.TelevisitRescheduleTrigger.class);

}