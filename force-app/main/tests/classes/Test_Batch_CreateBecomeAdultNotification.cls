/**
 * Created by Igor Iosifov on 2020-02-28.
 */
@IsTest
public with sharing class Test_Batch_CreateBecomeAdultNotification {

    @TestSetup
    static void setup() {

        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();

        String birthdayToReceiveAlert = String.valueOf(Datetime.now().addDays(7).addYears(-18)).substring(0,10);
        Participant__c participant = new Participant__c(
                First_Name__c = 'newParticipant',
                Last_Name__c = 'newParticipant',
                Date_of_Birth__c = birthdayToReceiveAlert,
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'MS'
        );
        insert participant;

        Study_Site__c studySite = [
                SELECT Id
                FROM Study_Site__c
        ];
        Contact piContact = [
                SELECT Id
                FROM Contact
                WHERE Email = 'pi@emil.com'
        ];

        Participant_Enrollment__c pe = new Participant_Enrollment__c(
                Study_Site__c = studySite.Id,
                Participant__c = participant.Id,
                PI_Contact__c = piContact.Id
        );
        insert pe;

        Contact delegate = new Contact(
                FirstName = 'Patient',
                LastName = 'Delegate',
                Email = 'delegate@somemail.com',
                AccountId = participant.Contact__r.AccountId,
                Current_Participant_Enrollment__c = pe.Id,
                userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
                userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT,
                UserCommunityIsDelegate__c = true
        );
        insert delegate;

        Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
                Contact__c = delegate.Id,
                Contact__r = delegate,
                Participant__c = participant.Id,
                Participant__r = participant
        );
        insert patientDelegate;
        delete [SELECT Id FROM Alert__c];
    }

    @IsTest
    static void test() {
        Test.startTest();
        Database.executeBatch(new Batch_CreateBecomeAdultNotification());
        Test.stopTest();
        List<Alert__c> alerts = [SELECT Id FROM Alert__c];
        List<Contact> delegates = [
                SELECT Id
                FROM Contact
                WHERE  Email = 'delegate@somemail.com'
        ];
        System.assertEquals(delegates.size(), alerts.size());
    }
}