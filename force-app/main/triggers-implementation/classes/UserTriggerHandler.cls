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

    public class AssignPendingTasksHandler extends TriggerHandler {

        public override void afterInsert(List<SObject> newList) {
            assignTasks(newList);
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
        for (User user : newList) {
            if (user.ContactId != null) userContactIds.add(user.ContactId);
        }

        List<Participant__c> participants = [SELECT Id, Contact__c FROM Participant__c WHERE Contact__c IN:userContactIds];
        Map<Id, Id> participantByContact = new Map<Id, Id>();
        for (Participant__c participant : participants) participantByContact.put(participant.Contact__c, participant.Id);

        List<Task> tasksForInsert = new List<Task>();
        for (User user : newList) {
            if (user.ContactId != null && user.ProfileId == CommunityService.COMMUNITY_USER_PROFILE_ID) {
                Id participantId = participantByContact.get(user.ContactId);
                if (participantId != null) {
                    tasksForInsert.add(
                            TaskService.getInstance().createCompleteYourProfileTask(user.Id, participantId, user.ContactId)
                    );
                }
            }
        }
        insert tasksForInsert;
    }

@TestVisible
    private static void assignCommunityPermissionSetToUser(List<User> insertedUsers) 
    {
        List<User> rhUsers = [
                SELECT Id,
                       ContactId,
                       Contact.userCommunityMode__c
                FROM User
                WHERE Id IN:insertedUsers
                AND ContactId != NULL
                AND Contact.userCommunityMode__c != 'Participant' And CreatedBy.Name != 'Covid-19 Site Guest User'
        ];

        Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
        if(rhUsers != null)
        {
            Set<Id> piIds = new Set<Id>();
            for (User user : rhUsers) {
                if (user.Contact.userCommunityMode__c == 'PI') {
                    piIds.add(user.ContactId);
                } else {
                    actionAssignContactPermissions.addPermission(
                            user.ContactId, CommunityTemplateService.PERMISSION_COMMUNITY_DEFAULT_NAME
                    );
                }

                if (!actionAssignContactPermissions.isEmpty()) {
                    ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
                }
            }
            if(!piIds.isEmpty()){
                Map<String, Set<Id>> commUserPermission = new Map<String, Set<Id>>();
                for(Study_Site__c ssList : [
                        SELECT Id,
                               Clinical_Trial_Profile__r.CommunityTemplate__c,
                                Principal_Investigator__c
                        FROM Study_Site__c
                        WHERE Principal_Investigator__c IN : piIds
                ]){
                    if(ssList.Clinical_Trial_Profile__r.CommunityTemplate__c == CommunityTemplateService.TEMPLATE_DEFAULT){
                        if(commUserPermission.containsKey(CommunityTemplateService.TEMPLATE_DEFAULT)) commUserPermission.get(CommunityTemplateService.TEMPLATE_DEFAULT).add(ssList.Principal_Investigator__c);
                        else commUserPermission.put(CommunityTemplateService.TEMPLATE_DEFAULT, new Set<Id>{ssList.Principal_Investigator__c});
                    } else {
                        if(commUserPermission.containsKey(CommunityTemplateService.TEMPLATE_JANSSEN)) commUserPermission.get(CommunityTemplateService.TEMPLATE_JANSSEN).add(ssList.Principal_Investigator__c);
                        else commUserPermission.put(CommunityTemplateService.TEMPLATE_JANSSEN, new Set<Id>{ssList.Principal_Investigator__c});
                    }
                }
                for (Id contId : commUserPermission.get(CommunityTemplateService.TEMPLATE_DEFAULT)) {
                    actionAssignContactPermissions.addPermission(
                            contId, CommunityTemplateService.PERMISSION_COMMUNITY_DEFAULT_NAME);
                    if (!actionAssignContactPermissions.isEmpty()) {
                        ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
                    }
                }
                for (Id contId : commUserPermission.get(CommunityTemplateService.TEMPLATE_JANSSEN)) {
                    actionAssignContactPermissions.addPermission(
                            contId, CommunityTemplateService.PERMISSION_COMMUNITY_JANSSEN_NAME);
                    if (!actionAssignContactPermissions.isEmpty()) {
                        ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
                    }
                }
            }
        }
        else
        {
            List<User> registryUsers = [
                    SELECT Id, ContactId
                    FROM User
                    WHERE Id IN:insertedUsers
                    AND ContactId != NULL
                    AND Contact.userCommunityMode__c != 'Participant' 
            ];
    
            Action_AssignContactPermissions registryActionAssignContactPermissions = new Action_AssignContactPermissions();
           
            for (User user : registryUsers) {
                registryActionAssignContactPermissions.addPermission(
                        user.ContactId, CommunityTemplateService.PERMISSION_COMMUNITY_COVID19_NAME
                );
            }
            
            if (!registryActionAssignContactPermissions.isEmpty()) {
                ActionExecutor.executeAsync(registryActionAssignContactPermissions, Datetime.now());
            }
        }
    }

    @TestVisible
    private static void assignTasks(List<User> users) {
        //assign tasks from tmp user to new user
        Set<Id> conIds = new Set<Id>();
        Map<Id, User> usersByContactMap = new Map<Id, User>();
        for (User user : users) {
            if (user.ContactId != null) {
                conIds.add(user.ContactId);
                usersByContactMap.put(user.ContactId, user);
            }
        }
        Map<Id, TimeZone> userTimezoneMap = DateTimeConverterUtil.getUsersTimezoneMap(conIds);

        List<Task> tasks = [
                SELECT Id,
                        Activity_Datetime__c,
                        OwnerId,
                        Owner_Contact__c,
                        Task_Type__c,
                        Start_Date__c,
                        ReminderDateTime,
                        Reminder_Date__c,
                        Survey_Invitation__r.ExpireDateTime__c,
                        Survey_Invitation__r.Reminder_Schedule__r.First_Reminder_day__c
                FROM Task
                WHERE Owner_Contact__c IN:conIds
        ];
        for (Task task : tasks) {
            User taskUser = usersByContactMap.get(task.Owner_Contact__c);
            task.OwnerId = taskUser.Id;
            task.Owner_Contact__c = null;

            if (task.Task_Type__c == TaskService.TASK_TYPE_SURVEY) {
                TimeZone userTZ = userTimezoneMap.get(taskUser.Id);
                Datetime userDatetime = DateTimeConverterUtil.getUserDT(Datetime.now().date(), Datetime.now().time(), userTZ);

                task.Start_Date__c = userDatetime.date();
                SurveyInvitation invitation = task.Survey_Invitation__r;
                if (invitation.ExpireDateTime__c != null) {
                    Date expiryDate = invitation.ExpireDateTime__c.date();
                    Integer daysBetween = Date.today().daysBetween(expiryDate);
                    task.Activity_Datetime__c = userDatetime.addDays(daysBetween);
                }

                if (invitation.Reminder_Schedule__r.First_Reminder_day__c != null) {
                    Integer firstReminderDay = (Integer) invitation.Reminder_Schedule__r.First_Reminder_day__c;
                    task.Reminder_Date__c = userDatetime.addDays(firstReminderDay);
                    task.ReminderDateTime = Datetime.now().addDays(firstReminderDay);
                }
            }
        }
        update tasks;
    }
}