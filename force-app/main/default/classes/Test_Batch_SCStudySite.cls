@IsTest
public class Test_Batch_SCStudySite {
    @TestSetup
    static void init(){
        TestData.loadTestData();        
    }
    @isTest static void studySiteReview_Test() {
    
        Id ctpId=[SELECT Id FROM Clinical_Trial_Profile__c LIMIT 1].Id;
        Study_Closure__c stClosure= new Study_Closure__c(
            Clinical_Trial_Profile_Id__c=ctpId, Clinical_Trial_Profile_Name__c='Test'
        );
        insert stClosure;
        
        Test.startTest();
            Batch_SCStudySite studySite = new Batch_SCStudySite();
            studySite.studyClosureId=ctpId;
            Database.executeBatch(studySite);
        Test.stopTest();
    }
    @isTest static void studySiteDelete_Test() {
    
        Id ctpId=[SELECT Id FROM Clinical_Trial_Profile__c LIMIT 1].Id;
        Study_Closure__c stClosure= new Study_Closure__c(
            Clinical_Trial_Profile_Id__c=ctpId,Clinical_Trial_Profile_Name__c='Test'
        );
        insert stClosure;
        
        Batch_SCParticipantEnrollment pEnroll = new Batch_SCParticipantEnrollment();
        pEnroll.studyClosureId=ctpId;
        pEnroll.isStudyToDelete=true;
        Database.executeBatch(pEnroll);
        
        Database.executeBatch(new HCPEnrollmentBatchDeletion(ctpId, true));
        
        Test.startTest();
            Batch_SCStudySite studySite = new Batch_SCStudySite();
            studySite.studyClosureId=ctpId;
            studySite.isStudyToDelete=true;
            Database.executeBatch(studySite);
        Test.stopTest();
    }
}