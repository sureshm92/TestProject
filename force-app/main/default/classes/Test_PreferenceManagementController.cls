/*
 * @author: Sonal Dhomne
 */

@IsTest
public class Test_PreferenceManagementController {
    class perObjWrapper {
        Id perId ;
        Id ParticipantContId ;
        Boolean participantOptInEmail ;
        Boolean participantOptInSMSText ;
        Boolean participantOptInPhone ;
        Boolean participantOptInDirectEmail ;
    }
    class pdeObjWrapper {
        
         String pdeId;
         Boolean delegateOptInEmail;
         Boolean delegateOptInSMSText;
         Boolean delegateOptInPhone;
         Boolean delegateOptInDirectEmail;
    }
    
    class conObjWrapper {
        Id contactId ;
        Boolean contactOptInEmail ;
        Boolean contactOptInSMSText; 
        Boolean contactOptInPhone;
        Boolean contactOptInDirectEmail;
        Boolean participantLoogedIn;
        Boolean isAdultParticipant;
        Boolean isEmailAvailabelForParticipant; 
        Boolean isDelegateSelfView;
        Boolean contactStorageOptIn;
    }
    
    Public static perObjWrapper perObj;
    public static pdeObjWrapper pdeObj;
    Public static conObjWrapper conObj;
    Public static TestData testDataInstance;
    
    @TestSetup
    Public static void setData(){
        Test.startTest();
         TestData.loadTestData();
        Test.stopTest();
        
    }
    
     static testMethod void testSaveConsent1() {
         //setData();      
        testDataInstance = new TestData();
        testDataInstance.pe.Permit_Mail_Email_contact_for_this_study__c = true;
        testDataInstance.pe.Permit_SMS_Text_for_this_study__c = true;
        testDataInstance.pe.Permit_Voice_Text_contact_for_this_study__c = true;
		testDataInstance.pe.Study_Direct_Mail_Consent__c = true;
        update testDataInstance.pe;
        
        testDataInstance.piContact.Participant_Opt_In_Status_Emails__c = true;
        testDataInstance.piContact.Participant_Opt_In_Status_SMS__c = true; 
        testDataInstance.piContact.Participant_Phone_Opt_In_Permit_Phone__c = true;
        testDataInstance.piContact.IQVIA_Direct_Mail_Consent__c = true;
        update testDataInstance.piContact;
        
        perObj = new perObjWrapper();
        perObj.perId = testDataInstance.pe.Id;
        //perObj.ParticipantContId = testDataInstance.pe.PI_Contact__c;
        perObj.participantOptInEmail = testDataInstance.pe.Permit_Mail_Email_contact_for_this_study__c;
        perObj.participantOptInSMSText = testDataInstance.pe.Permit_SMS_Text_for_this_study__c;
        perObj.participantOptInPhone = testDataInstance.pe.Permit_Voice_Text_contact_for_this_study__c;
		perObj.participantOptInDirectEmail = testDataInstance.pe.Study_Direct_Mail_Consent__c;
        List<Participant_Enrollment__c> storePart=new List<Participant_Enrollment__c>();
        storePart.add(testDataInstance.pe);
        
        conObj = new conObjWrapper();
        conObj.contactId = testDataInstance.piContact.Id;
        conObj.contactOptInEmail = testDataInstance.piContact.Participant_Opt_In_Status_Emails__c;
        conObj.contactOptInSMSText = testDataInstance.piContact.Participant_Opt_In_Status_SMS__c; 
        conObj.contactOptInPhone = testDataInstance.piContact.Participant_Phone_Opt_In_Permit_Phone__c;
        conObj.contactOptInDirectEmail = testDataInstance.piContact.IQVIA_Direct_Mail_Consent__c;
        conObj.participantLoogedIn = true;
        conObj.isAdultParticipant = true;
        conObj.isEmailAvailabelForParticipant = true;
        conObj.isDelegateSelfView = false;
        conObj.contactStorageOptIn=true;
       Test.startTest();
           
        Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = testDataInstance.piContact.Id,
            Contact__r = testDataInstance.piContact,
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
            Study_Direct_Mail_Consent__c=true
        );
        insert patientEnrollment;
        System.assert(patientEnrollment.id != null);
        pdeObj = new pdeObjWrapper();
        pdeObj.pdeId = patientEnrollment.Id;
        pdeObj.delegateOptInEmail = patientEnrollment.Study_Email_Consent__c;
        pdeObj.delegateOptInSMSText = patientEnrollment.Study_SMS_Consent__c;
        pdeObj.delegateOptInPhone = patientEnrollment.Study_Phone_Consent__c;
		pdeObj.delegateOptInDirectEmail = patientEnrollment.Study_Direct_Mail_Consent__c;
         
