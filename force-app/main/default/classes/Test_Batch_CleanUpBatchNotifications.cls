@isTest
public class Test_Batch_CleanUpBatchNotifications {
    @isTest
    private static void Notification_Available_TwentyDaysOld_Deleted(){
        Batch_Notification__c bn = new Batch_Notification__c();
        insert bn;
        Test.setCreatedDate(bn.Id, DateTime.now().addDays(-20));  
        Test.startTest();
        DataBase.executeBatch(new Batch_CleanUpBatchNotifications());
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM Batch_Notification__c].size());
    }
}