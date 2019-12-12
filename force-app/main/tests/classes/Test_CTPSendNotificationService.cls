/**
 * Created by Vitalii Aheienko on 9/30/2019.
 */

@IsTest(IsParallel=true)
private class Test_CTPSendNotificationService {
//    This is test for disabled workflow
//    @TestSetup
//    static void setup() {
//        Clinical_Trial_Profile__c ctp = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType(), new Map<String, Object> {
//                'Override_Recruitment_Status__c' => 'On Hold'
//        });
//        insert ctp;
//        Contact cont = (Contact) TestDataFactory.getSObject(Contact.getSObjectType());
//        insert cont;
//
//        Trial_Notification__c notification = new Trial_Notification__c(
//                Contact__c = cont.Id,
//                Clinical_Trial_Profile__c = ctp.Id
//        );
//        insert notification;
//    }
//
    @IsTest
    static void runWorkflow_test() {
//        Test.startTest();
//        Clinical_Trial_Profile__c ctp = [SELECT Id, Override_Recruitment_Status__c FROM Clinical_Trial_Profile__c];
//        ctp.Override_Recruitment_Status__c = TrialSearchWhereClauseFactory.ACTIVELY_ENROLLING;
//        update ctp;
//        Test.stopTest();
//
//        System.assertEquals(0, [SELECT Id FROM Trial_Notification__c].size());
    }
//
//    @IsTest
//    static void runWorkflowNoOpenedCtps_test() {
//        Test.startTest();
//        Clinical_Trial_Profile__c ctp = [SELECT Id, Study_Code_Name__c, Override_Recruitment_Status__c FROM Clinical_Trial_Profile__c];
//        ctp.Study_Code_Name__c = 'test';
//        update ctp;
//        Test.stopTest();
//
//        System.assertEquals(1, [SELECT Id FROM Trial_Notification__c].size());
//    }
//
//    @IsTest
//    static void removeRelatedTrialNotificationsOnDelete_test() {
//        Test.startTest();
//        Clinical_Trial_Profile__c ctp = [SELECT Id, Override_Recruitment_Status__c FROM Clinical_Trial_Profile__c];
//        delete ctp;
//        Test.stopTest();
//
//        System.assertEquals(0, [SELECT Id FROM Trial_Notification__c].size());
//    }

}