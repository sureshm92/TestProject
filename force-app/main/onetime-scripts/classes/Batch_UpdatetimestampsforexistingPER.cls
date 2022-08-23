global with sharing class Batch_UpdatetimestampsforexistingPER implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Set<Id> junkdataset = new Set<Id>{'a1U1j000000ZFrYEAW',
            'a1U1j000000ZJPZEA4',
            'a1U1j000000ZOuYEAW',
            'a1U1j000000ZfKNEA0',
            'a1U1j000000ZiIuEAK',
            'a1U1j000000ZylNEAS',
            'a1U1j000000ZylOEAS',
            'a1U1j000000ZyvaEAC',
            'a1U1j000000ZyvbEAC',
            'a1U1j000000ZyvcEAC',
            'a1U1j000000ZyvwEAC',
            'a1U1j000000ZywEEAS',
            'a1U1j000000ZywFEAS',
            'a1U1j000000ZywGEAS',
            'a1U1j000000Zz96EAC',
            'a1U1j000000ZMfcEAG',
            'a1U1j000000ZNvHEAW',
            'a1U1j000000ZOllEAG',
            'a1U1j000000ZOqgEAG',
            'a1U1j000000ZOs3EAG',
            'a1U1j000000ZOsNEAW',
            'a1U1j000000ZOtQEAW',
            'a1U1j000000ZP0FEAW',
            'a1U1j000000ZPBpEAO',
            'a1U1j000000ZPtqEAG',
            'a1U1j000000ZQ7pEAG',
            'a1U1j000000ZQ8nEAG',
            'a1U1j000000ZQWUEA4',
            'a1U1j000000ZQWZEA4',
            'a1U1j000000ZQWyEAO',
            'a1U1j000000ZReUEAW',
            'a1U1j000000ZS1CEAW',
            'a1U1j000000ZSOPEA4',
            'a1U1j000000ZTLgEAO',
            'a1U1j000000ZTMjEAO',
            'a1U1j000000ZUTbEAO',
            'a1U1j000000ZUVwEAO',
            'a1U1j000000ZUaDEAW',
            'a1U1j000000ZUejEAG',
            'a1U1j000000ZUeoEAG',
            'a1U1j000000ZUetEAG',
            'a1U1j000000ZUgVEAW'
            };
        List<String> filedsList = new List<String>{'Permit_Mail_Email_contact_for_this_study__c','Permit_Voice_Text_contact_for_this_study__c','Permit_SMS_Text_for_this_study__c','Permit_IQVIA_to_contact_about_study__c'};
        String query  = 'Select id,Study_Email_Consent_Time__c,Study_Phone_Consent_Time__c,Study_SMS_Consent_Time__c,Study_PI_Storage_Consent_Time__c,';
        query = query + '(Select id,parentId,Field, OldValue , NewValue,createddate from Histories where Field IN :filedsList)';
        query = query + ' from Participant_Enrollment__c where (Study_Email_Consent_Time__c = null or Study_Phone_Consent_Time__c = null or Study_SMS_Consent_Time__c = null or Study_PI_Storage_Consent_Time__c = null)';
        query = query + ' AND ID NOT IN:junkdataset';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Sobject> records){
        List<Participant_Enrollment__c> lst_PER = (List<Participant_Enrollment__c>)records;
        List<Participant_Enrollment__c> toupdateConsent = new List<Participant_Enrollment__c>();
        List<Participant_Enrollment__History> ListPers = new List<Participant_Enrollment__History>();
        Map<Id,Map<String,DateTime>> mapPer = new Map<Id,Map<String,DateTime>>();
        for(Participant_Enrollment__c per:lst_PER){
            ListPers.addAll(per.Histories);
        }
        for(Participant_Enrollment__History peh:ListPers){  
            Map<String,DateTime> maph = new Map<String,DateTime>();
            if(mapPer.containsKey(peh.parentId)){
                Map<String,DateTime> maph1 = mapPer.get(peh.parentId);
                if(maph1.keyset() != null && maph1.keyset().contains(peh.Field) && maph1.get(peh.Field) < peh.createddate){
                    maph1.put(peh.Field,peh.createddate);
                    mapPer.get(peh.parentId).putAll(maph1);
                }else if(maph1.keyset() != null && !maph1.keyset().contains(peh.Field)){
                    maph.put(peh.Field,peh.createddate);
                    mapPer.get(peh.parentId).putAll(maph);
                }
            }else{
                maph.put(peh.Field,peh.createddate);
                mapPer.put(peh.parentId,maph);
            }
        }
        system.debug('++++++++'+mapPer);
        for(Participant_Enrollment__c per:lst_PER){
            if(per.Histories != null && per.Histories.size() > 0){
                Participant_Enrollment__c pertoupdate = new Participant_Enrollment__c();
                pertoupdate.Id = per.Id;
                Boolean check = false;
                if(per.Study_Email_Consent_Time__c == null && mapPer.get(per.Id) != null && 
                   mapPer.get(per.Id).keyset().contains('Permit_Mail_Email_contact_for_this_study__c')){
                       
                       pertoupdate.Study_Email_Consent_Time__c = mapPer.get(per.Id).get('Permit_Mail_Email_contact_for_this_study__c');
                       check = true;
                   }
                if(per.Study_Phone_Consent_Time__c == null && mapPer.get(per.Id) != null && 
                   mapPer.get(per.Id).keyset().contains('Permit_Voice_Text_contact_for_this_study__c')){
                       
                       pertoupdate.Study_Phone_Consent_Time__c = mapPer.get(per.Id).get('Permit_Voice_Text_contact_for_this_study__c');
                       check = true;
                   } 
                if(per.Study_SMS_Consent_Time__c == null && mapPer.get(per.Id) != null && 
                   mapPer.get(per.Id).keyset().contains('Permit_SMS_Text_for_this_study__c')){
                       
                       pertoupdate.Study_SMS_Consent_Time__c = mapPer.get(per.Id).get('Permit_SMS_Text_for_this_study__c');
                       check = true;
                   } 
                if(per.Study_PI_Storage_Consent_Time__c == null && mapPer.get(per.Id) != null && 
                   mapPer.get(per.Id).keyset().contains('Permit_IQVIA_to_contact_about_study__c')){
                       
                       pertoupdate.Study_PI_Storage_Consent_Time__c = mapPer.get(per.Id).get('Permit_IQVIA_to_contact_about_study__c');
                       check = true;
                   }
                if(check || test.isRunningTest()){
                    toupdateConsent.add(pertoupdate);
                }
            }
            
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