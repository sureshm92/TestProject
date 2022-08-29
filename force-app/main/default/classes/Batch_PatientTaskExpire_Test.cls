/**
 * Created by Gaurav Saxena
 */
@isTest
public class Batch_PatientTaskExpire_Test {
    private static Action action;

    @testSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
        Contact con = [SELECT Id FROM Contact WHERE firstname = 'PITD' LIMIT 1];

        Task t = new Task();
        t.WhoId = con.id;
        t.status = 'TASK_STATUS_OPEN';
        t.Activity_Datetime__c = system.now();
        insert t;
    }

    static testMethod void Test_1() {
        Test.startTest();
        List<Task> tasks = [
            SELECT
                Id,
                Status,
                Activity_Datetime__c,
                Survey_Invitation__c,
                Survey_Invitation__r.Is_Expired__c
            FROM Task
        ];

        Batch_PatientTaskExpire obj = new Batch_PatientTaskExpire();
        Database.QueryLocator QL;
        Database.BatchableContext BC;
        QL = obj.start(BC);

        obj.execute(BC, tasks);
        obj.finish(BC);
        DataBase.executeBatch(obj);
        obj.getBatchDescription();
        obj.getRecommendedIntervalMode();
        obj.getRecommendedRelaunchInterval();
        Test.stopTest();
    }
}
