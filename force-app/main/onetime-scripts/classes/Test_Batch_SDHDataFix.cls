/**
 * Created by Denis Z on 09-Jul-19
 */

@IsTest
private class Test_Batch_SDHDataFix {
    @TestSetup
    static void setup() {
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SendDropOutEmailHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SetCurrentEnrollmentHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateUsersOrSendNotificationsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateWelcomeToStudyAlertHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.CreateNotificationHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdateNameOnPE.class);
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.ChangeUserEmailOnParticipantEmailChangeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.CreatePIOrSendNotificationHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            HCPEnrollmentTriggerHandler.CreateHCPUserOrSendNotificationHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
        );

        Account acc = new Account();
        acc.Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME;
        insert acc;

        TestData.loadTestData();
        ParticipantEnrollmentFactory.createParticipantEnrollmentRecords('1', '2', '3');

        List<Participant_Enrollment__c> peList = [
            SELECT Id, External_Key__c
            FROM Participant_Enrollment__c
            WHERE External_Key__c = '1~2~3'
            LIMIT 1
        ];

        Patient_Visit__c visit = new Patient_Visit__c();
        visit.Name = 'New Visit';
        visit.Completed_Date__c = Date.today();
        visit.Participant_Enrollment__c = peList[0].Id;
        visit.SDH_Key__c = '1~2~3' + 'New Visit' + Date.today();
        insert visit;
    }

    @IsTest
    static void visitResultsUpdateTest() {
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(
            CommunityService.class,
            StubBuilder.newInstance(CommunityService.class)
                .when('createPortalUsers')
                .then(null)
                .when('createParticipantUsers')
                .then(null)
                .build()
        );

        Date visitDate5 = Date.today()+2;
        Test.startTest();
        List<Integration_VisitResult__c> ivrList = new List<Integration_VisitResult__c>();
        Integration_VisitResult__c externalVisitResult1 = new Integration_VisitResult__c();
        externalVisitResult1.USUBJID__c = '1~2~3';
        externalVisitResult1.VISIT__c = 'New Visit';
        externalVisitResult1.VSDTC__c = Date.today();
        externalVisitResult1.TESTCD__c = 'BUNCC';
        externalVisitResult1.Vital_or_Lab__c = 'Vital';
        externalVisitResult1.STNRHI__c = 10;
        externalVisitResult1.STUDYID__c = '10';
        externalVisitResult1.IsDeletedInSDH__c = 'N';
        externalVisitResult1.VISITNUM__c = 1;

        Integration_VisitResult__c externalVisitResult2 = new Integration_VisitResult__c();
        externalVisitResult2.USUBJID__c = '1~2~3';
        externalVisitResult2.VISIT__c = 'New Visit';
        externalVisitResult2.VSDTC__c = Date.today();
        externalVisitResult2.TESTCD__c = 'NYESO';
        externalVisitResult2.Vital_or_Lab__c = 'Vital';
        externalVisitResult2.STNRHI__c = 11;
        externalVisitResult2.STUDYID__c = '10';
        externalVisitResult2.IsDeletedInSDH__c = 'N';
        externalVisitResult2.VISITNUM__c = 2;
        
        Integration_VisitResult__c externalVisitResult3 = new Integration_VisitResult__c();
        externalVisitResult3.USUBJID__c = '1~2~3';
        externalVisitResult3.VISIT__c = 'Unscheduled';
        externalVisitResult3.VSDTC__c = Date.today();
        externalVisitResult3.TESTCD__c = 'BUNCC';
        externalVisitResult3.Vital_or_Lab__c = 'Vital';
        externalVisitResult3.STNRHI__c = 11;
        externalVisitResult3.STUDYID__c = '10';
        externalVisitResult3.IsDeletedInSDH__c = 'N';
        externalVisitResult3.VISITNUM__c = 1.12;
        
        Integration_VisitResult__c externalVisitResult4 = new Integration_VisitResult__c();
        externalVisitResult4.USUBJID__c = '1~2~3';
        externalVisitResult4.VISIT__c = 'Unscheduled';
        externalVisitResult4.VSDTC__c = Date.today();
        externalVisitResult4.TESTCD__c = 'BUNCC';
        externalVisitResult4.Vital_or_Lab__c = 'Vital';
        externalVisitResult4.STNRHI__c = 11;
        externalVisitResult4.STUDYID__c = '10';
        externalVisitResult4.IsDeletedInSDH__c = 'N';
        externalVisitResult4.VISITNUM__c = 1.14;
        
        Integration_VisitResult__c externalVisitResult5 = new Integration_VisitResult__c();
        externalVisitResult5.USUBJID__c = '1~2~3';
        externalVisitResult5.VISIT__c = 'Unscheduled';
        externalVisitResult5.VSDTC__c = visitDate5;
        externalVisitResult5.TESTCD__c = 'BUNCC';
        externalVisitResult5.Vital_or_Lab__c = 'Vital';
        externalVisitResult5.STNRHI__c = 11;
        externalVisitResult5.STUDYID__c = '10';
        externalVisitResult5.IsDeletedInSDH__c = 'N';
        externalVisitResult5.VISITNUM__c = 1.7;
        
        Integration_VisitResult__c externalVisitResult6 = new Integration_VisitResult__c();
        externalVisitResult6.USUBJID__c = '1~2~3';
        externalVisitResult6.VISIT__c = 'Unscheduled';
        externalVisitResult6.VSDTC__c = visitDate5;
        externalVisitResult6.TESTCD__c = 'BUNCC';
        externalVisitResult6.Vital_or_Lab__c = 'Vital';
        externalVisitResult6.STNRHI__c = 11;
        externalVisitResult6.STUDYID__c = '10';
        externalVisitResult6.IsDeletedInSDH__c = 'N';
        externalVisitResult6.VISITNUM__c = 1.73;
        
        
        
        ivrList.add(externalVisitResult1);
        ivrList.add(externalVisitResult2);
        ivrList.add(externalVisitResult3);
        ivrList.add(externalVisitResult4);
        ivrList.add(externalVisitResult5);
        ivrList.add(externalVisitResult6);

        Database.insert(ivrList);
        List<Patient_Visit__c> pvList = [SELECT Id, Participant_Enrollment__r.External_Key__c, Name,
                                         	Completed_Date__c FROM Patient_Visit__c];
        List<Visit_Result__c> visitResultList = new List<Visit_Result__c>();
        Visit_Result__c vr1 = new Visit_Result__c(
        	Result_Type__c='BUN', 
            Patient_Visit__c=pvList[0].Id, 
            SDH_Key__c='1~2~3New Visit'+Date.today()
        );

        Visit_Result__c vr2 = new Visit_Result__c(
        	Actual_Value__c=1.0000, 
            Result_Type__c='New_York_carcinoma',
            Patient_Visit__c=pvList[0].Id, 
            SDH_Key__c='1~2~3New Visit'+Date.today()
        );
        
        Visit_Result__c vr3 = new Visit_Result__c(
        	Actual_Value__c=1.0000, 
            Result_Type__c='BUN',
            Patient_Visit__c=pvList[0].Id, 
            SDH_Key__c='1~2~3Unscheduled'+Date.today()
        );
        
        Visit_Result__c vr5 = new Visit_Result__c(
        	Actual_Value__c=1.0000, 
            Result_Type__c='BUN',
            Patient_Visit__c=pvList[0].Id, 
            SDH_Key__c='1~2~3Unscheduled'+visitDate5
        );
        Visit_Result__c vr6 = new Visit_Result__c(
        	Actual_Value__c=1.0000, 
            Result_Type__c='BUN',
            Patient_Visit__c=pvList[0].Id, 
            SDH_Key__c='1~2~3Unscheduled'+visitDate5
        );
        
        
        visitResultList.add(vr1);
        visitResultList.add(vr2);
        visitResultList.add(vr3);
        visitResultList.add(vr5);
        visitResultList.add(vr6);
        insert visitResultList;
        Database.executeBatch(new Batch_SDHDataFix());
        
        Test.stopTest();
        List<Visit_Result__c> vrList = [Select Id, SDH_Key__c FROM Visit_Result__c WHERE Result_Type__c='New_York_carcinoma'];
        System.assertEquals('1~2~3New Visit'+Date.today()+'2', vrList[0].SDH_Key__c);
    }

}