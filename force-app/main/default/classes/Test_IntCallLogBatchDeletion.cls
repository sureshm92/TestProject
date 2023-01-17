@IsTest
public class Test_IntCallLogBatchDeletion {
  @TestSetup
    static void init(){
        TestData.loadTestData();
    }
    @IsTest
    static void testPatientVisitDel_False() {
        List<Integration_Callout_Log__c> intLogLst = new list<Integration_Callout_Log__c> ();
        List<Participant_Enrollment__c> peRecs= [SELECT Id,Clinical_Trial_Profile__c,Name FROM Participant_Enrollment__c limit 2];
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=peRecs[0].Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test booking');
        insert studClTest;
        for(Participant_Enrollment__c peRec:peRecs){
            Integration_Callout_Log__c lg= new Integration_Callout_Log__c();
            lg.Name = 'New Visit';
            lg.Reference_Id__c = peRec.Name;
            intLogLst.add(lg);
        }
        insert intLogLst ;
        Test.startTest();
    Database.executeBatch(new IntegrationCalloutLogBatchDeletion(peRecs[0].Clinical_Trial_Profile__c,false),10);
        Test.stopTest();
        List<String> refId = new List<String>();
        for(Participant_Enrollment__c pe:peRecs){
          refId.add(pe.Name);
        }
        List<Integration_Callout_Log__c> intLogsLst=[SELECT Id,Reference_Id__c from Integration_Callout_Log__c where Reference_Id__c in:refId limit 10];
        System.assertEquals(2,intLogsLst.size());
    }
    @IsTest
    static void testPatientVisitDel_True() {
        List<Integration_Callout_Log__c> intLogLst = new list<Integration_Callout_Log__c> ();
        List<Participant_Enrollment__c> peRecs= [SELECT Id,Clinical_Trial_Profile__c,Name FROM Participant_Enrollment__c limit 2];
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=peRecs[0].Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test booking');
        insert studClTest;
        for(Participant_Enrollment__c peRec:peRecs){
            Integration_Callout_Log__c lg= new Integration_Callout_Log__c();
            lg.Name = 'New Visit';
            lg.Reference_Id__c = peRec.Name;
            intLogLst.add(lg);
        }
        insert intLogLst ;
        Test.startTest();
    Database.executeBatch(new IntegrationCalloutLogBatchDeletion(peRecs[0].Clinical_Trial_Profile__c,true),10);
        Test.stopTest();
        List<String> refId = new List<String>();
        for(Participant_Enrollment__c pe:peRecs){
          refId.add(pe.Name);
        }
        List<Integration_Callout_Log__c> intLogsLst=[SELECT Id,Reference_Id__c from Integration_Callout_Log__c where Reference_Id__c in:refId limit 10];
        System.assertEquals(0,intLogsLst.size());
    }

}