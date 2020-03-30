/**
 * Created by Leonid Bartenev
 */

public without sharing class TaskTriggerHandler {

    // Handlers: -------------------------------------------------------------------------------------------------------

    public class CheckTaskFieldsWithTaskCodeHandler extends TriggerHandler {

        public override void beforeInsert(List<SObject> newList) {
            checkTaskFields(newList);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            checkTaskFields(newList);
        }
    }

    public class SendImmediateEmailsForTaskCodeHandler extends TriggerHandler {

        public override void afterInsert(List<SObject> newList) {
            processSendImmediateEmails(newList);
        }
    }

    // Logic: ----------------------------------------------------------------------------------------------------------

    @TestVisible
    private static void checkTaskFields(List<Task> newList) {
        Map<String, Task_Catalog__mdt> cardsMap = getCardsMap(newList);
        List<Task> checkedTasks = new List<Task>();
        for (Task task : newList) {
            if (task.Task_Code__c == null) continue;
            Task_Catalog__mdt card = cardsMap.get(task.Task_Code__c);
            if (card == null) {
                task.Task_Code__c.addError('Task Catalog Card: ' + task.Task_Code__c + ' not found in catalog');
                continue;
            }
            if (card.Source_Object_Type__c == null && card.Parameters__c != null) {
                task.addError('Source Object Type can not be null in Task Catalog: ' + card.DeveloperName);
                continue;
            }
            SObjectType sourceObjectType = Schema.getGlobalDescribe().get(card.Source_Object_Type__c);
            if (sourceObjectType == null && card.Parameters__c != null) {
                task.addError('Wrong Source Object Type in Task Catalog ' + card.DeveloperName + ': ' + card.Source_Object_Type__c);
                continue;
            }
            System.debug('SOBJTYPE: ' + sourceObjectType);
            String errorsInParameters = CatalogParametersHelper.getErrorInParameters(sourceObjectType, card.Parameters__c);
            if (errorsInParameters != null) {
                task.addError('Task Catalog: ' + card.DeveloperName + '; Parameters error: ' + errorsInParameters);
                continue;
            }

            Id whatId = task.WhatId;
            if (whatId == null) {
                whatId = task.Survey_Invitation__c;
            }
            if (whatId == null && card.Parameters__c != null) {
                task.WhatId.addError('What Id can not be null');
                continue;
            }
            Id recId;
            if (task.WhatId != null) {
                try {
                    recId = task.WhatId;
                    if (recId.getSobjectType() != sourceObjectType) {
                        task.WhatId.addError('Wrong Related To SObject Type');
                        continue;
                    }
                } catch (Exception e) {
                    task.WhatId.addError('Wrong WhatId: ' + task.WhatId);
                    continue;
                }
            }
            checkedTasks.add(task);
        }
    }

    @TestVisible
    private static void processSendImmediateEmails(List<Task> tasks) {
        Map<String, Task_Catalog__mdt> cardsMap = getCardsMap(tasks);
        List<Notification__c> notifications = new List<Notification__c>();

        Set<Id> ownerIds = new Set<Id>();
        List<Task> tasksWithOwner = [
                SELECT
                        OwnerId,
                        Task_Code__c,
                        Task_Type__c,
                        Survey_Invitation__c,
                        Visible_For__c,
                        WhatId
                FROM Task
                WHERE Id IN:tasks AND Owner_Contact__c = NULL];
        for (Task t : tasksWithOwner) ownerIds.add(t.OwnerId);
        Map<Id, User> usersByIds = new Map<Id, User>([
                SELECT
                        Id,
                        ContactId,
                        Contact.Participant_Opt_In_Status_Emails__c,
                        Contact.UserCommunityIsDelegate__c
                FROM User
                WHERE Id IN:ownerIds
                AND IsActive = TRUE
        ]);

        List<Id> partContactsIds = new List<Id>();
        for (Id usId : usersByIds.keySet()) partContactsIds.add(usersByIds.get(usId).ContactId);

        List<Patient_Delegate__c> patientDelegates = [
                SELECT
                        Contact__c,
                        Participant__r.Contact__c
                FROM Patient_Delegate__c
                WHERE Participant__r.Contact__c IN:partContactsIds
                AND Contact__r.Participant_Opt_In_Status_Emails__c = TRUE
        ];
        Map<Id, List<Id>> delegatesCntByPartCnt = new Map<Id, List<Id>>();
        for (Patient_Delegate__c pd : patientDelegates) {
            if (!delegatesCntByPartCnt.containsKey(pd.Participant__r.Contact__c)) {
                delegatesCntByPartCnt.put(pd.Participant__r.Contact__c, new List<Id>());
            }
            delegatesCntByPartCnt.get(pd.Participant__r.Contact__c).add(pd.Contact__c);
        }

        for (Task task : tasksWithOwner) {
            if (task.Task_Code__c != null) {
                Task_Catalog__mdt card = cardsMap.get(task.Task_Code__c);
                if (card != null && card.Immediate_Email_Template__c != null) {
                    Id whatId = task.WhatId;
                    if (whatId == null && task.Task_Type__c == TaskService.TASK_TYPE_SURVEY) {
                        whatId = task.Survey_Invitation__c;
                    }
                    if(card.Immediate_Notification_Type__c != null) {
                        if (task.Visible_For__c.contains(TaskService.TASK_VISIBILITY_OWNER)) {
                            notifications.add(new Notification__c(
                                    Recipient__c = usersByIds.get(task.OwnerId).ContactId,
                                    WhatId__c = whatId,
                                    Notification_Type__c = card.Immediate_Notification_Type__c
                            ));
                        }
                        if (task.Visible_For__c.contains(TaskService.TASK_VISIBILITY_DELEGATES)) {
                            if (!delegatesCntByPartCnt.containsKey(usersByIds.get(task.OwnerId).ContactId)) continue;

                            for (Id delContactId : delegatesCntByPartCnt.get(usersByIds.get(task.OwnerId).ContactId)) {
                                notifications.add(new Notification__c(
                                        Recipient__c = delContactId,
                                        WhatId__c = whatId,
                                        Notification_Type__c = card.Immediate_Notification_Type__c
                                ));
                            }
                        }
                    }
                }
            }
        }
        if(!notifications.isEmpty()) insert notifications;
    }

    public static void processDefaultFieldValues(List<Task> tasks) {
        processDefaultFieldValues(tasks, UserInfo.getLanguage());
    }

    public static void processDefaultFieldValues(List<Task> tasks, String language) {
        Map<String, Task_Catalog__mdt> cardsMap = getCardsMap(tasks);
        Map<String, Set<Id>> idsByObjectType = new Map<String, Set<Id>>();
        Map<String, Set<String>> fieldsByObjectType = new Map<String, Set<String>>();
        for (Task task : tasks) {
            if (task.Task_Code__c == null) continue;
            Task_Catalog__mdt card = cardsMap.get(task.Task_Code__c);
            if (card == null) continue;
            if (card.Source_Object_Type__c == null) continue;

            if (task.WhatId == null && card.Parameters__c != null) {
                if (task.Task_Code__c == TaskService.TASK_CODE_COMPLETE_SURVEY && task.Survey_Invitation__c != null) {
                    task.WhatId = task.Survey_Invitation__c;
                } else {
                    task.WhatId.addError('What Id can not be null');
                    continue;
                }
            }

            if (String.isEmpty(card.Parameters__c)) continue;
            Map<String, String> cardParametersMap = CatalogParametersHelper.getParamsMap(card.Parameters__c);

            Set<Id> objectIds = idsByObjectType.get(card.Source_Object_Type__c);
            if (objectIds == null) objectIds = new Set<Id>();
            objectIds.add(task.WhatId);
            idsByObjectType.put(card.Source_Object_Type__c, objectIds);

            Set<String> objectFields = fieldsByObjectType.get(card.Source_Object_Type__c);
            if (objectFields == null) objectFields = new Set<String>();
            objectFields.addAll(cardParametersMap.values());
            fieldsByObjectType.put(card.Source_Object_Type__c, objectFields);
        }

        Map<Id, SObject> objectsMap = new Map<Id, SObject>();
        for (String objectType : idsByObjectType.keySet()) {
            List<SObject> objectsList = new List<SObject>();
            objectsList = CatalogParametersHelper.queryObjects(objectType, fieldsByObjectType.get(objectType), idsByObjectType.get(objectType));
            for (SObject sobj : objectsList) objectsMap.put(sobj.Id, sobj);
        }
        TranslateHelper.translate(objectsMap.values(), language);

        for (Task task : tasks) {
            Map<String, String> cardParametersValueMap = new Map<String, String>();
            if (String.isEmpty(task.Task_Code__c)) continue;
            Task_Catalog__mdt card = cardsMap.get(task.Task_Code__c);
            if (card == null) continue;
            if (task.WhatId != null) {
                SObject whatObject = objectsMap.get(task.WhatId);
                if (whatObject != null) {
                    cardParametersValueMap = CatalogParametersHelper.getParamsValueMap(whatObject, card.Parameters__c);
                }
            }
            task.Subject = CatalogParametersHelper.prepareLabel(card.Subject_Label__c, cardParametersValueMap);

            String description = CatalogParametersHelper.prepareLabel(card.Comments_Label__c, cardParametersValueMap);
            if (description != null) task.Description = description;

            task.Action_URL__c = CatalogParametersHelper.prepareMergeFields(card.Action_Link__c, cardParametersValueMap);

        }
    }

    @TestVisible
    private static Map<String, Task_Catalog__mdt> getCardsMap(List<Task> tasks) {
        Set<String> catalogCodes = new Set<String>();
        for (Task task : tasks) if (task.Task_Code__c != null) catalogCodes.add(task.Task_Code__c);
        List<Task_Catalog__mdt> cards = [
                SELECT Id,
                        DeveloperName,
                        Subject_Label__c,
                        Comments_Label__c,
                        Source_Object_Type__c,
                        Action_Link__c,
                        Parameters__c,
                        Immediate_Email_Template__c,
                        Immediate_Notification_Type__c
                FROM Task_Catalog__mdt
                WHERE DeveloperName IN:catalogCodes
        ];
        Map<String, Task_Catalog__mdt> cardsMap = new Map<String, Task_Catalog__mdt>();
        for (Task_Catalog__mdt card : cards) cardsMap.put(card.DeveloperName, card);
        return cardsMap;
    }

}