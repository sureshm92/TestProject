public class Batch_UpdateAgeOfParticipantsBDayToday implements Database.Batchable<SObject>, Database.Stateful {
    public DataBase.QueryLocator start (DataBase.BatchableContext bc){
        List<String> monthVariants = new List<String>(); 
        monthVariants.add(String.valueOf(Date.today().month()));
        if(Date.today().month()<10){
            monthVariants.add('0'+String.valueOf(Date.today().month()));            
        }
        List<String> dayVariants = new List<String>();
        dayVariants.add(String.valueOf(Date.today().day()));
        if(Date.today().day()<10){
            dayVariants.add('0'+String.valueOf(Date.today().day()));            
        }
        return DataBase.getQueryLocator([
                SELECT Id, Birth_Day__c, Birth_Month__c, Birth_Year__c, Date_of_Birth__c
                FROM Participant__c WHERE Birth_Month__c IN:monthVariants 
            	AND Birth_Day__c  IN:dayVariants
            ]);
    }
    
    public void execute(Database.BatchableContext bc, List<Participant__c> participants) {
        List<Participant__c> pList = new List<Participant__c>();
        for (Participant__c p : participants) {
            pList.add(p);
        }
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.PrepareCityStateFieldsHandler.class);
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.CreateContactsForParticipantsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.UpdateContactDetailsFromParticipant.class
        );
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.CheckBecomesAdultHandler.class);
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.UpdatePEAndContactLastNameHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.ChangeUserEmailOnParticipantEmailChangeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdateNameOnPE.class);
        //TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdateParticipantAge.class);
        
        Database.update(pList, false);
        
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
}