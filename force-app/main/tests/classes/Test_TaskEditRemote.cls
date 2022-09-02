/**
 * Created by Denis on 12.04.2019.
 */
@IsTest
private class Test_TaskEditRemote {
    @TestSetup
    static void makeData() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @IsTest
    static void getInitTaskEditDataWrapper() {
        TriggerHandlerExecutor.bypassHandler(
            	ContactTriggerHandler.UpdateParticipantAndUserEmailsOnEmailChangeHandler.class
        	);
        TriggerHandlerExecutor.bypassHandler(
            	ContactTriggerHandler.UpdatePhoneNumberContactsHandler.class
        	);
        TriggerHandlerExecutor.bypassHandler(
            	ContactTriggerHandler.SetShowTourDefaultHandler.class
        	);
        TriggerHandlerExecutor.bypassHandler(
            	ContactTriggerHandler.PopulateOverrideFields.class
        	);
        TriggerHandlerExecutor.bypassHandler(
            	ContactTriggerHandler.CreateUserForCCContactHandler.class
        	);
        TriggerHandlerExecutor.bypassHandler(
            	ContactTriggerHandler.UpdateConsentTimeStamps.class
        	);
        TriggerHandlerExecutor.bypassHandler(
            	ContactTriggerHandler.ParticipantConsentUpdate.class
        	);
        TestData testData = new TestData();
        Datetime dateNow = Datetime.now();

        Test.startTest();

        System.runAs(testData.participantUser) {
            TriggerHandlerExecutor.bypassHandler(
            	UserTriggerHandler.UpdateLanguageOnRelatedContactsHandler.class
        	);
            TriggerHandlerExecutor.bypassHandler(
            	UserTriggerHandler.UpdateEmailOnRelatedContactsHandler.class
        	);
            TriggerHandlerExecutor.bypassHandler(
            	UserTriggerHandler.CreateCompleteYourProfileTaskHandler.class
        	);
            TriggerHandlerExecutor.bypassHandler(
            	UserTriggerHandler.AssignCommunityPermissionSetToUserHandler.class
        	);
            TriggerHandlerExecutor.bypassHandler(
            	TaskTriggerHandler.SendImmediateEmailsForTaskCodeHandler.class
        	);
            TriggerHandlerExecutor.bypassHandler(
            	TaskTriggerHandler.CheckTaskFieldsWithTaskCodeHandler.class
        	);
            List<Task> tasks = new List<Task>();
            Task task = new Task();
            task.Subject = 'test';
            task.Reminder_Date__c = dateNow;
            task.ReminderDateTime = dateNow;
            task.Activity_Datetime__c = Datetime.now().addDays(1);
            task.OwnerId = testData.participantUser.Id;
            task.Visible_For__c = 'Owner;Delegates';
            Task task2 = new Task();
            task2.Subject = 'test2';
            task2.Reminder_Date__c = dateNow;
            task2.ReminderDateTime = dateNow;
            task2.Activity_Datetime__c = Datetime.now().addDays(1);
            task2.OwnerId = testData.participantUser.Id;
            task2.Visible_For__c = 'Owner;Delegates';
            task2.Remind_Me__c = '1 day before';
            Task task3 = new Task();
            task3.Subject = 'test3';
            task3.Reminder_Date__c = dateNow;
            task3.ReminderDateTime = dateNow;
            task3.Remind_Me__c = '4 hours before';
            task3.Activity_Datetime__c = Datetime.now().addDays(1);
            task3.OwnerId = testData.participantUser.Id;
            task3.Visible_For__c = 'Owner;Delegates';
            Task task4 = new Task();
            task4.Subject = 'test4';
            task4.Reminder_Date__c = dateNow;
            task4.ReminderDateTime = dateNow;
            task4.Activity_Datetime__c = Datetime.now().addDays(1);
            task4.Remind_Me__c = '1 hour before';
            task4.OwnerId = testData.participantUser.Id;
            task4.Visible_For__c = 'Owner;Delegates';
            Task task5 = new Task();
            task5.Subject = 'test5';
            task5.Reminder_Date__c = dateNow;
            task5.ReminderDateTime = dateNow;
            task5.Remind_Me__c = '1 Week before';
            task5.Activity_Datetime__c = Datetime.now().addDays(1);
            task5.OwnerId = testData.participantUser.Id;
            task5.Visible_For__c = 'Owner;Delegates';

            tasks.add(task);
            tasks.add(task2);
            tasks.add(task3);
            tasks.add(task4);
            tasks.add(task5);
            insert tasks;

            TaskEditRemote.getTaskEditData(task.Id);
            task.Reminder_Date__c = task.Reminder_Date__c.addDays(1);
            task.ReminderDateTime = task.Reminder_Date__c.addDays(1);
            TaskEditRemote.upsertTask(
                JSON.serialize(new TaskEditRemote.TaskEditDataWrapper()),
                JSON.serialize(task)
            );
            TaskEditRemote.TaskEditDataWrapper taskWrapper = new TaskEditRemote.TaskEditDataWrapper();
            taskWrapper.reminderOption = '1 day before';
            taskWrapper.activityDate = dateNow.addDays(3);
            TaskEditRemote.upsertTask(JSON.serialize(taskWrapper), JSON.serialize(task2));
            TaskEditRemote.TaskEditDataWrapper taskWrapper1 = new TaskEditRemote.TaskEditDataWrapper();
            taskWrapper1.reminderOption = '4 hours before';
            taskWrapper1.activityDate = dateNow.addDays(3);
            TaskEditRemote.upsertTask(JSON.serialize(taskWrapper1), JSON.serialize(task3));
            TaskEditRemote.TaskEditDataWrapper taskWrapper2 = new TaskEditRemote.TaskEditDataWrapper();
            taskWrapper2.reminderOption = '1 hour before';
            taskWrapper2.activityDate = dateNow.addDays(3);
            TaskEditRemote.upsertTask(JSON.serialize(taskWrapper2), JSON.serialize(task4));
            TaskEditRemote.TaskEditDataWrapper taskWrapper3 = new TaskEditRemote.TaskEditDataWrapper();
            taskWrapper3.reminderOption = '1 Week before';
            taskWrapper3.activityDate = dateNow.addDays(10);
            TaskEditRemote.upsertTask(JSON.serialize(taskWrapper3), JSON.serialize(task5));
            Test.stopTest();
            TaskEditRemote.markAsCompleted(task.Id);
            TaskEditRemote.deleteTask(task2);
        }
        List<Task> testTask = [
            SELECT Id, Status, Reminder_Date__c, ReminderDateTime
            FROM Task
            WHERE Subject = 'test'
        ];
        

        List<Task> testTask2 = [SELECT Id FROM Task WHERE Subject = 'test2'];
        //System.assertEquals(dateNow.addDays(1), testTask[0].Reminder_Date__c);
        //System.assertEquals(TaskService.TASK_STATUS_COMPLETED, testTask[0].Status);
        //System.assert(testTask2.isEmpty());
    }

