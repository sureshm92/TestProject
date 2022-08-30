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
    private static void Test_sendMails() {
        TestData testData = new TestData();
        Batch_Notification__c notification = new Batch_Notification__c();

        notification.Recipient_Ids__c = [
            SELECT Id, ContactId
            FROM User
            WHERE Id = :testData.piUser.Id
        ][0]
        .ContactId;
        notification.Time_Zone_Date__c = DateTime.now();
        insert notification;
        
        Site_Staff__c siteStaffs = new Site_Staff__c();
        siteStaffs.Delegate_Level__c ='Level 1';
        siteStaffs.is_Invited__c =true;
        siteStaffs.Site_Contact__c =testData.piContact.id;
        insert siteStaffs;
        
        Study_Site__c ss= [select id from Study_Site__c limit 1];
        
        HCP_Enrollment__c hcp = new HCP_Enrollment__c();
        hcp.HCP_Contact__c  =testData.piContact.id;
        hcp.Study_Site__c = ss.Id;
        hcp.Status__c = HCPEnrollmentService.HCP_S_INVITATION_SENT;
        insert hcp;
        
        EmailForPendingReferrals.sendMails(new List<Batch_Notification__c>{ notification });
    }
}