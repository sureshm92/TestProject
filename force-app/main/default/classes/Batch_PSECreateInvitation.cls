/**
 * Created by Igor Malyuta on 29.05.2019.
 */

public with sharing class Batch_PSECreateInvitation implements Database.Batchable<Participant_Study_Enrollment__c>, Database.Stateful {

    public static final String JOB_NAME = 'CreateSurveyInvitation';

    public Iterable<Participant_Study_Enrollment__c> start(Database.BatchableContext param1) {
        List<Trial_Survey__c> trialSurveys = [
                SELECT
                        Active_After_Days__c
                FROM Trial_Survey__c
                WHERE Clinical_Trial_Profile__r.Override_Recruitment_Status__c = :TrialService.STATUS_ACTIVELY_ENROLLING
                 AND (Active_After_Days__c != NULL OR Active_On_Status__c IN: PSEService.PSE_STATUS_GROUP_ALL)

        ];

        Set<Decimal> daysSet = new Set<Decimal>();
        for (Trial_Survey__c ts : trialSurveys) daysSet.add(ts.Active_After_Days__c);

        return [
                SELECT
                        Id,
                        Clinical_Trial_Profile__c,
                        Days_After_Enrolled__c,
                        Participant_Contact__c,
                        Status__c
                FROM Participant_Study_Enrollment__c
                WHERE Status__c IN: PSEService.PSE_STATUS_GROUP_ALL
                AND (Days_After_Enrolled__c IN: daysSet OR Days_After_Enrolled__c NOT IN: daysSet)
                AND Participant_Contact__c IN (SELECT ContactId FROM User WHERE IsActive = TRUE)
        ];
    }

    public void execute(Database.BatchableContext param1, List<Participant_Study_Enrollment__c> enrollments) {
        List<Trial_Survey__c> trialSurveys = [
                SELECT
                        Id,
                        Clinical_Trial_Profile__c,
                        Survey__c,
                        Survey__r.Name,
                        Active_After_Days__c,
                        Active_On_Status__c,
                        Expires_After_Days__c
                FROM Trial_Survey__c
                WHERE Clinical_Trial_Profile__c
                        IN (SELECT
                                Clinical_Trial_Profile__c
                        FROM Participant_Study_Enrollment__c
                        WHERE Id IN:enrollments)
        ];
        Map<Id, List<Trial_Survey__c>> ctpTotsMap = new Map<Id, List<Trial_Survey__c>>();
        for(Trial_Survey__c t : trialSurveys) {
            List<Trial_Survey__c> tsList = ctpTotsMap.get(t.Clinical_Trial_Profile__c);
            if(tsList == null) {
                tsList = new List<Trial_Survey__c>();
                ctpTotsMap.put(t.Clinical_Trial_Profile__c, tsList);
            }

            tsList.add(t);
        }

        List<SurveyInvitation> surveyInvitation = [
                SELECT
                        Id,
                        Participant_Study_Enrollment__c,
                        Trial_Survey__c
                FROM SurveyInvitation
                WHERE Participant_Study_Enrollment__c IN:enrollments
        ];
        System.debug('Current invitations: ' + surveyInvitation.size());

        Map<String, SurveyInvitation> invitationMap = new Map<String, SurveyInvitation>();
        for(SurveyInvitation inv : surveyInvitation) {
            System.debug('INV Key: ' + inv.Participant_Study_Enrollment__c + inv.Trial_Survey__c);
            invitationMap.put('' + inv.Participant_Study_Enrollment__c + inv.Trial_Survey__c, inv);
        }

        List<SurveyInvitation> newInvitations = new List<SurveyInvitation>();
        for(Participant_Study_Enrollment__c pse : enrollments) {
            List<Trial_Survey__c> surveys = ctpTotsMap.get(pse.Clinical_Trial_Profile__c);
            if(surveys != null) {
                for(Trial_Survey__c surv : surveys) {
                    if(surv.Active_After_Days__c == pse.Days_After_Enrolled__c || surv.Active_On_Status__c == pse.Status__c) {
                        String key = '' + pse.Id + surv.Id;
                        System.debug('TS Key: ' + pse.Id + surv.Id);
                        if(invitationMap.get(key) == null) {
                            newInvitations.add(SurveyService.getInstance().generateInvitation(surv, pse));
                        }
                    }
                }
            }

        }

        insert newInvitations;
        TaskService.getInstance().createSurveyTasks(newInvitations);
    }

    public void finish(Database.BatchableContext param1) {
        List<Batch_Executor__mdt> batchExecutor = [
                SELECT Relaunch_Interval__c FROM Batch_Executor__mdt WHERE Job_Name__c = :JOB_NAME];
        if(!batchExecutor.isEmpty()) {
            Integer minutes = batchExecutor.get(0).Relaunch_Interval__c.intValue();
            System.scheduleBatch(
                    new Batch_PSECreateInvitation(), JOB_NAME, minutes);
        }
    }

    public static void run() {
        Database.executeBatch(new Batch_PSECreateInvitation());
    }

    public static void stop() {
        List<CronTrigger> cronTriggers = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name =: JOB_NAME
        ];
        if(!cronTriggers.isEmpty()) {
            for(CronTrigger cronT : cronTriggers) {
                System.abortJob(cronT.Id);
            }
        }
    }
}