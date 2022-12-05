public with sharing class PatientDelegateEnrolTriggerHandler {
    public static final String PATIENT_DELEGATE_ACTIVE_STATUS = 'Active';
    public static final String PATIENT_DELEGATE_ONHOLD_STATUS = 'On Hold';
    public static final String PATIENT_DELEGATE_DISCONNECTED_STATUS = 'Disconnected';

    public class CreateNewAssignmentNotification extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            createDelegateAssignmentNotification(newList);
        }
    }
    public class CreateReactivatedNotification extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createDelegateReactivatedNotification(newList, (Map<Id, Patient_Delegate_Enrollment__c>) oldMap);
        }
    }


    @TestVisible
    private static void createDelegateReactivatedNotification(
        List<Patient_Delegate_Enrollment__c> patientDelegateEnrollmentrecrs,
        Map<Id, Patient_Delegate_Enrollment__c> oldMap
    ) {
        List<Patient_Delegate_Enrollment__c> updatedpatientDelegateEnrollmentrecrs = [
            SELECT Id,
            Patient_Delegate__r.Participant__r.Full_Name__c,
            Patient_Delegate__r.Id,
            Welcome_Message_Sent__c,
            Study_Email_Consent__c,
            Study_SMS_Consent__c,
            Welcome_Message_Delivered__c,
            Patient_Delegate__r.Participant__r.Contact__c,
            Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c,
            Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_SMS__c,
            Patient_Delegate__r.Participant__r.First_Name__c,
            Patient_Delegate__r.Participant__r.Last_Name__c,
            Patient_Delegate__r.Contact__c,
            Patient_Delegate__r.Participant__c,   
            Patient_Delegate__r.Participant_Delegate__r.Id,
            Patient_Delegate__r.Participant_Delegate__r.First_Name__c,
            Patient_Delegate__r.Participant_Delegate__r.Last_Name__c,
            Patient_Delegate__r.Participant_Delegate__r.Email__c,
            Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_Emails__c,
            Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_SMS__c,
            Status__c,
            Participant_Enrollment__c,
            Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c,
            Participant_Enrollment__r.Name,
            Participant_Enrollment__r.Clinical_Trial_Profile__c,
            Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c
            FROM Patient_Delegate_Enrollment__c
            WHERE Id IN :patientDelegateEnrollmentrecrs AND Status__c = :PATIENT_DELEGATE_ACTIVE_STATUS
        ];

        List<Patient_Delegate_Enrollment__c> activatedDelegateEnrolrecrds = new List<Patient_Delegate_Enrollment__c>();
        for (Patient_Delegate_Enrollment__c pd : updatedpatientDelegateEnrollmentrecrs) {
            if (
                pd.Status__c == PATIENT_DELEGATE_ACTIVE_STATUS &&
                oldMap.get(pd.Id).Status__c != PATIENT_DELEGATE_ACTIVE_STATUS
            ) {
                activatedDelegateEnrolrecrds.add(pd);
            }
        }

        createNotifications(activatedDelegateEnrolrecrds, 'DelReactivatedNotifType');
    }
    @TestVisible
    private static void createDelegateAssignmentNotification(
        List<Patient_Delegate_Enrollment__c> newPatientDelegateEnrollments
    ) {
        List<Patient_Delegate_Enrollment__c> patientDelegateEnrollRecrds = [
            SELECT Id,
            Patient_Delegate__r.Participant__r.Full_Name__c,
            Patient_Delegate__r.Id,
            Welcome_Message_Sent__c,
            Study_Email_Consent__c,
            Study_SMS_Consent__c,
            Welcome_Message_Delivered__c,
            Patient_Delegate__r.Participant__r.Contact__c,
            Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c,
            Patient_Delegate__r.Participant__r.Contact__r.Participant_Opt_In_Status_SMS__c,
            Patient_Delegate__r.Participant__r.First_Name__c,
            Patient_Delegate__r.Participant__r.Last_Name__c,
            Patient_Delegate__r.Contact__c,
            Patient_Delegate__r.Participant__c,   
            Patient_Delegate__r.Participant_Delegate__r.Id,
            Patient_Delegate__r.Participant_Delegate__r.First_Name__c,
            Patient_Delegate__r.Participant_Delegate__r.Last_Name__c,
            Patient_Delegate__r.Participant_Delegate__r.Email__c,
            Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_Emails__c,
            Patient_Delegate__r.Contact__r.Participant_Opt_In_Status_SMS__c,
            Status__c,
            Participant_Enrollment__c,
            Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c,
            Participant_Enrollment__r.Name,
            Participant_Enrollment__r.Clinical_Trial_Profile__c,
            Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c
            FROM Patient_Delegate_Enrollment__c
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
        Map<Id, Map<Id,Patient_Delegate_Enrollment__c>> delContIdMapOfPerIdPDEnromentMap = new Map<Id, Map<Id,Patient_Delegate_Enrollment__c>>();
        if (patientDelegateEnrollRecrds != null && !patientDelegateEnrollRecrds.isEmpty()) {
            for (Patient_Delegate_Enrollment__c pdelEnrollment : patientDelegateEnrollRecrds) {
                if (delContIdMapOfPerIdPDEnromentMap.containskey(pdelEnrollment.Patient_Delegate__r.Contact__c)){
                    Map<Id, Patient_Delegate_Enrollment__c> perIdPDEnrollment = delContIdMapOfPerIdPDEnromentMap.get(pdelEnrollment.Patient_Delegate__r.Contact__c);
                    perIdPDEnrollment.put(pdelEnrollment.Participant_Enrollment__c, pdelEnrollment);
                    delContIdMapOfPerIdPDEnromentMap.put(pdelEnrollment.Patient_Delegate__r.Contact__c, perIdPDEnrollment);
                }
                else{
                    Map<Id, Patient_Delegate_Enrollment__c> perIdPDEnrollment = new Map<Id, Patient_Delegate_Enrollment__c>();
                    perIdPDEnrollment.put(pdelEnrollment.Participant_Enrollment__c, pdelEnrollment);
                    delContIdMapOfPerIdPDEnromentMap.put(pdelEnrollment.Patient_Delegate__r.Contact__c, perIdPDEnrollment);
                }
            }
        }
        if (delContIdMapOfPerIdPDEnromentMap != null && !delContIdMapOfPerIdPDEnromentMap.isEmpty()) {
               // List<ParticipantEnrollmentPatientDelJunction__c> perDelJunctionRecList = new List<ParticipantEnrollmentPatientDelJunction__c>();
                for (Id delcon : delContIdMapOfPerIdPDEnromentMap.keyset()) { // Each del con
                    //Map<Id, Patient_Delegate_Enrollment__c> perIdPdEnrollMap = delContIdMapOfPerIdPDEnromentMap.get(delcon);
                    for (Id perId : delContIdMapOfPerIdPDEnromentMap.get(delcon).keyset()){
                        if (
                            delContIdMapOfPerIdPDEnromentMap.get(delcon).get(perId).Study_SMS_Consent__c && !delContIdMapOfPerIdPDEnromentMap.get(delcon).get(perId).Welcome_Message_Sent__c 
                            && delContIdMapOfPerIdPDEnromentMap.get(delcon).get(perId).Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c
                        ) {
                            welcomemsgnotifications.addAll(
                                ContactService.addwelcomeNotifications(
                                    delcon,
                                    perId,
                                    NotificationCatalog.MSG_TO_DELEGATE_STUDY_LEVEL_WELCOME_MSG,
                                    true
                                )
                            ); 

                        }
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