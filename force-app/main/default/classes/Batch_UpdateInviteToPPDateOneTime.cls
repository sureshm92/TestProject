/**
 * One time Batch for July release 2021.
 */


global with sharing class Batch_UpdateInviteToPPDateOneTime implements Database.Batchable<sObject> {


    global Batch_UpdateInviteToPPDateOneTime() {
    }


    global Database.querylocator start(Database.BatchableContext BC) {
        String strQuery = 'SELECT Id,Participant__c,Participant__r.Adult__c,Participant__r.Date_Of_Birth__c,Participant_Contact__c,Invited_To_PP_Date__c FROM Participant_Enrollment__c WHERE Participant_Contact__c IN (SELECT ContactId FROM User WHERE isActive = true) AND Invited_To_PP_Date__c = null AND Study_Site__r.Study_Site_Type__c = \'Traditional\'';
        return Database.getQueryLocator(strQuery);
    }

    global void execute(Database.BatchableContext BC, List<Participant_Enrollment__c> peList) {
        List<Id> contactIds = new List<Id>();
        List<Participant_Enrollment__c> updateList = new List<Participant_Enrollment__c>();
        for(Participant_Enrollment__c pe: peList){
            contactIds.add(pe.Participant_Contact__c);
        }
        Map<Id,DateTime> contactAndDate = new Map<Id,DateTime>();
        //List<User> users = [SELECT ContactId,CreatedDate FROM User WHERE ContactId IN : contactIds];
        for(User u : [SELECT Id,ContactId,CreatedDate FROM User WHERE ContactId IN : contactIds]){
            contactAndDate.put(u.ContactId,u.CreatedDate);
        }
        for(Participant_Enrollment__c pe: peList){
            if(!(pe.Participant__c!=null && pe.Participant__r.Adult__c ==false && pe.Participant__r.Date_Of_Birth__c!=null)){
                Participant_Enrollment__c up = new Participant_Enrollment__c();
                up.Id = pe.Id;
                
                up.Invited_To_PP_Date__c = contactAndDate.get(pe.Participant_Contact__c);
                updateList.add(up);
            }
        }
        TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class);
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
        );
        TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.SendEmailIfSSWasChanged.class);
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class
        );
        
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class);
        TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.CreateNotificationHandler.class);
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
        );
        DataBase.update(updateList,false);
        
    }


    global void finish(Database.BatchableContext BC) {
    
    }

}