 /**
 * Created by Julia Kazakevich on 24-Sep-19.
 */

public with sharing class Batch_DataBecomesAvailable extends Batch_ScheduledAbstract {
    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator(
            [
                SELECT
                    Id,
                    Completed_Date__c,
                    Participant_Enrollment__c,
                    Participant_Enrollment__r.Participant__r.Mailing_Country_Code__c,
                    Participant_Enrollment__r.Clinical_Trial_Profile__c,
                    Participant_Enrollment__r.Clinical_Trial_Profile__r.Shareback_Availability_Timing__c,
                    Participant_Enrollment__r.Participant_Contact__r.Visit_Results_OptIn__c,
                    Visit_Number__c,
                    (
                        SELECT
                            Id,
                            Actual_Value__c,
                            Max_Value__c,
                            Measurement__c,
                            Min_Value__c,
                            Patient_Visit__r.Completed_Date__c,
                            Patient_Visit__r.Notified__c,
                            Patient_Visit__r.Participant_Enrollment__r.Participant_Contact__c,
                            Patient_Visit__r.Participant_Enrollment__r.Participant_Contact__r.Participant_Opt_In_Status_Emails__c,
                            Result_Type__c
                        FROM Visit_Results__r
                    )
                FROM Patient_Visit__c
                WHERE
                    Status__c = 'Completed'
                    AND Notified__c = FALSE
                    AND Participant_Enrollment__r.Participant_Contact__c != NULL
                ORDER BY Visit_Number__c, Completed_Date__c
            ]
        );
    }

    public void execute(Database.BatchableContext param1, List<Patient_Visit__c> patientVisits) {
        Set<Id> setOfCTPIds = new Set<Id>();
        Map<Id, Clinical_Trial_Profile__c> ctpById = new Map<Id, Clinical_Trial_Profile__c>();
        for (Patient_Visit__c patVisit : patientVisits) {
            setOfCTPIds.add(patVisit.Participant_Enrollment__r.Clinical_Trial_Profile__c);
        }
        List<Clinical_Trial_Profile__c> listOfCTP = [
            SELECT
                Id,
                Visit_Data_Shareback__c,
                (
                    SELECT Id, Include_Countries__c, Type__c, Sharing_Countries__c
                    FROM Visit_Result_Type_Sharings__r
                )
            FROM Clinical_Trial_Profile__c
            WHERE Id IN :setOfCTPIds
        ];

        for (Clinical_Trial_Profile__c clinicalTrial : listOfCTP) {
            ctpById.put(clinicalTrial.Id, clinicalTrial);
        }
        List<Visit_Result__c> listOfResult = VisitResultSharingService.getAvailableVisitResults(
            patientVisits,
            true,
            ctpById,
            ''
        );
        List<Notification__c> notifications = new List<Notification__c>();

        Set<Patient_Visit__c> updatedPatientVisits = new Set<Patient_Visit__c>();
        Set<Id> recipientIds = new Set<Id>();
        for (Visit_Result__c visitResultObj : listOfResult) {
            Contact recipient = visitResultObj.Patient_Visit__r.Participant_Enrollment__r.Participant_Contact__r;
            if (!recipientIds.contains(recipient.Id)) {
                recipientIds.add(recipient.Id);
                notifications.add(
                    new Notification__c(
                        Recipient__c = recipient.Id,
                        WhatId__c = visitResultObj.Patient_Visit__r.Participant_Enrollment__c,
                        Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_DATA_AVAILABLE_TYPE,
                        Status__c = NotificationService.NOTIFICATION_STATUS_PENDING
                    )
                );
            }
            Patient_Visit__c patientVisit = visitResultObj.Patient_Visit__r;
            patientVisit.Notified__c = true;
            updatedPatientVisits.add(patientVisit);
        }
        update new List<Patient_Visit__c>(updatedPatientVisits);
        insert notifications;
    }

    public override Type getType() {
        return Batch_DataBecomesAvailable.class;
    }

    public override String getBatchDescription() {
        return 'This job sends Emails and SMS when new Visit Data becomes available';
    }

    public override String getRecommendedIntervalMode() {
        return Batch_ScheduledAbstract.INTERVAL_HOURS;
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 1;
    }
}
