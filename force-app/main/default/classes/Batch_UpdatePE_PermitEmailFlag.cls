global without sharing class Batch_UpdatePE_PermitEmailFlag implements Database.Batchable<SObject> {
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([Select Id, User__r.Contact.Id,Accepted_Date__c 
                                         FROM Terms_And_Conditions_Acceptance__c WHERE Accepted_Date__c != NULL]);
    }
    
    global void execute(Database.BatchableContext bc, List<Terms_And_Conditions_Acceptance__c> scope) {
        List<Id> conIdList = new List<id>();
        List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
        for(Terms_And_Conditions_Acceptance__c tca: scope){
            conIdList.add(tca.User__r.Contact.Id);
        }
        for(Participant_Enrollment__c pe : [SELECT Id,Permit_Mail_Email_contact_for_this_study__c,Participant_Contact__c 
                                            FROM Participant_Enrollment__c 
                                            WHERE Participant_Contact__c IN: conIdList]){
                                                pe.Permit_Mail_Email_contact_for_this_study__c = true; 
                                                peList.add(pe);
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
        Database.update(peList, false);
    }
    
    global void finish(Database.BatchableContext bc) {}
}