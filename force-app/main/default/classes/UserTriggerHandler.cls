/**
 * Created by Leonid Bartenev
 */

public without sharing class UserTriggerHandler {
    
    // Handlers: -------------------------------------------------------------------------------------------------------
    
    public class UpdateLanguageOnRelatedContactsHandler extends TriggerHandler{
    
        public override void afterInsert(List<SObject> newList) {
            updateLanguageOnRelatedContacts(newList, null);
        }
        
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updateLanguageOnRelatedContacts(newList, (Map<Id, User>)oldMap);
        }
    }
    
    public class UpdateEmailOnRelatedContactsHandler extends TriggerHandler{
        
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updateEmailOnRelatedContacts(newList, (Map<Id, User>)oldMap);
        }
    }
    
    public class CreateCompleteYourProfileTaskHandler extends TriggerHandler{
        
        public override void afterInsert(List<SObject> newList) {
            createCompleteYourProfileTask(newList);
        }
    }
    
    public class UpdateUserRoleHandler extends TriggerHandler{
        
        public override void beforeInsert(List<SObject> newList) {
            updateUserRoleToSPNL(newList);
        }
    }
    
    
    // Logic: ----------------------------------------------------------------------------------------------------------
    
    @TestVisible
    private static void updateLanguageOnRelatedContacts(List<User> newList, Map<Id, User> oldMap){
        List<Contact> contactsForUpdate = new List<Contact>();
        for(User user : newList){
            if(user.ContactId == null) continue;
            if(oldMap == null || (oldMap != null && oldMap.get(user.Id).LanguageLocaleKey != user.LanguageLocaleKey)){
                contactsForUpdate.add(new Contact(
                        Id = user.ContactId,
                        Language__c = user.LanguageLocaleKey
                ));
            }
        }
        update contactsForUpdate;
    }
    
    @TestVisible
    private static void updateEmailOnRelatedContacts(List<User> newList, Map<Id, User> oldMap){
        List<Contact> changeEmailContacts = new List<Contact>();
        for(User user : newList){
            if(user.ContactId == null) continue;
            if(oldMap.get(user.Id).Email != user.Email){
                if(user.ContactId != null){
                    changeEmailContacts.add(new Contact(
                            Id = user.ContactId,
                            Email = user.Email
                    ));
                }
            }
        }
        update changeEmailContacts;
    }
    
    @TestVisible
    private static void updateUserRoleToSPNL(List<User> newList){
        Id spnlId = [SELECT Id FROM UserRole WHERE Name='SPNL'].Id;
        for(User us : newList){
            if(us.ProfileId == CommunityService.SPNL_USER_PROFILE_ID){
                us.UserRoleId = spnlId;
            }
        }
    }
    
    @TestVisible
    private static void createCompleteYourProfileTask(List<User> newList){
        Set<Id> userContactIds = new Set<Id>();
        for(User user : newList) if(user.ContactId != null) userContactIds.add(user.ContactId);
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
        for(User user : newList){
            if(user.ProfileId == CommunityService.COMMUNITY_USER_PROFILE_ID){
                if(user.ContactId != null){
                    Participant__c participant = participantsByContactIdMap.get(user.ContactId);
                    if(participant != null){
                        tasksForInsert.add(TaskService.getInstance().createCompleteYourProfileTask(user.Id, participant.Id, user.ContactId));
                    }
                }
            }
        }
        insert tasksForInsert;
    }

}