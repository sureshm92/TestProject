global class TelevisitBatchDeletion implements Database.Batchable<sObject>, Database.Stateful{
    private String ctpId;
    private Boolean isStudyToDelete = false;
    private Set<Id> alltTelevisitIds = new Set<Id>();
    private Set<Id> allTVConnectionIds = new Set<Id>();
    
    global TelevisitBatchDeletion(String ctpId){
        this.ctpId = ctpId;
    }
    global TelevisitBatchDeletion(String ctpId, Boolean isStudyToDelete){
        this.ctpId = ctpId;
        this.isStudyToDelete = isStudyToDelete;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query='SELECT Id, Name, (SELECT Id, Name FROM Televisits__r) FROM Participant_Enrollment__c WHERE Clinical_Trial_Profile__c = :ctpId';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Participant_Enrollment__c> partEnrollRecords){
        List<Televisit__c> telVisitLst= new List<Televisit__c>();
        for(Participant_Enrollment__c parEnroll: partEnrollRecords){
            telVisitLst.addAll(parEnroll.Televisits__r);
        }
        List<TV_Connection__c> connectionLst= new List<TV_Connection__c>();
        for(Televisit_Attendee__c telAttendee:[select Id,(select Id from Connections__r) from Televisit_Attendee__c where Televisit__c in:telVisitLst]){
            connectionLst.addAll(telAttendee.Connections__r);
        }
        if(connectionLst.size()>0){
        
            if(isStudyToDelete) {
                delete connectionLst;
            } else {
               allTVConnectionIds.addAll((new Map<Id, TV_Connection__c>(
                   connectionLst
               )).keySet());
            }
        }
        
        if(isStudyToDelete) {
            delete telVisitLst;
        } else {
           alltTelevisitIds.addAll((new Map<Id, Televisit__c>(
               telVisitLst
           )).keySet());
        }
    }
    /*global void execute(Database.BatchableContext BC, List<Televisit__c> telVisitIdLst){
        List<Televisit_Attendee__c> teleVAttendees= new List<Televisit_Attendee__c>();
        for(Televisit__c telV: telVisitIdLst){
            teleVAttendees.addAll(telV.Televisit_Attendee__r);           
        }
        List<TV_Connection__c> connectionLst=[select Id from TV_Connection__c where Televisit_Attendee__c in:teleVAttendees];
        if(connectionLst.size()>0){
            delete connectionLst;
        }
        delete telVisitIdLst;
    }*/
    
    global void finish(Database.BatchableContext BC){
        
         if(isStudyToDelete == false) {
        
            List<Study_Closure__c> studyClosureProcessList = [
                SELECT Id FROM Study_Closure__c WHERE Clinical_Trial_Profile_Id__c = :ctpId LIMIT 1
            ];
            if(studyClosureProcessList.isEmpty() == false) {
                
                List<ContentVersion> contentVersions =new List<ContentVersion>();
                contentVersions.add(Batch_SCParticipantEnrollment.constructCsvFile(
                    ctpId, 'Televisit', alltTelevisitIds
                ));
                contentVersions.add(Batch_SCParticipantEnrollment.constructCsvFile(
                    ctpId, 'TV Connection', allTVConnectionIds
                ));
                
                Batch_SCParticipantEnrollment.insertContentVersions(studyClosureProcessList[0].Id, contentVersions);
            }
        }   
    }
}