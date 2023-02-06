/**
 * @description       : This Batch will be creating the Pre-Enrollment Patient Visit records for the existing Participant Enrollments which are on Pre
 *                      Enrollment statuses and Pre-Enrollment Visits are not created for them.
 *                    : This batch will run manually for the first time to create the Patient Visits for the Existing PERs and also it will be auto launch
 *                      whenever the Pre Enrollment toggle will be "ON" at CTP.
 * @author            : Krishna Mahto
 * @group             : IQVIA Patient Portal
 * @last modified on  : 03-07-2022
 * @last modified by  : Krishna Mahto
 **/ 
global without sharing class Batch_CreatePreEnrollVistsForExtngPERs implements Database.Batchable<SObject> {
    private Set<Id> ctpIds;
    private Set<Id> ssIds;

    global Batch_CreatePreEnrollVistsForExtngPERs() {
    }

    global Batch_CreatePreEnrollVistsForExtngPERs(Set<Id> ctpIds) {
        this.ctpIds = ctpIds;
    }

    global Batch_CreatePreEnrollVistsForExtngPERs(Set<Id> ssIds, Boolean isNewTravelVendor) {
        this.ssIds = ssIds;
    }
    //Start Method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        List<String> peStatuses = PEStatusState.PE_STATUS_GROUP_PRE_ENROLLMENT;
        String queryString =
            'SELECT Id, ' +
            'Participant_Status__c, ' +
            'Study_Site__c, ' +
            'Clinical_Trial_Profile__r.Received_Until_Consent_Is_Available__c, ' +
            'Clinical_Trial_Profile__r.Enrolled_Or_Randomized_Consent_Available__c, ' +
            'Clinical_Trial_Profile__r.CommunityTemplate__c ' +
            'FROM Participant_Enrollment__c ' +
            'WHERE ' +
            'Participant_Status__c IN :peStatuses ' +
            'AND (Clinical_Trial_Profile__r.Received_Until_Consent_Is_Available__c = TRUE ' +
            'OR Clinical_Trial_Profile__r.Enrolled_Or_Randomized_Consent_Available__c = TRUE) ' +
            'AND Id NOT IN (SELECT Participant_Enrollment__c ' +
            'FROM Patient_Visit__c ' +
            'WHERE Is_Pre_Enrollment_Patient_Visit__c = TRUE) ';
        if (ctpIds != null && !ctpIds.isEmpty()) {
            queryString += 'AND Clinical_Trial_Profile__c IN :ctpIds ';
        }
        if (ssIds != null && !ssIds.isEmpty()) {
            queryString += 'AND Study_Site__c IN :ssIds ';
        }
        return Database.getQueryLocator(queryString);
    }

    //Execute Method
    global void execute(Database.BatchableContext bc, List<Participant_Enrollment__c> scope) {
        Map<Id, Participant_Enrollment__c> peWithCTPPreEnrollConsentIsOnMap = new Map<Id, Participant_Enrollment__c>();
        Map<Id, Participant_Enrollment__c> peEligibilityQualified = new Map<Id, Participant_Enrollment__c>();
        List<Patient_Visit__c> patentientVisitsToInsert = new List<Patient_Visit__c>();

        for (Participant_Enrollment__c pe : scope) {
            if(pe.Clinical_Trial_Profile__r.CommunityTemplate__c !='PatientPortal') {
                peWithCTPPreEnrollConsentIsOnMap.put(pe.id, pe);
            }
        }
        //check Pre Enrollment Patient Visit Creation eligibility.
        PreEnrollmentPatientVisitServie.bypassPatientVisitUpdFromBatch = true;
        peEligibilityQualified = PreEnrollmentPatientVisitServie.checkPreEnrollmentVisitEligibility(
            peWithCTPPreEnrollConsentIsOnMap
        );
        if (peEligibilityQualified != null && !peEligibilityQualified.isEmpty()) {
            //Create Pre Enrollment patient Visits record data.
            patentientVisitsToInsert = PreEnrollmentPatientVisitServie.preparePreEnrollmentVisits(
                peWithCTPPreEnrollConsentIsOnMap
            );
        }
        //Insert Pre Enrollment patient Visits.
        if (patentientVisitsToInsert != null && !patentientVisitsToInsert.isEmpty()) {
            Database.insert(patentientVisitsToInsert, false);
        }
    }

    //Finish Method
    global void finish(Database.BatchableContext bc) {
    }
}
