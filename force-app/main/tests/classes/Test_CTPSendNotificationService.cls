/**
 * Created by Vitalii Aheienko on 9/30/2019.
 */

@IsTest
private class Test_CTPSendNotificationService {

    @TestSetup
    static void setup() {
        Clinical_Trial_Profile__c ctp = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType(), new Map<String, Object> {
                'Override_Recruitment_Status__c' => 'On Hold'
        });
        insert ctp;
        Contact cont = (Contact) TestDataFactory.getSObject(Contact.getSObjectType());
        insert cont;

        Trial_Notification__c notification = new Trial_Notification__c(
                Contact__c = cont.Id,
                Clinical_Trial_Profile__c = ctp.Id
        );
        insert notification;
    }

    @IsTest
    static void runWorkflow_test() {
        Clinical_Trial_Profile__c profile = [SELECT Id, Override_Recruitment_Status__c FROM Clinical_Trial_Profile__c];
        profile.Override_Recruitment_Status__c = TrialSearchWhereClauseFactory.ACTIVELY_ENROLLING;
        update profile;

        System.assertEquals(0, [SELECT Id FROM Trial_Notification__c].size());

    }

}