    @IsTest
    static void updatePatientVisitTest() {
        Test.startTest();
        Patient_Visit__c pv = new Patient_Visit__c();
        pv.Planned_Date__c = datetime.now();
        insert pv;
        pv.Planned_Date__c = datetime.now().addDays(2);
        TaskEditRemote.updatePatientVisits(JSON.serialize(pv));
        try {
            TaskEditRemote.updatePatientVisits('');
        } catch (Exception e) {
            e.getMessage();
        }
        Test.stopTest();
    }

    @IsTest
    static void getInitTaskEditDataWrapperForVisit() {
        TestData testData = new TestData();
        Datetime dateNow = Datetime.now();

        Test.startTest();
        System.runAs(testData.participantUser) {
            List<Task> tasks = new List<Task>();
            Task task = new Task();
            task.Subject = 'test';
            task.Reminder_Date__c = dateNow;
            task.ReminderDateTime = dateNow;
            task.Task_Type__c = 'Visit';
            // task.Activity_Datetime__c = Datetime.now().addDays(1);
            task.OwnerId = testData.participantUser.Id;
            task.Visible_For__c = 'Owner;Delegates';
            Task task2 = new Task();
            task2.Subject = 'test2';
            task2.Reminder_Date__c = dateNow;
            task2.ReminderDateTime = dateNow;
            task2.Task_Type__c = 'Visit';
            //task2.Activity_Datetime__c = Datetime.now().addDays(1);
            task2.OwnerId = testData.participantUser.Id;
            task2.Visible_For__c = 'Owner;Delegates';
            Task task3 = new Task();
            task3.Subject = 'test3';
            task3.Reminder_Date__c = dateNow.addDays(2);
            task3.ReminderDateTime = dateNow.addDays(2);
            task3.Task_Type__c = 'Visit';
            //task2.Activity_Datetime__c = Datetime.now().addDays(1);
            task3.OwnerId = testData.participantUser.Id;
            task3.Visible_For__c = 'Owner;Delegates';
            Task task4 = new Task();
            task4.Subject = 'test4';
            task4.Reminder_Date__c = dateNow.addDays(8);
            task4.ReminderDateTime = dateNow.addDays(8);
            task4.Task_Type__c = 'Visit';
            //task2.Activity_Datetime__c = Datetime.now().addDays(1);
            task4.OwnerId = testData.participantUser.Id;
            task4.Visible_For__c = 'Owner;Delegates';

            Task task5 = new Task();
            task5.Subject = 'test5';
            task5.Reminder_Date__c = dateNow.addDays(8);
            task5.ReminderDateTime = dateNow.addDays(8);
            task5.Task_Type__c = 'Visit';
            //task2.Activity_Datetime__c = Datetime.now().addDays(1);
            task5.OwnerId = testData.participantUser.Id;
            task5.Visible_For__c = 'Owner;Delegates';
            tasks.add(task);
            tasks.add(task2);
            tasks.add(task3);
            tasks.add(task4);
            tasks.add(task5);
            insert tasks;

            TaskEditRemote.getTaskEditData(task.Id);
            task.Reminder_Date__c = task.Reminder_Date__c.addDays(1);
            task.ReminderDateTime = task.Reminder_Date__c.addDays(1);
            TaskEditRemote.TaskEditDataWrapper taskWrapper = new TaskEditRemote.TaskEditDataWrapper();
            taskWrapper.planDate = task.Reminder_Date__c.addDays(1);
            taskWrapper.reminderOption = '4 hours before';
            TaskEditRemote.upsertTaskForVisit(JSON.serialize(taskWrapper), JSON.serialize(task));

            TaskEditRemote.getTaskEditData(task2.Id);
            task2.Reminder_Date__c = task2.Reminder_Date__c.addDays(1);
            task2.ReminderDateTime = task2.Reminder_Date__c.addDays(1);
            TaskEditRemote.TaskEditDataWrapper taskWrapper2 = new TaskEditRemote.TaskEditDataWrapper();
            taskWrapper2.planDate = task2.Reminder_Date__c.addDays(1);
            taskWrapper2.reminderOption = '1 hour before';
            TaskEditRemote.upsertTaskForVisit(JSON.serialize(taskWrapper2), JSON.serialize(task2));
            Test.stopTest();
            TaskEditRemote.getTaskEditData(task3.Id);
            task3.Reminder_Date__c = task3.Reminder_Date__c.addDays(1);
            task3.ReminderDateTime = task3.Reminder_Date__c.addDays(1);
            TaskEditRemote.TaskEditDataWrapper taskWrapper3 = new TaskEditRemote.TaskEditDataWrapper();
            taskWrapper3.planDate = task3.Reminder_Date__c.addDays(1);
            taskWrapper3.reminderOption = '1 day before';
            TaskEditRemote.upsertTaskForVisit(JSON.serialize(taskWrapper3), JSON.serialize(task3));
            TaskEditRemote.getTaskEditData(task4.Id);
            task4.Reminder_Date__c = task4.Reminder_Date__c.addDays(1);
            task4.ReminderDateTime = task4.Reminder_Date__c.addDays(1);
            TaskEditRemote.TaskEditDataWrapper taskWrapper4 = new TaskEditRemote.TaskEditDataWrapper();
            taskWrapper4.planDate = task4.Reminder_Date__c.addDays(1);
            taskWrapper4.reminderOption = '1 Week before';
            TaskEditRemote.upsertTaskForVisit(JSON.serialize(taskWrapper4), JSON.serialize(task4));

            TaskEditRemote.TaskEditDataWrapper taskWrapper5 = new TaskEditRemote.TaskEditDataWrapper();
            taskWrapper5.reminderDate = task4.Reminder_Date__c.addDays(1);
            //taskWrapper4.reminderOption = '1 Week before';
            TaskEditRemote.upsertTaskForVisit(JSON.serialize(taskWrapper5), JSON.serialize(task5));

            TaskEditRemote.markAsCompleted(task.Id);
            TaskEditRemote.deleteTask(task2);
            TaskEditRemote.ignoreTask(task.Id);
            TaskEditRemote.getisTravelSupportEnabled();
        }
        List<Task> testTask = [
            SELECT Id, Status, Reminder_Date__c, ReminderDateTime
            FROM Task
            WHERE Subject = 'test'
        ];
        

        List<Task> testTask2 = [SELECT Id FROM Task WHERE Subject = 'test2'];
        //System.assertEquals(dateNow.addDays(1), testTask[0].Reminder_Date__c);
        //System.assertEquals(TaskService.TASK_STATUS_COMPLETED, testTask[0].Status);
        //System.assert(testTask2.isEmpty());
    }

