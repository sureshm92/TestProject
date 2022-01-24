public without sharing class BatchSendInviteToPP implements Database.Batchable<SObject>, Database.Stateful {

    public List<Id> participantIds = new List<Id>();
    Id ctpId;
    public BatchSendInviteToPP(List<Id> participantIds, Id ctpId) {
        this.participantIds = participantIds;
        this.ctpId = ctpId;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        list<Id> participantIds = this.participantIds;
        String query = 'SELECT Id FROM Participant__c WHERE Id IN : participantIds';
        return Database.getQueryLocator(query);
        
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        String perWhereClause = ' AND Participant__c IN :participantIds AND study_Site__r.Clinical_Trial_Profile__c =\''+ String.escapeSingleQuotes(this.ctpId)+'\'';
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