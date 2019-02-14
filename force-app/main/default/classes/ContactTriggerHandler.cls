/**
 * Created by D.Yasinskyi on 05.05.2018
 */
public without sharing class ContactTriggerHandler {
    
    public static void updateParticipantAndUserEmailsOnContactEmailChange(){
        if(Trigger.isAfter && Trigger.isUpdate){
            //prepare participants map:
            List<Participant__c> participants = [SELECT Id, Contact__c FROM Participant__c WHERE Contact__c IN: Trigger.newMap.keySet()];
            Map<Id, Participant__c> participantsByContactMap = new Map<Id, Participant__c>();
            for(Participant__c participant : participants) participantsByContactMap.put(participant.Contact__c, participant);
            //prepare users map:
            List<User> users = [SELECT Id, ContactId FROM User WHERE ContactId IN: Trigger.newMap.keySet()];
            Map<Id, User> usersByContactMap = new Map<Id, User>();
            for(User user : users) usersByContactMap.put(user.ContactId, user);
            //process contacts:
            List<Contact> contacts = (List<Contact>)Trigger.new;
            List<Participant__c> participantsForUpdate = new List<Participant__c>();
            List<User> usersForUpdate = new List<User>();
            for(Contact cnt : contacts){
                Contact oldCnt = (Contact)Trigger.oldMap.get(cnt.Id);
                if(oldCnt.Email != cnt.Email){
                    Participant__c participant = participantsByContactMap.get(cnt.Id);
                    if(participant != null){
                        participant.Email__c = cnt.Email;
                        participantsForUpdate.add(participant);
                    }
                    User user = usersByContactMap.get(cnt.Id);
                    if(user != null){
                        user.Email = cnt.Email;
                        usersForUpdate.add(user);
                    }
                }
            }
            update usersForUpdate;
            update participantsForUpdate;
        }
    }
    
    //===================================PUBLIC=========================================================================
    public static void onAfterinsert(List<Contact> contacts) {
        //create new Users for Delegates (if not exist)
        createUserForDelegateContact(contacts);
    }
    public static void onAfterUpdate(Map<Id, Contact> newContacts, Map<Id, Contact> oldContacts) {
        //create new Users for Delegates (if not exist)
        createUserForDelegateContact(newContacts.values());
    }
    //===================================PRIVATE========================================================================
    private static void createUserForDelegateContact(List<Contact> contacts) {

        Map<Id, Contact> filteredContactsByIds = new Map<Id, Contact>();
        for (Contact cont : contacts) {
            if (cont.primaryContact__c != null && cont.Email != null) {
                filteredContactsByIds.put(cont.Id, cont);
            }
        }
        if (filteredContactsByIds.isEmpty()) return;

        //get users if exist
        Map<Id, User> communityUsers = new Map<Id, User>();
        for (User usr : CommunityService.getCommunityUsersByContactIds(filteredContactsByIds.keySet())) {

            if (communityUsers.containsKey(usr.ContactId)) {
                System.debug('Several users for contact Id= ' + usr.Id);
            } else {
                communityUsers.put(usr.ContactId, usr);
            }
        }

        Set<Id> toCreateUser = new Set<Id>();
        for (Id contactId : filteredContactsByIds.keySet()) {

            if (!communityUsers.containsKey(contactId)) {
                toCreateUser.add(contactId);
            }
        }

        if (!toCreateUser.isEmpty()) {
            CommunityService.createPortalUsers(toCreateUser);
        }
    }
}