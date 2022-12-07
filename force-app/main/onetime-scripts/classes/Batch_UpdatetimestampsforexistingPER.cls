global with sharing class Batch_UpdatetimestampsforexistingPER implements Database.Batchable<sObject>{
    public List<Id> perExcludeIds = new List<Id>();
    public List<Id> perTargetIds = new List<Id>();
    public Batch_UpdatetimestampsforexistingPER(List<Id> perExcludeIds,List<Id> perTargetIds){
        this.perExcludeIds = perExcludeIds;
        this.perTargetIds = perTargetIds;
    }
    public Batch_UpdatetimestampsforexistingPER(){}

    global Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> filedsList = new List<String>{'Permit_Mail_Email_contact_for_this_study__c','Permit_Voice_Text_contact_for_this_study__c','Permit_SMS_Text_for_this_study__c','Permit_IQVIA_to_contact_about_study__c'};
        String query  = 'Select id,CreatedDate,Study_Email_Consent_Time__c,Study_Phone_Consent_Time__c,Study_Pre_recorded_Calls_Consent_Time__c,Study_Artificial_Voice_Consent_Time__c,Study_SMS_Consent_Time__c,Study_Assisted_Dialing_Consent_Time__c,Study_PI_Storage_Consent_Time__c,Permit_Mail_Email_contact_for_this_study__c,';
        query += 'Participant__r.Mailing_Country_Code__c,Participant__r.Mailing_Country__c,Permit_IQVIA_to_contact_about_study__c,Permit_SMS_Text_for_this_study__c,Study_Direct_Mail_Consent_Time__c,Permit_Voice_Text_contact_for_this_study__c,Participant_Contact__r.MailingCountry,';
        query = query + '(Select id,parentId,Field, OldValue , NewValue,createddate from Histories where Field IN :filedsList)';
        query = query + ' from Participant_Enrollment__c ';
        query = query + ' where  ((Participant__c!=null and Participant__r.Mailing_Country__c!=null) or (Participant_Contact__c!=null and Participant_Contact__r.MailingCountry!=null)) ';
        if(perExcludeIds.size()>0 && perTargetIds.size()>0){
            query = query + '  and ID NOT IN:perExcludeIds and ID IN:perTargetIds';
        }
        else if(perExcludeIds.size()>0){
            query = query + '  and ID NOT IN:perExcludeIds';
        }else if(perTargetIds.size()>0){
            query = query + '  and ID IN:perTargetIds';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Participant_Enrollment__c> scope){
        
        List<Participant_Enrollment__c> enrollmentsToUpdate = new List<Participant_Enrollment__c>();
        List<Participant_Enrollment__History> enrollmentHistories = new List<Participant_Enrollment__History>();
        Map<Id,Map<String,DateTime>> enrollmentWithConsentTimestamps = new Map<Id,Map<String,DateTime>>();
        //Get all histories in a list to avoid looping
        for(Participant_Enrollment__c enrollment:scope){
            enrollmentHistories.addAll(enrollment.Histories);
        }
        //Iterate through all history to form an PER vs History map
        for(Participant_Enrollment__History peh:enrollmentHistories){  
            Map<String,DateTime> fieldHistory = new Map<String,DateTime>();
            if(enrollmentWithConsentTimestamps.containsKey(peh.parentId)){
                fieldHistory = enrollmentWithConsentTimestamps.get(peh.parentId);
                if(fieldHistory.keyset() != null && ((fieldHistory.keyset().contains(peh.Field) && fieldHistory.get(peh.Field) < peh.createddate)
                ||  !fieldHistory.keyset().contains(peh.Field))){
                    fieldHistory.put(peh.Field,peh.createddate);
                }
            }else{
                fieldHistory.put(peh.Field,peh.createddate);
            }
            enrollmentWithConsentTimestamps.put(peh.parentId,fieldHistory);
        }

        for(Participant_Enrollment__c per:scope){
                Participant_Enrollment__c pertoupdate = new Participant_Enrollment__c();
                pertoupdate.Id = per.Id;
                Boolean check = false;
                Boolean hasHistory = enrollmentWithConsentTimestamps.containsKey(per.Id);
                Boolean isCountryUS = false;
                if(per.Participant__r.Mailing_Country__c == 'United States' || (per.Participant_Contact__c!=null && (String.isEmpty(per.Participant__c) || String.isEmpty(per.Participant__r.Mailing_Country__c)) && per.Participant_Contact__r.MailingCountry == 'United States')){
                    isCountryUS = true;
                }
                if(per.Study_PI_Storage_Consent_Time__c == null && hasHistory && per.Permit_IQVIA_to_contact_about_study__c &&
                enrollmentWithConsentTimestamps.get(per.Id).keyset().contains('Permit_IQVIA_to_contact_about_study__c')){
                    pertoupdate.Study_PI_Storage_Consent_Time__c = enrollmentWithConsentTimestamps.get(per.Id).get('Permit_IQVIA_to_contact_about_study__c');
                    check = true;
                }else if(per.Study_PI_Storage_Consent_Time__c == null && per.Permit_IQVIA_to_contact_about_study__c){
                    pertoupdate.Study_PI_Storage_Consent_Time__c = per.createddate;
                    check = true;
                }

                if(per.Study_SMS_Consent_Time__c == null && hasHistory && per.Permit_SMS_Text_for_this_study__c &&
                enrollmentWithConsentTimestamps.get(per.Id).keyset().contains('Permit_SMS_Text_for_this_study__c')){
                    pertoupdate.Study_SMS_Consent_Time__c = enrollmentWithConsentTimestamps.get(per.Id).get('Permit_SMS_Text_for_this_study__c');
                    check = true;
                }else if(per.Study_SMS_Consent_Time__c == null && per.Permit_SMS_Text_for_this_study__c){
                    pertoupdate.Study_SMS_Consent_Time__c = per.createddate;
                    check = true;
                }

                if(per.Study_Email_Consent_Time__c == null && hasHistory && per.Permit_Mail_Email_contact_for_this_study__c &&
                enrollmentWithConsentTimestamps.get(per.Id).keyset().contains('Permit_Mail_Email_contact_for_this_study__c')){
                    pertoupdate.Study_Email_Consent_Time__c = enrollmentWithConsentTimestamps.get(per.Id).get('Permit_Mail_Email_contact_for_this_study__c');
                    check = true;
                }else if(per.Study_Email_Consent_Time__c == null && per.Permit_Mail_Email_contact_for_this_study__c){
                    pertoupdate.Study_Email_Consent_Time__c = per.createddate;
                    check = true;
                }
                if(per.Permit_Mail_Email_contact_for_this_study__c){
                    pertoupdate.Study_Direct_Mail_Consent__c = true;
                }

                if(per.Study_Direct_Mail_Consent_Time__c == null && hasHistory && per.Permit_Mail_Email_contact_for_this_study__c &&
                enrollmentWithConsentTimestamps.get(per.Id).keyset().contains('Permit_Mail_Email_contact_for_this_study__c')){
                    pertoupdate.Study_Direct_Mail_Consent_Time__c = enrollmentWithConsentTimestamps.get(per.Id).get('Permit_Mail_Email_contact_for_this_study__c');
                    check = true;
                }else if(per.Study_Direct_Mail_Consent_Time__c == null && per.Permit_Mail_Email_contact_for_this_study__c){
                    pertoupdate.Study_Direct_Mail_Consent_Time__c = per.createddate;
                    check = true;
                }

                if(per.Study_Phone_Consent_Time__c == null && hasHistory && per.Permit_Voice_Text_contact_for_this_study__c &&
                enrollmentWithConsentTimestamps.get(per.Id).keyset().contains('Permit_Voice_Text_contact_for_this_study__c')){
                    pertoupdate.Study_Phone_Consent_Time__c = enrollmentWithConsentTimestamps.get(per.Id).get('Permit_Voice_Text_contact_for_this_study__c');
                   check = true;
                }else if(per.Study_Phone_Consent_Time__c == null && per.Permit_Voice_Text_contact_for_this_study__c){
                    pertoupdate.Study_Phone_Consent_Time__c = per.createddate;
                    check = true;
                }

                if(per.Permit_Voice_Text_contact_for_this_study__c){
                    pertoupdate.Study_Assisted_Dialing_Consent__c = true;
                    
                }

                if(per.Study_Assisted_Dialing_Consent_Time__c == null && hasHistory && per.Permit_Voice_Text_contact_for_this_study__c &&
                enrollmentWithConsentTimestamps.get(per.Id).keyset().contains('Permit_Voice_Text_contact_for_this_study__c')){
                    pertoupdate.Study_Assisted_Dialing_Consent_Time__c = enrollmentWithConsentTimestamps.get(per.Id).get('Permit_Voice_Text_contact_for_this_study__c');
                   check = true;
                }else if(per.Study_Assisted_Dialing_Consent_Time__c == null && per.Permit_Voice_Text_contact_for_this_study__c){
                    pertoupdate.Study_Assisted_Dialing_Consent_Time__c = per.createddate;
                    check = true;
                }

                if(!isCountryUS){
                    if(per.Permit_Voice_Text_contact_for_this_study__c){
                        pertoupdate.Study_Artificial_Voice_Consent__c = true;
                        pertoupdate.Study_Pre_recorded_Voice_Consent__c = true;
                    }
                    if(per.Study_Artificial_Voice_Consent_Time__c == null && hasHistory && per.Permit_Voice_Text_contact_for_this_study__c &&
                    enrollmentWithConsentTimestamps.get(per.Id).keyset().contains('Permit_Voice_Text_contact_for_this_study__c')){
                        pertoupdate.Study_Artificial_Voice_Consent_Time__c = enrollmentWithConsentTimestamps.get(per.Id).get('Permit_Voice_Text_contact_for_this_study__c');
                    check = true;
                    }else if(per.Study_Artificial_Voice_Consent_Time__c == null && per.Permit_Voice_Text_contact_for_this_study__c){
                        pertoupdate.Study_Artificial_Voice_Consent_Time__c = per.createddate;
                        check = true;
                    }

                    if(per.Study_Pre_recorded_Calls_Consent_Time__c == null && hasHistory && per.Permit_Voice_Text_contact_for_this_study__c &&
                    enrollmentWithConsentTimestamps.get(per.Id).keyset().contains('Permit_Voice_Text_contact_for_this_study__c')){
                        pertoupdate.Study_Pre_recorded_Calls_Consent_Time__c = enrollmentWithConsentTimestamps.get(per.Id).get('Permit_Voice_Text_contact_for_this_study__c');
                    check = true;
                    }else if(per.Study_Pre_recorded_Calls_Consent_Time__c == null && per.Permit_Voice_Text_contact_for_this_study__c){
                        pertoupdate.Study_Pre_recorded_Calls_Consent_Time__c = per.createddate;
                        check = true;
                    }
                }
                
                if(check || test.isRunningTest()){
                    enrollmentsToUpdate.add(pertoupdate);
                }
        }
        if(!enrollmentsToUpdate.isEmpty()){
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
            update enrollmentsToUpdate;
        }
        
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    } 
}