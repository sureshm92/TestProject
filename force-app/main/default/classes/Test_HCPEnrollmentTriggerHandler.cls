/**
 * Created by Prince on 22-Nov-22
 */
@IsTest
public class Test_HCPEnrollmentTriggerHandler {
	@TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    
    @IsTest
    private static void test() {
        TestData testData = new TestData();
        List<Account> accounts = new List<Account>();
		List<HCP_Enrollment__c> enrollmentList = new List<HCP_Enrollment__c>();
        Map<Id, HCP_Enrollment__c> enrollmentOldMap = new Map<Id, HCP_Enrollment__c>();
        Account hcpAccount = new Account(Name = 'HCP Account');
            accounts.add(hcpAccount);
        insert accounts;
        List<Contact> contacts = new List<Contact>();
        Contact hcpContact = new Contact(
            FirstName = 'HCPTD',
            LastName = 'HCPTD',
            Email = 'hcp@emil.com',
            AccountId = hcpAccount.Id,
            MailingLatitude = 40.766594,
            MailingLongitude = -73.991509,
            userCommunytyType__c = CommunityService.USER_MODE_HCP,
            userCommunityMode__c = CommunityService.USER_MODE_HCP
        );
            contacts.add(hcpContact);
        insert contacts;
        HCP_Enrollment__c hcpEnrollment = new HCP_Enrollment__c(
                Study_Site__c = testData.ss.Id,
                HCP_Contact__c = hcpContact.Id,
                Status__c = HCPEnrollmentService.HCP_S_INVITATION_SENT
            );
        enrollmentList.add(hcpEnrollment);
        insert hcpEnrollment;
   		Test.startTest();
        enrollmentOldMap.put(hcpEnrollment.Id,hcpEnrollment);
        HCPEnrollmentTriggerHandler.deleteStatusHistory(enrollmentList);
        HCPEnrollmentTriggerHandler.sendNotificationForActivatedHCPE(enrollmentList,enrollmentOldMap);
        HCPEnrollmentTriggerHandler.sendNotificationForDeclinedHCPE(enrollmentList,enrollmentOldMap);
        HCPEnrollmentTriggerHandler.createStatusHistory(enrollmentList,enrollmentOldMap);
        HCPEnrollmentTriggerHandler.sendOnHoldNotification(enrollmentList,enrollmentOldMap);
        HCPEnrollmentTriggerHandler.switchContactUserMode(enrollmentList);
        ProviderPaymentsService.checkHCPEForReimbursableActivities(enrollmentList,enrollmentOldMap);
        
        TriggerHandlerExecutor.bypassHandler(
            HCPEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            HCPEnrollmentTriggerHandler.DeleteStatusHistoryOnDeleteHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            HCPEnrollmentTriggerHandler.CreateHCPUserOrSendNotificationHandler.class
        );
        TriggerHandlerExecutor.execute(
            HCPEnrollmentTriggerHandler.SendNotificationForActivatedHCPEHandler.class
        );
        TriggerHandlerExecutor.execute(
            HCPEnrollmentTriggerHandler.SendNotificationForDeclinedHCPEHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            HCPEnrollmentTriggerHandler.SwitchContactUserModeHandler.class
        );
        TriggerHandlerExecutor.execute(
            HCPEnrollmentTriggerHandler.CreateRecruitingHCPStaffModeHandler.class
        );
        TriggerHandlerExecutor.execute(
            HCPEnrollmentTriggerHandler.CreateStatusHistoryHandler.class
        );
        TriggerHandlerExecutor.execute(
            HCPEnrollmentTriggerHandler.CheckReimbursableActivities.class
        );
        
      }
    
