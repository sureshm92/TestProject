global without sharing class Batch_UpdateConsentCheckboxesOnPER implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Set<Id> junkdataset = new Set<Id>{'a1U1j000000ZJPZEA4',
        'a1U1j000000ZMfcEAG',
        'a1U1j000000ZNvHEAW',
        'a1U1j000000ZPBpEAO',
        'a1U1j000000ZQ7pEAG',
        'a1U1j000000ZQ8nEAG',
        'a1U1j000000ZQWUEA4',
        'a1U1j000000ZQWZEA4',
        'a1U1j000000ZReUEAW',
        'a1U1j000000ZS1CEAW',
        'a1U1j000000ZUaDEAW',
        'a1U1j000000ZUejEAG',
        'a1U1j000000ZUeoEAG',
        'a1U1j000000ZUetEAG',
        'a1U1j000000ZUgVEAW'
        };
        String query  = 'Select id,Permit_Mail_Email_contact_for_this_study__c,Permit_SMS_Text_for_this_study__c,Permit_Voice_Text_contact_for_this_study__c';
        query = query + ' from Participant_Enrollment__c where (Permit_Mail_Email_contact_for_this_study__c = true or Permit_SMS_Text_for_this_study__c = true or Permit_Voice_Text_contact_for_this_study__c = true)';
        query = query + ' AND ID NOT IN:junkdataset';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Sobject> records){
        List<Participant_Enrollment__c> lst_PER = (List<Participant_Enrollment__c>)records;
        List<Participant_Enrollment__c> toupdateConsent = new List<Participant_Enrollment__c>();
        for(Participant_Enrollment__c con:lst_PER){
            Participant_Enrollment__c pertoupdate = new Participant_Enrollment__c();
            pertoupdate.Id = con.Id;
            if(con.Permit_Voice_Text_contact_for_this_study__c){
                pertoupdate.Study_Pre_recorded_Voice_Consent__c = con.Permit_Voice_Text_contact_for_this_study__c;
                pertoupdate.Study_Assisted_Dialing_Consent__c = con.Permit_Voice_Text_contact_for_this_study__c;
                pertoupdate.Study_Artificial_Voice_Consent__c = con.Permit_Voice_Text_contact_for_this_study__c;
            }
            if(con.Permit_Mail_Email_contact_for_this_study__c){
                pertoupdate.Study_Direct_Mail_Consent__c = con.Permit_Mail_Email_contact_for_this_study__c;
            } 
            toupdateConsent.add(pertoupdate);
        }
        if(!toupdateConsent.isEmpty()){
            TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class);
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.SendEmailIfSSWasChanged.class);
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.createNotifications.class
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
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SendFOVtoAPI.class);
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.UnenrollorCancelPer.class);
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.UpdateParticipantInitialVisit.class
            );
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateMissingStatuses.class);
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.EcoaEvents.class);
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.DefaultEcoaTask.class);
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.UpdatePatientConsent.class);
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.StudyConsentTimestamps.class);
            update toupdateConsent;
        }
        
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    } 
}