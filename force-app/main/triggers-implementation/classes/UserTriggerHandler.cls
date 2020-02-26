/**
 * Created by Leonid Bartenev
 */

public without sharing class UserTriggerHandler {

    // Handlers: -------------------------------------------------------------------------------------------------------

    public class UpdateLanguageOnRelatedContactsHandler extends TriggerHandler {

        public override void afterInsert(List<SObject> newList) {
            updateLanguageOnRelatedContacts(newList, null);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updateLanguageOnRelatedContacts(newList, (Map<Id, User>) oldMap);
        }
    }

    public class UpdateEmailOnRelatedContactsHandler extends TriggerHandler {

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updateEmailOnRelatedContacts(newList, (Map<Id, User>) oldMap);
        }
    }

    public class CreateCompleteYourProfileTaskHandler extends TriggerHandler {

        public override void afterInsert(List<SObject> newList) {
            createCompleteYourProfileTask(newList);
        }
    }

    public class UpdateUserRoleHandler extends TriggerHandler {

        public override void beforeInsert(List<SObject> newList) {
            updateUserRoleToSPNL(newList);
        }
    }

    public class AssignCommunityPermissionSetToUserHandler extends TriggerHandler {

        public override void afterInsert(List<SObject> newList) {
            assignCommunityPermissionSetToUser(newList);
        }
    }

    // Logic: ----------------------------------------------------------------------------------------------------------

    @TestVisible
    private static void updateLanguageOnRelatedContacts(List<User> newList, Map<Id, User> oldMap) {
        List<Contact> contactsForUpdate = new List<Contact>();
        for (User user : newList) {
            if (user.ContactId == null) continue;
            if (oldMap == null || (oldMap != null && oldMap.get(user.Id).LanguageLocaleKey != user.LanguageLocaleKey)) {
                contactsForUpdate.add(new Contact(
                        Id = user.ContactId,
                        Language__c = user.LanguageLocaleKey
                ));
            }
        }
        if (contactsForUpdate.size() > 0) update contactsForUpdate;
    }

    @TestVisible
    private static void updateEmailOnRelatedContacts(List<User> newList, Map<Id, User> oldMap) {
        List<Contact> changeEmailContacts = new List<Contact>();
        for (User user : newList) {
            if (user.ContactId == null) continue;
            if (oldMap.get(user.Id).Email != user.Email) {
                if (user.ContactId != null) {
                    changeEmailContacts.add(new Contact(
                            Id = user.ContactId,
                            Email = user.Email
                    ));
                }
            }
        }
        if (changeEmailContacts.size() > 0) update changeEmailContacts;
    }

    @TestVisible
    private static void updateUserRoleToSPNL(List<User> newList) {
        for (User us : newList) {
            if (us.ProfileId == CommunityService.SPNL_USER_PROFILE_ID) {
                us.UserRoleId = CommunityService.SPNL_ROLE;
            }
        }
    }

    @TestVisible
    private static void createCompleteYourProfileTask(List<User> newList) {
        Set<Id> userContactIds = new Set<Id>();
        for (User user : newList) if (user.ContactId != null) userContactIds.add(user.ContactId);
        List<Participant_Enrollment__c> participantEnrollments = [
                SELECT Id, Participant_Contact__c, Participant__c
                FROM Participant_Enrollment__c
                WHERE Participant_Contact__c IN:userContactIds
        ];
        Map<Id, Id> participantIdByContactIdMap = new Map<Id, Id>();
        for (Participant_Enrollment__c pe : participantEnrollments) {
            participantIdByContactIdMap.put(pe.Participant_Contact__c, pe.Participant__c);
        }

        List<Task> tasksForInsert = new List<Task>();
        for (User user : newList) {
            if (user.ProfileId == CommunityService.COMMUNITY_USER_PROFILE_ID) {
                if (user.ContactId != null) {
                    Id participant = participantIdByContactIdMap.get(user.ContactId);
                    if (participant != null) {
                        tasksForInsert.add(TaskService.getInstance().createCompleteYourProfileTask(user.Id, participant, user.ContactId));
                    }
                }
            }
        }
        insert tasksForInsert;
    }

    @TestVisible
    private static void assignCommunityPermissionSetToUser(List<User> insertedUsers) {
        List<User> rhUsers = [
                SELECT Id, ContactId
                FROM User
                WHERE Id IN:insertedUsers
                AND ContactId != NULL
                AND Contact.userCommunityMode__c != 'Participant'
        ];

        Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
        for (User user : rhUsers) {
            actionAssignContactPermissions.addPermissions(user.ContactId, new Set<String>{
                    CommunityTemplateService.PERMISSION_COMMUNITY_DEFAULT_NAME,
                    CommunityTemplateService.PERMISSION_COMMUNITY_GSK_NAME
            });
        }

        if(!actionAssignContactPermissions.isEmpty()) {
            ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
        }
    }
}