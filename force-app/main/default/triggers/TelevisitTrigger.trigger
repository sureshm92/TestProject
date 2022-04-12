trigger TelevisitTrigger on Televisit__c (after Insert) {
    if(Trigger.isInsert && Trigger.isAfter){
        List<Id> televisitRecordIdsSet = new List<Id>();
        for(Televisit__c televisitRecord : Trigger.New){
            televisitRecordIdsSet.add(televisitRecord.Id);
        }
        TelevisitTriggerHandler.SendRequestToVonageAPI(televisitRecordIdsSet );
    }
}