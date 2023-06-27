@IsTest
public class Test_BellNotificationsHelper {

    @TestSetup
    static void init(){
        TestData.loadTestData();
    }
    
    @IsTest
    static void getTarget_Test() {
        Test.startTest();
        BellNotificationsHelper.getTarget('BELL_Message_on_Bulk_Import_Success');
        BellNotificationsHelper.getTarget('');
        BellNotificationsHelper.getMapOfTypeVsTarget(new List<String>());
        Test.stopTest();
    }
    
    @IsTest
    static void getRecipientVsContact_Test() {
        
        TestData td = new TestData();
        
        Test.startTest();
        
        Site_Staff__c siteStaff = new Site_Staff__c(
            Site_Contact__c = td.piDelegateContact.Id,
            Delegate_Level__c = DelegateService.DELEGATE_LEVEL_1,
            Study_Site__c = td.ss.Id,
            is_Invited__c = true
        );
        insert siteStaff;
        
        Site_Staff__c siteStaffPi = new Site_Staff__c(
            Site_Contact__c = td.piContact.Id,
            Delegate_Level__c = DelegateService.DELEGATE_LEVEL_2,
            Study_Site__c = td.ss.Id,
            is_Invited__c = true
        );
        insert siteStaffPi;
        
        HCP_Enrollment__c hcpEnrollment = new HCP_Enrollment__c(
            Study_Site__c = td.ss.Id,
            HCP_Contact__c = td.piDelegateContact.Id,
            Status__c = HCPEnrollmentService.HCP_S_INVITATION_SENT
        );
        insert hcpEnrollment;
        hcpEnrollment.Status__c = HCPEnrollmentService.HCP_S_ACTIVATED;
        update hcpEnrollment;
        
        HCP_Enrollment__c hcpEnrollmentPi = new HCP_Enrollment__c(
            Study_Site__c = td.ss.Id,
            HCP_Contact__c = td.piContact.Id,
            Status__c = HCPEnrollmentService.HCP_S_INVITATION_SENT
        );
        insert hcpEnrollmentPi;
        hcpEnrollmentPi.Status__c = HCPEnrollmentService.HCP_S_ACTIVATED;
        update hcpEnrollmentPi;
        
        BellNotificationsHelper.getRecipientVsContact(new List<String>{'Self', 'PI Delegate L1', 'PI Delegate L2', 'PI Delegate L3', 'RP'}, td.ss.Id, td.piContact.Id);
        BellNotificationsHelper.getRecipientVsContact(new List<String>{'Self', 'PI Delegate L1', 'PI Delegate L2', 'PI Delegate L3', 'RP'}, td.ss.Id, td.piDelegateContact.Id);
        BellNotificationsHelper.getRecipientVsContact(new List<String>{'Self', 'PI Delegate L1', 'PI Delegate L2', 'PI Delegate L3', 'RP'}, td.ss.Id);
        
        Test.stopTest();
    }
    
    @IsTest
    static void getContactForStudy_Test() {
    
        TestData td = new TestData();
        Site_Staff__c siteStaff = new Site_Staff__c(
            Site_Contact__c = td.piDelegateContact.Id,
            Delegate_Level__c = DelegateService.DELEGATE_LEVEL_1,
            Study_Site__c = td.ss.Id,
            is_Invited__c = true
        );
        insert siteStaff;
        
        Site_Staff__c siteStaffPi = new Site_Staff__c(
            Site_Contact__c = td.piContact.Id,
            Delegate_Level__c = DelegateService.DELEGATE_LEVEL_2,
            Study_Site__c = td.ss.Id,
            is_Invited__c = true
        );
        insert siteStaffPi;
        
        Test.startTest();
        BellNotificationsHelper.getContactForStudy(td.ctp.Id);
        BellNotificationsHelper.getContactForStudy(new List<Id>{td.ctp.Id});
        Test.stopTest();
    }
    
