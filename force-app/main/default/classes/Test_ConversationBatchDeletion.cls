@IsTest
public class Test_ConversationBatchDeletion {
    @TestSetup
    static void init(){
        TestData.loadTestData();
    }
    @IsTest
    static void testConversationBatchDel_False() {
        List<Participant_Enrollment__c> peRecs= [SELECT Id,Clinical_Trial_Profile__c FROM Participant_Enrollment__c limit 3];
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=peRecs[0].Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test booking');
        insert studClTest;
        List<Conversation__c> conLst= new List<Conversation__c>();
        for(Participant_Enrollment__c peRec:peRecs){
            Conversation__c conversation = new Conversation__c(Participant_Enrollment__c = peRec.Id);
            conLst.add(conversation);
        }
        insert conLst;
        Test.startTest();
		Database.executeBatch(new ConversationBatchDeletion(peRecs[0].Clinical_Trial_Profile__c,false),10);
        Test.stopTest();
        List<Conversation__c> conList=[SELECT Id from Conversation__c where Participant_Enrollment__c in:peRecs limit 5];
        System.assertEquals(3,conList.size());
    }
    @IsTest
    static void testConversationBatchDel_True() {
        List<Participant_Enrollment__c> peRecs= [SELECT Id,Clinical_Trial_Profile__c FROM Participant_Enrollment__c limit 3];
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=peRecs[0].Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test booking');
        insert studClTest;
        List<Conversation__c> conLst= new List<Conversation__c>();
        for(Participant_Enrollment__c peRec:peRecs){
            Conversation__c conversation = new Conversation__c(Participant_Enrollment__c = peRec.Id);
            conLst.add(conversation);
        }
        insert conLst;
        Test.startTest();
		Database.executeBatch(new ConversationBatchDeletion(peRecs[0].Clinical_Trial_Profile__c,true),10);
        Test.stopTest();
        List<Conversation__c> conList=[SELECT Id from Conversation__c where Participant_Enrollment__c in:peRecs limit 5];
        System.assertEquals(0,conList.size());
    }

}