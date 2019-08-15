/**
 * Created by dmytro.fedchyshyn on 26.07.2019.
 */
@IsTest(IsParallel=true)
public with sharing class Test_IconPlanetVisitInfoEditRemote {

    @IsTest
    static void saveIconInfoWithVisitPlan_test(){
        List<Clinical_Trial_Profile__c> ctp = new List<Clinical_Trial_Profile__c>{
                (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType())};

        List<Icon_Details__c> iconDetails = new List<Icon_Details__c>{
                new Icon_Details__c(),
                new Icon_Details__c()};

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(CTPSelector.class, StubBuilder.newInstance(CTPSelector.class)
                .when('getCtpById')
                .then(ctp)
                .build()
       );

        ClassFactory.putStubTypeByClassName(DatabaseProxy.class, StubBuilder.newInstance(DatabaseProxy.class)
                .when('upsertRecords')
                .then(null)
                .build()
       );

        Test.startTest();
        IconPlanetVisitInfoEditRemote.saveIconInfo(iconDetails, null);
        Test.stopTest();
    }

    @IsTest
    static void saveIconInfoWithException_test(){
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(CTPSelector.class, StubBuilder.newInstance(CTPSelector.class)
                .when('getIconDetailsByVisitPlanInCTP')
                .then(new AuraHandledException('Something wrong'))
                .build()
       );
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            IconPlanetVisitInfoEditRemote.saveIconInfo(null, null);
        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }

    @IsTest
    static void getIconDetailsWithCtpId_test(){
        List<Icon_Details__c> iconDetails = new List<Icon_Details__c>{
                new Icon_Details__c(),
                new Icon_Details__c()};

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(CTPSelector.class, StubBuilder.newInstance(CTPSelector.class)
                .when('getIconDetailsByVisitPlanInCTP')
                .then(iconDetails)
                .build()
       );

        Test.startTest();
        List<Icon_Details__c> iconDetailsTest = IconPlanetVisitInfoEditRemote.getIconDetails(
                TestDataFactory.getFakeId(Clinical_Trial_Profile__c.getSObjectType()) );
        Test.stopTest();

        System.assertEquals(2, iconDetailsTest.size());
    }

    @IsTest
    static void getIconDetailsWithoutExistingIconDetails_test(){
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(CTPSelector.class, StubBuilder.newInstance(CTPSelector.class)
                .when('getIconDetailsByVisitPlanInCTP')
                .then(null)
                .build()
       );

        Test.startTest();
        List<Icon_Details__c> iconDetailsTest = IconPlanetVisitInfoEditRemote.getIconDetails(
                TestDataFactory.getFakeId(Clinical_Trial_Profile__c.getSObjectType()));
        Test.stopTest();

        System.assert(iconDetailsTest == null);
    }

    @IsTest
    static void getIconDetailsWithException_test(){
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(CTPSelector.class, StubBuilder.newInstance(CTPSelector.class)
                .when('getIconDetailsByVisitPlanInCTP')
                .then(new AuraHandledException('error'))
                .build()
       );
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            IconPlanetVisitInfoEditRemote.getIconDetails( null);
        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }
}