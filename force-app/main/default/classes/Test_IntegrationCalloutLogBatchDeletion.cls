@IsTest
public class Test_IntegrationCalloutLogBatchDeletion {
@TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @IsTest
    static void testIntegrationCalloutLogBatchDel_false() {
        Test.startTest();
        Participant_Enrollment__c  enroll = [select Id,Study_Hub_Log__c,Clinical_Trial_Profile__c,Participant__c from Participant_Enrollment__c limit 1];
        Contact con = [select Id from Contact limit 1];
        Integration_Callout_Log__c icl =new Integration_Callout_Log__c (Reference_Id__c=enroll.id);
        insert icl;
        
        Participant__c participant = new Participant__c(id= enroll.Participant__c);
        participant.Contact__c = con.id;
        update participant;
        
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=enroll.Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test booking');
        insert studClTest;
        
        
        Database.executeBatch(new IntegrationCalloutLogBatchDeletion(enroll.Clinical_Trial_Profile__c,false),10);
        Test.stopTest();
        List<Integration_Callout_Log__c> iclList=[SELECT Id from Integration_Callout_Log__c where Reference_Id__c=:enroll.Id limit 10];
        System.assertEquals(1,iclList.size());
        
    }
    @IsTest
    static void testIntegrationCalloutLogBatchDel_True() {
        Test.startTest();
        Participant_Enrollment__c  enroll = [select Id,Study_Hub_Log__c,Clinical_Trial_Profile__c,Participant__c from Participant_Enrollment__c limit 1];
        Contact con = [select Id from Contact limit 1];
        Integration_Callout_Log__c icl =new Integration_Callout_Log__c (Reference_Id__c=enroll.id);
        insert icl;
        
        Participant__c participant = new Participant__c(id= enroll.Participant__c);
        participant.Contact__c = con.id;
        update participant;
        
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=enroll.Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test booking');
        insert studClTest;
        
        Database.executeBatch(new IntegrationCalloutLogBatchDeletion(enroll.Clinical_Trial_Profile__c,true),10);
        Test.stopTest();
        List<Integration_Callout_Log__c> iclList=[SELECT Id from Integration_Callout_Log__c where Reference_Id__c=:enroll.Id limit 10];
        System.assertEquals(1,iclList.size());
        
    }
    @IsTest
    static void testIntegrationCalloutLogBatchDel_OnlyPart() {
        Test.startTest();
        Participant_Enrollment__c  enroll = [select Id,Clinical_Trial_Profile__c,Participant__c from Participant_Enrollment__c limit 1];
        Contact con = [select Id from Contact limit 1];
        
        Participant__c participant = new Participant__c(id= enroll.Participant__c);
        participant.Contact__c = con.id;
        update participant;
        Integration_Callout_Log__c icl =new Integration_Callout_Log__c (Reference_Id__c=enroll.id);
        insert icl;
        
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=enroll.Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test booking',Only_Selected_Participants__c=true);
        insert studClTest;
        Participant_Closure__c partCls= new Participant_Closure__c(Name='REF00000',Study_Closure__c=studClTest.id);
        insert partCls;
        
        
        Database.executeBatch(new IntegrationCalloutLogBatchDeletion(enroll.Clinical_Trial_Profile__c,false),10);
        Test.stopTest();
        List<Integration_Callout_Log__c> iclList=[SELECT Id from Integration_Callout_Log__c where Reference_Id__c=:enroll.Id limit 10];
        System.assertEquals(1,iclList.size());

        
    }
}