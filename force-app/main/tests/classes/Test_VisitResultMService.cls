/**
 * Created by dmytro.fedchyshyn on 01.08.2019.
 */
@IsTest
public with sharing class Test_VisitResultMService {

    private static VisitResultMService service = new VisitResultMService();

    @IsTest
    static void getVisitResultGroups_test() {
        Test.startTest();
        List<Visit_Result_GroupM__mdt> testVisitResultGroupMS = service.getVisitResultGroups(true, 'Vitals');
        List<Visit_Result_GroupM__mdt> testVisitResultGroupMSWithTypesFalse = service.getVisitResultGroups(false, 'Vitals');
        Test.stopTest();

        System.assert(testVisitResultGroupMS.size() >= 1);
        System.assert(testVisitResultGroupMSWithTypesFalse.size() >= 1);
    }

    @IsTest
    static void getVisitResultTypes_test() {
        Test.startTest();
        List<Visit_Result_TypeM__mdt> testVisitResultTypeMS = service.getVisitResultTypes('Vitals');
        Test.stopTest();

        System.assert(testVisitResultTypeMS.size() > 5);
    }

    @IsTest
    static void getVisitResultTypeDashboardConfigs_test() {
        Test.startTest();
        List<Visit_Result_TypeM_Dashboard_Config__mdt> testVisitResultTypeMDashboardConfigs = service.getVisitResultTypeDashboardConfigs();
        Test.stopTest();

        System.assert(testVisitResultTypeMDashboardConfigs.size() > 3);
    }

    @IsTest
    static void getVisitResultGroupNames_test() {
        Test.startTest();
        List<String> testNames = service.getVisitResultGroupNames('Vitals');
        Test.stopTest();

        System.assert(testNames.size() >= 1);
    }
}