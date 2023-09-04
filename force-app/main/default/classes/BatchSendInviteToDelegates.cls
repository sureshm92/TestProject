public without sharing class BatchSendInviteToDelegates implements Database.Batchable<SObject>, Database.Stateful {
    public List<Id> delParticipantIds = new List<Id>();
    public Clinical_Trial_Profile__c ctpDetails = new Clinical_Trial_Profile__c();
 
    public BatchSendInviteToDelegates(List<Id> delParticipantIds, Clinical_Trial_Profile__c ctpDetails) {
        this.delParticipantIds = delParticipantIds;
        this.ctpDetails = ctpDetails;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        list<Id> delParticipantIds = this.delParticipantIds;
        String query = 'SELECT Id FROM Participant__c WHERE Id IN : delParticipantIds';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Participant__c> scope) {
        List<Id> delParticipantIds = new List<Id>();
        List<Id> contactIds = new List<Id>();
        List<Patient_Delegate__c> pdListToUpdate = new List<Patient_Delegate__c>();
        Map<Id,Id> contIdToCreateUserMap = New Map<Id,Id>();
        for(Participant__c par: scope) {
            delParticipantIds.add(par.Id);
        }
        List<Patient_delegate__c> pdList = [SELECT Contact__c,Participant_Delegate__c,Status__c,isInviteToPP__c,Participant__c
            FROM Patient_Delegate__c 
            WHERE Participant_Delegate__c IN : delParticipantIds];
        
        //Store the patient delegate contact ids. 
        for(Patient_Delegate__c pd:pdList) {
            contIdToCreateUserMap.put(pd.Contact__c,null);
        }
        if(ctpDetails.CommunityTemplate__c != 'Janssen') {
            //check if Patient Delegate has user Record. if not create user for them. 
            if (contIdToCreateUserMap != null && !contIdToCreateUserMap.isEmpty()){
                checkifPatientDelHasUser(contIdToCreateUserMap);
            }
        }
		//Update the status of the patient Delegate records to active. 
        for(Patient_Delegate__c pd:pdList) {
            if(pd.contact__c != null && !pd.isInviteToPP__c && pd.Participant__c != null) {
                contactIds.add(pd.Contact__c);
                pd.Status__c = 'Active';
                if(ctpDetails.CommunityTemplate__c != 'Janssen') {
                    pd.isInviteToPP__c = true;
                }
                pdListToUpdate.add(pd);
            }
        }

        if(ctpDetails.CommunityTemplate__c == 'Janssen') {
            TriggerHandlerExecutor.bypassHandler(
                PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class
            );
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

    /**
    * @description: Thios method Verifies if the patient Delegate has user record created or not. If not then create user record for them
    * @author: Krishna kumar Mahto | 02-03-2022 
    * @param: contIdToCreateUserMap 
    * @return: Void
    **/ 
    public static Void checkifPatientDelHasUser (Map<id,Id> contIdToCreateUserMap) {
        //Check if Patient Delegate has user record or not
        for(User u: [SELECT Id, ContactId FROM User WHERE ContactId = :contIdToCreateUserMap.keySet()]){
            //Remove the contactid from map if user is already created for them. 
            if(contIdToCreateUserMap.containskey(u.ContactId)){
                contIdToCreateUserMap.remove(u.ContactId);
            }
        }
        //Create Patient Delegate's user record
        if (contIdToCreateUserMap != null && !contIdToCreateUserMap.isEmpty()) {
            ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                .createParticipantUsers(contIdToCreateUserMap);
        }
    }

    public void finish(Database.BatchableContext BC) {
        
    }
}