/**
 * Created by Igor Malyuta on 19.04.2019.
 */

@IsTest(IsParallel=false)
private class Test_ManualTaskRemote {

    @IsTest
    static void getInitDataTest() {
        ManualTaskRemote.getInitData();
    }

    @IsTest
    static void createTasksEnrolledTest() {
        ManualTaskFilter manualTaskFilter = new ManualTaskFilter();
        manualTaskFilter.statuses.add(PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS);

        Task testTask = new Task(
                Subject = 'TestTask',
                Priority = 'Critical',
                Start_Date__c = System.today(),
                ActivityDate = System.today().addDays(1),
                Visible_For__c = 'Owner;Delegates',
                Reminder_Date__c = Datetime.now()
        );

        Test.startTest();
        Integer countOfTaskCreated = ManualTaskRemote.createTasks(JSON.serialize(testTask), JSON.serialize(manualTaskFilter));
        Test.stopTest();

        List<Task> tasks2 = [
                SELECT OwnerId,
                        Subject,
                        Priority,
                        Start_Date__c,
                        ActivityDate,
                        Visible_For__c,
                        Reminder_Date__c
                FROM Task
                WHERE Subject = 'TestTask'
                ORDER BY OwnerId
        ];
        List<User> users = [
                SELECT Id
                FROM User
                WHERE Id IN: manualTaskFilter.getUsers()
                ORDER BY Id
        ];

        System.debug('Task2 size: ' + tasks2.size());
        System.debug('Users size: ' + users.size());

        for(Integer i = 0; i < tasks2.size(); i++) {
            System.assertEquals(users.get(i).Id, tasks2.get(i).OwnerId);
            System.assertEquals('TestTask', tasks2.get(i).Subject);
            System.assertEquals('Critical', tasks2.get(i).Priority);
            System.assertEquals(System.today(), tasks2.get(i).Start_Date__c);
            System.assertEquals(System.today().addDays(1), tasks2.get(i).ActivityDate);
            System.assertEquals('Owner;Delegates', tasks2.get(i).Visible_For__c);
        }

        System.assertEquals(manualTaskFilter.getUsers().size(), countOfTaskCreated);
    }

    @IsTest
    static void createTasksReferredTest() {
        ManualTaskFilter manualTaskFilter = new ManualTaskFilter();
        manualTaskFilter.statuses.add('Referred');

        Task testTask = new Task(
                Subject = 'TestTask',
                Priority = 'Critical',
                Start_Date__c = System.today(),
                ActivityDate = System.today().addDays(1),
                Visible_For__c = 'Owner;Delegates',
                Reminder_Date__c = Datetime.now()
        );

        Test.startTest();
        Integer countOfTaskCreated = ManualTaskRemote.createTasks(JSON.serialize(testTask), JSON.serialize(manualTaskFilter));
        Test.stopTest();

        System.assertEquals(manualTaskFilter.getUsers().size(), countOfTaskCreated);

        List<Task> tasks = [SELECT Id FROM Task WHERE Subject = 'TestTask' AND OwnerId IN: manualTaskFilter.getUsers()];
        System.assertEquals(countOfTaskCreated, tasks.size());
    }

    @TestSetup
    static void setup() {
        Therapeutic_Area__c ta = new Therapeutic_Area__c(Name = 'Test Area');
        insert ta;

        Clinical_Trial_Profile__c trial = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'Prot-333',
                NCT_Number__c = 'NCT02804789',
                Therapeutic_Area__c = ta.Id
        );
        insert trial;

        Account accountPartic = new Account(Name = 'Participant');
        insert accountPartic;

        Contact patientContact = new Contact(
                FirstName = 'Richard',
                LastName = 'Wilson',
                Email = 'r.wilson@gmail.com',
                userCommunityMode__c = 'Participant',
                AccountId = accountPartic.Id
        );
        insert patientContact;

        User newUser = new User(
                ProfileId = CommunityService.COMMUNITY_USER_PROFILE_ID,
                Username = patientContact.Email,
                CommunityNickname = 'test',
                Email = patientContact.Email,
                EmailEncodingKey = 'UTF-8',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles',
                ContactId = patientContact.Id,
                LastName = patientContact.LastName,
                FirstName = patientContact.FirstName,
                Alias = 'test',
                IsActive = true
        );
        insert newUser;


        Account clinic = new Account(Name = 'Clinic');
        insert clinic;
        Contact pi = new Contact(
                FirstName = 'Joseph',
                LastName = 'Davis PI And HCP',
                Email = 'jdavis@somemail.com',
                AccountId = clinic.Id
        );
        insert pi;

        Study_Site__c studySite = new Study_Site__c(
                Name = 'Test SS1',
                Clinical_Trial_Profile__c =  trial.Id,
                Site__c =  clinic.Id,
                Principal_Investigator__c =  pi.Id,
                Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
                Study_Site_Key__c = '12132123132313',
                Study_Site_Phone__c =  '+1(232) 222-3434'
        );
        insert studySite;

        Participant__c participant = new Participant__c(
                First_Name__c = patientContact.FirstName,
                Contact__c = patientContact.Id
        );
        insert participant;

        Participant_Enrollment__c pe = new Participant_Enrollment__c(
                Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS,
                Participant__c = participant.Id,
                Clinical_Trial_Profile__c = trial.Id,
                Study_Site__c = studySite.Id
        );
        insert pe;
    }
}