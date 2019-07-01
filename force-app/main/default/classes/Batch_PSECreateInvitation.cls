/**
 * Created by Igor Malyuta on 29.05.2019.
 */

public without sharing class Batch_PSECreateInvitation extends Batch_ScheduledAbstract{

    public Iterable<SObject> start(Database.BatchableContext param1) {
        List<Trial_Survey__c> trialSurveys = [
                SELECT
                        Active_After_Days__c
                FROM Trial_Survey__c
                WHERE Clinical_Trial_Profile__r.Override_Recruitment_Status__c = :TrialService.STATUS_ACTIVELY_ENROLLING
                 AND Active_After_Days__c != NULL

        ];

        Set<Decimal> daysSet = new Set<Decimal>();
        for (Trial_Survey__c ts : trialSurveys) daysSet.add(ts.Active_After_Days__c);

        return [
                SELECT
                        Id,
                        Clinical_Trial_Profile__c,
                        Days_After_Referred__c,
                        Participant_Contact__c
                FROM Participant_Enrollment__c
                WHERE Participant_Status__c IN: SurveyService.getAvailableStatuses()
                AND (Participant_Study_Enrollment__c = NULL
                    OR Participant_Study_Enrollment__r.Status__c IN: SurveyService.getAvailableStatuses())
                AND Days_After_Referred__c IN: daysSet
                AND Participant_Contact__c IN (SELECT ContactId FROM User WHERE IsActive = TRUE)
        ];
    }

    public void execute(Database.BatchableContext param1, List<SObject> enrollments) {
        List<Trial_Survey__c> trialSurveys = [
                SELECT
                        Id,
                        Clinical_Trial_Profile__c,
                        Survey__c,
                        Survey__r.Name,
                        Active_After_Days__c,
                        Expires_After_Days__c,
                        Reminder_Schedule__c,
                        Whose_response_needed__c
                FROM Trial_Survey__c
                WHERE Clinical_Trial_Profile__c
                        IN (SELECT
                                Clinical_Trial_Profile__c
                        FROM Participant_Enrollment__c
                        WHERE Id IN:enrollments)
        ];

        Map<Id, String> trialWhoseResponse = new Map<Id, String>();
        Map<Id, List<Trial_Survey__c>> ctpToTSMap = new Map<Id, List<Trial_Survey__c>>();
        for(Trial_Survey__c t : trialSurveys) {
            trialWhoseResponse.put(t.Id, t.Whose_response_needed__c);

            List<Trial_Survey__c> tsList = ctpToTSMap.get(t.Clinical_Trial_Profile__c);
            if(tsList == null) {
                tsList = new List<Trial_Survey__c>();
                ctpToTSMap.put(t.Clinical_Trial_Profile__c, tsList);
            }
            tsList.add(t);
        }

        List<SurveyInvitation> surveyInvitation = [
                SELECT
                        Id,
                        Participant_Enrollment__c,
                        Trial_Survey__c
                FROM SurveyInvitation
                WHERE Participant_Enrollment__c IN:enrollments
        ];

        Map<String, SurveyInvitation> invitationMap = new Map<String, SurveyInvitation>();
        for(SurveyInvitation inv : surveyInvitation) {
            invitationMap.put('' + inv.Participant_Enrollment__c + inv.Trial_Survey__c, inv);
        }

        List<SurveyInvitation> newInvitations = new List<SurveyInvitation>();
        for(Participant_Enrollment__c pe : (List<Participant_Enrollment__c>) enrollments) {
            List<Trial_Survey__c> surveys = ctpToTSMap.get(pe.Clinical_Trial_Profile__c);
            if(surveys != null) {
                for(Trial_Survey__c surv : surveys) {
                    if(surv.Active_After_Days__c == pe.Days_After_Referred__c) {
                        String key = '' + pe.Id + surv.Id;
                        if(invitationMap.get(key) == null) {
                            newInvitations.add(SurveyService.getInstance().generateInvitation(surv, pe.Id));
                        }
                    }
                }
            }
        }

        insert newInvitations;
        Map<Id, String> invitationsVisible = new Map<Id, String>();
        for(SurveyInvitation inv : newInvitations) {
            invitationsVisible.put(inv.Id, trialWhoseResponse.get(inv.Trial_Survey__c));
        }

        TaskService.getInstance().createSurveyTasks(invitationsVisible);
    }

    public override Type getType() {
        return Batch_PSECreateInvitation.class;
    }

}