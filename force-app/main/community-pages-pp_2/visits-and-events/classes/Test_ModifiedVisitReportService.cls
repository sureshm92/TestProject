/**
 * Created by Jayashree J
 */
@IsTest
private class Test_ModifiedVisitReportService {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void getReportWrapperTest() {
        TestData testData = new TestData();
        testData.ctp.Shareback_Availability_Timing__c = 1;
        update testData.ctp;

        Test.startTest();
        Visit_Result_Type_Sharing__c vrts = new Visit_Result_Type_Sharing__c(
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Include_Countries__c = true,
            Type__c = 'Calcium',
            Sharing_Countries__c = 'US',
            Custom_Tooltip__c = 'Tool tip'
        );
        insert vrts;

        Visit_Result_Type_Sharing__c vrts1 = new Visit_Result_Type_Sharing__c(
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Include_Countries__c = true,
            Type__c = 'Other',
            Sharing_Countries__c = 'US'
        );
        insert vrts1;

        Visit_Result_Type_Sharing__c vrts2 = new Visit_Result_Type_Sharing__c(
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Include_Countries__c = true,
            Type__c = 'Triglycerides',
            Sharing_Countries__c = 'US'
        );
        insert vrts2;

        Visit_Result_Type_Sharing__c vrts3 = new Visit_Result_Type_Sharing__c(
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Include_Countries__c = true,
            Type__c = 'New_York_carcinoma',
            Sharing_Countries__c = 'US',
            Custom_Tooltip__c = 'Tool tip'
        );
        insert vrts3;
        Visit_Result_Type_Sharing__c vrts4 = new Visit_Result_Type_Sharing__c(
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Include_Countries__c = true,
            Type__c = 'Albumin',
            Sharing_Countries__c = 'US'
        );
        insert vrts4;
        Visit_Result_Type_Sharing__c vrts5 = new Visit_Result_Type_Sharing__c(
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Include_Countries__c = true,
            Type__c = 'Height',
            Sharing_Countries__c = 'US'
        );
        insert vrts5;
        Visit_Result_Type_Sharing__c vrts6 = new Visit_Result_Type_Sharing__c(
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Include_Countries__c = true,
            Type__c = 'Programmed_death_ligand_1',
            Sharing_Countries__c = 'US',
            Custom_Tooltip__c = 'Tool tip'
        );
        insert vrts6;

        Visit_Result_Type_Sharing__c vrts7 = new Visit_Result_Type_Sharing__c(
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Include_Countries__c = true,
            Type__c = 'Human_leukocyte_antigen',
            Sharing_Countries__c = 'US'
        );
        insert vrts7;
        Visit_Result_Type_Sharing__c vrts8 = new Visit_Result_Type_Sharing__c(
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Include_Countries__c = true,
            Type__c = 'Weight',
            Sharing_Countries__c = 'US'
        );
        insert vrts8;

        testData.ss.Visit_Results_Sharing__c = true;
        update testData.ss;

        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
        insert vp;

        List<Visit__c> visits = new List<Visit__c>();
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        insert visits;

        List<Patient_Visit__c> patientVisits = new List<Patient_Visit__c>();
        patientVisits.add(
            new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Completed_Date__c = Date.today(),
                Visit__c = visits.get(0).Id,
                Visit_Number__c = 1,
                Name = 'Visit 1'
            )
        );
        patientVisits.add(
            new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Missed',
                Visit__c = visits.get(1).Id,
                Visit_Number__c = 2
            )
        );

        insert patientVisits;
        Id recordTypeIdVisitRes = Schema.SObjectType.Visit_Result__c.getRecordTypeInfosByName()
            .get(VisitReportService.VISIT_RES_RECORD_TYPE_BIO)
            .getRecordTypeId();
        Id recordTypeIdVisitResLabs = Schema.SObjectType.Visit_Result__c.getRecordTypeInfosByName()
            .get('Lab')
            .getRecordTypeId();
        Id recordTypeIdVisitResVital = Schema.SObjectType.Visit_Result__c.getRecordTypeInfosByName()
            .get('Vital')
            .getRecordTypeId();

        List<Visit_Result__c> visitResults = new List<Visit_Result__c>();
        visitResults.add(
            new Visit_Result__c(
                Actual_Value__c = 0.0,
                Patient_Visit__c = patientVisits.get(0).Id,
                Result_Type__c = 'New_York_carcinoma',
                RecordTypeId = recordTypeIdVisitRes
            )
        );
        visitResults.add(
            new Visit_Result__c(
                Actual_Value__c = 80,
                Patient_Visit__c = patientVisits.get(0).Id,
                Result_Type__c = 'Height',
                RecordTypeId = recordTypeIdVisitResVital,
                Measurement__c = 'cm'
            )
        );

        visitResults.add(
            new Visit_Result__c(
                Actual_Value__c = 0.5,
                Patient_Visit__c = patientVisits.get(0).Id,
                Result_Type__c = 'Triglycerides',
                RecordTypeId = recordTypeIdVisitResLabs
            )
        );
        visitResults.add(
            new Visit_Result__c(
                Actual_Value__c = 0.8,
                Patient_Visit__c = patientVisits.get(0).Id,
                Result_Type__c = 'Calcium',
                RecordTypeId = recordTypeIdVisitRes
            )
        );
        visitResults.add(
            new Visit_Result__c(
                Actual_Value__c = -1.0,
                Patient_Visit__c = patientVisits.get(0).Id,
                Result_Type__c = 'Programmed_death_ligand_1',
                RecordTypeId = recordTypeIdVisitRes
            )
        );
        visitResults.add(
            new Visit_Result__c(
                Actual_Value__c = 1.0,
                Patient_Visit__c = patientVisits.get(0).Id,
                Result_Type__c = 'Human_leukocyte_antigen',
                RecordTypeId = recordTypeIdVisitRes
            )
        );

        insert visitResults;

        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_TRIAL_COMPLETE;
        update testData.pe;
        ModifiedVisitReportContainerRemote.ReportDataWrapper testReportDataWrapper;
        ModifiedVisitReportService visRepService = new ModifiedVisitReportService();
        System.runAs(testData.participantUser) {
            testReportDataWrapper = visRepService.getReportDataWrapper(
                testData.pe.Id,
                patientVisits[0].Id
            );
            String peId = patientVisits[0].Id;
            String res = ModifiedVisitReportContainerRemote.getBase64fromVisitSummaryReportPage_Modified(
                peId,
                'false',
                'Visit 1',
                patientVisits[0].Id
            );
            System.assert(testReportDataWrapper != null);
        }
        Test.stopTest();
    }
}
