/**
 * Created by user on 10/7/2019.
 */

@IsTest
private class Test_Batch_IntegrationVisitProcess {
    @IsTest
    static void testBatchExecution() {
        List<Account> accounts = new List<Account>();
        Account participantsAccount = new Account(
                Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
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
                AccountId = piAccount.Id
        );
        contacts.add(piContact);
        insert contacts;

        Clinical_Trial_Profile__c study = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'CTP1',
                Override_Recruitment_Status__c = 'Actively Enrolling',
                NCT_Number__c = 'NCT99999999',
                Link_to_Pre_screening__c = 'some link',
                Study_Title__c = 'Some Title',
                Study_Code_Name__c = 'Some Code Name',
                Suppress_Participant_Emails__c = false,
                Participating_in_Digital_Recruitment__c = 'YES',
                Participating_in_Rocket_Referral__c = 'YES',
                Participating_in_Patient_Portal__c = 'Yes',
                Shareback_Settings_On_Participant_Level__c = true,
                Shareback_Availability_Timing__c = 1,
                Visit_Data_Shareback__c = true,
                Synch_with_TMDH__c = true
        );
        insert study;

        Study_Site__c studySite = new Study_Site__c(
                Principal_Investigator__c = piContact.Id,
                Clinical_Trial_Profile__c = study.Id,
                Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
                Site__c = studySiteAccount.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false,
                Study_Site_Number__c = 'SS1'
        );
        insert studySite;

        Participant__c participant = new Participant__c(
                First_Name__c = 'Max',
                Last_Name__c = 'James',
                Birth_Year__c = '1985',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'NY',
                Email__c = 'MaxJames@mail.com'
        );
        insert participant;

        Participant_Enrollment__c participantEnrollment = new Participant_Enrollment__c(
                Participant__c = participant.Id,
                Screening_ID__c = 'PE1',
                Study_Site__c = studySite.Id
        );
        insert participantEnrollment;

        Test.startTest();

        List<Integration_Visit__c> externalVisits = new List<Integration_Visit__c>();
        Integration_Visit__c visit = new Integration_Visit__c(
                USUBJID__c = 'CTP1~SS1~PE1',
                SVSTDTC__c = Date.today(),
                VISIT__c = 'New Visit 1',
                VISITNUM__c = 1,
                IsDeletedInSDH__c = 'N'
        );
        externalVisits.add(visit);
        insert externalVisits;

        List<Integration_VisitResult__c> visitResults = new List<Integration_VisitResult__c>();
        Integration_VisitResult__c result = new Integration_VisitResult__c(
                USUBJID__c = 'CTP1~SS1~PE1',
                Vital_or_Lab__c = 'Lab',
                STUDYID__c = '10',
                TESTCD__c = 'BUNCC',
                VSDTC__c = Date.today(),
                VISIT__c = 'New Visit 1',
                IsDeletedInSDH__c = 'N'
        );
        Integration_VisitResult__c result1 = new Integration_VisitResult__c(
                USUBJID__c = 'CTP1~SS1~PE1',
                Vital_or_Lab__c = 'Biomarker',
                STUDYID__c = '10',
                TESTCD__c = 'NYESO-1',
                VSDTC__c = Date.today(),
                VISIT__c = 'New Visit 1',
                STRESN__c = 1,
                IsDeletedInSDH__c = 'N'
        );
        visitResults.add(result);
        visitResults.add(result1);
        insert visitResults;

        Database.executeBatch(new Batch_IntegrationVisitProcess());
        Test.stopTest();

        List<Patient_Visit__c> patientVisits = [
                SELECT Id, Participant_Enrollment__c
                FROM    Patient_Visit__c
        ];
        List<Participant_Enrollment__c> enrollments = [
                SELECT Id
                FROM Participant_Enrollment__c
        ];
        System.assert(patientVisits.size() > 0, 'Visits not found');
        System.assertEquals(enrollments.get(0).Id, patientVisits.get(0).Participant_Enrollment__c);

        List<Visit_Result__c> results = [SELECT Id, Patient_Visit__c, Result_Type__c, Actual_Value__c FROM Visit_Result__c];
        System.assertEquals(2, results.size());
    }
}