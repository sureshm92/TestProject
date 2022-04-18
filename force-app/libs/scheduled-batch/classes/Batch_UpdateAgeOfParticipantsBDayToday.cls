/* This Batch is called from Scheduler class which updates batches daily
*  who have birthday on the same day as today
*/
public class Batch_UpdateAgeOfParticipantsBDayToday implements Database.Batchable<SObject>, Database.Stateful {
    

    public DataBase.QueryLocator start (DataBase.BatchableContext bc){
        //month list containing number 'X' and '0X' if X is one digit 
        List<String> monthVariants = new List<String>(); 
        monthVariants.add(String.valueOf(Date.today().month()));
        if(Date.today().month()<10){
            monthVariants.add('0'+String.valueOf(Date.today().month()));            
        }
        //day list containing number 'X' and '0X' if X is one digit
        List<String> dayVariants = new List<String>();
        dayVariants.add(String.valueOf(Date.today().day()));
        if(Date.today().day()<10){
            dayVariants.add('0'+String.valueOf(Date.today().day()));            
        }
        //query only participants who have birthday as today
        return DataBase.getQueryLocator([
                SELECT Id, Birth_Day__c, Birth_Month__c, Birth_Year__c, Date_of_Birth__c
                FROM Participant__c WHERE Birth_Month__c IN:monthVariants 
            	AND Birth_Day__c  IN:dayVariants
            ]);
    }

    public void execute(Database.BatchableContext bc, List<Participant__c> participants) {
        List<Participant__c> pList = new List<Participant__c>();
        //loop as placeholder to just execute update trigger to calculate age
        for (Participant__c p : participants) {
            pList.add(p);
        }
        //Bypass sub class PrepareCityStateFieldsHandler trigger handler on Participant Trigger
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.PrepareCityStateFieldsHandler.class);
        
        //Bypass sub class CreateContactsForParticipantsHandler trigger handler on Participant Trigger
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.CreateContactsForParticipantsHandler.class
        );

        //Bypass sub class UpdateContactDetailsFromParticipant trigger handler on Participant Trigger
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.UpdateContactDetailsFromParticipant.class
        );

        //Bypass sub class CheckBecomesAdultHandler trigger handler on Participant Trigger
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.CheckBecomesAdultHandler.class);

        //Bypass sub class UpdatePEAndContactLastNameHandler trigger handler on Participant Trigger
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.UpdatePEAndContactLastNameHandler.class
        );

        //Bypass sub class CreateContactsForParticipantsHandler trigger handler on Participant Trigger        
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.ChangeUserEmailOnParticipantEmailChangeHandler.class
        );
        
        //Bypass sub class CreateContactsForParticipantsHandler trigger handler on Participant Trigger
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdateNameOnPE.class);
        
        //Only allow UpdateParticipantAge.class on ParticipantTriggerHandler
        Database.update(pList, false);
        
    }
    
    public void finish(Database.BatchableContext bc){
        // no logic needed on finish.just a placeholder        
    }
}