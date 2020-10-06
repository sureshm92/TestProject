global without sharing class Batch_UpdateParticipantAge implements Database.Batchable<SObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([Select Id, Age__c,Date_of_Birth__c,CreatedDate, Gender__c,Gender_Technical__c FROM Participant__c ]);
    }
    global void execute(Database.BatchableContext bc, List<Participant__c> scope) {
        List<Participant__c> pList = new List<Participant__c>();
        for(Participant__c p : scope){
            
            if(!String.isBlank(p.Date_of_Birth__c)){
                Date birthDate = Date.newInstance(
                    Integer.valueOf(p.Date_of_Birth__c.substring(0, 4)),
                    Integer.valueOf(p.Date_of_Birth__c.substring(5, 7)),
                    Integer.valueOf(p.Date_of_Birth__c.substring(8, 10)));
                
                Integer participantAge =
                    Date.newInstance(2000, birthDate.month(), birthDate.day()) <=
                    Date.newInstance(2000, p.CreatedDate.month(), p.CreatedDate.day()) ?
                    p.CreatedDate.year() - birthDate.year() : p.CreatedDate.year() - birthDate.year() - 1;
                
                Date CreatedDate_temp = Date.newInstance(
                    Integer.valueOf(p.CreatedDate.year()),
                    Integer.valueOf(p.CreatedDate.month()),
                    Integer.valueOf(p.CreatedDate.day()));
                
                Integer dt1 = (CreatedDate_temp).daysBetween(Date.valueOf(Date.newInstance(Date.today().year(), birthDate.month(), birthDate.day()))) ;
                
                p.Age__c = participantAge;
                If(p.Gender__c == 'Male')
                    p.Gender_Technical__c = 'M';
                else if(p.Gender__c == 'Female')
                    p.Gender_Technical__c = 'F';
                else
                    p.Gender_Technical__c = '';
                pList.add(p);
            }           
        }
        TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class);
        TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.SendEmailIfSSWasChanged.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class);
        
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateWelcomeToStudyAlertHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class);
        TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.CreateNotificationHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class);
        Database.update(pList,false); 
        
    }
    global void finish(Database.BatchableContext bc) {}
    
}