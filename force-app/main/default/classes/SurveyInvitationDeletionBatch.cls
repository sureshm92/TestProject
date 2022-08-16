global class SurveyInvitationDeletionBatch implements Database.Batchable<sObject>, Database.Stateful{
    private String ctpId;
    private Boolean isStudyToDelete = false;
    private Set<Id> surveyInvitationIds = new Set<Id>();
    
    global SurveyInvitationDeletionBatch(String ctpId){
        this.ctpId = ctpId;
    }
    global SurveyInvitationDeletionBatch(String ctpId, Boolean isStudyToDelete){
        this.ctpId = ctpId;
        this.isStudyToDelete = isStudyToDelete;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'SELECT Id FROM Participant_Enrollment__c ';
        if(String.isNotBlank(ctpId)) {
            query += 'WHERE Clinical_Trial_Profile__c = :ctpId';
        } else {
            query += 'LIMIT 0';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Participant_Enrollment__c> enrollmentList){
    
        if(isStudyToDelete) {
            delete [SELECT Id FROM SurveyInvitation WHERE Participant_Enrollment__c IN :enrollmentList];
        } else {
            
            surveyInvitationIds.addAll((new Map<Id,SurveyInvitation>(
                [SELECT Id FROM SurveyInvitation WHERE Participant_Enrollment__c IN :enrollmentList]
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
                    ctpId, 'Survey Invitation', surveyInvitationIds
                ));
                
                Batch_SCParticipantEnrollment.insertContentVersions(studyClosureProcessList[0].Id, contentVersions);
            }
        }
    }
}