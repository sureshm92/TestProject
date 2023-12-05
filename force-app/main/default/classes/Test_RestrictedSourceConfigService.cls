@IsTest
public class Test_RestrictedSourceConfigService {
    @TestSetup
    Public static void setData(){
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
        
    }
    @IsTest
    static void testConsentPreferences() {
        TestData testDataInstance = new TestData();
        
        List<Id> storeConIds=new List<Id>();
        storeConIds.add(testDataInstance.pe.Participant_Contact__c);
        
        Clinical_Trial_Profile__c study= testDataInstance.ctp;
        study.IQVIA_Outreach__c=true;
        study.Patient_Portal_Enabled__c=true;
        study.CommunityTemplate__c='PatientPortal';
        update study;
        
        Participant_Enrollment__c pe =testDataInstance.pe;
        pe.Invited_To_PP_Date__c=DateTime.now();
        update pe;
        
        Test.startTest();
        RestrictedSourceConfigService.getConsentPreferences(storeConIds);
        Test.stopTest();
    }
    @IsTest
    static void testConsentPreferences1() {
        TestData testDataInstance = new TestData();
        
        List<Id> storeConIds=new List<Id>();
        storeConIds.add(testDataInstance.pe.Participant_Contact__c);
        
        Clinical_Trial_Profile__c study= testDataInstance.ctp;
        study.IQVIA_Outreach__c=true;
        study.Patient_Portal_Enabled__c=true;
        study.CommunityTemplate__c='PatientPortal';
        update study;
        
        Participant_Enrollment__c pe =testDataInstance.pe;
        pe.Invited_To_PP_Date__c=DateTime.now();
        update pe;
        
        Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = testDataInstance.participant.Contact__c,
            Contact__r = testDataInstance.participant.Contact__r,
            Participant__c = testDataInstance.participant.Id,
            Participant__r = testDataInstance.participant
        );
        insert patientDelegate;
        Patient_delegate_enrollment__c patientEnrollment =new Patient_delegate_enrollment__c(
            Participant_Enrollment__c = testDataInstance.pe.Id,
            Patient_Delegate__c= patientDelegate.id,
            Study_Email_Consent__c=true,
            Study_SMS_Consent__c=true,
            Study_Phone_Consent__c=true,
            Study_Direct_Mail_Consent__c=true,
            Status__c ='Active'
        );
        insert patientEnrollment;
        Restricted_Source_Config__c restrictedRecrd = new Restricted_Source_Config__c();
        restrictedRecrd.study__c = testDataInstance.ctp.Id;
        restrictedRecrd.Sponsor__c = testDataInstance.ctp.Study_Sponsor__c;
        insert restrictedRecrd;
        Test.startTest();
        Assert.isNotNull(patientEnrollment, 'Expected the Enrollment to not be null');
        RestrictedSourceConfigService.getConsentPreferences(storeConIds);
        Test.stopTest();
    }
}