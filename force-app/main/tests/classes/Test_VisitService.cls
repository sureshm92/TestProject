/**
 * Created by Igor Malyuta on 19.04.2019.
 */
@IsTest
private class Test_VisitService {

    @IsTest
    static void getVisitsTest() {
        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
        insert vp;

        Visit__c testvisit = new Visit__c(
                Name = 'TestVisit',
                Visit_Schedule__c = 'Week1',
                Icons__c = 'icon-ecg',
                Order__c = 1,
                Visit_Plan__c = vp.Id,
                Patient_Portal_Name__c = 'PPName'
        );
        insert testvisit;
        TestData.loadTestData();
        TestData testData = new TestData();
        testData.updatePEStatusEnrollmentSuccess();

        insert VisitService.createPatientVisit(testvisit, testData.pe.Id);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateUsersOrSendNotificationsHandler.class);
        Test.startTest();
        List<Visit__c> visits;
        System.runAs(testData.participantUser) {
            visits = VisitService.getInstance().getVisits(null);
        }
        Test.stopTest();

        List<Visit__c> visitsFromDB = [
                SELECT Id,
                        Name,
                        Icons__c,
                        Order__c,
                        Visit_Plan__c
                FROM Visit__c
                ORDER BY Order__c
        ];
        System.assertEquals(visitsFromDB.size(), visits.size());

        for (Integer i = 0; i < visitsFromDB.size(); i++) {
            Visit__c v1 = visits.get(i);
            Visit__c v2 = visitsFromDB.get(i);

            System.assertEquals(v1.Id, v2.Id);
            System.assertEquals(v1.Name, v2.Name);
        }
    }

    @IsTest
    static void getPreviewVisitsTest() {

        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
        insert vp;

        Visit__c testvisit = new Visit__c(
                Name = 'TestVisit',
                Visit_Schedule__c = 'Week1',
                Icons__c = 'icon-ecg',
                Order__c = 1,
                Visit_Plan__c = vp.Id,
                Patient_Portal_Name__c = 'PPName'
        );
        insert testvisit;
        TestData.loadTestData();
        TestData testData = new TestData();
        testData.updatePEStatusEnrollmentSuccess();

        insert VisitService.createPatientVisit(testvisit, testData.pe.Id);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateUsersOrSendNotificationsHandler.class);
        Test.startTest();
        List<Visit__c> visits;
        System.runAs(testData.participantUser) {
            visits = VisitService.getInstance().getPreviewVisits();
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

        System.assertEquals(visits2.size(), visits.size());

        for (Integer i = 0; i < visits2.size(); i++) {
            Visit__c v1 = visits.get(i);
            Visit__c v2 = visits2.get(i);

            System.assertEquals(v1.Id, v2.Id);
            System.assertEquals(v1.Name, v2.Name);
            System.assertEquals(v1.Icons__c, v2.Icons__c);
        }
    }
}