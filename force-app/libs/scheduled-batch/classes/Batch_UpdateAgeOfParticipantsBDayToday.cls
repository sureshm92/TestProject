/* 
 * This Batch is called from Scheduler class which updates batches daily
 * who have birthday on the same day as today
 */
public class Batch_UpdateAgeOfParticipantsBDayToday implements Database.Batchable<SObject>, Database.Stateful {
    

    public DataBase.QueryLocator start (DataBase.BatchableContext bc){
        Organization org = [select IsSandbox from Organization limit 1];
        Date today = Date.today();        
        if(Test.isRunningTest()){
            today = date.newinstance(2000, 12, 31);
        }
        //dayToday
        String dayToday = String.valueOf(today.day());
        if(today.day()<10){
            dayToday = '0'+String.valueOf(today.day());            
        }
        //monthToday
        String monthToday = String.valueOf(today.month());
        if(today.month()<10){
            monthToday ='0'+String.valueOf(today.month());            
        }
        //is last day of month
        Boolean isLastDateOfMonth = (Date.daysInMonth(today.year(), today.month()) == today.day());
        //is last day of year
        Boolean isLastDateOfYear = (dayToday=='31' && monthToday=='12'); 

        String qryStr = 'SELECT Id, Birth_Day__c, Birth_Month__c, Birth_Year__c, Date_of_Birth__c FROM Participant__c where ';
        //birthday today
        qryStr = qryStr + '(Birth_Month__c =:monthToday AND Birth_Day__c  =:dayToday) ';
        //birthday this month and day not in system
        if(isLastDateOfMonth || (System.Label.DOB_Batch_Label == 'true' && org.IsSandbox)){
            qryStr = qryStr + 'OR (Birth_Month__c =:monthToday AND Birth_Day__c  =null) ';
        }
        //birthday this year and month, day not in system
        if(isLastDateOfYear || (System.Label.DOB_Batch_Label == 'true' && org.IsSandbox)){
            qryStr = qryStr + 'OR (Birth_Month__c =null AND Birth_Day__c  =null) ';
        }
        return Database.getQueryLocator(qryStr);
    }

    public void execute(Database.BatchableContext bc, List<Participant__c> participants) {
        List<Participant__c> pList = new List<Participant__c>();
        //loop as placeholder to just execute update trigger to calculate age
        for (Participant__c p : participants) {
            system.debug(p.id);
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
        ParticipantTriggerHandler.updatePartAge = true;
        Database.update(pList, false);
        
    }
    
    public void finish(Database.BatchableContext bc){
        // no logic needed on finish.just a placeholder        
    }
}