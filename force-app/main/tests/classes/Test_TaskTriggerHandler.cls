/**
 * Created by Sravani on 06.Apr.2022.
 */
@IsTest
public class Test_TaskTriggerHandler {
    @IsTest(SeeAllData=true)
    static void taskTest() {
        Datetime dateNow = Datetime.now();

        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
        TestData testData = new TestData();
        Test.startTest();
        testData.piContact.Participant_Opt_In_Status_Emails__c = true;
        update testData.piContact;
        user u = testData.createPatientDelegate();

        List<Survey> survey = [SELECT Id FROM Survey WHERE ActiveVersionId != NULL LIMIT 1];

        Trial_Survey__c ts = new Trial_Survey__c(
            Active_On_Status__c = PEStatusState.PE_STATUS_RECEIVED,
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Survey__c = survey.get(0).Id,
            Is_Recurrence_Survey__c = true,
            Survey_end_date__c = date.today(),
            Survey_start_date__c = date.today() - 1,
            Whose_response_needed__c = 'Patient only'
        );
        insert ts;

        SurveyInvitation invitation = SurveyService.getInstance()
            .generateInvitation(
                ts,
                testData.pe.Id,
                CommunityService.getCommunityId(null),
                System.today(),
                UserInfo.getTimeZone()
            );

        insert invitation;

        List<Task> tasks = new List<Task>();
        Task task = new Task();
        task.Subject = 'test';
        task.Reminder_Date__c = dateNow;
        task.ReminderDateTime = dateNow;
        task.Activity_Datetime__c = Datetime.now().addDays(1);
        task.OwnerId = testData.participantUser.Id;
        task.Task_Type__c = 'Survey';
        task.Visible_For__c = 'Owner;Delegates';
        task.Task_Code__c = 'Complete_Survey';
        task.WhoId = testData.participant.Contact__r.Id;
        task.Survey_Invitation__c = invitation.Id;

        tasks.add(task);
        insert tasks;

        TaskTriggerHandler.CheckTaskFieldsWithTaskCodeHandler tsHandler = new TaskTriggerHandler.CheckTaskFieldsWithTaskCodeHandler();
        tsHandler.beforeInsert(new List<Task>{ task });

        TaskTriggerHandler.SendImmediateEmailsForTaskCodeHandler tsHandler1 = new TaskTriggerHandler.SendImmediateEmailsForTaskCodeHandler();
        tsHandler1.afterInsert(new List<Task>{ task });

        Test.stopTest();
    }
    @IsTest
    static void test_checkTaskFields() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
        TestData testData = new TestData();
        Datetime dateNow = Datetime.now();

