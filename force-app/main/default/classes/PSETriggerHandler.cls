/**
 * Created by Leonid Bartenev
 */

public class PSETriggerHandler {
    
    public static final String TASK_CODE_COMPLETE_BASELINE_SURVEY = 'Complete_Baseline_Survey';
    
    public static void processStatusHistory(){
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
            List<PSE_Status_History__c> pseStatusHistories = new List<PSE_Status_History__c>();
            Map<Id, Participant_Study_Enrollment__c> oldMap;
            Map<Id, Participant_Study_Enrollment__c> newMap = (Map<Id, Participant_Study_Enrollment__c>)Trigger.newMap;
            if(Trigger.isUpdate) oldMap = (Map<Id, Participant_Study_Enrollment__c>)Trigger.oldMap;
            for(Participant_Study_Enrollment__c pse : newMap.values()){
                if(Trigger.isInsert || (Trigger.isUpdate && pse.Status__c != oldMap.get(pse.Id).Status__c)){
                    if(pse.Status__c == PSEService.PSE_STATUS_ENROLLED){
                        pseStatusHistories.add(new PSE_Status_History__c(
                                PSE__c = pse.Id,
                                Status__c = pse.Status__c,
                                Changed_Date__c = Datetime.now()
                        ));
                    }
                }
            }
            if(pseStatusHistories.size() > 0) insert pseStatusHistories;
        }
    }
    
    public static void createCompleteBaselineSurveyTask(){
        if(Trigger.isAfter && Trigger.isInsert){
            List<Task> tasks = new List<Task>();
            List<Participant_Study_Enrollment__c> pseList = (List<Participant_Study_Enrollment__c>) Trigger.new;
            List<Id> participantIds = new List<Id>();
            for(Participant_Study_Enrollment__c pse : pseList) participantIds.add(pse.Participant__c);
            List<Participant__c> participants = [SELECT Id, Contact__c FROM Participant__c WHERE Id IN: participantIds];
            List<Id> contactIds = new List<Id>();
            for(Participant__c participant : participants) contactIds.add(participant.Contact__c);
            List<User> users = [SELECT Id FROM User WHERE ContactId IN: contactIds];
            for(User taskOwner : users){
                tasks.add(new Task(
                        OwnerId = taskOwner.Id,
                        Subject = TASK_CODE_COMPLETE_BASELINE_SURVEY,
                        Task_Code__c =TASK_CODE_COMPLETE_BASELINE_SURVEY
                ));
            }
            insert tasks;
        }
    }

}