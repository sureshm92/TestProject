@isTest
private class Batch_SiteStaff_Invited_UpdateTest {
	 @TestSetup
    static void init(){
        TestData.loadTestData();
    }
    
    @isTest
    static void Testing(){
        //TestData.loadTestData();
        TestData testData = new TestData();
        Test.startTest();
        Contact con = [
            SELECT Id, AccountId, MailingCountryCode, Participant_Opt_In_Status_SMS__c
            FROM Contact
            WHERE Id = :testData.participant.Contact__c
        ];
        //User u = [SELECT ContactId, Id, IsActive FROM User WHERE ContactId=:testData.participant.Contact__c];
        List<Site_Staff__c> SS = new List<Site_Staff__c>();
        for (Integer i = 0; i < 20; i++) {
            Site_Staff__c s = new Site_Staff__c(
                Email__c = 'sitestaff' + i + '@emil.com',
                Site_Contact__c = con.id,
                Delegate_Level__c = 'Level 1'
            );
            SS.add(s);
        }
        insert SS;
        
        Batch_SiteStaff_Invited_Update b = new Batch_SiteStaff_Invited_Update();
        Database.executeBatch(b);
        Test.stopTest();
    }
}