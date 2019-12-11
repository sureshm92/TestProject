/**
 * Created by Olga Skrynnikova on 11/26/2019.
 */

@IsTest
private class Test_PENotificationTriggerHandler {
//    @testSetup
//    static void setup() {
//        TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.class);
//        TestData.loadTestData();
//    }
    @IsTest
    static void testCheckHCPNotificationType() {
//        Participant_Enrollment__c pe = [
//                SELECT Id,
//                        Participant_Status__c
//                FROM Participant_Enrollment__c
//                LIMIT 1
//        ];
//        pe.Participant_Status__c = PEStatusState.PE_STATUS_REFERRAL_DECLINED;
//        update pe;
//
//        String notificationHCPTypeStr;
//        Test.startTest();
//        notificationHCPTypeStr = NotificationService.checkHCPNotificationType(pe, false);
//        Test.stopTest();
//        System.assertEquals('Message_to_HCP_Patient_Declined_Type', notificationHCPTypeStr);
    }
//
//    @IsTest
//    static void testCheckPatientNotificationType() {
//        Participant_Enrollment__c pe = [
//                SELECT Id,
//                        Participant_Status__c
//                FROM Participant_Enrollment__c
//                LIMIT 1
//        ];
//        pe.Participant_Status__c = PEStatusState.PE_STATUS_REFERRAL_ON_HOLD;
//        update pe;
//
//        String notificationHCPTypeStr;
//        Test.startTest();
//        notificationHCPTypeStr = NotificationService.checkPatientNotificationType(pe, false);
//        Test.stopTest();
//        System.assertEquals('Message_to_PT_Patient_On_Hold_Type', notificationHCPTypeStr);
//    }
//
//    @IsTest
//    static void testCheckPatientNotificationTypeWithResource() {
//        Participant_Enrollment__c pe = [
//                SELECT Id,
//                        Participant_Status__c, Referral_Source__c
//                FROM Participant_Enrollment__c
//                LIMIT 1
//        ];
//        pe.Participant_Status__c = PEStatusState.PE_STATUS_REFERRAL_SENT_TO_PI;
//        update pe;
//
//        String notificationPTTypeStr;
//        Test.startTest();
//        notificationPTTypeStr = NotificationService.checkPatientNotificationVTType(pe);
//        Test.stopTest();
//        System.assertEquals('Message_to_PT_New_Study_HCP_VT_Type', notificationPTTypeStr);
//    }
//
//    @IsTest
//    static void testCheckCreateNotificationByStatus() {
//        List<Participant_Enrollment__c> peList = [
//                SELECT Id,
//                        Participant_Status__c,
//                        HCP_Contact_HCPEnroll__r.HCP_Opt_In_Patient_Status_Emails__c,
//                        Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c
//                FROM Participant_Enrollment__c
//        ];
//        Map<Id, SObject> oldMap = new Map<Id, SObject>();
//        for (Participant_Enrollment__c pe : peList) {
//            oldMap.put(pe.Id, pe);
//            pe.Participant_Status__c = PEStatusState.PE_STATUS_REFERRAL_ON_HOLD;
//        }
//        update peList;
//
//        Test.startTest();
//        PENotificationTriggerHandler.createNotificationByStatus(peList, oldMap);
//        Test.stopTest();
//        List<Notification__c> notifyList = [SELECT Id, Notification_Type__c FROM Notification__c];
//        System.assertEquals(2, notifyList.size());

//    }
}
