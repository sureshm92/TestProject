@IsTest
public class Test_TrialNotificationBatchDeletion {
	@TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @IsTest
    static void testTrialNotificationBatchDel() {
        Test.startTest();
        Clinical_Trial_Profile__c  ctpRec = [select Id from Clinical_Trial_Profile__c limit 1];
        Contact con = [select Id from Contact limit 1];
        List<Trial_Notification__c> tNoteLst= new List<Trial_Notification__c>();
        for(Integer i=0;i<10;i++){
            Trial_Notification__c tNote= new Trial_Notification__c();
            tNote.Clinical_Trial_Profile__c=ctpRec.Id;
            tNote.CTP_Name__c='Test'+i;
            tNote.Contact__c=con.Id;
            tNoteLst.add(tNote);
        }
        insert tNoteLst;
        Database.executeBatch(new TrialNotificationBatchDeletion(ctpRec.Id),10);
        Test.stopTest();
        List<Trial_Notification__c> tNoteList=[SELECT Id from Trial_Notification__c where Clinical_Trial_Profile__c=:ctpRec.Id limit 10];
        System.assertEquals(0,tNoteList.size());
        
    }
}