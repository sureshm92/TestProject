/**One time batch to update Participant records backup class
 * 
 * 
 **/
public class Batch_OneTimeUpdDayMonthYearAgeBkp implements Database.Batchable<SObject>, Database.Stateful {
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(
            [
                SELECT Id, Birth_Day__c, Birth_Month__c, Birth_Year__c, Date_of_Birth__c
                FROM Participant__c WHERE Birth_Day__c = NULL
            ]
        );
    }
    
    public void execute(Database.BatchableContext bc, List<Participant__c> participants) {
        List<Participant__c> updateParticipants = new List<Participant__c>();
        for(Participant__c participant : participants){
            if (!String.isBlank(participant.Date_of_Birth__c)) {
                updateParticipants.add(participant);
            }
        }
        if(!updateParticipants.isEmpty()){
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
            DataBase.update(updateParticipants,false);            
        }

    }
    
    public void finish(Database.BatchableContext bc){
        
    }
}