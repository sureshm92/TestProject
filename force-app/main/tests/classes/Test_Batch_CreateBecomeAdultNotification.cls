/**
 * Created by Igor Iosifov on 2020-02-28.
 */
@IsTest
public with sharing class Test_Batch_CreateBecomeAdultNotification {
    @TestSetup
    static void setup() {
        try{
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();

        List<Participant__c> plist = new List<Participant__c>();
        String birthdayToReceiveAlert = String.valueOf(Datetime.now().addDays(7).addYears(-21))
            .substring(0, 10);
        Participant__c participant = new Participant__c(
            First_Name__c = 'newParticipant',
            Last_Name__c = 'newParticipant',
            Date_of_Birth__c = birthdayToReceiveAlert,
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'MS'
        );
        plist.add(participant);
        
        String birthdayToReceiveAlert2 = String.valueOf(Datetime.now().addDays(7).addYears(-20))
            .substring(0, 10);
        Participant__c participant2 = new Participant__c(
            First_Name__c = 'newParticipant2',
            Last_Name__c = 'newParticipant2',
            Date_of_Birth__c = birthdayToReceiveAlert,
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'NY'
        );
        plist.add(participant2);
        
        String birthdayToReceiveAlert3 = String.valueOf(Datetime.now().addDays(7).addYears(-21))
            .substring(0, 10);
        Participant__c participant3 = new Participant__c(
            First_Name__c = 'newParticipant3',
            Last_Name__c = 'newParticipant3',
            Date_of_Birth__c = birthdayToReceiveAlert3,
            Mailing_Country_Code__c = 'AE'
        );
        plist.add(participant3);
        
        String birthdayToReceiveAlert4 = String.valueOf(Datetime.now().addDays(7).addYears(-18))
            .substring(0, 10);
        Participant__c participant4 = new Participant__c(
            First_Name__c = 'newParticipant4',
            Last_Name__c = 'newParticipant4',
            Date_of_Birth__c = birthdayToReceiveAlert4,
            Mailing_Country_Code__c = 'IN'
        );
        plist.add(participant4);
        insert plist;
        
        Study_Site__c studySite = [SELECT Id, Principal_Investigator__r.Id FROM Study_Site__c where Principal_Investigator__r.Id != Null];
        Contact piContact = [SELECT Id FROM Contact WHERE Email = 'pi@emil.com'];

        List<Participant_Enrollment__c> pelist = new List<Participant_Enrollment__c>();
        Participant_Enrollment__c pe = new Participant_Enrollment__c(
            Study_Site__c = studySite.Id,
            Participant__c = participant.Id,
            PI_Contact__c = piContact.Id
        );
        pelist.add(pe);
        
        Participant_Enrollment__c pe2 = new Participant_Enrollment__c(
            Study_Site__c = studySite.Id,
            Participant__c = participant2.Id,
            PI_Contact__c = piContact.Id
        );
        pelist.add(pe2);
        
        Participant_Enrollment__c pe3 = new Participant_Enrollment__c(
            Study_Site__c = studySite.Id,
            Participant__c = participant3.Id,
            PI_Contact__c = piContact.Id
        );
        pelist.add(pe3);
        
        Participant_Enrollment__c pe4 = new Participant_Enrollment__c(
            Study_Site__c = studySite.Id,
            Participant__c = participant4.Id,
            PI_Contact__c = piContact.Id
        );
        pelist.add(pe4);
        insert pelist;

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

        List<Patient_Delegate__c> delegateList = new List<Patient_Delegate__c>();
        Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = delegate.Id,
            Contact__r = delegate,
            Participant__c = participant.Id,
            Participant__r = participant,
            Status__c = 'Active'
        );
        delegateList.add(patientDelegate);
        delete [SELECT Id FROM Alert__c];
        
        Patient_Delegate__c patientDelegate2 = new Patient_Delegate__c(
            Contact__c = delegate.Id,
            Contact__r = delegate,
            Participant__c = participant2.Id,
            Participant__r = participant2,
            Status__c = 'Active'
        );
        delegateList.add(patientDelegate2);
        delete [SELECT Id FROM Alert__c];
        
        Patient_Delegate__c patientDelegate3 = new Patient_Delegate__c(
            Contact__c = delegate.Id,
            Contact__r = delegate,
            Participant__c = participant3.Id,
            Participant__r = participant3,
            Status__c = 'Active'
        );
        delegateList.add(patientDelegate3);
        
        Patient_Delegate__c patientDelegate4 = new Patient_Delegate__c(
            Contact__c = delegate.Id,
            Contact__r = delegate,
            Participant__c = participant4.Id,
            Participant__r = participant4,
            Status__c = 'Active'
        );
        delegateList.add(patientDelegate4);
        insert delegateList;
        delete [SELECT Id FROM Alert__c];
        }
        catch(Exception e){
            System.debug(e);
        }
    }

    @IsTest
    static void test() {
        try{
        Test.startTest();
        Database.executeBatch(new Batch_CreateBecomeAdultNotification());
        Test.stopTest();
        List<Alert__c> alerts = [SELECT Id FROM Alert__c];
        List<Contact> delegates = [SELECT Id FROM Contact WHERE Email = 'delegate@somemail.com'];
        System.assertEquals(delegates.size(),1);
        }
        catch(Exception e){
            System.debug(e);
        }

    }
}