    @IsTest
    static void getContactForSites_Test() {
        
        TestData td = new TestData();
        
        Test.startTest();
        
        Site_Staff__c siteStaff = new Site_Staff__c(
            Site_Contact__c = td.piDelegateContact.Id,
            Delegate_Level__c = DelegateService.DELEGATE_LEVEL_1,
            Study_Site__c = td.ss.Id,
            is_Invited__c = true
        );
        insert siteStaff;
        
        Site_Staff__c siteStaffPi = new Site_Staff__c(
            Site_Contact__c = td.piContact.Id,
            Delegate_Level__c = DelegateService.DELEGATE_LEVEL_2,
            Study_Site__c = td.ss.Id,
            is_Invited__c = true
        );
        insert siteStaffPi;
        
        HCP_Enrollment__c hcpEnrollment = new HCP_Enrollment__c(
            Study_Site__c = td.ss.Id,
            HCP_Contact__c = td.piDelegateContact.Id,
            Status__c = HCPEnrollmentService.HCP_S_INVITATION_SENT
        );
        insert hcpEnrollment;
        hcpEnrollment.Status__c = HCPEnrollmentService.HCP_S_ACTIVATED;
        update hcpEnrollment;
        
        HCP_Enrollment__c hcpEnrollmentPi = new HCP_Enrollment__c(
            Study_Site__c = td.ss.Id,
            HCP_Contact__c = td.piContact.Id,
            Status__c = HCPEnrollmentService.HCP_S_INVITATION_SENT
        );
        insert hcpEnrollmentPi;
        hcpEnrollmentPi.Status__c = HCPEnrollmentService.HCP_S_ACTIVATED;
        update hcpEnrollmentPi;
        
        //BellNotificationsHelper.getContactForSites(new List<String>{'Self', 'PI Delegate L1', 'PI Delegate L2', 'PI Delegate L3', 'RP'}, new Set<String>{td.ss.Id}, td.piContact.Id);
        //BellNotificationsHelper.getContactForSites(new List<String>{'Self', 'PI Delegate L1', 'PI Delegate L2', 'PI Delegate L3', 'RP'}, new Set<String>{td.ss.Id}, td.piDelegateContact.Id);
        BellNotificationsHelper.getContactForSites(new Set<String>{td.ss.Id});
        BellNotificationsHelper.getContactGeneric();
        
        Test.stopTest();
    }
    
    @IsTest
    static void publishPEForBellNotifications_Test() {
    
        TestData td = new TestData();
        
        Test.startTest();
        Notification__c notObj = new Notification__c();
        notObj.Recipient__c = td.pe.Participant_Contact__c;
        notObj.Status__c = 'In Progress';
        notObj.WhatId__c=td.piContact.Id;
        notObj.Notification_Type__c = 'Message_To_PI_Contact_Participant_Type';
        insert notObj;
        Send_Result__c srObj = new Send_Result__c();
        srObj.Notification__c = notObj.Id;
        srObj.Status__c = 'In Progress';
        srObj.Target_Type__c='Bell';
        srObj.Notification_Type__c = 'Message_To_PI_Contact_Participant_Type';
        insert srObj;
        BellNotificationsHelper.getCurrentUserLevelByStudySite(td.piDelegateContact.Id, td.ss.Id);
        Test.stopTest();
    }
    
    @IsTest
    static void getCurrentUserLevelByStudySite_Test() {
        
        TestData td = new TestData();
        Site_Staff__c siteStaff = new Site_Staff__c(
            Site_Contact__c = td.piDelegateContact.Id,
            Delegate_Level__c = DelegateService.DELEGATE_LEVEL_1,
            Study_Site__c = td.ss.Id,
            is_Invited__c = true
        );
        insert siteStaff;
        
        Site_Staff__c siteStaffPi = new Site_Staff__c(
            Site_Contact__c = td.piContact.Id,
            Delegate_Level__c = DelegateService.DELEGATE_LEVEL_2,
            Study_Site__c = td.ss.Id,
            is_Invited__c = true
        );
        insert siteStaffPi;
        
        Test.startTest();
        BellNotificationsHelper.getCurrentUserLevelByStudySite(td.piContact.Id, td.ss.Id);
        BellNotificationsHelper.getCurrentUserLevelByStudySite(td.piDelegateContact.Id, td.ss.Id);
        
        siteStaff.Delegate_Level__c = DelegateService.DELEGATE_LEVEL_2;
        update siteStaff;
        
        BellNotificationsHelper.getCurrentUserLevelByStudySite(td.piDelegateContact.Id, td.ss.Id);
        
        siteStaff.Delegate_Level__c = DelegateService.DELEGATE_LEVEL_3;
        update siteStaff;
        
        BellNotificationsHelper.getCurrentUserLevelByStudySite(td.piDelegateContact.Id, td.ss.Id);
        Test.stopTest();
    }
    
    @IsTest
    static void createNotification_Test() {
    
        TestData td = new TestData();
        
        Test.startTest();
        
        TriggerHandlerExecutor.bypassHandler(NotificationTriggerHandler.CheckFieldsHandler.class);
        
        Map<String, List<Contact>> mapofGroupVsContact = new Map<String, List<Contact>>{
            'Self' => new List<Contact>{td.piContact},
            'PI Delegate L1' => new List<Contact>{td.piDelegateContact}
        };
        
        BellNotificationsHelper.createNotification(
            'Message_To_PI_Contact_Participant_Type', mapofGroupVsContact, true
        );
        
        BellNotificationsHelper.createNotification(
            'Message_To_PI_Contact_Participant_Type', mapofGroupVsContact, 'Test', td.pe.Id, true
        );
        
        BellNotificationsHelper.createNotification(
            'Message_To_PI_Contact_Participant_Type', td.piContact.Id, true
        );
        
        BellNotificationsHelper.createNotification(
            'Message_To_PI_Contact_Participant_Type', td.piContact.Id, td.pe.Id, true
        );
        
        BellNotificationsHelper.createNotification(
            'Message_To_PI_Contact_Participant_Type', td.piContact.Id, 'Self', 'Test', true
        );
        Test.stopTest();
    }
}