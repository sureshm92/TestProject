@IsTest
public class Test_PatientVisitDeletionBatch {
	@TestSetup
    static void init(){
        TestData.loadTestData();
    }
    @IsTest
    static void testPatientVisitDel_False() {
        List<Patient_Visit__c> visitPLst = new list<Patient_Visit__c> ();
        List<Participant_Enrollment__c> peRecs= [SELECT Id,Clinical_Trial_Profile__c FROM Participant_Enrollment__c limit 2];
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=peRecs[0].Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test booking');
        insert studClTest;
        for(Participant_Enrollment__c peRec:peRecs){
            Patient_Visit__c visit = new Patient_Visit__c();
            visit.Name = 'New Visit';
            visit.Completed_Date__c = Date.today();
            visit.Participant_Enrollment__c = peRec.Id;
            visit.SDH_Key__c = '1~2~3' + 'New Visit' + Date.today();
            visitPLst.add(visit);
        }
        insert visitPLst;
        Test.startTest();
		Database.executeBatch(new PatientVisitDeletionBatch(peRecs[0].Clinical_Trial_Profile__c,false),10);
        Test.stopTest();
        List<Patient_Visit__c> patVisitLst=[SELECT Id from Patient_Visit__c where Participant_Enrollment__c in:peRecs limit 10];
        System.assertEquals(2,patVisitLst.size());
    }
    @IsTest
    static void testPatientVisitDel_True() {
        List<Patient_Visit__c> visitPLst = new list<Patient_Visit__c> ();
        List<Participant_Enrollment__c> peRecs= [SELECT Id,Clinical_Trial_Profile__c FROM Participant_Enrollment__c limit 2];
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=peRecs[0].Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test booking');
        insert studClTest;
        for(Participant_Enrollment__c peRec:peRecs){
            Patient_Visit__c visit = new Patient_Visit__c();
            visit.Name = 'New Visit';
            visit.Completed_Date__c = Date.today();
            visit.Participant_Enrollment__c = peRec.Id;
            visit.SDH_Key__c = '1~2~3' + 'New Visit' + Date.today();
            visitPLst.add(visit);
        }
        insert visitPLst;
        Test.startTest();
		Database.executeBatch(new PatientVisitDeletionBatch(peRecs[0].Clinical_Trial_Profile__c,true),10);
        Test.stopTest();
        List<Patient_Visit__c> patVisitLst=[SELECT Id from Patient_Visit__c where Participant_Enrollment__c in:peRecs limit 10];
        System.assertEquals(0,patVisitLst.size());
    }
}