        Test.startTest();
        Contact delegate = new Contact(
            FirstName = 'Patient',
            LastName = 'Delegate',
            Email = 'jsmith@somemail.com',
            AccountId = testData.participant.Contact__r.AccountId,
            Current_Participant_Enrollment__c = testData.pe.Id,
            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
            userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT,
            UserCommunityIsDelegate__c = true
        );
        insert delegate;
        Participant__c p = new Participant__c(
            First_Name__c = 'Patient',
            Last_Name__c = 'Delegate',
            Contact__c = delegate.Id
        );
        insert p;

        Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = delegate.Id,
            Contact__r = delegate,
            Participant__c = testData.participant.Id,
            Participant__r = testData.participant,
            Status__c = 'Active'
        );
        insert patientDelegate;

        User delegateUser = CommunityService.createUser(delegate, null, null, null);

        System.runAs(testData.participantUser) {
            List<Task> tasks = new List<Task>();
            Task task = new Task();
            task.Subject = 'test';
            task.Reminder_Date__c = dateNow;
            task.ReminderDateTime = dateNow;
            task.Activity_Datetime__c = Datetime.now().addDays(1);
            task.OwnerId = testData.participantUser.Id;
            task.Visible_For__c = 'Owner;Delegates';
            task.Task_Code__c = 'Complete_Your_Profile';
            task.WhatId = testData.participant.Id;
            Task task2 = new Task();
            task2.Subject = 'test2';
            task2.Reminder_Date__c = dateNow;
            task2.ReminderDateTime = dateNow;
            task2.Activity_Datetime__c = Datetime.now().addDays(1);
            task2.OwnerId = testData.participantUser.Id;
            task2.Visible_For__c = 'Owner;Delegates';
            task2.Remind_Me__c = '1 day before';
            task2.Task_Code__c = 'Complete_Baseline_Survey';

            Task task4 = new Task();
            task4.Subject = 'test2';
            task4.Reminder_Date__c = dateNow;
            task4.ReminderDateTime = dateNow;
            task4.Activity_Datetime__c = Datetime.now().addDays(1);
            task4.Visible_For__c = 'Owner;Delegates';
            task4.Remind_Me__c = '1 day before';
            task4.Task_Code__c = 'Select_COI';
            task4.Task_Type__c = 'Not Selected';

            Task task5 = new Task();
            task5.Subject = 'Test';
            task5.OwnerId = testData.participantUser.Id;
            task5.Visible_For__c = 'Owner';

            Task task6 = new Task();
            task6.Subject = 'test2';
            task6.Reminder_Date__c = dateNow;
            task6.Visible_For__c = 'Owner;Delegates';
            task6.Remind_Me__c = '1 day before';
            task6.Task_Code__c = 'Select_COI';
            task6.Task_Type__c = 'Not Selected';
            task6.InitialTaskNotification__c = true;
            task6.WhoId = testData.participant.Contact__r.Id;

            tasks.add(task);
            tasks.add(task2);
            tasks.add(task4);
            tasks.add(task5);
            tasks.add(task6);
            try {
                insert tasks;
            } catch (Exception e) {
            }

            TaskTriggerHandler.CheckTaskFieldsWithTaskCodeHandler tsHandler = new TaskTriggerHandler.CheckTaskFieldsWithTaskCodeHandler();
            tsHandler.beforeInsert(new List<Task>{ task });
            tsHandler.beforeInsert(new List<Task>{ task2 });
            tsHandler.beforeInsert(new List<Task>{ task4 });
            tsHandler.beforeInsert(new List<Task>{ task5 });
            tsHandler.beforeInsert(new List<Task>{ task6 });

            TaskTriggerHandler.SendImmediateEmailsForTaskCodeHandler tsHandler1 = new TaskTriggerHandler.SendImmediateEmailsForTaskCodeHandler();
            tsHandler1.afterInsert(new List<Task>{ task });
            tsHandler1.afterInsert(new List<Task>{ task2 });
            tsHandler1.afterInsert(new List<Task>{ task4 });
            tsHandler1.afterInsert(new List<Task>{ task5 });
            tsHandler1.afterInsert(new List<Task>{ task6 });

            task.Remind_Me__c = '2 day before';
            task2.Remind_Me__c = '2 day before';
            task4.Remind_Me__c = '3 day before';
            task5.Remind_Me__c = '4 day before';
            task6.Remind_Me__c = '2 day before';

            Map<Id, Task> oldMap = new Map<Id, Task>();
            oldMap.put(task.id, task);
            oldMap.put(task2.id, task2);
            oldMap.put(task4.id, task4);
            oldMap.put(task5.id, task5);
            oldMap.put(task6.id, task6);

            List<Task> tasks1 = new List<Task>();
            tasks1.add(task);
            tasks1.add(task2);
            tasks1.add(task4);
            tasks1.add(task5);
            tasks1.add(task6);

            update tasks1;

            tsHandler.beforeUpdate(new List<Task>{ task }, oldMap);
            tsHandler.beforeUpdate(new List<Task>{ task2 }, oldMap);
            tsHandler.beforeUpdate(new List<Task>{ task4 }, oldMap);
            tsHandler.beforeUpdate(new List<Task>{ task5 }, oldMap);
            tsHandler.beforeUpdate(new List<Task>{ task6 }, oldMap);

            TaskTriggerHandler.processDefaultFieldValues(tasks);
        }
        Test.stopTest();
    }

    @IsTest
    static void test_checkTaskFieldsNegative() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
        TestData testData = new TestData();
        Datetime dateNow = Datetime.now();

        Test.startTest();
        Contact delegate = new Contact(
            FirstName = 'Patient',
            LastName = 'Delegate',
            Email = 'jsmith@somemail.com',
            AccountId = testData.participant.Contact__r.AccountId,
            Current_Participant_Enrollment__c = testData.pe.Id,
            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
            userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT,
            UserCommunityIsDelegate__c = true
        );
        insert delegate;
        Participant__c p = new Participant__c(
            First_Name__c = 'Patient',
            Last_Name__c = 'Delegate',
            Contact__c = delegate.Id
        );
        insert p;

        Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = delegate.Id,
            Contact__r = delegate,
            Participant__c = testData.participant.Id,
            Participant__r = testData.participant,
            Status__c = 'Active'
        );
        insert patientDelegate;

        User delegateUser = CommunityService.createUser(delegate, null, null, null);

        System.runAs(testData.participantUser) {
            List<Task> tasks = new List<Task>();
            Task task = new Task();
            task.Subject = 'test';
            task.Reminder_Date__c = dateNow;
            task.ReminderDateTime = dateNow;
            task.Activity_Datetime__c = Datetime.now().addDays(1);
            task.OwnerId = testData.participantUser.Id;
            task.Visible_For__c = 'Owner;Delegates';
            task.Task_Code__c = 'Complete_Your_Profile_Invalid';
            task.WhatId = testData.participant.Id;
            Task task2 = new Task();
            task2.Subject = 'test2';
            task2.Reminder_Date__c = dateNow;
            task2.ReminderDateTime = dateNow;
            task2.Activity_Datetime__c = Datetime.now().addDays(1);
            task2.OwnerId = testData.participantUser.Id;
            task2.Visible_For__c = 'Owner;Delegates';
            task2.Remind_Me__c = '1 day before';
            task2.Task_Code__c = 'Complete_Baseline_Survey_Invalid';

            tasks.add(task);
            tasks.add(task2);
            try {
                insert tasks;
                TaskTriggerHandler.CheckTaskFieldsWithTaskCodeHandler tsHandler = new TaskTriggerHandler.CheckTaskFieldsWithTaskCodeHandler();
                tsHandler.beforeInsert(new List<Task>{ task });
                tsHandler.beforeInsert(new List<Task>{ task2 });
            } catch (Exception e) {
                Boolean expectedExceptionThrown = e.getMessage().contains('Task Catalog Card:')
                    ? true
                    : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
        }
        Test.stopTest();
    }

    @IsTest(SeeAllData=true)
    static void taskTestSurvey() {
        Datetime dateNow = Datetime.now();

        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
        TestData testData = new TestData();
        Test.startTest();
        testData.piContact.Participant_Opt_In_Status_Emails__c = true;
        update testData.piContact;
        user u = testData.createPatientDelegate();

        List<Survey> survey = [SELECT Id FROM Survey WHERE ActiveVersionId != NULL LIMIT 1];

        Trial_Survey__c ts = new Trial_Survey__c(
            Active_On_Status__c = PEStatusState.PE_STATUS_RECEIVED,
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Survey__c = survey.get(0).Id,
            Is_Recurrence_Survey__c = true,
            Survey_end_date__c = date.today(),
            Survey_start_date__c = date.today() - 1,
            Whose_response_needed__c = 'Patient only'
        );
        insert ts;

        SurveyInvitation invitation = SurveyService.getInstance()
            .generateInvitation(
                ts,
                testData.pe.Id,
                CommunityService.getCommunityId(null),
                System.today(),
                UserInfo.getTimeZone()
            );

        insert invitation;

        List<Task> tasks = new List<Task>();
        Task task = new Task();
        task.Subject = 'test';
        task.Reminder_Date__c = dateNow;
        task.ReminderDateTime = dateNow;
        task.Activity_Datetime__c = Datetime.now().addDays(1);
        task.OwnerId = testData.participantUser.Id;
        task.Task_Type__c = 'Survey';
        task.Visible_For__c = 'Owner;Delegates';
        task.Task_Code__c = 'Complete_Survey';
        task.WhoId = testData.participant.Contact__r.Id;
        task.Survey_Invitation__c = invitation.Id;

        tasks.add(task);
        insert tasks;

        TaskTriggerHandler.CheckTaskFieldsWithTaskCodeHandler tsHandler = new TaskTriggerHandler.CheckTaskFieldsWithTaskCodeHandler();
        tsHandler.beforeInsert(new List<Task>{ task });

        TaskTriggerHandler.SendImmediateEmailsForTaskCodeHandler tsHandler1 = new TaskTriggerHandler.SendImmediateEmailsForTaskCodeHandler();
        tsHandler1.afterInsert(new List<Task>{ task });
        TaskTriggerHandler.processDefaultFieldValues(tasks);
        Test.stopTest();
    }
}
