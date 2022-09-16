/* 
 * This Batch is a one time batch to update new dob fields on existing participants, so can be removed after the activity in completed
 */
public without sharing class Batch_UpdateDOBFieldsParticipants implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select id,Date_of_Birth__c from Participant__c ');//IF limit records and check if recursion requiered in finally
     }
  
     public void execute(Database.BatchableContext BC, List<Participant__c> participants){
        List<Participant__c> pList = new List<Participant__c>();
        for (Participant__c participant : participants) {
            if(!String.isBlank(participant.Date_of_Birth__c)){
                participant.Birth_Day__c = participant.Date_of_Birth__c.substring(8,10);
                participant.Birth_Month__c = participant.Date_of_Birth__c.substring(5,7);
                participant.Birth_Year__c = participant.Date_of_Birth__c.substring(0,4);
                pList.add(participant);
            }
        }
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.PrepareCityStateFieldsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.CreateContactsForParticipantsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdateContactDetailsFromParticipant.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.CheckBecomesAdultHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdatePEAndContactLastNameHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.ChangeUserEmailOnParticipantEmailChangeHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdateNameOnPE.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdateParticipantAge.class);
        Database.update(pList, false);
      }
  
     public void finish(Database.BatchableContext BC){
     }
}