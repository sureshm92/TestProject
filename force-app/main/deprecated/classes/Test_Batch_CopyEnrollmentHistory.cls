/**
 * Created by Igor Malyuta on 09.08.2019.
 */

@IsTest
private class Test_Batch_CopyEnrollmentHistory {

    @IsTest
    static void testReferred() {
        disableTriggers();

        PSE_Status_History__c pseHistoryBefore = [SELECT Id, Changed_Date__c, Status__c FROM PSE_Status_History__c];

        Test.startTest();
        Batch_CopyEnrollmentHistory.run();
        Test.stopTest();

        Participant_Enrollment__c enrollment = [
                SELECT Id,
                        Participant_Status__c,
                (SELECT
                        Id,
                        Date__c,
                        Status__c
                FROM Participant_Enrollment_Status_History__r)
                FROM Participant_Enrollment__c
        ];
        System.assertEquals(PEStatusState.PE_STATUS_TREATMENT_PERIOD_STARTED, enrollment.Participant_Status__c);

        List<Participant_Study_Enrollment__c> pse = [SELECT Id FROM Participant_Study_Enrollment__c];
        System.assert(pse.isEmpty());

        List<PSE_Status_History__c> pseHistoryAfter = [SELECT Id FROM PSE_Status_History__c];
        System.assert(pseHistoryAfter.isEmpty());

        for(Participant_Enrollment_Status_History__c history : enrollment.Participant_Enrollment_Status_History__r) {
            if(history.Date__c.date() == System.today()) {
                System.assertEquals(pseHistoryBefore.Changed_Date__c.date(), history.Date__c.date());
                System.assertEquals(pseHistoryBefore.Status__c, history.Status__c);
            }
        }
    }

    @TestSetup
    private static void setup() {
        disableTriggers();

        Participant__c participant = new Participant__c(
                First_Name__c = 'Participant',
                Last_Name__c = 'Participant',
                Phone__c = '55313535',
                Email__c = 'part1@email.com'
        );
        insert participant;

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
                BillingLatitude = 41.766594,
                BillingLongitude = -74.991509
        );
        accounts.add(studySiteAccount);
        insert accounts;

        Contact piContact = new Contact(
                FirstName = 'PI',
                LastName = 'PI',
                Email = 'pi@emil.com',
                AccountId = piAccount.Id
        );
        insert piContact;

        Clinical_Trial_Profile__c study = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'CTP1',
                Override_Recruitment_Status__c = 'Actively Enrolling',
                NCT_Number__c = 'NCT00000001',
                Link_to_Pre_screening__c = 'some link',
                Study_Title__c = 'Some Title',
                Study_Code_Name__c = 'Some Code Name',
                Suppress_Participant_Emails__c = false,
                Synch_with_TMDH__c = true,
                Include_in_RP_trial_search__c = true,
                Patient_Portal_Enabled__c = true,
                Shareback_Settings_On_Participant_Level__c = true,
                Shareback_Availability_Timing__c = 1,
                Visit_Data_Shareback__c = true
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

        Participant_Enrollment__c pe = new Participant_Enrollment__c(
                Clinical_Trial_Profile__c = study.Id,
                Patient_ID__c = 'SomePatientId1',
                Referral_Source__c = 'HCP',
                Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_REFERRAL_SENT_TO_PI,
                Participant__c = participant.Id,
                PI_Contact__c = piContact.Id,
                Screening_ID__c = 'PESCR1',
                Study_Site__c = studySite.Id
        );
        insert pe;

        Participant_Study_Enrollment__c pse = new Participant_Study_Enrollment__c(
                Status__c = PEStatusState.PE_STATUS_TREATMENT_PERIOD_STARTED,
                Participant__c = participant.Id,
                Participant_Enrollment__c = pe.Id
        );
        insert pse;
        
        pe.Participant_Study_Enrollment__c = pse.Id;
        update pe;

        PSE_Status_History__c pseStatusHistory = new PSE_Status_History__c(
                Status__c = pse.Status__c,
                Changed_Date__c = System.now(),
                PSE__c = pse.Id
        );
        insert pseStatusHistory;
    }

    private static void disableTriggers() {
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.CreateContactsForParticipantsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdatePEAndContactLastNameHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.ChangeUserEmailOnParticipantEmailChangeHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.PrepareCityStateFieldsHandler.class);

        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.DeleteStatusHistoryOnDeleteHandler.class);
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.CreatePIOrSendNotificationHandler.class);
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.SwitchContactUserModeHandler.class);
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.CreateStatusHistoryHandler.class);

        Batch_CopyEnrollmentHistory.disableTriggers();
    }
}