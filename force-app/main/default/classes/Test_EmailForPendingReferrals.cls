@isTest
public class Test_EmailForPendingReferrals {
    
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        TestData.createTCAcceptance();
        Test.stopTest();
    }
    @isTest
    private static void Test_sendMails(){
        
        TestData testData = new TestData();
        Batch_Notification__c notification = new Batch_Notification__c();
        
        notification.Recipient_Ids__c = [SELECT Id,ContactId FROM User WHERE Id =:testData.piUser.Id][0].ContactId;
        notification.Time_Zone_Date__c = DateTime.now();
        insert notification;
        EmailForPendingReferrals.sendMails(new List<Batch_Notification__c>{notification});
        
    }
}