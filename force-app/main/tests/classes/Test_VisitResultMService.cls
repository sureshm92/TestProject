/**
 * Created by dmytro.fedchyshyn on 01.08.2019.
 */
@IsTest
public with sharing class Test_VisitResultMService {

    private static VisitResultMService service = new VisitResultMService();

    @IsTest
    static void getVisitResultGroups_test() {
        List<Visit_Result_GroupM__mdt> visitResultGroupMS = new List<Visit_Result_GroupM__mdt>{
                new Visit_Result_GroupM__mdt(),
                new Visit_Result_GroupM__mdt()
        };

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(DatabaseProxy.class, StubFactory.newInstance(DatabaseProxy.class)
                .when('query')
                .then(visitResultGroupMS)
                .getInstance()
        );

        Test.startTest();
        List<Visit_Result_GroupM__mdt> testVisitResultGroupMS = service.getVisitResultGroups(true, 'Vitals');
        Test.stopTest();

        System.assertEquals(2, testVisitResultGroupMS.size());
    }

    @IsTest
    static void getVisitResultTypes_test() {
        List<Visit_Result_TypeM__mdt> visitResultTypeMS = new List<Visit_Result_TypeM__mdt>{
                new Visit_Result_TypeM__mdt(),
                new Visit_Result_TypeM__mdt()
        };

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(DatabaseProxy.class, StubFactory.newInstance(DatabaseProxy.class)
                .when('query')
                .then(visitResultTypeMS)
                .getInstance()
        );

        Test.startTest();
        List<Visit_Result_TypeM__mdt> testVisitResultTypeMS = service.getVisitResultTypes('Vitals');
        Test.stopTest();

        System.assertEquals(2, testVisitResultTypeMS.size());
    }

    @IsTest
    static void getVisitResultTypeDashboardConfigs_test() {
        List<Visit_Result_TypeM_Dashboard_Config__mdt> visitResultTypeMDashboardConfigs = new List<Visit_Result_TypeM_Dashboard_Config__mdt>{
                new Visit_Result_TypeM_Dashboard_Config__mdt(),
                new Visit_Result_TypeM_Dashboard_Config__mdt()
        };

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(DatabaseProxy.class, StubFactory.newInstance(DatabaseProxy.class)
                .when('query')
                .then(visitResultTypeMDashboardConfigs)
                .getInstance()
        );

        Test.startTest();
        List<Visit_Result_TypeM_Dashboard_Config__mdt> testVisitResultTypeMDashboardConfigs = service.getVisitResultTypeDashboardConfigs();
        Test.stopTest();

        System.assertEquals(2, testVisitResultTypeMDashboardConfigs.size());

    }

    @IsTest
    static void getVisitResultGroupNames_test() {
        List<Visit_Result_GroupM__mdt> names = new List<Visit_Result_GroupM__mdt>{
                new Visit_Result_GroupM__mdt(),
                new Visit_Result_GroupM__mdt()
        };

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(DatabaseProxy.class, StubFactory.newInstance(DatabaseProxy.class)
                .when('query')
                .then(names)
                .getInstance()
        );

        Test.startTest();
        List<String> testNames = service.getVisitResultGroupNames('test');
        Test.stopTest();

        System.assertEquals(2, testNames.size());

    }
}