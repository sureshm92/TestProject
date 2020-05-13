/**
 * Created by Igor Malyuta on 19.04.2019.
 */

@IsTest(IsParallel=false)
private class Test_ParticipantVisitsRemote {

    @TestSetup
    static void setup() {
        TestData.loadTestData();
        TestData testData = new TestData();

        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
        insert vp;
        vp = [SELECT Id FROM Visit_Plan__c];

        Visit__c visit = new Visit__c(
                Name = 'TestVisit' + 1,
                Visit_Schedule__c = 'Week ' + 1,
                Icons__c = 'Test_icon',
                Order__c = 1,
                Visit_Plan__c = vp.Id
        );
        insert visit;

        testData.ctp.Visit_Plan__c = vp.Id;
        update testData.ctp;

        testData.pe.Visit_Plan__c = vp.Id;
        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS;
        update testData.pe;

        Patient_Visit__c patientVisit = PatientVisitService.createPatientVisit(visit, testData.pe.Id);
        insert patientVisit;

        Icon_Details__c icon = new Icon_Details__c(Name = 'ICON', Label__c = 'icon label', Description__c = 'This is icon!', Visit_Plan__c = vp.Id);
        insert icon;
    }

    @IsTest
    static void test() {
        TestData testData = new TestData();

        Test.startTest();
        System.runAs(testData.participantUser) {
            ParticipantVisitsRemote.isStudySiteHasVisits();
            ParticipantVisitsRemote.getVisitsPreview();
            ParticipantVisitsRemote.getParticipantVisits('Current');
            ParticipantVisitsRemote.getCardPatientVisits();
        }
        Test.stopTest();
    }

    @IsTest
    static void updatePatientVisitTest() {
        TestData testData = new TestData();

        Test.startTest();
        Patient_Visit__c patientVisit = [SELECT Id, Planned_Date__c FROM Patient_Visit__c LIMIT 1];
        System.runAs(testData.participantUser) {
            patientVisit.Planned_Date__c = Date.newInstance(2020, 3, 17);
            ParticipantVisitsRemote.updatePatientVisit(JSON.serialize(patientVisit));
        }
        Test.stopTest();
    }

    @IsTest
    static void getVisitsLegendTest() {
        TestData testData = new TestData();

        Test.startTest();
        String legend;
        System.runAs(testData.participantUser) {
            legend = ParticipantVisitsRemote.getVisitsLegend('ICON');
        }
        Test.stopTest();
        System.assertEquals('[{"iconLegend":"This is icon!","iconLabel":"icon label","iconId":"ICON"}]', legend);
    }

    @IsTest
    static void isStudySiteHasVisitsWithException_test() {
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            ParticipantVisitsRemote.isStudySiteHasVisits();
        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }

    @IsTest
    static void getVisitsPreviewWithException_test() {
        Boolean isExceptionThrown = false;
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
    static void getCardPatientVisitsWithException_test() {
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            ParticipantVisitsRemote.getCardPatientVisits();
        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }

    @IsTest
    static void updatePatientVisitWithException_test() {
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            ParticipantVisitsRemote.updatePatientVisit(null);
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
