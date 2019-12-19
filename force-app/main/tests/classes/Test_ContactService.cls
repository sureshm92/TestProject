/**
 * Created by Leonid Bartenev
 */

@IsTest
private without sharing class Test_ContactService {
    

    @IsTest
    private static void defaultPEOnContact() {
        TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.CreateNotificationHandler.class);

        Account participantsAccount = new Account(
                Name = 'Participant'
        );
        insert participantsAccount;
        Participant__c participant = new Participant__c(
                First_Name__c = 'Participant',
                Last_Name__c = 'Participant',
                Phone__c = '55313535',
                Email__c = 'part1@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL'
        );
        insert participant;
        Participant_Enrollment__c pe1 = new Participant_Enrollment__c(
                Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
                Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
                Patient_ID__c = 'SomePatientId1',
                Referral_Source__c = 'HCP',
                Participant_Status__c = PEStatusState.PE_STATUS_CONTACT_ATTEMPT_IN_PROGRESS,
                Participant__c = participant.Id,
                Screening_ID__c = 'PESCR1'
        );
        insert pe1;
        Contact delegate1 = new Contact(LastName = 'Del1');
        insert delegate1;
        Patient_Delegate__c pd1 = new Patient_Delegate__c(Participant__c = participant.Id, Contact__c = delegate1.Id);
        insert pd1;
        
        System.debug('>>> ' + [SELECT Id FROM Patient_Delegate__c WHERE Participant__c IN: (new List<Id>{participant.Id})]);
        
        Test.startTest();
        
        //case1:
        Id pContactId = [SELECT Id, Contact__c FROM Participant__c WHERE Id =: participant.Id].Contact__c;
        Contact contact = [SELECT Id, Current_Participant_Enrollment__c FROM Contact WHERE Id =: pContactId];
        System.assert(contact.Current_Participant_Enrollment__c == pe1.Id);
        delegate1 = [SELECT Id, Current_Participant_Enrollment__c FROM Contact WHERE Id =: delegate1.Id];
        System.assert(delegate1.Current_Participant_Enrollment__c == pe1.Id);
    
        //case2:
        pe1.Participant_Status__c = PEStatusState.PE_STATUS_DROP_OUT;
        update pe1;
        contact = [SELECT Id, Current_Participant_Enrollment__c FROM Contact WHERE Id =: pContactId];
        System.assert(contact.Current_Participant_Enrollment__c == null);
        delegate1 = [SELECT Id, Current_Participant_Enrollment__c FROM Contact WHERE Id =: delegate1.Id];
        System.assert(delegate1.Current_Participant_Enrollment__c == null);

        //case3:
        Participant_Enrollment__c pe2 = new Participant_Enrollment__c(
                Patient_ID__c = 'SomePatientId2',
                Referral_Source__c = 'HCP',
                Participant_Status__c = PEStatusState.PE_STATUS_CONTACT_ATTEMPT_IN_PROGRESS,
                Participant__c = participant.Id,
                Screening_ID__c = '1343242'
        );
        insert pe2;
        contact = [SELECT Id, Current_Participant_Enrollment__c FROM Contact WHERE Id =: pContactId];
        System.assert(contact.Current_Participant_Enrollment__c == pe2.Id);
        delegate1 = [SELECT Id, Current_Participant_Enrollment__c FROM Contact WHERE Id =: delegate1.Id];
        System.assert(delegate1.Current_Participant_Enrollment__c == pe2.Id);

        //case4:
        pe1.Participant_Status__c = PEStatusState.PE_STATUS_CONTACT_ATTEMPT_IN_PROGRESS;
        update pe1;
        contact = [SELECT Id, Current_Participant_Enrollment__c FROM Contact WHERE Id =: pContactId];
        System.assert(contact.Current_Participant_Enrollment__c == pe2.Id);
        delegate1 = [SELECT Id, Current_Participant_Enrollment__c FROM Contact WHERE Id =: delegate1.Id];
        System.assert(delegate1.Current_Participant_Enrollment__c == pe2.Id);
    
        //case5:
        delete pd1;
        delegate1 = [SELECT Id, Current_Participant_Enrollment__c FROM Contact WHERE Id =: delegate1.Id];
        System.assert(delegate1.Current_Participant_Enrollment__c == null);
    
        Test.stopTest();
    }

}