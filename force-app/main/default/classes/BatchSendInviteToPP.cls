public without sharing class BatchSendInviteToPP implements Database.Batchable<SObject>, Database.Stateful {

    public List<Id> participantIds = new List<Id>();
    public BatchSendInviteToPP(List<Id> participantIds) {
        this.participantIds = participantIds;
        
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        list<Id> participantIds = this.participantIds;;
        String query = 'SELECT Id FROM Participant__c WHERE Id IN : participantIds';
        return Database.getQueryLocator(query);
        
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        String perWhereClause = ' AND Participant__c IN :participantIds';
        List<String> perIds = new List<String>();
        List<Participant_Enrollment__c> perList = DashboardParticipantCount.fetchPerRecords(perWhereClause,participantIds);
        for(Participant_Enrollment__c per:perList) {
            perIds.add(per.Id);
        }
        ListViewParticipantController.createUserForPatientProtal(perIds,true);
    }

    public void finish(Database.BatchableContext BC) {
        
    }
}