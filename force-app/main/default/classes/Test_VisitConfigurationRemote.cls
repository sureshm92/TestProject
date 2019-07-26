@IsTest
public with sharing class Test_VisitConfigurationRemote {

    @IsTest
    static void getRelatedPlannedVisitsWithVisit_test() {
        List<Clinical_Trial_Profile__c> ctp = new List<Clinical_Trial_Profile__c>{
                (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType(),
                        new Map<String, Object>{
                                'Visit_Plan__c' => TestDataFactory.getFakeId(Visit_Plan__c.getSObjectType())})};

        List<Visit__c> visits2 = new List<Visit__c>{
                new Visit__c(Name = 'Test1'),
                new Visit__c(Name = 'Test2')
        };

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(CTPSelector.class, StubFactory.newInstance(CTPSelector.class)
                .when('getCtpById')
                .then(ctp)
                .when('getVisitsByCtpId')
                .then(visits2)
                .getInstance()
        );

        Test.startTest();
        List<Visit__c> visits = VisitConfigurationRemote.getRelatedPlannedVisits(ctp[0].Id);
        Test.stopTest();

        System.assertEquals(2, visits.size());
    }

    @IsTest
    static void getRelatedPlannedVisitsWithoutVisit_test() {
        List<Clinical_Trial_Profile__c> ctp = new List<Clinical_Trial_Profile__c>{
                (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType())
        };

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(CTPSelector.class, StubFactory.newInstance(CTPSelector.class)
                .when('getCtpById')
                .then(ctp)
                .getInstance()
        );

        Test.startTest();
        List<Visit__c> visits = VisitConfigurationRemote.getRelatedPlannedVisits(ctp[0].Id);
        Test.stopTest();

        System.assertEquals(0, visits.size());
    }

    @IsTest
    static void getRelatedPlannedVisitsWithException_test() {
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            VisitConfigurationRemote.getRelatedPlannedVisits(null);
        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }

    @IsTest
    static void updateCtp_test() {
        TriggerHandlerExecutor.bypassHandler(ClinicalTrialProfileTriggerHandler.class);

        List<Clinical_Trial_Profile__c> ctp = new List<Clinical_Trial_Profile__c>{
                (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType())
        };

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(DatabaseProxy.class, StubFactory.newInstance(DatabaseProxy.class)
                .when('updateRecord')
                .then(null)
                .getInstance()
        );

        Test.startTest();
        VisitConfigurationRemote.updateCtp(ctp[0].Visit_Plan__c, ctp[0].Id);
        Test.stopTest();
    }

    @IsTest
    static void updateCtpWithException_test() {
        TriggerHandlerExecutor.bypassHandler(ClinicalTrialProfileTriggerHandler.class);

        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            VisitConfigurationRemote.updateCtp(null, null);
        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }

    @IsTest
    static void deleteVisit_test() {
        Visit_Plan__c visitPlan = new Visit_Plan__c(Name = 'Test');
        insert visitPlan;

        List<Visit__c> visits = new List<Visit__c>{
                new Visit__c(Name = 'Test1', Visit_Plan__c = visitPlan.Id),
                new Visit__c(Name = 'Test2', Visit_Plan__c = visitPlan.Id)
        };
        insert visits;

        Test.startTest();
        VisitConfigurationRemote.deleteVisit(visits[0].Id);
        visits = [SELECT Id FROM Visit__c];
        Test.stopTest();

        System.assertEquals(1, visits.size());
    }

    @IsTest
    static void deleteVisitWithException_test() {
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            VisitConfigurationRemote.deleteVisit(null);
        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }
}