       List<Patient_delegate_enrollment__c> storeDel=new List<Patient_delegate_enrollment__c>();
        storeDel.add(patientEnrollment);
         
         
		PreferenceManagementController.saveConsent(JSON.serialize(perObj), JSON.serialize(conObj), 'PER');
        PreferenceManagementController.saveConsent(JSON.serialize(pdeObj), JSON.serialize(conObj), 'PDE');
        PreferenceManagementController.saveConsent(JSON.serialize(perObj), JSON.serialize(conObj), 'IQVIA_OUTREACH');
        PreferenceManagementController.optOutSMSWhenMobileIsDeleted(storePart,storeDel,conObj.contactId);
        PreferenceManagementController.createCommPrefEvent();
        PreferenceManagementController.updateParticipantMobileNumber(testDataInstance.participant.Id, conObj.contactId, '1234567890');
        PreferenceManagementController.getIsRTL();
        Test.stopTest();
     }
    
    static testMethod void testSaveConsent2() {
		
        testDataInstance = new TestData();
        testDataInstance.pe.Permit_Mail_Email_contact_for_this_study__c = true;
        testDataInstance.pe.Permit_SMS_Text_for_this_study__c = true;
        testDataInstance.pe.Permit_Voice_Text_contact_for_this_study__c = true;
		testDataInstance.pe.Study_Direct_Mail_Consent__c = true;
        update testDataInstance.pe;
        
        testDataInstance.piContact.Participant_Opt_In_Status_Emails__c = true;
        testDataInstance.piContact.Participant_Opt_In_Status_SMS__c = false; 
        testDataInstance.piContact.Participant_Phone_Opt_In_Permit_Phone__c = true;
        testDataInstance.piContact.IQVIA_Direct_Mail_Consent__c = true;
        update testDataInstance.piContact;
        
        perObj = new perObjWrapper();
        perObj.perId = testDataInstance.pe.Id;
        //perObj.ParticipantContId = testDataInstance.pe.PI_Contact__c;
        perObj.participantOptInEmail = testDataInstance.pe.Permit_Mail_Email_contact_for_this_study__c;
        perObj.participantOptInSMSText = testDataInstance.pe.Permit_SMS_Text_for_this_study__c;
        perObj.participantOptInPhone = testDataInstance.pe.Permit_Voice_Text_contact_for_this_study__c;
		perObj.participantOptInDirectEmail = testDataInstance.pe.Study_Direct_Mail_Consent__c;
        
        conObj = new conObjWrapper();
        conObj.contactId = testDataInstance.piContact.Id;
        conObj.contactOptInEmail = testDataInstance.piContact.Participant_Opt_In_Status_Emails__c;
        conObj.contactOptInSMSText = testDataInstance.piContact.Participant_Opt_In_Status_SMS__c; 
        conObj.contactOptInPhone = testDataInstance.piContact.Participant_Phone_Opt_In_Permit_Phone__c;
        conObj.contactOptInDirectEmail = testDataInstance.piContact.IQVIA_Direct_Mail_Consent__c;
        conObj.participantLoogedIn = true;
        conObj.isAdultParticipant = false;
        conObj.isEmailAvailabelForParticipant = false;
        conObj.isDelegateSelfView = false;
 
        Test.startTest();
		perObj.participantOptInSMSText = false;  
        perObj.ParticipantContId = conObj.contactId;
        conObj.isAdultParticipant = false;
        Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = testDataInstance.piContact.Id,
            Contact__r = testDataInstance.piContact,
            Participant__c = testDataInstance.participant.Id,
            Participant__r = testDataInstance.participant
        );
        insert patientDelegate;
        Patient_delegate_enrollment__c patientEnrollment =new Patient_delegate_enrollment__c(
            Participant_Enrollment__c = testDataInstance.pe.Id,
            Attested_By__c= conObj.contactId,
            Patient_Delegate__c= patientDelegate.id,
            Study_Email_Consent__c=true,
            Study_SMS_Consent__c=false,
            Study_Phone_Consent__c=true,
            Study_Direct_Mail_Consent__c=true
        );
        insert patientEnrollment;
        System.assert(patientEnrollment.id != null);
        pdeObj = new pdeObjWrapper();
        pdeObj.pdeId = patientEnrollment.Id;
        pdeObj.delegateOptInEmail = patientEnrollment.Study_Email_Consent__c;
        pdeObj.delegateOptInSMSText = patientEnrollment.Study_SMS_Consent__c;
        pdeObj.delegateOptInPhone = patientEnrollment.Study_Phone_Consent__c;
		pdeObj.delegateOptInDirectEmail = patientEnrollment.Study_Direct_Mail_Consent__c;
		PreferenceManagementController.saveConsent(JSON.serialize(perObj), JSON.serialize(conObj), 'PER');
        PreferenceManagementController.saveConsent(JSON.serialize(pdeObj), JSON.serialize(conObj), 'PDE');
        PreferenceManagementController.saveConsent(JSON.serialize(perObj), JSON.serialize(conObj), 'IQVIA_OUTREACH');
        PreferenceManagementController.getConOfMinorOfAdultWithoutEmailPar(conObj.contactId);
        Test.stopTest();
}
    
}