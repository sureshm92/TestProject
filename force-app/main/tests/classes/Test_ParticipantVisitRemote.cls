/**
 * Created by dmytro.fedchyshyn on 20.08.2019.
 */

@IsTest
public with sharing class Test_ParticipantVisitRemote {

    @IsTest
    private static void getVisitsPreview_test() {

        TestData.loadTestData();
        TestData testData = new TestData();
        testData.ctp.Shareback_Availability_Timing__c = 1;
        update testData.ctp;

        Test.startTest();
        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
        insert vp;

        testData.ctp.Visit_Plan__c = vp.Id;
        update testData.ctp;

        List<Visit__c> visits = new List<Visit__c>();
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        insert visits;

        testData.createPSE();

        List<Patient_Visit__c> patientVisits = new List<Patient_Visit__c>();
        patientVisits.add(new Patient_Visit__c(
                Participant_Study_Enrollment__c = testData.pse.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(0).Id,
                Visit_Number__c = 1
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Study_Enrollment__c = testData.pse.Id,
                Status__c = 'Missed',
                Visit__c = visits.get(1).Id,
                Visit_Number__c = 2
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Study_Enrollment__c = testData.pse.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(2).Id,
                Visit_Number__c = 3
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Study_Enrollment__c = testData.pse.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(3).Id,
                Visit_Number__c = 3.1
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Study_Enrollment__c = testData.pse.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(4).Id,
                Visit_Number__c = 4
        ));
        insert patientVisits;

        System.runAs(testData.participantUser) {
            ClassFactory.clearStubTypesByClassNamesMap();
            List<PatientVisitService.VisitWrapper> wrappers = ParticipantVisitsRemote.getVisitsPreview();

            System.assertEquals(3, wrappers.size());
        }
        Test.stopTest();
    }

    @IsTest
    private static void getParticipantVisits_test() {
        TestData.loadTestData();
        TestData testData = new TestData();
        testData.ctp.Shareback_Availability_Timing__c = 1;
        update testData.ctp;

        Test.startTest();
        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
        insert vp;

        testData.ctp.Visit_Plan__c = vp.Id;
        update testData.ctp;

        List<Visit__c> visits = new List<Visit__c>();
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        insert visits;

        testData.createPSE();

        List<Patient_Visit__c> patientVisits = new List<Patient_Visit__c>();
        patientVisits.add(new Patient_Visit__c(
                Participant_Study_Enrollment__c = testData.pse.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(0).Id,
                Visit_Number__c = 1
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Study_Enrollment__c = testData.pse.Id,
                Status__c = 'Missed',
                Visit__c = visits.get(1).Id,
                Visit_Number__c = 2
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Study_Enrollment__c = testData.pse.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(2).Id,
                Visit_Number__c = 3
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Study_Enrollment__c = testData.pse.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(3).Id,
                Visit_Number__c = 3.1
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Study_Enrollment__c = testData.pse.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(4).Id,
                Visit_Number__c = 4
        ));
        insert patientVisits;

        System.runAs(testData.participantUser) {
            ClassFactory.clearStubTypesByClassNamesMap();
            List<PatientVisitService.VisitWrapper> wrappers = ParticipantVisitsRemote.getParticipantVisits('Current');

            System.assertEquals(5, wrappers.size());
        }
        Test.stopTest();
    }

    @IsTest
    private static void getLegend_test() {
        TestData.loadTestData();
        TestData testData = new TestData();
        testData.ctp.Shareback_Availability_Timing__c = 1;
        update testData.ctp;

        Test.startTest();
        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
        insert vp;

        testData.ctp.Visit_Plan__c = vp.Id;
        update testData.ctp;

        List<Icon_Details__c> iconDetails = new List<Icon_Details__c>{
                new Icon_Details__c(Name = 'cancel', Visit_Plan__c = testData.ctp.Visit_Plan__c),
                new Icon_Details__c(Name = 'Hand-X-Ray', Visit_Plan__c = testData.ctp.Visit_Plan__c),
                new Icon_Details__c(Name = 'custom-fasting', Visit_Plan__c = testData.ctp.Visit_Plan__c)
        };
        insert iconDetails;

        System.runAs(testData.participantUser) {
            ClassFactory.clearStubTypesByClassNamesMap();
            String legend = ParticipantVisitsRemote.getVisitsLegend('custom-fasting;Hand-X-Ray;cancel');

            System.assert(legend.contains('Hand-X-Ray'));
        }
        Test.stopTest();
    }

    @IsTest
    static void etVisitsPreviewWithException_test() {
        Boolean isExceptionThrown = false;
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(PatientVisitService.class, StubFactory.newInstance(PatientVisitService.class)
                .when('getVisitWrappers')
                .then(new AuraHandledException('exception'))
                .getInstance()
        );
        Test.startTest();
        try {
            ParticipantVisitsRemote.getVisitsPreview();
        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();

        System.assert(true, isExceptionThrown);
    }

    @IsTest
    static void getParticipantVisitsWithException_test() {
        Boolean isExceptionThrown = false;
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(PatientVisitService.class, StubFactory.newInstance(PatientVisitService.class)
                .when('getVisitWrappers')
                .then(new AuraHandledException('exception'))
                .getInstance()
        );
        Test.startTest();
        try {
            ParticipantVisitsRemote.getParticipantVisits(null);
        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();

        System.assert(true, isExceptionThrown);
    }

    @IsTest
    static void getVisitsLegendWithException_test() {
        Boolean isExceptionThrown = false;
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(DatabaseProxy.class, StubFactory.newInstance(DatabaseProxy.class)
                .when('query')
                .then(new AuraHandledException('exception'))
                .getInstance()
        );
        Test.startTest();
        try {
            ParticipantVisitsRemote.getVisitsLegend(null);
        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();
        
        System.assert(true, isExceptionThrown);
    }
}