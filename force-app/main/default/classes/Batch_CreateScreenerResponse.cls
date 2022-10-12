public class Batch_CreateScreenerResponse implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(
            [
                SELECT Id, Clinical_Trial_Profile__c, Medical_Record_Review_Completed_by__c, Medical_Record_Review_Completed_Date__c, 
                    Medical_Record_Review_Status__c, MRR_Survey_Results_URL__c, Pre_Screener_Completed_by__c,
                    Pre_Screener_Completed_Date__c, Pre_Screener_Survey_Response__c, Pre_screening_Status__c
                FROM Participant_Enrollment__c 
                WHERE Medical_Record_Review_Completed_Date__c != null OR Pre_Screener_Completed_Date__c != null
            ]
        );
    }
    
    public void execute(Database.BatchableContext bc, List<Participant_Enrollment__c> enrollmentRecords) {
        
        Map<Id, Id> ctpMRRSurveyIdsMap = new Map<Id, Id>();
        Map<Id, Id> ctpScreenerSurveyIdsMap = new Map<Id, Id>();
        Set<Id> trailIds = new Set<Id>();

        for(Participant_Enrollment__c peRecord : enrollmentRecords) {

            trailIds.add(peRecord.Clinical_Trial_Profile__c);
        }

        for(PreScreener_Survey__c surveyRecord : [
            SELECT Id, MRR__c, Prescreener__c, Study__c 
            FROM PreScreener_Survey__c 
            WHERE Study__c IN :trailIds]) {

            if(surveyRecord.MRR__c) {
                ctpMRRSurveyIdsMap.put(surveyRecord.Study__c, surveyRecord.Id);
            } else if(surveyRecord.Prescreener__c) {
                ctpScreenerSurveyIdsMap.put(surveyRecord.Study__c, surveyRecord.Id);
            }
        }

        List<Participant_PrescreenerResponse__c> responseRecords = new List<Participant_PrescreenerResponse__c>();
        for(Participant_Enrollment__c peRecord : enrollmentRecords) {

            if(String.isNotBlank(peRecord.MRR_Survey_Results_URL__c)) {

                if(String.isNotBlank(peRecord.Medical_Record_Review_Completed_by__c)
                    && ctpMRRSurveyIdsMap.containsKey(peRecord.Clinical_Trial_Profile__c)) {
                    responseRecords.add(
                        new Participant_PrescreenerResponse__c(
                            Completed_by__c = peRecord.Medical_Record_Review_Completed_by__c,
                            Completed_Date__c = peRecord.Medical_Record_Review_Completed_Date__c,
                            Participant_enrollment__c = peRecord.Id,
                            PreScreener_Survey__c = ctpMRRSurveyIdsMap.get(peRecord.Clinical_Trial_Profile__c),
                            Screener_Response__c = peRecord.MRR_Survey_Results_URL__c,
                            Status__c = peRecord.Medical_Record_Review_Status__c
                        )
                    );
                } else if(String.isBlank(peRecord.Medical_Record_Review_Completed_by__c) 
                        && String.isBlank(peRecord.Medical_Record_Review_Status__c)){
                    responseRecords.add(
                        new Participant_PrescreenerResponse__c(
                            Completed_Date__c = peRecord.Medical_Record_Review_Completed_Date__c,
                            Participant_enrollment__c = peRecord.Id,
                            Screener_Response__c = peRecord.MRR_Survey_Results_URL__c,
                            Status__c = 'Pass'
                        )
                    );
                }
            }
            
            if(String.isNotBlank(peRecord.Pre_Screener_Survey_Response__c)
                && ctpScreenerSurveyIdsMap.containsKey(peRecord.Clinical_Trial_Profile__c)) {

                responseRecords.add(
                    new Participant_PrescreenerResponse__c(
                        Completed_by__c = peRecord.Pre_Screener_Completed_by__c,
                        Completed_Date__c = peRecord.Pre_Screener_Completed_Date__c,
                        Participant_enrollment__c = peRecord.Id,
                        PreScreener_Survey__c = ctpScreenerSurveyIdsMap.get(peRecord.Clinical_Trial_Profile__c),
                        Screener_Response__c = peRecord.Pre_Screener_Survey_Response__c,
                        Status__c = peRecord.Pre_screening_Status__c
                    )
                );
            }
        }
        
        List<Database.SaveResult> saveResults = Database.insert(responseRecords, false);
        Map<Id, Participant_Enrollment__c> peToUpdate = new Map<Id, Participant_Enrollment__c>();
        for (Integer i = 0; i < saveResults.size(); i++) {
            
            if (saveResults[i].isSuccess()) {
                
                Participant_PrescreenerResponse__c surveyResponseRec = responseRecords[i];
                Participant_Enrollment__c peRecord = new Participant_Enrollment__c(Id = surveyResponseRec.Participant_enrollment__c);
                if(peToUpdate.containsKey(surveyResponseRec.Participant_enrollment__c)) { 
                    peRecord = peToUpdate.get(surveyResponseRec.Participant_enrollment__c);
                } 
                if(surveyResponseRec.PreScreener_Survey__c == null 
                    || ctpMRRSurveyIdsMap.values().contains(surveyResponseRec.PreScreener_Survey__c)) { 
                    peRecord.Medical_Record_Review_Completed_by__c = null;
                    peRecord.Medical_Record_Review_Completed_Date__c = null;
                    peRecord.MRR_Survey_Results_URL__c = null;
                    peRecord.Medical_Record_Review_Status__c = null;
                } else if(ctpScreenerSurveyIdsMap.values().contains(surveyResponseRec.PreScreener_Survey__c)){
                    peRecord.Pre_Screener_Completed_by__c = null;
                    peRecord.Pre_Screener_Completed_Date__c = null;
                    peRecord.Pre_Screener_Survey_Response__c = null;
                    peRecord.Pre_screening_Status__c = null;
                }
                peToUpdate.put(peRecord.Id, peRecord);
            } 
        }
        bypassTriggers();
        update peToUpdate.values();
    }
    
    public void finish(Database.BatchableContext bc){
        
    }

    public static void bypassTriggers() {

        TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.UpdateParticipantInitialVisit.class
        );
        /*TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateUsersOrSendNotificationsHandler.class
        );*/
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.DefaultEcoaTask.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.createNotifications.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateMissingStatuses.class
        );
        /*TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
        );*/
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class
        );
        /*TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateWelcomeToStudyAlertHandler.class
        );*/
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SendFOVtoAPI.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.UnenrollorCancelPer.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.EcoaEvents.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.StudyConsentTimestamps.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.UpdatePatientConsent.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.SendEmailIfSSWasChanged.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.CreateNotificationHandler.class
        );
        /*TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SendDropOutEmailHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SetCurrentEnrollmentHandler.class
        );*/
    }
}