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

    @IsTest
    static void testdataBecomesAvailiable() {
        Test.startTest();
        TestData.loadTestData();
        TestData tstData = new TestData();

        List<Patient_Visit__c> participants = [
                SELECT  Id,
                        Completed_Date__c,
                        Participant_Enrollment__c,
                        Participant_Enrollment__r.Participant__r.Mailing_Country_Code__c,
                        Participant_Enrollment__r.Clinical_Trial_Profile__c,
                        Participant_Enrollment__r.Clinical_Trial_Profile__r.Shareback_Availability_Timing__c,
                        Participant_Enrollment__r.Participant_Contact__r.Visit_Results_Opt_In__c,
                        Visit_Number__c, (
                        SELECT
                                Id,
                                Actual_Value__c,
                                Max_Value__c,
                                Measurement__c,
                                Min_Value__c,
                                Patient_Visit__r.Completed_Date__c,
                                Patient_Visit__r.Notified__c,
                                Patient_Visit__r.Participant_Enrollment__r.Participant_Contact__c,
                                Result_Type__c
                        FROM Visit_Results__r
                )
                FROM Patient_Visit__c
                WHERE Status__c = 'Completed'
                AND Notified__c = false
                ORDER BY Visit_Number__c, Completed_Date__c
        ];
        new Batch_DataBecomesAvailable().execute(null, participants);
        Test.stopTest();

    }
}