    @IsTest
    private static void test1() {
        TestData testData = new TestData();
        List<Account> accounts = new List<Account>();
		List<HCP_Enrollment__c> enrollmentList = new List<HCP_Enrollment__c>();
        List<HCP_Enrollment__c> enrollmentList1 = new List<HCP_Enrollment__c>();
        List<HCP_Enrollment__c> enrollmentList2 = new List<HCP_Enrollment__c>();
        Map<Id, HCP_Enrollment__c> enrollmentOldMap = new Map<Id, HCP_Enrollment__c>();
        Account piAccount = new Account(Name = 'PI Account', BillingCountry = 'United States');
            accounts.add(piAccount);
        Account hcpAccount = new Account(Name = 'HCP Account');
            accounts.add(hcpAccount);
        insert accounts;
        List<Contact> contacts = new List<Contact>();
        Contact piContact = new Contact(
                FirstName = 'PITD',
                LastName = 'PITD',
                Email = 'pi@emil.com',
                MailingCountry = 'United States',
                AccountId = piAccount.Id,
                userCommunytyType__c = 'PI'
            );
            contacts.add(piContact);
        Contact hcpContact = new Contact(
            FirstName = 'HCPTD',
            LastName = 'HCPTD',
            Email = 'hcp@emil.com',
            AccountId = hcpAccount.Id,
            MailingLatitude = 40.766594,
            MailingLongitude = -73.991509,
            userCommunytyType__c = CommunityService.USER_MODE_PI,
            userCommunityMode__c = CommunityService.USER_MODE_PI,
            HCP_Opt_In_Referral_Status_Emails__c = true
        );
            contacts.add(hcpContact);
        insert contacts;
        HCP_Enrollment__c hcpEnrollment = new HCP_Enrollment__c(
                Study_Site__c = testData.ss.Id,
                HCP_Contact__c = hcpContact.Id,
                Status__c = HCPEnrollmentService.HCP_S_INVITATION_SENT
            );
        enrollmentList.add(hcpEnrollment);
        insert hcpEnrollment;
           
        HCP_Enrollment__c hcpEnrollment1 = new HCP_Enrollment__c(
                Study_Site__c = testData.ss.Id,
                HCP_Contact__c = hcpContact.Id,
                Status__c = HCPEnrollmentService.HCP_S_ACTIVATION_PENDING_O
            );
        enrollmentList.add(hcpEnrollment1);
        insert hcpEnrollment1;
        hcpEnrollment1.Status__c = HCPEnrollmentService.HCP_S_ACTIVATED;
        update hcpEnrollment1;
        enrollmentList1.add(hcpEnrollment1);
        
        HCP_Enrollment__c hcpEnrollment2 = new HCP_Enrollment__c(
                Study_Site__c = testData.ss.Id,
                HCP_Contact__c = hcpContact.Id,
                Status__c = HCPEnrollmentService.HCP_S_ACTIVATION_PENDING_O
            );
        enrollmentList.add(hcpEnrollment2);
        insert hcpEnrollment2;
        hcpEnrollment2.Status__c = HCPEnrollmentService.HCP_S_DECLINE_ACTIVATION;
        update hcpEnrollment2;
        hcpEnrollment2.Status__c = HCPEnrollmentService.HCP_S_DECLINED_APPROVAL;
        update hcpEnrollment2;
        enrollmentList2.add(hcpEnrollment2);
        
        HCP_Enrollment__c hcpEnrollment3 = new HCP_Enrollment__c(
                Study_Site__c = testData.ss.Id,
                HCP_Contact__c = hcpContact.Id,
                Status__c = HCPEnrollmentService.HCP_S_NON_RESPONCIVE_A
            );
        insert hcpEnrollment3;
        hcpEnrollment3.Status__c = HCPEnrollmentService.HCP_S_ON_HOLD_ACCEPTANCE;
        update hcpEnrollment3;
        
        HCP_Enrollment__c hcpEnrollment4 = new HCP_Enrollment__c(
                Study_Site__c = testData.ss.Id,
                HCP_Contact__c = hcpContact.Id,
                Status__c = HCPEnrollmentService.HCP_S_NON_RESPONCIVE_A
            );
        insert hcpEnrollment4;
        hcpEnrollment4.Status__c = HCPEnrollmentService.HCP_S_INVITATION_SENT;
        update hcpEnrollment4;
        
        HCP_Enrollment__c hcpEnrollment5 = new HCP_Enrollment__c(
                Study_Site__c = testData.ss.Id,
                HCP_Contact__c = hcpContact.Id,
                Status__c = HCPEnrollmentService.HCP_S_ACTIVATION_PENDING_O
            );
        insert hcpEnrollment5;
        
        Participant_Enrollment__c pe = [
            SELECT Id, Participant__r.Contact__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ];
        List<Notification__c> newList = new List<Notification__c>();
        Notification__c notifyForTest = new Notification__c(
            Notification_Type__c = 'PP_RH_Push_Notification',
            Recipient__c = pe.Participant__r.Contact__c,
            WhatId__c = pe.Id
        ); 
        newList.add(notifyForTest);
   		Test.startTest();
        enrollmentOldMap.put(hcpEnrollment.Id,hcpEnrollment);
        HCPEnrollmentTriggerHandler.switchContactUserMode(enrollmentList);
		try{
            HCPEnrollmentTriggerHandler.createStatusHistory(enrollmentList1,enrollmentOldMap);
          	HCPEnrollmentTriggerHandler.sendNotificationForActivatedHCPE(enrollmentList,enrollmentOldMap);
        }catch(Exception ex){}
          
       }
}