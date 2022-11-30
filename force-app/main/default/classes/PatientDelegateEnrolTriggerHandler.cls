public with sharing class PatientDelegateEnrolTriggerHandler {
    public PatientDelegateEnrolTriggerHandler() {

    }
    @TestVisible
    private static void createDelegateAssignmentNotification(
        List<Patient_Delegate_Enrollment__c> newPatientDelegateEnrollments
    ) {
        List<Patient_Delegate_Enrollment__c> patientDelegateEnrollRecrds = [
            SELECT Contact__c, Participant__c, Participant__r.Contact__c
            FROM Patient_Delegate__c
            WHERE Id IN :newPatientDelegateEnrollments AND Status__c = :PATIENT_DELEGATE_ACTIVE_STATUS
        ];
        createNotifications(patientDelegateEnrollRecrds, 'DelNewAssignNotifType');
    }

    private static List<Notification__c> createwelcomemsgSMSNotifications(
        List<Patient_Delegate_Enrollment__c> patientDelegateEnrollRecrds
    ) {
        Set<Id> participantIdSet = new Set<Id>();
        Set<Id> proccessedPlatDelCon = new Set<Id>();
        Set<Id> proccessedStudyDelCon = new Set<Id>();
        Map<Id, Patient_Delegate_Enrollment__c> patientdelegateslist = new Map<Id, Patient_Delegate_Enrollment__c>();
        List<Notification__c> welcomemsgnotifications = new List<Notification__c>();
        Map<Id, Map<Participant_Enrollment__c,Patient_Delegate_Enrollment__c>> delContIdMapOfPerIdPDEnromentMap = new Map<Participant_Enrollment__c, Map<Id,Patient_Delegate_Enrollment__c>>();
        if (patientDelegateEnrollRecrds != null && !patientDelegateEnrollRecrds.isEmpty()) {
            for (Patient_Delegate_Enrollment__c delegate : patientDelegateEnrollRecrds) {
                if (!delContIdMapOfPerIdPDEnromentMap.containskey(pdelEnrollment.Patient_Delegate__r.Contact__c)){
                    Map<Id, Patient_Delegate_Enrollment__c> perIdPDEnrollment = delContIdMapOfPerIdPDEnromentMap.get(pdelEnrollment.Patient_Delegate__r.Contact__c);
                    perIdPDEnrollment.put(pdelEnrollment.Participant_Enrollment__r, pdelEnrollment);
                    delContIdMapOfPerIdPDEnromentMap.put(pdelEnrollment.Patient_Delegate__r.Contact__c, perIdPDEnrollment);
                }
                else{
                    Map<Id, Patient_Delegate_Enrollment__c> perIdPDEnrollment = new Map<Id, Patient_Delegate_Enrollment__c>();
                    perIdPDEnrollment.put(pdelEnrollment.Participant_Enrollment__r, pdelEnrollment);
                    delContIdMapOfPerIdPDEnromentMap.put(pdelEnrollment.Patient_Delegate__r.Contact__c, perIdPDEnrollment);
                }
            }
        }
        if (delContIdMapOfPerIdPDEnromentMap != null && !delContIdMapOfPerIdPDEnromentMap.isEmpty()) {
               // List<ParticipantEnrollmentPatientDelJunction__c> perDelJunctionRecList = new List<ParticipantEnrollmentPatientDelJunction__c>();
                for (Id delcon : delContIdMapOfPerIdPDEnromentMap.keyset()) {
                    Map<Patient_Delegate_Enrollment__c, Patient_Delegate_Enrollment__c> perPdEnroll = delContIdMapOfPerIdPDEnromentMap.get(delcon);
                    for (Patient_Delegate_Enrollment__c per : perPdEnroll.keyset()){
                        if (
                            perPdEnroll.get(per).SMS_Consent__c && !perPdEnroll.get(per).Welcome_Message_Sent__c &&
                            per.Study_Site__r.SMS_Are_Available__c
                        ) {
                            welcomemsgnotifications.addAll(
                                ContactService.addwelcomeNotifications(
                                    delcon,
                                    per.Id,
                                    NotificationCatalog.MSG_TO_DELEGATE_STUDY_LEVEL_WELCOME_MSG,
                                    true
                                )
                            ); 

                        }
                    }
                }
         
        Map<Id, Contact> delconMaplst = new Map<Id, Contact>(
            [
                SELECT Id, Welcome_Message_Sent__c, Welcome_Message_Delivered__c
                FROM Contact
                WHERE ID IN :delContIdMapOfPerIdPDEnromentMap.keyset()
            ]
        );
        if (!delContIdMapOfPerIdPDEnromentMap.isEmpty() && delContIdMapOfPerIdPDEnromentMap != null) {
            for (Id delCont : delContIdMapOfPerIdPDEnromentMap.keySet()) {
                if (
                    !proccessedPlatDelCon.contains(delCont) &&
                    delconMaplst.containskey(delCont) &&
                    !delconMaplst.get(delCont).Welcome_Message_Sent__c &&
                    delContIdMapOfPerIdPDEnromentMap.get(delCont) != null
                ) {
                    proccessedPlatDelCon.add(delCont);
                        
                     }
                    }
                }
            }
        }
        return welcomemsgnotifications;
    }
    private static void createNotifications(
        List<Patient_Delegate_Enrollment__c> patientDelegates,
        String templateProperty
    ) {
        Set<Id> participantContacts = new Set<Id>();
        List<Notification__c> notifications = new List<Notification__c>();
        Map<Id, List<Participant__c>> participantsByDelContId = new Map<Id, List<Participant__c>>();
        if (
            templateProperty == 'DelReactivatedNotifType' ||
            templateProperty == 'DelNewAssignNotifType'
        ) {
            notifications.addAll(createwelcomemsgSMSNotifications(patientDelegates));
        }
        
        // Add logic For minor participants
        if (!notifications.isEmpty())
            insertNotifications(notifications);
    }

    private static void insertNotifications(List<Notification__c> notifications) {
        if (System.isFuture() || System.isBatch()) {
            insert notifications;
        } else {
            insertNotificationsAsync(JSON.serialize(notifications));
        }
    }

    @Future
    private static void insertNotificationsAsync(String notificationsJSON) {
        List<Notification__c> newNotifications = (List<Notification__c>) JSON.deserialize(
            notificationsJSON,
            List<Notification__c>.class
        );
        insert newNotifications;
    }


}
