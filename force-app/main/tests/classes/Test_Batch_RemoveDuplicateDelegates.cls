/**
 * Created by Dmitry Ivakhnenko on 20-Mar-20.
 */

@IsTest
private class Test_Batch_RemoveDuplicateDelegates {

    @TestSetup
    static void init() {
        Test.startTest();
        Account participantAccount = new Account(
                Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
        );
        insert participantAccount;

        Account delegateAccount = new Account(
                Name = CommunityService.COMMUNITY_DELEGATE_ACCOUNT_NAME
        );
        insert delegateAccount;

        Participant__c participantWithoutDelegates = new Participant__c(
                First_Name__c = 'ParticipantWithoutDelegates',
                Last_Name__c = 'ParticipantWithoutDelegates',
                Phone__c = '1110000000',
                Email__c = 'part1@email.com'
        );
        insert participantWithoutDelegates;

        Participant__c participantWith1Delegate = new Participant__c(
                First_Name__c = 'ParticipantWith1Delegate',
                Last_Name__c = 'ParticipantWith1Delegate',
                Phone__c = '2220000000',
                Email__c = 'part2@email.com'
        );
        insert participantWith1Delegate;

        Participant__c participantWithDoubleDelegates = new Participant__c(
                First_Name__c = 'ParticipantWithDuplicateDelegates',
                Last_Name__c = 'ParticipantWithDuplicateDelegates',
                Phone__c = '3330000000',
                Email__c = 'part3@email.com'
        );
        insert participantWithDoubleDelegates;

        Participant__c participantWithManyDelegates = new Participant__c(
                First_Name__c = 'ParticipantWithManyDelegates',
                Last_Name__c = 'ParticipantWithManyDelegates',
                Phone__c = '4440000000',
                Email__c = 'part3@email.com'
        );
        insert participantWithManyDelegates;

        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(
                FirstName = 'DelegateContact1',
                LastName = 'DelegateContact1',
                Email = 'delegate1@email.com',
                AccountId = delegateAccount.Id,
                userCommunityMode__c = 'Delegate'
        ));
        contacts.add(new Contact(
                FirstName = 'DelegateContact2',
                LastName = 'DelegateContact2',
                Email = 'delegate2@email.com',
                AccountId = delegateAccount.Id,
                userCommunityMode__c = 'Delegate'
        ));
        contacts.add(new Contact(
                FirstName = 'DelegateContact3',
                LastName = 'DelegateContact3',
                Email = 'delegate3@email.com',
                AccountId = delegateAccount.Id,
                userCommunityMode__c = 'Delegate'
        ));
        insert contacts;

        List<Patient_Delegate__c> patientDelegates = new List<Patient_Delegate__c>();
        /* 1 delegate */
        patientDelegates.add(new Patient_Delegate__c(
                Contact__c = contacts[0].Id,
                Contact__r = contacts[0],
                Participant__c = participantWith1Delegate.Id,
                Participant__r = participantWith1Delegate
        ));

        /* Duplicate delegates */
        patientDelegates.add(new Patient_Delegate__c(
                Contact__c = contacts[0].Id,
                Contact__r = contacts[0],
                Participant__c = participantWithDoubleDelegates.Id,
                Participant__r = participantWithDoubleDelegates
        ));
        patientDelegates.add(new Patient_Delegate__c(
                Contact__c = contacts[1].Id,
                Contact__r = contacts[1],
                Participant__c = participantWithDoubleDelegates.Id,
                Participant__r = participantWithDoubleDelegates
        ));
        patientDelegates.add(new Patient_Delegate__c(
                Contact__c = contacts[2].Id,
                Contact__r = contacts[2],
                Participant__c = participantWithDoubleDelegates.Id,
                Participant__r = participantWithDoubleDelegates
        ));
        patientDelegates.add(new Patient_Delegate__c(
                Contact__c = contacts[1].Id,
                Contact__r = contacts[1],
                Participant__c = participantWithDoubleDelegates.Id,
                Participant__r = participantWithDoubleDelegates
        ));
        patientDelegates.add(new Patient_Delegate__c(
                Contact__c = contacts[2].Id,
                Contact__r = contacts[2],
                Participant__c = participantWithDoubleDelegates.Id,
                Participant__r = participantWithDoubleDelegates
        ));
        patientDelegates.add(new Patient_Delegate__c(
                Contact__c = contacts[2].Id,
                Contact__r = contacts[2],
                Participant__c = participantWithDoubleDelegates.Id,
                Participant__r = participantWithDoubleDelegates
        ));

        /* Many different delegates */
        patientDelegates.add(new Patient_Delegate__c(
                Contact__c = contacts[0].Id,
                Contact__r = contacts[0],
                Participant__c = participantWithManyDelegates.Id,
                Participant__r = participantWithManyDelegates
        ));
        patientDelegates.add(new Patient_Delegate__c(
                Contact__c = contacts[1].Id,
                Contact__r = contacts[1],
                Participant__c = participantWithManyDelegates.Id,
                Participant__r = participantWithManyDelegates
        ));
        patientDelegates.add(new Patient_Delegate__c(
                Contact__c = contacts[2].Id,
                Contact__r = contacts[2],
                Participant__c = participantWithManyDelegates.Id,
                Participant__r = participantWithManyDelegates
        ));
        insert patientDelegates;
        Test.stopTest();
    }

    @IsTest
    static void testBehavior() {
        List<Patient_Delegate__c> patientDelegates = [SELECT Id FROM Patient_Delegate__c];
        System.assertEquals(10, patientDelegates.size());

        Test.startTest();
        Batch_RemoveDuplicateDelegates.run();
        Test.stopTest();

        patientDelegates = new List<Patient_Delegate__c>([
                SELECT Id
                FROM Patient_Delegate__c
                WHERE Participant__r.Last_Name__c = 'ParticipantWithoutDelegates'
        ]);
        System.assertEquals(0, patientDelegates.size());

        patientDelegates = new List<Patient_Delegate__c>([
                SELECT Id
                FROM Patient_Delegate__c
                WHERE Participant__r.Last_Name__c = 'ParticipantWith1Delegate'
        ]);
        System.assertEquals(1, patientDelegates.size());

        patientDelegates = new List<Patient_Delegate__c>([
                SELECT Id
                FROM Patient_Delegate__c
                WHERE Participant__r.Last_Name__c = 'ParticipantWithDuplicateDelegates'
        ]);
        System.assertEquals(3, patientDelegates.size());

        patientDelegates = new List<Patient_Delegate__c>([
                SELECT Id
                FROM Patient_Delegate__c
                WHERE Participant__r.Last_Name__c = 'ParticipantWithManyDelegates'
        ]);
        System.assertEquals(3, patientDelegates.size());
    }
}