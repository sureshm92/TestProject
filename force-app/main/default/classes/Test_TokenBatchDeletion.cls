@IsTest
public class Test_TokenBatchDeletion {
	@TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @IsTest
    static void testTokenBatchDel_false() {
        Test.startTest();
        Participant_Enrollment__c  enroll = [select Id,Clinical_Trial_Profile__c from Participant_Enrollment__c limit 1];
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=enroll.Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test booking');
        insert studClTest;
        List<Token__c> tokenLst= new List<Token__c>();
        for(integer i =0; i<10;i++){
            Token__c token = new Token__c(Participant_Enrollment__c = enroll.Id ,Token_Type__c = 'session' , Token_Value__c = 'token'+i , Expiration_Date__c = System.now().addSeconds(Integer.valueOf(8600)));
        	tokenLst.add(token);
        }
        insert tokenLst;
        Database.executeBatch(new TokenBatchDeletion(enroll.Clinical_Trial_Profile__c,false),10);
        Test.stopTest();
        List<Token__c> tokList=[SELECT Id from Token__c where Participant_Enrollment__c=:enroll.Id limit 10];
        System.assertEquals(10,tokList.size());
    }
    @IsTest
    static void testTokenBatchDel_True() {
        Test.startTest();
        Participant_Enrollment__c  enroll = [select Id,Clinical_Trial_Profile__c from Participant_Enrollment__c limit 1];
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=enroll.Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test booking');
        insert studClTest;
        List<Token__c> tokenLst= new List<Token__c>();
        for(integer i =0; i<10;i++){
            Token__c token = new Token__c(Participant_Enrollment__c = enroll.Id ,Token_Type__c = 'session' , Token_Value__c = 'token'+i , Expiration_Date__c = System.now().addSeconds(Integer.valueOf(8600)));
        	tokenLst.add(token);
        }
        insert tokenLst;
        Database.executeBatch(new TokenBatchDeletion(enroll.Clinical_Trial_Profile__c,true),10);
        Test.stopTest();
        List<Token__c> tokList=[SELECT Id from Token__c where Participant_Enrollment__c=:enroll.Id limit 10];
        System.assertEquals(0,tokList.size());
    }
}