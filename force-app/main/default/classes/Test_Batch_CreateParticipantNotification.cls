/**
 * Created by Julia Kazakevich on 20-Sep-19.
 */

@IsTest
public without sharing class Test_Batch_CreateParticipantNotification {
    @IsTest
    static void testBehavior() {
        
        Test.startTest();
        TestData.loadTestData();
        TestData tstData = new TestData();
        tstData.ctp.Participating_in_Patient_Portal__c = 'Yes';
        tstData.ctp.Logged_Out_Days_Notification__c = 13;
        update tstData.ctp;

        List<Clinical_Trial_Profile__c> studies = [
                SELECT  Id,
                        Participating_in_Patient_Portal__c,
                        Patient_Portal_Enabled__c,
                        Logged_Out_Days_Notification__c
                FROM Clinical_Trial_Profile__c
                WHERE Participating_in_Patient_Portal__c = 'Yes'
        ];

        new Batch_CreateParticipantLoginNotification().execute(null, studies);
        Test.stopTest();

    }
    
   	@IsTest
    static void testCreateDate() {
        
        Test.startTest();
        TestData.loadTestData();
        TestData tstData = new TestData();

        List<Participant__c> participants = [
            SELECT  Id,
                        Name,
                        Contact__c,
                        Contact__r.Profile_Update_Years_Notification__c
            FROM Participant__c
        ];
        new Batch_UserCreatedDateNotification().execute(null, participants);
        Test.stopTest();

    }
}