public without sharing class Batch_CreateEcoaTasks extends Batch_ScheduledAbstract {
    private String query;
    public List<Ecoa_Task_Configuration__c> taskList = new List<Ecoa_Task_Configuration__c>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime gmtDateTimetoday = System.now();
        Date todayDate = gmtDateTimetoday.dateGmt();

       return Database.getQueryLocator(
            [
               SELECT Id,Diary_Name__c,Participant_Enrollment__c,Participant_Enrollment__r.Participant_Contact__c,Window_Begin__c,Diary_Status__c,Window_End__c,Diary_End_Date__c,Diary_Start_Date__c,Reminder_config__c,ParticipantId__c,ContactId__c 
               FROM Ecoa_Task_Configuration__c 
               WHERE Window_Begin__c <= TODAY 
               AND Diary_Status__c != 'completed'
               AND IsProcessed__c = FALSE
               AND ParticipantId__c != null
               AND Window_Begin__c = Last_N_Days:2
            ]
        );
    }

    public void execute(Database.BatchableContext bc, List<Ecoa_Task_Configuration__c> taskConfigList) {
        System.debug('Execute methd');
        EcoaTaskService.createTask(taskConfigList);
    }
     public override Type getType() {
        return Batch_CreateEcoaTasks.class;
    }

    public override virtual String getBatchDescription() {
        return 'Create task in PP using Ecoa Schedule';
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 5;
    }

    public override Integer getRecommendedScopeSize() {
        return 50;
    }
}