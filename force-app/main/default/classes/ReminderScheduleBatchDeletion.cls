global class ReminderScheduleBatchDeletion implements Database.Batchable<sObject>, Database.Stateful{
    private String ctpId;
    private Boolean isStudyToDelete = false;
    private Set<Id> reminderScheduleIds = new Set<Id>();
    
    global ReminderScheduleBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
     global ReminderScheduleBatchDeletion(String ctpId, Boolean isStudyToDelete){
        this.ctpId = ctpId;
        this.isStudyToDelete = isStudyToDelete;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        /*List<Reminder_Schedule__c> remSchLst = CTPDeletionHelper.getReminderSchedules(ctpId);
        return Database.getQueryLocator([SELECT Id, Name FROM Reminder_Schedule__c WHERE Id IN :remSchLst]);*/
        return Database.getQueryLocator([SELECT Id, Name, Clinical_Trial_Profile__c, Reminder_Schedule__r.Id, Reminder_Schedule__r.Name FROM Trial_Survey__c 
                                         WHERE Clinical_Trial_Profile__c = :ctpId]);
    }
    
    global void execute(Database.BatchableContext BC, List<Trial_Survey__c> trialSurveyLst){
        Set<Id> remSchIds = new Set<Id>();
        for(Trial_Survey__c ts : trialSurveyLst){
            remSchIds.add(ts.Reminder_Schedule__r.Id);
        }
        
        if(isStudyToDelete) {
            delete [SELECT Id, Name FROM Reminder_Schedule__c WHERE Id IN :remSchIds];
        } else {
        
           reminderScheduleIds.addAll((new Map<Id, Reminder_Schedule__c>(
               [SELECT Id, Name FROM Reminder_Schedule__c WHERE Id IN :remSchIds]
           )).keySet());
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
        if(isStudyToDelete == false) {
        
            List<Study_Closure__c> studyClosureProcessList = [
                SELECT Id FROM Study_Closure__c WHERE Clinical_Trial_Profile_Id__c = :ctpId LIMIT 1
            ];
            if(studyClosureProcessList.isEmpty() == false) {
                
                List<ContentVersion> contentVersions =new List<ContentVersion>();
                contentVersions.add(Batch_SCParticipantEnrollment.constructCsvFile(
                    ctpId, 'Reminder Schedule', reminderScheduleIds
                ));
                
                Batch_SCParticipantEnrollment.insertContentVersions(studyClosureProcessList[0].Id, contentVersions);
            }
        }   
    }
}