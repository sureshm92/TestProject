@IsTest(IsParallel=true)
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
        ClassFactory.putStubTypeByClassName(CTPSelector.class, StubBuilder.newInstance(CTPSelector.class)
                .when('getCtpById')
                .then(ctp)
                .when('getVisitsByCtpId')
                .then(visits2)
                .build()
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
        ClassFactory.putStubTypeByClassName(CTPSelector.class, StubBuilder.newInstance(CTPSelector.class)
                .when('getCtpById')
                .then(ctp)
                .build()
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
        ClassFactory.putStubTypeByClassName(DatabaseProxy.class, StubBuilder.newInstance(DatabaseProxy.class)
                .when('updateRecord')
                .then(null)
                .build()
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

        ClassFactory.putStubTypeByClassName(DatabaseProxy.class, StubBuilder.newInstance(DatabaseProxy.class)
                .when('deleteRecord')
                .then(null)
                .build()
       );
        Test.startTest();
        VisitConfigurationRemote.deleteVisit(null);
        Test.stopTest();
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