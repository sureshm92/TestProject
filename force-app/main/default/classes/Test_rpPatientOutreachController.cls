@isTest
public class Test_rpPatientOutreachController {
    @TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @IsTest
    static void testDeactivateDeceasedUsers() {
        TestData testData = new TestData();
        string peId = testData.pe.Id;
        string studyId = [select Clinical_Trial_Profile__c from Participant_Enrollment__c where id =: peID].Clinical_Trial_Profile__c;
        rpPatientOutreachController.fetchOutreachInfo(new list<string>{peId});
        rpPatientOutreachController.getPatientInfo(peid);        
        Clinical_Trial_Profile__c studyCTP = new Clinical_Trial_Profile__c(id=studyId,Enable_RP_Outreach_Email__c= false);
        update studyCTP;
        Participant_Enrollment__c peUpd = new Participant_Enrollment__c(id=peId,Patient_ID__c =  null,Outreach_Email_Status__c='Delivered',Participant_Surname__c=null,Participant_Name__c=null);
        update peUpd;
        rpPatientOutreachController.peBulkValidate(new list<string>{peId});
        peUpd.Outreach_Email_Status__c ='Submitted';
        update peUpd;
        rpPatientOutreachController.peBulkValidate(new list<string>{peId});
    }
}