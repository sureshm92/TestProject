/**
 * Created by Igor Malyuta on 19.04.2019.
 */
@IsTest(IsParallel=true)
private class Test_VisitService {

    @IsTest
    static void getVisitsTest() {
        ParticipantService.ParticipantState state = new ParticipantService.ParticipantState();
        state.pe = [
                SELECT Id,
                        Clinical_Trial_Profile__r.Visit_Plan__c
                FROM Participant_Enrollment__c
        ].get(0);
        state.ctp = state.pe.Clinical_Trial_Profile__r;
        state.showVisits = true;
        ClassFactory.putStubTypeByClassName(ParticipantService.class, StubFactory.newInstance(ParticipantService.class)
                .when('getState')
                .then(state)
                .getInstance()
        );

        Test.startTest();
        List<Visit__c> visits = VisitService.getInstance().getVisits(null);
        Test.stopTest();

        List<Visit__c> visits2 = [
                SELECT Id,
                        Name,
                        Icons__c,
                        Order__c,
                        Visit_Plan__c
                FROM Visit__c
                ORDER BY Order__c
        ];
        System.assertEquals(visits2.size(), visits.size());

        for (Integer i = 0; i < visits2.size(); i++) {
            Visit__c v1 = visits.get(i);
            Visit__c v2 = visits2.get(i);

            System.assertEquals(v1.Id, v2.Id);
            System.assertEquals(v1.Name, v2.Name);
            System.assertEquals(v1.Icons__c, v2.Icons__c);
        }
    }

    @IsTest
    static void getPreviewVisitsTest() {
        ParticipantService.ParticipantState state = new ParticipantService.ParticipantState();
        state.pe = [
                SELECT Id,
                        Clinical_Trial_Profile__r.Visit_Plan__c
                FROM Participant_Enrollment__c
        ].get(0);
        state.ctp = state.pe.Clinical_Trial_Profile__r;
        state.showVisits = true;
        ClassFactory.putStubTypeByClassName(ParticipantService.class, StubFactory.newInstance(ParticipantService.class)
                .when('getState')
                .then(state)
                .getInstance()
        );

        Test.startTest();
        List<Visit__c> previewVisits = VisitService.getInstance().getPreviewVisits();
        Test.stopTest();

        List<Visit__c> visits2 = [
                SELECT Id,
                        Name,
                        Icons__c,
                        Order__c,
                        Visit_Plan__c
                FROM Visit__c
                ORDER BY Order__c
                LIMIT 3
        ];
        System.assertEquals(visits2.size(), previewVisits.size());

        for (Integer i = 0; i < visits2.size(); i++) {
            Visit__c v1 = previewVisits.get(i);
            Visit__c v2 = visits2.get(i);

            System.assertEquals(v1.Id, v2.Id);
            System.assertEquals(v1.Name, v2.Name);
            System.assertEquals(v1.Icons__c, v2.Icons__c);
        }
    }

    @TestSetup
    static void setup() {

        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateUsersOrSendNotificationsHandler.class);
        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
        insert vp;

        List<String> iconsApiName = new List<String>{
                'icon-questionnaires;icon-ecg',
                'icon-vital-signs;icon-blood-test',
                'icon-questionnaires;icon-brief-ph-ex',
                'icon-questionnaires;icon-blood-test;icon-brief-ph-ex',
                'icon-questionnaires;icon-ecg;icon-vital-signs;icon-blood-test'
        };
        List<Visit__c> visits = new List<Visit__c>();
        for (Integer i = 0; i < 5; i++) {
            visits.add(new Visit__c(
                    Name = 'TestVisit' + i,
                    Visit_Schedule__c = 'Week' + i,
                    Icons__c = iconsApiName.get(i),
                    Order__c = i,
                    Visit_Plan__c = vp.Id
            ));
        }
        insert visits;

        Clinical_Trial_Profile__c trial = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'Prot-333',
                NCT_Number__c = 'NCT02804789',
                Visit_Plan__c = vp.Id
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

        Participant__c participant = new Participant__c(
                First_Name__c = patientContact.FirstName,
                Contact__c = patientContact.Id
        );
        insert participant;

        Participant_Enrollment__c pe = new Participant_Enrollment__c(
                Clinical_Trial_Profile__c = trial.Id,
                Patient_ID__c = 'SomePatientId1',
                Referral_Source__c = 'HCP',
                Participant__c = participant.Id
        );
        insert pe;
    }
}