/**
 * Created by Sravani Dasari on 5/21/2019.
 */

@IsTest
private class Test_TrialMatchPageRemote {
    @IsTest
    static void getMatchCTPs_test() {
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.createVisitsSchedule.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.CreateNotificationHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.SendEmailIfSSWasChanged.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SendFOVtoAPI.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.UnenrollorCancelPer.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateMissingStatuses.class
        );
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.EcoaEvents.class);
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.DefaultEcoaTask.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.UpdatePatientConsent.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.StudyConsentTimestamps.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandler.class
        );
        TestData.loadTestData();
        Test.startTest();
        Clinical_Trial_Profile__c ctp = [
            SELECT
                Id,
                Therapeutic_Area__c,
                Study_Code_Name__c,
                Study_Title__c,
                Protocol_ID__c,
                Patient_Portal_Enabled__c,
                Terms_and_Conditions__c,
                Initial_Visit_Required__c,
                Participant_Workflow_Final_Step__c,
                Final_Consent_Required__c,
                Enable_for_Call_Center_Support__c,
                Link_to_Medical_Record_Review__c,
                Link_to_Pre_screening__c
            FROM Clinical_Trial_Profile__c
            WHERE NCT_Number__c = 'NCT99999999'
        ];
        Participant__c participant = [
            SELECT
                Id,
                Name,
                First_Name__c,
                Last_Name__c,
                Email__c,
                Status__c,
                Balance__c,
                Contact__c,
                Mailing_Country_Code__c,
                Mailing_Country__c,
                Contact__r.AccountId
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
        Participant_Enrollment__c pe = [
            SELECT
                Id,
                Name,
                External_Key__c,
                Participant_Contact__c,
                Participant_Status__c,
                Participant_Contact__r.Visit_Results_OptIn__c,
                Clinical_Trial_Profile__r.Shareback_Availability_Timing__c,
                Initial_visit_scheduled_date__c,
                Initial_visit_occurred_date__c,
                Initial_visit_scheduled_time__c,
                Initial_visit_occurred_flag__c,
                Initial_visit_scheduled_flag__c,
                Screening_ID__c,
                Participant__c,
                Medical_Record_Review_Completed_Date__c,
                Study_Site__r.Principal_Investigator__c,
                Study_Site__r.Principal_Investigator__r.Name,
                Study_Site__r.Principal_Investigator__r.Title,
                Participant__r.Mailing_Country_Code__c,
                Participant__r.Mailing_Country__c
            FROM Participant_Enrollment__c
            WHERE Participant__c = :participant.Id
        ];
        User participantUser = [
            SELECT Id, ContactId, LastName
            FROM User
            WHERE LastName = :participant.Name
        ];
        TrialMatchPageRemote.TrialMatchContainer container;
        Trial_Match__c tm = new Trial_Match__c(
            Clinical_Trial_Profile__c = ctp.id,
            Is_Eligible__c = true,
            Matched_Date__c = Datetime.now().dateGmt(),
            Matching_Details__c = 'Sample Matching Details',
            Matching_Score__c = 77,
            Is_User_notified__c = true,
            Participant_Enrollment__c = pe.id,
            Passed__c = false,
            Therapeutic_Area__c = 'Therapeutic Area Sample test data'
        );
        insert tm;

        System.runAs(participantUser) {
            TrialMatchPageRemote.TrialMatchCTP tmd = new TrialMatchPageRemote.TrialMatchCTP();
            tmd.ctp = ctp;
            tmd.trm = tm;
            tmd.isEnrollingCTP = true;
            tmd.ctpid = ctp.id;
            tmd.TherapeuticArea = tm.Therapeutic_Area__c;
            tmd.StudyCodeName = ctp.Study_Code_Name__c;
            tmd.OfficialTitle = 'OT_Virus_101/R/PNHV/FCY/VPY';
            tmd.matchDate = String.valueOf(tm.Matched_Date__c);
            container = new TrialMatchPageRemote.TrialMatchContainer();
            container.trialmatchctps = new List<TrialMatchPageRemote.TrialMatchCTP>{ tmd };
        }

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(
            TrialMatchHelper.class,
            StubBuilder.newInstance(TrialMatchHelper.class)
                .when('getInitTrialMatchContainer')
                .then(container)
                .build()
        );
        System.assertEquals(1, TrialMatchPageRemote.getMatchCTPs(pe.id).trialmatchctps.size());
        try {
            PageReference pageRef = Page.TrialMatchData;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', pe.id);
            TrialMatchPageRemote.getBase64TrialMatchData(pe.id);
        } catch (AuraHandledException e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void getMatchCTPsWithException_test() {
        Boolean isExceptionThrown = false;
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(
            TrialMatchHelper.class,
            StubBuilder.newInstance(TrialMatchHelper.class)
                .when('getInitTrialMatchContainer')
                .then(new AuraHandledException(''))
                .build()
        );
        try {
            TrialMatchPageRemote.getMatchCTPs(null);
        } catch (AuraHandledException e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        System.assert(true, isExceptionThrown);
    }
}
