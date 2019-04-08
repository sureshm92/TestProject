/**
 * Created by Leonid Bartenev
 */

public class PSETriggerHandler {
    
    public static void setDefaultFieldsBeforeUpsert(){
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
            Set<Id> ssIds = new Set<Id>();
            Set<Id> participantIds = new Set<Id>();
            for (Participant_Study_Enrollment__c pse : (List<Participant_Study_Enrollment__c>)Trigger.new){
                ssIds.add(pse.Study_Site__c);
                participantIds.add(pse.Participant__c);
            }
            Map<Id, Study_Site__c> studySitesMap = new Map<Id, Study_Site__c>([
                    SELECT Id, Principal_Investigator__c FROM Study_Site__c WHERE Id IN: ssIds
            ]);
            Map<Id, Participant__c> participantsMap = new Map<Id, Participant__c>([
                    SELECT Id, Contact__c FROM Participant__c WHERE Id IN: participantIds
            ]);
            for (Participant_Study_Enrollment__c pse : (List<Participant_Study_Enrollment__c>)Trigger.new){
                pse.PI_Contact__c = null;
                pse.Participant_Contact__c = null;
                if(pse.Study_Site__c != null) pse.PI_Contact__c = studySitesMap.get(pse.Study_Site__c).Principal_Investigator__c;
                if(pse.Participant__c != null) pse.Participant_Contact__c = participantsMap.get(pse.Participant__c).Contact__c;
            }
        }
    }
    
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
                tasks.add(TaskService.createCompleteBaselineSurveyTask(taskOwner.Id));
            }
            insert tasks;
        }
    }

}