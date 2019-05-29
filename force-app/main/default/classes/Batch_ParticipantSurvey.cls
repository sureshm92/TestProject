/**
 * Created by Igor Malyuta on 24.05.2019.
 */

public with sharing class Batch_ParticipantSurvey implements Database.Batchable<Participant_Survey__c>, Database.Stateful {

    public Integer intervalInMinutes;

    public Batch_ParticipantSurvey(Integer intervalInMinutes) {
        this.intervalInMinutes = intervalInMinutes;
    }

    public Iterable<Participant_Survey__c> start(Database.BatchableContext param1) {
        List<Participant_Survey__c> participantSurveys = [
                SELECT
                        Expiration_Date__c,
                        Id,
                        Name,
                        Participant_Contact__c,
                        Participant_Study_Enrollment__c,
                        Show_Date__c,
                        Survey__c,
                        Survey__r.Name,
                        Visible_To_Delegates__c
                FROM Participant_Survey__c
                WHERE Show_Date__c = :System.today()
                    AND Processed__c = FALSE
        ];

        System.debug('Records found: '+ participantSurveys.size());
        return participantSurveys;
    }

    public void execute(Database.BatchableContext param1, List<Participant_Survey__c> participantSurveys) {
        createSurveyTasks(participantSurveys);
        SurveyService.getInstance().generateInvitations(participantSurveys);

        for(Participant_Survey__c ps : participantSurveys) ps.Processed__c = true;
        update participantSurveys;
    }

    private void createSurveyTasks(List<Participant_Survey__c> participantSurveys) {
        Map<Id, Participant_Survey__c> contactToPS = new Map<Id, Participant_Survey__c>();
        for (Participant_Survey__c partS : participantSurveys) {
            contactToPS.put(partS.Participant_Contact__c, partS);
        }

        List<User> users = [
                SELECT Id, ContactId
                FROM User
                WHERE ContactId IN:contactToPS.keySet()
                AND IsActive = TRUE
        ];

        List<Task> tasks = new List<Task>();
        for (User taskOwner : users) {
            Participant_Survey__c ps = contactToPS.get(taskOwner.ContactId);
            tasks.add(TaskService.getInstance().createCompleteSurveyTask(taskOwner.Id, ps));
        }

        insert tasks;
    }

    public void finish(Database.BatchableContext param1) {
        System.scheduleBatch(
                new Batch_ParticipantSurvey(intervalInMinutes), 'ParticipantSurvey', intervalInMinutes
        );
    }

    public static void run(Integer intervalInMinutes) {
        Database.executeBatch(new Batch_ParticipantSurvey(intervalInMinutes));
    }

    public static void stop() {
        List<CronTrigger> cronTriggers = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name = 'ParticipantSurvey'
        ];
        if(!cronTriggers.isEmpty()) {
            for(CronTrigger cronT : cronTriggers) {
                System.abortJob(cronT.Id);
            }
        }
    }
}