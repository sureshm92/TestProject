/**
 * Created by Igor Malyuta on 19.04.2019.
 */
@IsTest
private class Test_VisitService {

    @IsTest
    static void getVisitsTest() {
        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
        insert vp;

        List<String> iconsApiName = new List<String>{
                'icon-questionnaires;icon-ecg',
                'icon-vital-signs;icon-blood-test',
                'icon-questionnaires;icon-brief-ph-ex',
                'icon-questionnaires;icon-blood-test;icon-brief-ph-ex',
                'icon-questionnaires;icon-ecg;icon-vital-signs;icon-blood-test'
        };
        List<Visit__c> testVisits = new List<Visit__c>();
        for (Integer i = 0; i < 5; i++) {
            testVisits.add(new Visit__c(
                    Name = 'TestVisit' + i,
                    Visit_Schedule__c = 'Week' + i,
                    Icons__c = iconsApiName.get(i),
                    Order__c = i,
                    Visit_Plan__c = vp.Id
            ));
        }
        insert testVisits;

        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateUsersOrSendNotificationsHandler.class);
        ParticipantService.ParticipantState state = new ParticipantService.ParticipantState();
        state.pe = [
                SELECT Id,
                        Clinical_Trial_Profile__r.Visit_Plan__c
                FROM Participant_Enrollment__c
        ].get(0);
        state.ctp = state.pe.Clinical_Trial_Profile__r;
        state.showVisits = true;
        ClassFactory.putStubTypeByClassName(ParticipantService.class, StubBuilder.newInstance(ParticipantService.class)
                .when('getState')
                .then(state)
                .build()
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
        System.assertEquals(visits2.size(), testVisits.size());

        for (Integer i = 0; i < visits2.size(); i++) {
            Visit__c v1 = testVisits.get(i);
            Visit__c v2 = visits2.get(i);

            System.assertEquals(v1.Id, v2.Id);
            System.assertEquals(v1.Name, v2.Name);
            System.assertEquals(v1.Icons__c, v2.Icons__c);
        }
    }

    @IsTest
    static void getPreviewVisitsTest() {
        List<String> iconsApiName = new List<String>{
                'icon-questionnaires;icon-ecg',
                'icon-vital-signs;icon-blood-test',
                'icon-questionnaires;icon-brief-ph-ex',
                'icon-questionnaires;icon-blood-test;icon-brief-ph-ex',
                'icon-questionnaires;icon-ecg;icon-vital-signs;icon-blood-test'
        };

        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
        insert vp;
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
//        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateUsersOrSendNotificationsHandler.class);
        TestData.loadTestData();
        TestData testData = new TestData();

        Test.startTest();
        List<Visit__c> previewVisits;
        System.runAs(testData.participantUser){
            previewVisits = VisitService.getInstance().getPreviewVisits();
        }

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
        System.debug('>>>prev_visits2:' + previewVisits.size());

        System.assertEquals(visits2.size(), previewVisits.size());

        for (Integer i = 0; i < visits2.size(); i++) {
            Visit__c v1 = previewVisits.get(i);
            Visit__c v2 = visits2.get(i);

            System.assertEquals(v1.Id, v2.Id);
            System.assertEquals(v1.Name, v2.Name);
            System.assertEquals(v1.Icons__c, v2.Icons__c);
        }
    }
}