@IsTest
public class Test_MediaOutreachBatchDeletion {
	@TestSetup
    static void init(){
        TestData.loadTestData();
    }
    @IsTest
    static void testMediaOutreachBatchDeletion() {                
        List<Study_Site__c> testStudySites = [SELECT Id,Clinical_Trial_Profile__c,Site__c FROM Study_Site__c Limit 1];        
        List<Media_Outreach__c> medOutReLst =new  List<Media_Outreach__c>();
        for(integer i =0; i<=20;i++){
            String mailTest='nksTest'+i+'@gmail.com';
            Media_Outreach__c mediaOut = new Media_Outreach__c(
            Study_Name__c = testStudySites[0].Id,
            Study_Site__c = testStudySites[0].Site__c,
            Media_Type__c = 'Radio;Television;Social Media;',
            Preferred_contact_method__c = 'test@gmail.com',
            Status__c = 'Requested',
            Requested_Start_Date__c = Date.parse('5/22/2020'),
            Requested_End_Date__c = Date.parse('5/29/2020'),
            Alternate_Email_Phone_Number__c = mailTest
            );
            medOutReLst.add(mediaOut);
        }
        insert medOutReLst;
        Test.startTest();
		Database.executeBatch(new MediaOutreachBatchDeletion(testStudySites[0].Clinical_Trial_Profile__c),100);
        Test.stopTest();
        List<Media_Outreach__c> mediaOutLst=[Select Id,Name FROM Media_Outreach__c where Study_Name__c in:[select id from Study_Site__c where Clinical_Trial_Profile__c=:testStudySites[0].Clinical_Trial_Profile__c]];
        System.assertEquals(0,mediaOutLst.size());
    }
}