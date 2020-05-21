/**
 * Created by Olga Skrynnikova on 4/21/2020.
 */

@IsTest
private class Test_Batch_CreateParticipantForDelegate {
    @TestSetup
    static void setup() {

        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();

        Participant__c participant = new Participant__c(
                First_Name__c = 'newParticipant',
                Last_Name__c = 'newParticipant',
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
    }

    @IsTest
    static void test() {
        Test.startTest();
        Database.executeBatch(new Batch_CreateParticipantForDelegate());
        Test.stopTest();
        List<Participant__c> delegateParticipant = [SELECT Id, Contact__r.Email FROM Participant__c WHERE Contact__r.Email =: 'delegate@somemail.com'];
        System.assertEquals(1, delegateParticipant.size());
    }
}