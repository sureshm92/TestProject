@isTest
public class Test_StudySiteItemRemote {
    @isTest
    private static void totalPEs_getRec(){
        TestData.loadTestData();
        Test.startTest();

        TestData testData = new TestData();
        Visit_Plan__c visitPlan = new Visit_Plan__c(Name = 'Test_StudySiteVisitConfigRemote VP');
        insert visitPlan;
        StudySiteItemRemote.CountAndProgram cAndL = new StudySiteItemRemote.CountAndProgram();
        cAndL.count =0;
        List<Participant_Enrollment__c> peList = [SELECT Id,Study_Site__c,Clinical_Trial_Profile__c,
                                                  Participant_Status__c FROM Participant_Enrollment__c];
        if(!peList.isEmpty()){
            Participant_Enrollment__c pe = new Participant_Enrollment__c();
            //pesh.Date__c = DateTime.now();
            pe.Id = peList[0].Id;
            pe.Participant_Status__c = 'Enrollment Success';
            update pe;
	        cAndL =StudySiteItemRemote.totalPEs(peList[0].Study_Site__c, peList[0].Clinical_Trial_Profile__c);
            
        }

        Test.stopTest();
        system.assertEquals(1, cAndL.count);
    }
    @isTest
    private static void getLatestBatchStatusForStudySite_gettrue(){
        TestData.loadTestData();
        Test.startTest();

        TestData testData = new TestData();
        Visit_Plan__c visitPlan = new Visit_Plan__c(Name = 'Test_StudySiteVisitConfigRemote VP');
        insert visitPlan;
        Boolean present = false;
        List<Participant_Enrollment__c> peList = [SELECT Id,Study_Site__c,Clinical_Trial_Profile__c,
                                                  Participant_Status__c FROM Participant_Enrollment__c];
        if(!peList.isEmpty()){
            Participant_Enrollment__c pe = new Participant_Enrollment__c();
            //pesh.Date__c = DateTime.now();
            pe.Id = peList[0].Id;
            pe.Participant_Status__c = 'Enrollment Success';
            update pe;
            Study_Site__c ss = new Study_Site__c();
            ss.Id = peList[0].Study_Site__c;
            ss.Is_Patient_Visit_Batch_Running__c = true;
            update ss;
            present =StudySiteItemRemote.getLatestBatchStatusForStudySite(peList[0].Study_Site__c);
            
        }

        Test.stopTest();
        system.assertEquals(true, present);
    }
}