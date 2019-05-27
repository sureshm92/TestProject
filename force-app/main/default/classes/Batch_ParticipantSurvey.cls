/**
 * Created by Igor Malyuta on 24.05.2019.
 */

public with sharing class Batch_ParticipantSurvey implements Database.Batchable<Participant_Survey__c> {

    public void execute(Database.BatchableContext param1, List<Participant_Survey__c> participantSurveys) {
        Map<Id, Participant_Survey__c> pseToPS = new Map<Id, Participant_Survey__c>();
        for(Participant_Survey__c ps: participantSurveys) {
            pseToPS.put(ps.Participant_Study_Enrollment__c, ps);
        }

        List<Participant_Study_Enrollment__c> pseList = [
                SELECT Id, Participant_Contact__c
                FROM Participant_Study_Enrollment__c
                WHERE Id IN: pseToPS.keySet()
        ];

        Map<Id, Participant_Survey__c> contactToPS = new Map<Id, Participant_Survey__c>();
        for(Participant_Study_Enrollment__c pse : pseList) {
            contactToPS.put(pse.Participant_Contact__c, pseToPS.get(pse.Id));
        }

        List<User> users = [
                SELECT Id, ContactId
                FROM User
                WHERE ContactId IN: contactToPS.keySet()
        ];

        List<Task> tasks = new List<Task>();
        for (User taskOwner : users) {
            Participant_Survey__c ps = contactToPS.get(taskOwner.ContactId);
            String subject = Label.Task_Subject_Complete_Survey.replace('##SurveyName', ps.Survey_Name__c);

            Task task = new Task(
                    OwnerId = taskOwner.Id,
                    Subject = subject,
                    Priority = TaskService.TASK_PRIORITY_CRITICAL,
                    Start_Date__c = ps.Show_Date__c,
                    Reminder_Date__c = ps.Show_Date__c
            );
            if(ps.Expiration_Date__c != null) task.ActivityDate = ps.Expiration_Date__c;

            String visible = TaskService.TASK_VISIBILITY_OWNER;
            if(ps.Visible_To_Delegates__c) visible += ';' + TaskService.TASK_VISIBILITY_DELEGATE;

            task.Visible_For__c = visible;

            tasks.add(task);
        }
    }

    public void finish(Database.BatchableContext param1) {
    }

    public Iterable<Participant_Survey__c> start(Database.BatchableContext param1) {
        List<Participant_Survey__c> participantSurveys = [
                SELECT
                        Expiration_Date__c,
                        Id,
                        Invitation_Link__c,
                        Name,
                        Participant_Study_Enrollment__c,
                        Show_Date__c,
                        Survey_Name__c,
                        Visible_To_Delegates__c
                FROM Participant_Survey__c
                WHERE (Show_Date__c = :System.today()
                    OR Expiration_Date__c =: System.today())
        ];

        System.debug('Records found: '+ participantSurveys.size());
        return participantSurveys;
    }

    public static void run() {
        Database.executeBatch(new Batch_ParticipantSurvey());
    }
}