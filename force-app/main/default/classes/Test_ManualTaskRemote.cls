/**
 * Created by Igor Malyuta on 19.04.2019.
 */

@IsTest
private class Test_ManualTaskRemote {

    @IsTest
    static void createTasksEnrolledTest() {
        ManualTaskFilter manualTaskFilter = new ManualTaskFilter();
        manualTaskFilter.statuses.add(PSEService.PSE_STATUS_ENROLLED);

        Task testTask = new Task(
                Subject = 'TestTask',
                Priority = 'Critical',
                Start_Date__c = System.today(),
                ActivityDate = System.today().addDays(1),
                Visible_For__c = 'Owner;Delegates'
        );

        Test.startTest();
        Integer countOfTaskCreated = ManualTaskRemote.createTasks(JSON.serialize(testTask), JSON.serialize(manualTaskFilter));
        Test.stopTest();

        System.assertEquals(manualTaskFilter.getUsers().size(), countOfTaskCreated);

        List<Task> tasks = [SELECT Id FROM Task WHERE OwnerId IN :manualTaskFilter.getUsers()];
        System.assertEquals(countOfTaskCreated, tasks.size());
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
                Visible_For__c = 'Owner;Delegates'
        );

        Test.startTest();
        Integer countOfTaskCreated = ManualTaskRemote.createTasks(JSON.serialize(testTask), JSON.serialize(manualTaskFilter));
        Test.stopTest();

        System.assertEquals(manualTaskFilter.getUsers().size(), countOfTaskCreated);

        List<Task> tasks = [SELECT Id FROM Task WHERE OwnerId IN :manualTaskFilter.getUsers()];
        System.assertEquals(countOfTaskCreated, tasks.size());
    }

    @IsTest
    static void remindBeforeDaysTest() {
        Test.startTest();
        Date remainder = ManualTaskRemote.remindBeforeDays(System.today(), 5);
        Test.stopTest();

        Date before = System.today().addDays(-5);
        System.assertEquals(before, remainder);
    }

    @IsTest
    static void checkAndGetValidDateTest() {
        Date before = System.today().addDays(-5);
        Date now = System.today();

        Test.startTest();
        Date nearestDate = ManualTaskRemote.checkAndGetValidDate(before, now);
        Test.stopTest();

        System.assertEquals(now, nearestDate);
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

        Contact patientContact = new Contact(
                FirstName = 'Richard',
                LastName = 'Wilson',
                Email = 'r.wilson@gmail.com',
                userCommunityMode__c = 'Participant'
        );
        insert patientContact;

        Participant__c participant = new Participant__c(
                First_Name__c = patientContact.FirstName,
                Contact__c = patientContact.Id
        );
        insert participant;

        Participant_Enrollment__c pe = new Participant_Enrollment__c(
                Participant_Status__c = PEStatusState.PE_STATUS_REFERRAL_SENT_TO_PI,
                Participant__c = participant.Id,
                Clinical_Trial_Profile__c = trial.Id
        );
        insert pe;

        Participant_Study_Enrollment__c pse = new Participant_Study_Enrollment__c(
                Clinical_Trial_Profile__c = trial.Id,
                Participant__c = participant.Id
        );
        insert pse;
    }
}