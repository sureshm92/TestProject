@IsTest
public class Test_SHntegrationLogDeletionBatch {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @IsTest
    static void testSHIntegrationBatchDel_false() {
        Test.startTest();
        Participant_Enrollment__c  enroll = [select Id,Study_Hub_Log__c,Clinical_Trial_Profile__c,Participant__c from Participant_Enrollment__c limit 1];
        Contact con = [select Id from Contact limit 1];
        Integration_Log__c sh =new Integration_Log__c (Request__c='test');
        insert sh;
        enroll.Study_Hub_Log__c=sh.id;
        update enroll;
        Participant__c participant = new Participant__c(id= enroll.Participant__c);
        participant.Contact__c = con.id;
        update participant;
        
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=enroll.Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test booking');
        insert studClTest;
        
        
        Database.executeBatch(new StudbyHubIntegrationLogDeletionBatch(enroll.Clinical_Trial_Profile__c,false),10);
        Test.stopTest();
        List<Participant_Enrollment__c> shList=[SELECT Id from Participant_Enrollment__c where Study_Hub_Log__c=:sh.Id limit 10];
        System.assertEquals(1,shList.size());
        
    }
    @IsTest
    static void testSHIntegrationBatchDel_True() {
        Test.startTest();
        Participant_Enrollment__c  enroll = [select Id,Study_Hub_Log__c,Clinical_Trial_Profile__c,Participant__c from Participant_Enrollment__c limit 1];
        Contact con = [select Id from Contact limit 1];
        Integration_Log__c sh =new Integration_Log__c (Request__c='test');
        insert sh;
        enroll.Study_Hub_Log__c=sh.id;
        update enroll;
        Participant__c participant = new Participant__c(id= enroll.Participant__c);
        participant.Contact__c = con.id;
        update participant;
        
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=enroll.Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test booking');
        insert studClTest;
        
        Database.executeBatch(new StudbyHubIntegrationLogDeletionBatch(enroll.Clinical_Trial_Profile__c,true),10);
        Test.stopTest();
        List<Participant_Enrollment__c> shList=[SELECT Id from Participant_Enrollment__c where Study_Hub_Log__c=:sh.Id limit 10];
        System.assertEquals(0,shList.size());
        
    }
    @IsTest
    static void testSHIntegrationBatchDel_OnlyPart() {
        Test.startTest();
        Participant_Enrollment__c  enroll = [select Id,Clinical_Trial_Profile__c,Participant__c from Participant_Enrollment__c limit 1];
        Contact con = [select Id from Contact limit 1];
        
        Participant__c participant = new Participant__c(id= enroll.Participant__c);
        participant.Contact__c = con.id;
        update participant;
        Integration_Log__c sh =new Integration_Log__c (Request__c='test');
        insert sh;
        enroll.Study_Hub_Log__c=sh.id;
        update enroll;
        
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=enroll.Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test booking',Only_Selected_Participants__c=true);
        insert studClTest;
        Participant_Closure__c partCls= new Participant_Closure__c(Name='REF00000',Study_Closure__c=studClTest.id);
        insert partCls;
        
        
        Database.executeBatch(new StudbyHubIntegrationLogDeletionBatch(enroll.Clinical_Trial_Profile__c,false),10);
        Test.stopTest();
        List<Participant_Enrollment__c> shList=[SELECT Id from Participant_Enrollment__c where Study_Hub_Log__c=:sh.Id limit 10];
        System.assertEquals(1,shList.size());

        
    }
}