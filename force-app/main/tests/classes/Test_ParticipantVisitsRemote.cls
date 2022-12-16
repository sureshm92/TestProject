/**
 * Created by Igor Malyuta on 19.04.2019.
 */

@IsTest(IsParallel=false)
private class Test_ParticipantVisitsRemote {
    @TestSetup
    static void setup() {
        TestData.loadTestData();
        Test.startTest();
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

        Patient_Visit__c patientVisit = PatientVisitService.createPatientVisit(
            visit,
            testData.pe.Id
        );
        insert patientVisit;

        Icon_Details__c icon = new Icon_Details__c(
            Name = 'ICON',
            Label__c = 'icon label',
            Description__c = 'This is icon!',
            Visit_Plan__c = vp.Id
        );
        insert icon;
        Test.stopTest();
    }

    @IsTest
    static void test() {

        Participant__c participant = [
            SELECT
                Id,
                Name,
                First_Name__c,
                Last_Name__c,
                Email__c,
                Status__c,
                Balance__c,
                Contact__c,
                Mailing_Country_Code__c,
                Mailing_Country__c,
                Contact__r.AccountId
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
        User participantUser = [
            SELECT Id, ContactId, LastName
            FROM User
            WHERE LastName = :participant.Name
        ];
        Boolean ssHasVisit;
        List<PatientVisitService.VisitWrapper> visitsPreview;
        List<PatientVisitService.VisitWrapper> participantVisits;
        List<Patient_Visit__c> cardPatientVisits;
        Test.startTest();
        System.runAs(participantUser) {
            ssHasVisit = ParticipantVisitsRemote.isStudySiteHasVisits();
            visitsPreview = ParticipantVisitsRemote.getVisitsPreview();
            // participantVisits = ParticipantVisitsRemote.getParticipantVisits('Current');
            // cardPatientVisits = ParticipantVisitsRemote.getCardPatientVisits();
        }
        Test.stopTest();

        System.assert(ssHasVisit);
        System.assertEquals('Pending', visitsPreview[0].visitStatus);
        //System.assertEquals('TestVisit1', participantVisits[0].visit.Name);
        //System.assertEquals('TestVisit1', cardPatientVisits[0].Name);
    }

    @IsTest
    static void testwithcount() {

        Participant__c participant = [
            SELECT
                Id,
                Name,
                First_Name__c,
                Last_Name__c,
                Email__c,
                Status__c,
                Balance__c,
                Contact__c,
                Mailing_Country_Code__c,
                Mailing_Country__c,
                Contact__r.AccountId
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
        User participantUser = [
            SELECT Id, ContactId, LastName
            FROM User
            WHERE LastName = :participant.Name
        ];
        Boolean ssHasVisit;
        List<PatientVisitService.VisitWrapper> visitsPreview;
        List<PatientVisitService.VisitWrapper> participantVisits;
        List<Patient_Visit__c> cardPatientVisits;
        Test.startTest();
        System.runAs(participantUser) {
            visitsPreview = ParticipantVisitsRemote.getVisitsPreviewAndCount().visitPreviewList;
        }
        Test.stopTest();
        System.assertEquals('Pending', visitsPreview[0].visitStatus);
        //System.assertEquals('TestVisit1', participantVisits[0].visit.Name);
        //System.assertEquals('TestVisit1', cardPatientVisits[0].Name);
    }

    @IsTest
    static void test1() {
        Participant__c participant = [
            SELECT
                Id,
                Name,
                First_Name__c,
                Last_Name__c,
                Email__c,
                Status__c,
                Balance__c,
                Contact__c,
                Mailing_Country_Code__c,
                Mailing_Country__c,
                Contact__r.AccountId
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
        User participantUser = [
            SELECT Id, ContactId, LastName
            FROM User
            WHERE LastName = :participant.Name
        ];
        Test.startTest();
        List<PatientVisitService.VisitWrapper> participantVisits;
        List<Patient_Visit__c> cardPatientVisits;
        System.runAs(participantUser) {
            participantVisits = ParticipantVisitsRemote.getParticipantVisits('Current');
            cardPatientVisits = ParticipantVisitsRemote.getCardPatientVisits();
        }
        Test.stopTest();
        System.assertEquals('TestVisit1', participantVisits[0].visit.Name);
        System.assertEquals('TestVisit1', cardPatientVisits[0].Name);
    }

    @IsTest
    static void test2() {
        Participant__c participant = [
            SELECT
                Id,
                Name,
                First_Name__c,
                Last_Name__c,
                Email__c,
                Status__c,
                Balance__c,
                Contact__c,
                Mailing_Country_Code__c,
                Mailing_Country__c,
                Contact__r.AccountId
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
        Participant_Enrollment__c pe = [SELECT Id,Clinical_Trial_Profile__c FROM Participant_Enrollment__c WHERE Participant__c =:participant.Id];
        Clinical_Trial_Profile__c ctp = new Clinical_Trial_Profile__c();
        ctp.Id = pe.Clinical_Trial_Profile__c;
        ctp.Is_Program__c = true;
        User participantUser = [
            SELECT Id, ContactId, LastName
            FROM User
            WHERE LastName = :participant.Name
        ];
        Test.startTest();
        List<PatientVisitService.VisitWrapper> participantVisits;
        List<Patient_Visit__c> cardPatientVisits;
        System.runAs(participantUser) {
            participantVisits = ParticipantVisitsRemote.getParticipantVisitsAndStudyType('Current').pvList;
            cardPatientVisits = ParticipantVisitsRemote.getCardPatientVisits();
        }
        Test.stopTest();
        System.assertEquals('TestVisit1', participantVisits[0].visit.Name);
        System.assertEquals('TestVisit1', cardPatientVisits[0].Name);
    }

    @IsTest
    static void updatePatientVisitTest() {
        Participant__c participant = [
            SELECT
                Id,
                Name,
                First_Name__c,
                Last_Name__c,
                Email__c,
                Status__c,
                Balance__c,
                Contact__c,
                Mailing_Country_Code__c,
                Mailing_Country__c,
                Contact__r.AccountId
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
        User participantUser = [
            SELECT Id, ContactId, LastName
            FROM User
            WHERE LastName = :participant.Name
        ];
        Test.startTest();
        Patient_Visit__c patientVisit = [SELECT Id, Planned_Date__c FROM Patient_Visit__c LIMIT 1];
        //Datetime newPlannedDate = Date.newInstance(2020, 3, 17);
        Date myDate = Date.newInstance(2020, 3, 18);
        Time myTime = Time.newInstance(3, 3, 3, 0);
        Datetime newPlannedDate = DateTime.newInstance(myDate, myTime);
        System.runAs(participantUser) {
            patientVisit.Planned_Date__c = newPlannedDate;
            ParticipantVisitsRemote.updatePatientVisit(JSON.serialize(patientVisit));
        }
        Test.stopTest();
        patientVisit = [SELECT Id, Planned_Date__c FROM Patient_Visit__c LIMIT 1];
        System.assertEquals(newPlannedDate, patientVisit.Planned_Date__c);
    }

    @IsTest
    static void getVisitsLegendTest() {
        Participant__c participant = [
            SELECT
                Id,
                Name,
                First_Name__c,
                Last_Name__c,
                Email__c,
                Status__c,
                Balance__c,
                Contact__c,
                Mailing_Country_Code__c,
                Mailing_Country__c,
                Contact__r.AccountId
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
        User participantUser = [
            SELECT Id, ContactId, LastName
            FROM User
            WHERE LastName = :participant.Name
        ];

        Test.startTest();
        String legend;
        System.runAs(participantUser) {
            legend = ParticipantVisitsRemote.getVisitsLegend('ICON');
        }
        Test.stopTest();
        System.assertEquals(
            '[{"iconLegend":"This is icon!","iconLabel":"icon label","iconId":"ICON"}]',
            legend
        );
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
    static void getParticipantVisitsDetailsWithException_test() {
        Boolean isExceptionThrown = false;
        Patient_Visit__c pv = [SELECT Id FROM Patient_Visit__c LIMIT 1];
        Test.startTest();
        try {
            ParticipantVisitsRemote.getParticipantVisitsDetails(pv.Id);
        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }

    @IsTest
    static void getIsVisitPathEnabledWithException_test() {
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            ParticipantVisitsRemote.getIsVisitPathEnabled();
        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.NullPointerException');
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }

    @IsTest
    static void getIsRTLWithException_test() {
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            ParticipantVisitsRemote.getIsRTL();
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

    @IsTest
    static void getIconDetails_test(){
        List<Patient_Visit__c> vl = [select Id FROM Patient_Visit__c];
        PatientVisitService.getVisitIcons(vl[0].Id);
        PatientVisitService.getVisitIconsbyName(vl[0].Id);
        PatientVisitService pvs = new PatientVisitService();
        pvs.getPatientVisitDetails(vl[0].Id);
                Participant__c participant = [
            SELECT
                Id,
                Name,
                First_Name__c,
                Last_Name__c,
                Email__c,
                Status__c,
                Balance__c,
                Contact__c,
                Mailing_Country_Code__c,
                Mailing_Country__c,
                Contact__r.AccountId
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
        User participantUser = [
            SELECT Id, ContactId, LastName
            FROM User
            WHERE LastName = :participant.Name
        ];
        Boolean ssHasVisit;
        List<PatientVisitService.VisitWrapper> visitsPreview;
        List<PatientVisitService.VisitWrapper> participantVisits;
        List<Patient_Visit__c> cardPatientVisits;
        Test.startTest();
        System.runAs(participantUser) {
            PatientVisitService pvsl = new PatientVisitService();
            pvsl.getVisitWrappers('Scheduled',5);
        }
        Test.stopTest();

    }
 
    
}