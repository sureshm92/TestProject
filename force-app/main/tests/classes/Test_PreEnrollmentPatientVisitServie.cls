@isTest
public class Test_PreEnrollmentPatientVisitServie {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @isTest
    static void testPreEnrollmentPatientVisitServie() {
        TestData testData = new TestData();
        Test.startTest();
        Map<Id, Id> peIdInPreEnrollmentStatusStudySiteMap = new Map<Id, Id>();
        Map<Id, Participant_Enrollment__c> peWithCTPPreEnrollConsentIsOnMap = new Map<Id, Participant_Enrollment__c>();
        Map<Id, Participant_Enrollment__c> peEligibilityQualified = new Map<Id, Participant_Enrollment__c>();
        List<Participant_Enrollment__c> peList = [
            SELECT
                Id,
                Study_Site__c,
                Clinical_Trial_Profile__c,
                Participant_Status__c,
                Clinical_Trial_Profile__r.Enrolled_Or_Randomized_Consent_Available__c
            FROM Participant_Enrollment__c
        ];
        Participant_Enrollment__c pe = new Participant_Enrollment__c();
        pe.Id = peList[0].Id;
        update pe;
        peWithCTPPreEnrollConsentIsOnMap.put(pe.ID, pe);
        List<Participant_Enrollment__c> peList1 = [
            SELECT
                Id,
                Study_Site__c,
                Clinical_Trial_Profile__c,
                Participant_Status__c,
                Clinical_Trial_Profile__r.Enrolled_Or_Randomized_Consent_Available__c
            FROM Participant_Enrollment__c
        ];
        Participant_Enrollment__c pe1 = new Participant_Enrollment__c();
        pe1.Id = peList1[0].Id;
        update pe1;
        list<Patient_Visit__c> pv = [SELECT Id FROM Patient_Visit__c];
        peEligibilityQualified.put(pe1.ID, pe1);
        peIdInPreEnrollmentStatusStudySiteMap.put(pe1.ID, pe.Id);
        PreEnrollmentPatientVisitServie.processPreEnrollmentPatientVisits(
            peIdInPreEnrollmentStatusStudySiteMap
        );
        PreEnrollmentPatientVisitServie.checkPreEnrollmentVisitEligibility(
            peWithCTPPreEnrollConsentIsOnMap
        );
        //PreEnrollmentPatientVisitServie.preparePreEnrollmentVisits(peEligibilityQualified);
        PreEnrollmentPatientVisitServie.updatePreEnrollmentVisitAsCompleted(
            pv,
            peWithCTPPreEnrollConsentIsOnMap
        );
        Test.stopTest();
    }
}
