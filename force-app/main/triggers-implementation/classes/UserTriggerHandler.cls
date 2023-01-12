/**
 * Created by Leonid Bartenev
 */

public without sharing class UserTriggerHandler {
    // Handlers: -------------------------------------------------------------------------------------------------------

    public class UpdateLanguageOnRelatedContactsHandler extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            updateLanguageOnRelatedContactsAfterInsert(newList, null);
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
    public class AssignPendingTelevisitsHandler extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            assignPendingTelevisits(newList);
        }
    }
    // Logic: ----------------------------------------------------------------------------------------------------------

    @TestVisible
    private static void updateLanguageOnRelatedContacts(List<User> newList, Map<Id, User> oldMap) {
        List<Contact> contactsForUpdate = new List<Contact>();
        for (User user : newList) {
            if (user.ContactId == null)
                continue;
            if (
                oldMap == null ||
                (oldMap != null &&
                oldMap.get(user.Id).LanguageLocaleKey != user.LanguageLocaleKey)
            ) {
                contactsForUpdate.add(
                    new Contact(Id = user.ContactId, Language__c = user.LanguageLocaleKey)
                );
            }
        }
        if (contactsForUpdate.size() > 0)
            update contactsForUpdate;
    }

    @TestVisible
    private static void updateLanguageOnRelatedContactsAfterInsert(List<User> newList, Map<Id, User> oldMap) {
        List<Contact> contactsForUpdate = new List<Contact>();
        List<Id> conId = new List<Id>();
        List<Contact> lstContacts = new List<Contact>();
        Map<Id, String> usrLangKey = new Map<Id, String>();
        for (User user : newList) {
            if (user.ContactId != null)
            {
              conId.add(user.ContactId);
              usrLangKey.put(user.ContactId,user.LanguageLocaleKey);
            }
          } 
       if (conId.size() > 0) {
            lstContacts = [select Id,Is_Patient_User_Created__c,Language__c,userCommunytyType__c from Contact where Id IN:conId];
            for(Contact con:lstContacts)
            {
               if(!con.Is_Patient_User_Created__c)
                {
                    contactsForUpdate.add(new Contact(Id = con.Id,Is_Patient_User_Created__c=true,Language__c = usrLangKey.get(con.Id)));
                }else{
                     contactsForUpdate.add(new Contact(Id = con.Id, Language__c = usrLangKey.get(con.Id)));
                }
            }
            if (contactsForUpdate.size() > 0)
            update contactsForUpdate;
         }
    }

    @TestVisible
    private static void updateEmailOnRelatedContacts(List<User> newList, Map<Id, User> oldMap) {
        List<Contact> changeEmailContacts = new List<Contact>();
        for (User user : newList) {
            if (user.ContactId == null)
                continue;
            if (oldMap.get(user.Id).Email != user.Email) {
                if (user.ContactId != null) {
                    changeEmailContacts.add(new Contact(Id = user.ContactId, Email = user.Email));
                }
            }
        }
        if (changeEmailContacts.size() > 0)
            update changeEmailContacts;
    }
	

    @TestVisible
    private static void createCompleteYourProfileTask(List<User> newList) {
        Set<Id> userContactIds = new Set<Id>();
        for (User user : newList) {
            if (user.ContactId != null)
                userContactIds.add(user.ContactId);
        }

        List<Participant__c> participants = [
            SELECT Id, Contact__c
            FROM Participant__c
            WHERE Contact__c IN :userContactIds FOR UPDATE
        ];
        Map<Id, Id> participantByContact = new Map<Id, Id>();
        for (Participant__c participant : participants)
            participantByContact.put(participant.Contact__c, participant.Id);

        List<Task> tasksForInsert = new List<Task>();
        for (User user : newList) {
            if (
                user.ContactId != null &&
                user.ProfileId == CommunityService.COMMUNITY_USER_PROFILE_ID
            ) {
                Id participantId = participantByContact.get(user.ContactId);
                if (participantId != null) {
                    tasksForInsert.add(
                        TaskService.getInstance()
                            .createCompleteYourProfileTask(user.Id, participantId, user.ContactId)
                    );
                }
            }
        }
        insert tasksForInsert;
    }

    @TestVisible
    private static void assignCommunityPermissionSetToUser(List<User> insertedUsers) {
        List<User> rhUsers = [
            SELECT Id, ContactId, Contact.userCommunityMode__c, Contact.userCommunytyType__c
            FROM User
            WHERE
                Id IN :insertedUsers
                AND ContactId != NULL
                AND Contact.userCommunityMode__c != 'Participant'
                AND CreatedBy.Name != 'Covid-19 Site Guest User'
        ];

        Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
        if (rhUsers != null) {
            Set<Id> piIds = new Set<Id>();
            for (User user : rhUsers) {
                if (
                    !String.isBlank(user.Contact.userCommunytyType__c) &&
                    user.Contact.userCommunytyType__c.contains('PI')
                ) {
                    piIds.add(user.ContactId);
                } else {
                    actionAssignContactPermissions.addPermission(
                        user.ContactId,
                        CommunityTemplateService.PERMISSION_COMMUNITY_DEFAULT_NAME
                    );
                }

                if (!actionAssignContactPermissions.isEmpty()) {
                    ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
                }
            }
            if (!piIds.isEmpty()) {
                Map<String, Set<Id>> commUserPermission = new Map<String, Set<Id>>{
                    CommunityTemplateService.TEMPLATE_DEFAULT => new Set<Id>(),
                    CommunityTemplateService.TEMPLATE_JANSSEN => new Set<Id>()
                };
                List<Study_Site__c> ssList = [
                    SELECT
                        Id,
                        Clinical_Trial_Profile__r.CommunityTemplate__c,
                        Principal_Investigator__c
                    FROM Study_Site__c
                    WHERE Principal_Investigator__c IN :piIds
                ];
                if (!ssList.isEmpty()) {
                    for (Integer i = 0, j = ssList.size(); i < j; i++) {
                        if (
                            ssList[i].Clinical_Trial_Profile__r.CommunityTemplate__c ==
                            CommunityTemplateService.TEMPLATE_JANSSEN
                        ) {
                            commUserPermission.get(CommunityTemplateService.TEMPLATE_JANSSEN)
                                .add(ssList[i].Principal_Investigator__c);
                        } else {
                            commUserPermission.get(CommunityTemplateService.TEMPLATE_DEFAULT)
                                .add(ssList[i].Principal_Investigator__c);
                        }
                    }
                } else {
                    List<Site_Staff__c> delegatesSS = [
                        SELECT
                            Id,
                            Site_Contact__c,
                            Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c
                        FROM Site_Staff__c
                        WHERE Site_Contact__c IN :piIds AND is_Invited__c = true
                    ];
                    if (!delegatesSS.isEmpty()) {
                        for (Integer i = 0, j = delegatesSS.size(); i < j; i++) {
                            if (
                                delegatesSS[i]
                                    .Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c ==
                                CommunityTemplateService.TEMPLATE_JANSSEN
                            ) {
                                commUserPermission.get(CommunityTemplateService.TEMPLATE_JANSSEN)
                                    .add(delegatesSS[i].Site_Contact__c);
                            } else {
                                commUserPermission.get(CommunityTemplateService.TEMPLATE_DEFAULT)
                                    .add(delegatesSS[i].Site_Contact__c);
                            }
                        }
                    }
                }
                for (String community : commUserPermission.keySet()) {
                    for (Id contId : commUserPermission.get(community)) {
                        if (community == CommunityTemplateService.TEMPLATE_JANSSEN) {
                            actionAssignContactPermissions.addPermission(
                                contId,
                                CommunityTemplateService.PERMISSION_COMMUNITY_JANSSEN_NAME
                            );
                        } else {
                            actionAssignContactPermissions.addPermission(
                                contId,
                                CommunityTemplateService.PERMISSION_COMMUNITY_DEFAULT_NAME
                            );
                        }
                    }
                }
                if (!actionAssignContactPermissions.isEmpty()) {
                    ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
                }
            }
        } else {
            List<User> registryUsers = [
                SELECT Id, ContactId
                FROM User
                WHERE
                    Id IN :insertedUsers
                    AND ContactId != NULL
                    AND Contact.userCommunityMode__c != 'Participant'
            ];

            Action_AssignContactPermissions registryActionAssignContactPermissions = new Action_AssignContactPermissions();

            for (User user : registryUsers) {
                registryActionAssignContactPermissions.addPermission(
                    user.ContactId,
                    CommunityTemplateService.PERMISSION_COMMUNITY_COVID19_NAME
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
            SELECT
                Id,
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
            WHERE Owner_Contact__c IN :conIds
        ];
        for (Task task : tasks) {
            User taskUser = usersByContactMap.get(task.Owner_Contact__c);
            task.OwnerId = taskUser.Id;
            task.Owner_Contact__c = null;

            if (task.Task_Type__c == TaskService.TASK_TYPE_SURVEY) {
                TimeZone userTZ = userTimezoneMap.get(taskUser.Id);
                Datetime userDatetime = DateTimeConverterUtil.getUserDT(
                    Datetime.now().date(),
                    Datetime.now().time(),
                    userTZ
                );

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
    @TestVisible
    private static void assignPendingTelevisits(List<User> users) {
        Map<Id, User> usersByContactMap = new Map<Id, User>();
        List<Televisit_Attendee__c> attendeeList = new List<Televisit_Attendee__c>();

        for (User user : users) {
            if (user.ContactId != null) {
                usersByContactMap.put(user.ContactId, user);
            }
        }

        for (Televisit_Attendee__c tvAttendee : [SELECT Id, User__c, Contact__c FROM Televisit_Attendee__c
                                                 WHERE Contact__c IN :usersByContactMap.keyset() AND User__c = NULL AND
                                                 Televisit__r.Status__c = 'Scheduled']) {
            Televisit_Attendee__c tva = new Televisit_Attendee__c();
            tva.id = tvAttendee.Id;                                       
            tva.User__c = usersByContactMap.get(tvAttendee.Contact__c).Id;
            attendeeList.add(tva);                                         
        }
        if(!attendeeList.isEmpty()){
            update attendeeList; 
        }
        
    }
}
}