@IsTest
public with sharing class Test_VisitConfigurationRemote {

    @TestSetup
    public static void setup() {
        Visit_Plan__c visitPlan = new Visit_Plan__c(Name = 'Test 0');
        insert visitPlan;
        Visit_Plan__c visitPlan2 = new Visit_Plan__c(Name = 'Test 1');
        insert visitPlan2;
        Clinical_Trial_Profile__c singleCTP = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType());
        singleCTP.Visit_Plan__c = visitPlan.Id;
        Visit__c visit1 = new Visit__c(Name = 'Test1', Visit_Plan__c = visitPlan.Id);
        Visit__c visit2 = new Visit__c(Name = 'Test2', Visit_Plan__c = visitPlan.Id);
        insert new List<SObject>{
                singleCTP,
                visit1,
                visit2
        };
    }

    @IsTest
    public static void getRelatedPlannedVisitsWithVisit_test() {

        List<Clinical_Trial_Profile__c> ctp = [SELECT Id, Visit_Plan__c FROM Clinical_Trial_Profile__c];
        List<Visit__c> visits2 = [SELECT Id, Visit_Plan__c FROM Visit__c];
        System.assertEquals(1, ctp.size());

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
    public static void getRelatedPlannedVisitsWithoutVisit_test() {
        TriggerHandlerExecutor.bypassHandler(ClinicalTrialProfileTriggerHandler.class);

        List<Clinical_Trial_Profile__c> ctp = [SELECT Id, Visit_Plan__c FROM Clinical_Trial_Profile__c];
        ctp[0].Visit_Plan__c = null;
        update ctp[0];
        System.assertEquals(1, ctp.size());

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
    public static void deleteVisit_test() {

        List<Visit__c> visits = [SELECT Id, Visit_Plan__c FROM Visit__c];

        Test.startTest();
        VisitConfigurationRemote.deleteVisit(visits[0].Id);
        visits = [SELECT Id, Visit_Plan__c FROM Visit__c];
        Test.stopTest();

        System.assertEquals(1, visits.size());
    }

    @IsTest
    public static void updateCtp_test() {
        TriggerHandlerExecutor.bypassHandler(ClinicalTrialProfileTriggerHandler.class);

        List<Clinical_Trial_Profile__c> ctp = [SELECT Id, Visit_Plan__c FROM Clinical_Trial_Profile__c];
        List<Visit_Plan__c> visitPlans = [SELECT Id FROM Visit_Plan__c WHERE Name = 'Test 1'];
        System.debug(visitPlans);
        System.debug(ctp);

        Test.startTest();
        List<Visit__c> visits = VisitConfigurationRemote.updateCtp(visitPlans[0].Id, ctp[0].Id);
        Test.stopTest();

        List<Clinical_Trial_Profile__c> newCTP = [SELECT Id, Visit_Plan__c FROM Clinical_Trial_Profile__c];
        System.assertEquals(visitPlans[0].Id, newCTP[0].Visit_Plan__c);
    }

    @IsTest
    public static void getRelatedPlannedVisitsWithNullCTP_test() {

        List<Clinical_Trial_Profile__c> ctp = null;
        List<Visit__c> visits2 = [SELECT Id, Visit_Plan__c FROM Visit__c];

        ClassFactory.clearStubTypesByClassNamesMap();

        ClassFactory.putStubTypeByClassName(VisitConfigurationRemote.class, StubFactory.newInstance(VisitConfigurationRemote.class)
                .when('getVisitsByCtpId')
                .then(new AuraHandledException('Test Exception'))
                .getInstance()
        );

        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            VisitConfigurationRemote.getRelatedPlannedVisits(ctp[0].Id);
        } catch (Exception e) {
            isExceptionThrown = true;
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }

    @IsTest
    public static void deleteVisitsWithNullCTP_test() {

        List<Clinical_Trial_Profile__c> ctp = null;
//        List<Visit__c> visits2 = [SELECT Id, Visit_Plan__c FROM Visit__c];

        ClassFactory.clearStubTypesByClassNamesMap();

        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            VisitConfigurationRemote.deleteVisit(ctp[1].Id);
        } catch (Exception e) {
            isExceptionThrown = true;
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }
}