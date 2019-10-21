/**
 * Created by Julia Kazakevich on 20-Sep-19.
 */

@IsTest
public without sharing class Test_Batch_CreateParticipantNotification {
    @IsTest
    static void testBatchExecution() {
        List<Account> accounts = new List<Account>();
        Account participantsAccount = new Account(
                Name = 'Participant'
        );
        accounts.add(participantsAccount);
        Account piAccount = new Account(
                Name = 'PI Account'
        );
        accounts.add(piAccount);
        Account studySiteAccount = new Account(
                Name = 'Study Site Account',
                BillingCountryCode = 'US'
        );
        accounts.add(studySiteAccount);
        insert accounts;

        List<Contact> contacts = new List<Contact>();
        Contact piContact = new Contact(
                FirstName = 'PI',
                LastName = 'PI',
                Email = 'pi@emil.com',
                AccountId = piAccount.Id,
                Participant_Opt_In_Status_Emails__c = true,
                Next_Notify_Date__c = Date.today()
        );
        contacts.add(piContact);
        insert contacts;

        Participant__c participant = new Participant__c(
                First_Name__c = 'Max',
                Last_Name__c = 'James',
                Birth_Year__c = '1985',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'NY',
                Email__c = 'MaxJames@mail.com'
        );
        insert participant;
        Participant__c part1 = [SELECT Contact__c FROM Participant__c WHERE Id =: participant.Id];
        Contact con = new Contact(Id = part1.Contact__c, Next_Notify_Date__c = Date.today(), Participant_Opt_In_Status_Emails__c = true);
        update con;

        Test.startTest();
        Database.executeBatch(new Batch_CreateParticipantLoginNotification());
        Test.stopTest();
        List<Contact> checkConListEmail = [SELECT Id, Next_Notify_Date__c, Participant_Opt_In_Status_Emails__c
        FROM Contact
        WHERE Next_Notify_Date__c != null];

        System.assertEquals(2, checkConListEmail.size());
    }
    
   	@IsTest
    static void testCreateDate() {
        Test.startTest();
        TestData.loadTestData();

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