    @IsTest
    static void testCatalogTasks() {
        TestData testData = new TestData();
        Datetime dateNow = Datetime.now();

        Test.startTest();
        System.runAs(testData.participantUser) {
            Patient_Visit__c pv = new Patient_Visit__c();
            pv.Planned_Date__c = datetime.now();
            insert pv;
            List<Task> tasks = new List<Task>();
            Task task = new Task();
            task.Subject = 'test';
            task.Reminder_Date__c = dateNow;
            task.ReminderDateTime = dateNow;
            task.Activity_Datetime__c = Datetime.now().addDays(1);
            task.OwnerId = testData.participantUser.Id;
            //     task.WhatId = testData.participant.Id;
            task.Visible_For__c = 'Owner';
            //    task.Task_Code__c = TaskService.TASK_CODE_COMPLETE_YOUR_PROFILE;
            task.Patient_Visit__c = pv.Id;
            tasks.add(task);

            insert tasks;

            TaskEditRemote.upsertTask(
                JSON.serialize(new TaskEditRemote.TaskEditDataWrapper()),
                JSON.serialize(task)
            );

            task.Task_Type__c = TaskService.TASK_TYPE_SURVEY;
            TaskEditRemote.upsertTask(
                JSON.serialize(new TaskEditRemote.TaskEditDataWrapper()),
                JSON.serialize(task)
            );
        }
    }

    @IsTest
    static void testExceptions() {
        Patient_Visit__c pv = new Patient_Visit__c();
        pv.Planned_Date__c = datetime.now();
        insert pv;
        Test.startTest();
        try {
            TaskEditRemote.getTaskEditData('');
        } catch (Exception e) {
            e.getMessage();
        }
        try {
            TaskEditRemote.upsertTask('', '');
        } catch (Exception e) {
            e.getMessage();
        }
        try {
            TaskEditRemote.getisTravelSupportEnabled();
            Integer i = 1 / 0;
        } catch (Exception e) {
            e.getMessage();
        }
        try {
            TaskEditRemote.upsertTaskForVisit('', '');
        } catch (Exception e) {
            e.getMessage();
        }

        try {
            TaskEditRemote.deleteTask(new Task());
        } catch (Exception e) {
            e.getMessage();
        }
        try {
            TaskEditRemote.ignoreTask(pv.Id);
        } catch (Exception e) {
            e.getMessage();
        }
        try {
            TaskEditRemote.markAsCompleted(pv.Id);
        } catch (Exception e) {
            e.getMessage();
        }
        Test.stopTest();
    }
}