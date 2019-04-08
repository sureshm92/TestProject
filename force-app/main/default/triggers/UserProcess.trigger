/**
 * Created by Leonid Bartenev
 */

trigger UserProcess on User (after insert, after update) {
    List<Contact> contactsForUpdate = new List<Contact>();
    List<Contact> changeEmailContacts = new List<Contact>();
    for(User user : Trigger.new){
        if(user.ContactId == null) continue;
        if(Trigger.isInsert || (Trigger.isUpdate && Trigger.oldMap.get(user.Id).LanguageLocaleKey != user.LanguageLocaleKey)){
            contactsForUpdate.add(new Contact(
                    Id = user.ContactId,
                    Language__c = user.LanguageLocaleKey
            ));
        }
        if(Trigger.isUpdate && Trigger.oldMap.get(user.Id).Email != user.Email){
            if(user.ContactId != null){
                changeEmailContacts.add(new Contact(
                        Id = user.ContactId,
                        Email = user.Email
                ));
            }
        }
    }
    update contactsForUpdate;
    update changeEmailContacts;

    
    if(Trigger.isAfter && Trigger.isInsert){
        Id portalProfileId = [SELECT Id FROM Profile WHERE Name = 'IQVIA Customer Community Plus Login User'].Id;
        Set<Id> userContactIds = new Set<Id>();
        for(User user : Trigger.new) if(user.ContactId != null) userContactIds.add(user.ContactId);
        List<Participant__c> participants = [
                SELECT Id, Contact__c
                FROM Participant__c
                WHERE Contact__c IN: userContactIds
        ];
        Map<Id, Participant__c> participantsByContactIdMap = new Map<Id, Participant__c>();
        for(Participant__c participant : participants){
            participantsByContactIdMap.put(participant.Contact__c, participant);
        }
    
        List<Task> tasksForInsert = new List<Task>();
        for(User user : Trigger.new){
            if(user.ProfileId == portalProfileId){
                if(user.ContactId != null){
                    Participant__c participant = participantsByContactIdMap.get(user.ContactId);
                    if(participant != null){
                        tasksForInsert.add(TaskService.createCompleteYourProfileTask(user.Id, participant.Id, user.ContactId));
                    }
                }
            }
        }
        insert tasksForInsert;
    }
}