public without sharing class BatchSendInviteToDelegates implements Database.Batchable<SObject>, Database.Stateful {
    public List<Id> delParticipantIds = new List<Id>();

    public BatchSendInviteToDelegates(List<Id> delParticipantIds) {
        this.delParticipantIds = delParticipantIds;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        list<Id> delParticipantIds = this.delParticipantIds;
        System.debug('delParticipantIds:'+delParticipantIds);
        String query = 'SELECT Id FROM Participant__c WHERE Id IN : delParticipantIds';
        System.debug('query:'+query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Participant__c> scope) {
        List<Id> delParticipantIds = new List<Id>();
        List<Id> contactIds = new List<Id>();
        List<Patient_Delegate__c> pdListToUpdate = new List<Patient_Delegate__c>();
        for(Participant__c par: scope) {
            delParticipantIds.add(par.Id);
        }
        List<Patient_delegate__c> pdList = [SELECT Contact__c,Participant_Delegate__c,Status__c,isInviteToPP__c,Participant__c
            FROM Patient_Delegate__c 
            WHERE Participant_Delegate__c IN : delParticipantIds];

        for(Patient_Delegate__c pd:pdList) {
            if(pd.contact__c != null && !pd.isInviteToPP__c && pd.Participant__c != null) {
                contactIds.add(pd.Contact__c);
                pd.Status__c = 'Active';
                pd.isInviteToPP__c = true;
                pdListToUpdate.add(pd);
            }
        }

        Database.update(pdListToUpdate);


        /*if(contactIds != null){
            particpantUser = [SELECT ID, Email, ContactId FROM User WHERE ContactId IN :contactIds];
        }
        List<Conversation__c> patientConversation = new List<Conversation__c>();
        
        for(User usr: particpantUser){
            if(participantObj != null && participantObj.Contact__c != null && usr.ContactId == participantObj.Contact__c){
                participantShareIds = usr.Id;
            }else{
                delegateUser = usr.Id;  
            }
        }
        if(participantShareIds != null){
        patientConversation = ConversationService.getSharedConversations(
                    participantShareIds
                );
        }
        if (patientConversation != null && delegateUser != null) {
            List<Id> conversationIds = new List<Id>();
            for (Conversation__c conversation : patientConversation)
                conversationIds.add(conversation.Id);
            
            insert ConversationService.createConversationSharesForUser(
                conversationIds,
                delegateUser
            );
        }*/
    }

    public void finish(Database.BatchableContext BC) {
        
    }
}
