@IsTest()
public class Test_BatchFollowUpReminder {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @isTest()
    static void testFollowUpReminder() {
        TestData testData = new TestData();
        List<Contact> con = [Select Id,Is_First_Logon__c,Is_FollowUp_Sent__c,Visited_Communities__c from contact where Id =:testData.participantUser.ContactId];
        system.debug('con-->'+con);
        con[0].Is_First_Logon__c = TRUE;
        con[0].Is_FollowUp_Sent__c = FALSE;
        con[0].Visited_Communities__c = NULL;
        update con;
        System.runAs(new User(Id = UserInfo.getUserID())){
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Community_Default'];
            PermissionSetAssignment permAs = new PermissionSetAssignment(AssigneeId = testData.participantUser.Id, PermissionSetId = ps.Id);
            insert permAs;
            system.debug('permAs'+permAs);
        }
        List<PermissionSetAssignment> psaa = [SELECT AssigneeId,PermissionSet.Name,Assignee.Contact.Is_First_Logon__c,Assignee.Contact.Is_FollowUp_Sent__c 
                                              FROM PermissionSetAssignment WHERE 
                                              AssigneeId = :testData.participantUser.Id
                                             ];
        system.debug('psaa'+psaa);
        Batch_FollowUpReminder cb = New Batch_FollowUpReminder();
        Test.startTest();
        // System.runAs(testData.participantUser) {
        //Database.executeBatch(new Batch_FollowUpReminder());
        //}
        Database.QueryLocator ql = cb.start(null);
        cb.execute(null,psaa);
        cb.Finish(null);
        cb.getBatchDescription();
        cb.getRecommendedIntervalMode();
        cb.getRecommendedRelaunchInterval();


        Test.stopTest();
    }
    
    
}