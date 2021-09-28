@isTest
public class Test_Batch_UpdateVisitPlanCreatePVisits {
    @isTest
    private static void getLatestBatchStatusForStudySite_gettrue(){
        TestData.loadTestData();
        TestData testData = new TestData();
        Visit_Plan__c visitPlan = new Visit_Plan__c(Name = 'Test_StudySiteVisitConfigRemote VP');
        insert visitPlan;
        Boolean present = false;
        Id peId;
        Test.startTest();
        List<Participant_Enrollment__c> peList = [SELECT Id,Study_Site__c,Clinical_Trial_Profile__c,
                                                  Participant_Status__c FROM Participant_Enrollment__c];
        if(!peList.isEmpty()){
            Participant_Enrollment__c pe = new Participant_Enrollment__c();
            //pesh.Date__c = DateTime.now();
            pe.Id = peList[0].Id;
            pe.Participant_Status__c = 'Enrollment Success';
            update pe;
            peId = pe.Id;
            Study_Site__c ss = new Study_Site__c();
            ss.Id = peList[0].Study_Site__c;
            ss.Is_Patient_Visit_Batch_Running__c = true;
            update ss;
            Map<String,Object> studySiteVisitPlan = new Map<String,Object>();
            studySiteVisitPlan.put(String.valueOf(ss.Id),visitPlan.Id);
            StudySiteVisitConfigRemote.updatePEsAndStartBatch(studySiteVisitPlan,peList[0].Clinical_Trial_Profile__c);
        }

        Test.stopTest();
        Participant_Enrollment__c res = [SELECT Id,Study_Site__c,Visit_Plan__c,Clinical_Trial_Profile__c,
                                         Participant_Status__c FROM Participant_Enrollment__c WHERE Id =:peId];
        system.assertEquals(visitPlan.Id, res.Visit_Plan__c);
    }

}