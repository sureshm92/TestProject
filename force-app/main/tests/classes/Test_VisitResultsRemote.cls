/**
 * Created by dmytro.fedchyshyn on 01.08.2019.
 */
@IsTest
public with sharing class Test_VisitResultsRemote {

    @TestSetup
    static void setup() {
        TriggerHandlerExecutor.bypassHandler(ContactReferralNetworkTriggerHandler.SyncContactInterestedSites.class);
        TriggerHandlerExecutor.bypassHandler(ContactTherapeuticAreaTriggerHandler.SyncContactInterestedTopics.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class);
        TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.CreateNotificationHandler.class);
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.CreateStatusHistoryHandler.class);
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.CreatePIOrSendNotificationHandler.class);

        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void getInitData_test() {
        List<Clinical_Trial_Profile__c> ctp = new List<Clinical_Trial_Profile__c>{
                (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType(),
                        new Map<String, Object>{
                                'Visit_Plan__c' => TestDataFactory.getFakeId(Visit_Plan__c.getSObjectType())
                        })
        };

        List<Visit__c> visits2 = new List<Visit__c>{
                new Visit__c(Name = 'Test1'),
                new Visit__c(Name = 'Test2')
        };

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(CTPSelector.class, StubBuilder.newInstance(CTPSelector.class)
                .when('getCtpById')
                .then(ctp)
                .when('getVisitsByCtpId')
                .then(visits2)
                .build()
        );

        Test.startTest();
        TestData testData = new TestData();
        testData.updatePEStatusEnrollmentSuccess();

        System.runAs(testData.participantUser) {
            Map<String, Map<String, List<String>>> visitResultSharings = new Map<String, Map<String, List<String>>>();
            visitResultSharings.put('Vitals', new Map<String, List<String>>());
            VisitResultsRemote.InitDataWrapper wrapper = VisitResultsRemote.getInitData('Vitals', visitResultSharings);
            System.assert(wrapper != null);
        }
        Test.stopTest();
    }

    @IsTest
    static void getVisitResultsGroupNames_test() {
        List<String> visitResultGroupNames = new List<String>{
                'test1',
                'test2'
        };

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(VisitResultsService.class, StubBuilder.newInstance(VisitResultsService.class)
                .when('getVisitResultsGroupNames')
                .then(visitResultGroupNames)
                .build()
        );

        Test.startTest();
        List<String> names = VisitResultsRemote.getVisitResultsGroupNames('');
        Test.stopTest();

        System.assertEquals(2, names.size());
    }

    @IsTest
    static void getVisitResultsContainer_test() {
        Patient_Visit__c patientVisit = new Patient_Visit__c(Id = TestDataFactory.getFakeId(Patient_Visit__c.getSObjectType()));
        VisitResultsService.VisitResultsContainer container = new VisitResultsService.VisitResultsContainer(patientVisit, null, 'Vitals');

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(VisitResultsService.class, StubBuilder.newInstance(VisitResultsService.class)
                .when('getVisitResultsContainer')
                .then(container)
                .build()
        );

        Test.startTest();
        Map<String, List<String>> visitResultSharings = new Map<String, List<String>>();
        visitResultSharings.put('Vitals', new List<String>());
        TestData testData = new TestData();
        VisitResultsService.VisitResultsContainer tesContainer;
        System.runAs(testData.participantUser) {
            tesContainer = VisitResultsRemote.getVisitResultsContainer('Vitals', JSON.serialize(visitResultSharings));
        }
        Test.stopTest();

        System.assert(tesContainer.groupName.equals('Vitals'));
    }

    @IsTest
    static void getVisitResultWrappersForDashboard_test() {
        List<VisitResultsService.VisitResultWrapper> wrappers = new List<VisitResultsService.VisitResultWrapper>{
                new VisitResultsService.VisitResultWrapper(null, null, null, null)
        };

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(VisitResultsService.class, StubBuilder.newInstance(VisitResultsService.class)
                .when('getVisitResultWrappersForDashboard')
                .then(wrappers)
                .build()
        );

        Test.startTest();
        List<VisitResultsService.VisitResultWrapper> newWrappers = VisitResultsRemote.getVisitResultWrappersForDashboard();
        Test.stopTest();

        System.assert(newWrappers != null);
    }

    @IsTest
    static void getInitDataWithException_test() {
        Boolean isExceptionThrown = false;

        Test.startTest();
        TestData testData = new TestData();
        testData.updatePEStatusEnrollmentSuccess();
        testData.participant.Contact__c = null;
        update testData.participant;

        try {
            System.runAs(testData.participantUser) {
                VisitResultsRemote.getInitData('', null);
            }
        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();

        System.assert(true, isExceptionThrown);
    }

    @IsTest
    static void getVisitResultsGroupNamesWithException_test() {
        Boolean isExceptionThrown = false;
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(VisitResultsService.class, StubBuilder.newInstance(VisitResultsService.class)
                .when('getVisitResultsGroupNames')
                .then(new AuraHandledException('exception'))
                .build()
        );

        Test.startTest();
        try {
            VisitResultsRemote.getVisitResultsGroupNames(null);

        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();

        System.assert(true, isExceptionThrown);
    }

    @IsTest
    static void getVisitResultsContainerWithException_test() {
        Boolean isExceptionThrown = false;
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(VisitResultsService.class, StubBuilder.newInstance(VisitResultsService.class)
                .when('getVisitResultsContainer')
                .then(new AuraHandledException('exception'))
                .build()
        );

        Test.startTest();
        try {
            VisitResultsRemote.getVisitResultsContainer(null, null);

        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();

        System.assert(true, isExceptionThrown);
    }

    @IsTest
    static void getVisitResultWrappersForDashboardWithException_test() {
        Boolean isExceptionThrown = false;
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(VisitResultsService.class, StubBuilder.newInstance(VisitResultsService.class)
                .when('getVisitResultWrappersForDashboard')
                .then(new AuraHandledException('exception'))
                .build()
        );

        Test.startTest();
        try {
            VisitResultsRemote.getVisitResultWrappersForDashboard();

        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();

        System.assert(true, isExceptionThrown);
    }

    @IsTest
    static void switchToggleRemoteToggleOn_test() {
        TestData testData = new TestData();
        testData.updatePEStatusEnrollmentSuccess();

        Contact contact = [
                SELECT Visit_Results_OptIn__c
                FROM Contact
                WHERE Id = :testData.participantUser.ContactId
        ];
        contact.Visit_Results_OptIn__c = 'Biomarkers';
        update contact;

        Test.startTest();
        System.runAs(testData.participantUser) {
            VisitResultsRemote.switchToggleRemote('Vitals', true);
        }
        Test.stopTest();

        contact = [
                SELECT Visit_Results_OptIn__c
                FROM Contact
                WHERE Id = :testData.participantUser.ContactId
        ];
        System.assertEquals('Vitals;Biomarkers', contact.Visit_Results_OptIn__c);
    }

    @IsTest
    static void switchToggleRemoteToggleOff_test() {
        TestData testData = new TestData();
        testData.updatePEStatusEnrollmentSuccess();

        Contact contact = [
                SELECT Visit_Results_OptIn__c
                FROM Contact
                WHERE Id = :testData.participantUser.ContactId
        ];
        contact.Visit_Results_OptIn__c = 'Vitals;Labs;Biomarkers';
        update contact;

        Test.startTest();
        System.runAs(testData.participantUser) {
            VisitResultsRemote.switchToggleRemote('Vitals', false);
            VisitResultsRemote.switchToggleRemote('Biomarkers', false);
        }
        Test.stopTest();

        contact = [
                SELECT Visit_Results_OptIn__c
                FROM Contact
                WHERE Id = :testData.participantUser.ContactId
        ];
        System.assertEquals('Labs', contact.Visit_Results_OptIn__c);
    }
}
