/**
 * Created by Leonid Bartenev
 */

public without sharing class PatientDelegateTriggerHandler {
    public static final String PATIENT_DELEGATE_ACTIVE_STATUS = 'Active';
    public static final String PATIENT_DELEGATE_ONHOLD_STATUS = 'On Hold';
    public static final String PATIENT_DELEGATE_DISCONNECTED_STATUS = 'Disconnected';

    // Handlers: -------------------------------------------------------------------------------------------------------

    public class SetDefaultPatientDelegateStatusHandler extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            setDefaultPatientStatus(newList);
        }
    }

    public class UpdatePermissionSetAssignments extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            List<Patient_Delegate__c> lstPd = (Patient_Delegate__c[]) newList;
            List<Patient_Delegate__c> tempListPD = new List<Patient_Delegate__c>();
            for (Patient_Delegate__c objPd : lstPd) {
                if (
                    objPd.Status__c == PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS
                ) {
                    tempListPD.add(objPd);
                    break;
                }
            }
            if (!tempListPD.isEmpty())
                updatePermissionSets(newList);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updatePermissionSets(newList);
        }

        public override void afterDelete(List<SObject> oldList) {
            updatePermissionSets(oldList);
        }
    }

    public class CreateNewAssignmentNotification extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            createDelegateAssignmentNotification(newList);
        }
    }

    public class CreatePrimaryDelegateForMinor extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            checkPrimaryDelegate(newList);
            updateDelegateParticipant(newList, null);
        }

        public override void beforeDelete(List<SObject> newList) {
            notDeletePrimaryDelegate(newList);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            //     updatePrimaryDelegate(newList,(Map<Id, Patient_Delegate__c>) oldMap);
            updateDelegateParticipant(newList, (Map<Id, Patient_Delegate__c>) oldMap);
        }
    }

    public class CreateReactivatedNotification extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createDelegateReactivatedNotification(newList, (Map<Id, Patient_Delegate__c>) oldMap);
        }
    }

    // Logic: ----------------------------------------------------------------------------------------------------------

    @TestVisible
    private static void setDefaultPatientStatus(List<Patient_Delegate__c> newList) {
        for (Patient_Delegate__c participantDelegate : newList) {
            if (participantDelegate.Status__c == null) {
                participantDelegate.Status__c = PATIENT_DELEGATE_ACTIVE_STATUS;
            }
        }
    }

    private static void updatePermissionSets(List<Patient_Delegate__c> changedPDList) {
        Set<Id> contactIds = new Set<Id>();
        for (Patient_Delegate__c pd : changedPDList)
            contactIds.add(pd.Contact__c);
        System.debug('CONTACTS FOR UPDATE PERMISSIONS:' + contactIds);
        PatientDelegateService.updatePermissionSets(contactIds);
    }

    @TestVisible
    private static void createDelegateAssignmentNotification(
        List<Patient_Delegate__c> patientDelegates
    ) {
        List<Patient_Delegate__c> newPatientDelegates = [
            SELECT Contact__c, Participant__c, Participant__r.Contact__c
            FROM Patient_Delegate__c
            WHERE Id IN :patientDelegates AND Status__c = :PATIENT_DELEGATE_ACTIVE_STATUS
        ];
        createNotifications(newPatientDelegates, 'DelNewAssignNotifType');
    }

    @TestVisible
    private static void createDelegateReactivatedNotification(
        List<Patient_Delegate__c> patientDelegates,
        Map<Id, Patient_Delegate__c> oldMap
    ) {
        List<Patient_Delegate__c> updatedDelegates = [
            SELECT Contact__c, Participant__c, Participant__r.Contact__c, Status__c
            FROM Patient_Delegate__c
            WHERE Id IN :patientDelegates
        ];

        List<Patient_Delegate__c> activatedDelegates = new List<Patient_Delegate__c>();
        for (Patient_Delegate__c pd : updatedDelegates) {
            if (
                pd.Status__c == PATIENT_DELEGATE_ACTIVE_STATUS &&
                oldMap.get(pd.Id).Status__c != PATIENT_DELEGATE_ACTIVE_STATUS
            ) {
                activatedDelegates.add(pd);
            }
        }

        createNotifications(activatedDelegates, 'DelReactivatedNotifType');
    }
    private static List<Notification__c> createwelcomemsgSMSNotifications(
        List<Patient_Delegate__c> patientDelegates
    ) {
        Set<Id> participantIdSet = new Set<Id>();
        Set<Id> proccessedPlatDelCon = new Set<Id>();
        Set<Id> proccessedStudyDelCon = new Set<Id>();
        Map<Id, Patient_Delegate__c> patientdelegateslist = new Map<Id, Patient_Delegate__c>();
        List<Notification__c> welcomemsgnotifications = new List<Notification__c>();
        Map<Id, List<Id>> participantsByDelContId = new Map<Id, List<Id>>();
        if (patientDelegates != null && !patientDelegates.isEmpty()) {
            for (Patient_Delegate__c delegate : patientDelegates) {
                if (!participantsByDelContId.containsKey(delegate.Contact__c)) {
                    participantsByDelContId.put(delegate.Contact__c, new List<Id>());
                }
                patientdelegateslist.put(delegate.Contact__c, delegate);
                participantsByDelContId.get(delegate.Contact__c).add(delegate.Participant__c); // For each del contact list of participnats
                participantIdSet.add(delegate.Participant__c); // this is list of participants
            }
        }
        //For minor participants Study level
        Map<Id, Participant_Enrollment__c> perEnrollments;
        Map<Id, ParticipantEnrollmentPatientDelJunction__c> perJunctionIdMap;
        if (!participantsByDelContId.isEmpty() && participantsByDelContId != null) {
            perJunctionIdMap = new Map<Id, ParticipantEnrollmentPatientDelJunction__c>(
                [
                    SELECT
                        Id,
                        Participant_Enrollment__c,
                        Welcome_Message_Delivered__c,
                        Patient_Delegate_Contact__c,
                        Welcome_Message_Sent__c
                    FROM ParticipantEnrollmentPatientDelJunction__c
                    WHERE Patient_Delegate_Contact__c IN :participantsByDelContId.keyset()
                ]
            );
        }
        system.debug(
            'perJunctionIdMap:::' +
            perJunctionIdMap +
            'participantIdSet::' +
            participantIdSet
        );
        if (
            (perJunctionIdMap == null || perJunctionIdMap.isEmpty()) &&
            (participantIdSet != null && !participantIdSet.isEmpty())
        ) {
            perEnrollments = new Map<Id, Participant_Enrollment__c>(
                [
                    SELECT
                        Id,
                        Welcome_Message_Sent__c,
                        Permit_SMS_Text_for_this_study__c,
                        Participant__c,
                        Participant_Contact__c,
                        Welcome_Message_Delivered__c
                    FROM Participant_Enrollment__c
                    WHERE Participant__c IN :participantIdSet
                ]
            );
            if (perEnrollments != null && perEnrollments.size() > 0) {
                List<ParticipantEnrollmentPatientDelJunction__c> perDelJunctionRecList = new List<ParticipantEnrollmentPatientDelJunction__c>();
                for (Participant_Enrollment__c per : perEnrollments.values()) {
                    if (participantsByDelContId.size() > 0) {
                        /// each del contact will be having list of participants
                        for (Id conId : participantsByDelContId.keySet()) {
                            // delegate contacts iterate -- list of participants
                            if (!proccessedStudyDelCon.contains(conId)) {
                                proccessedStudyDelCon.add(conId);
                                for (Id par : participantsByDelContId.get(conId)) {
                                    if (
                                        par == per.Participant__c &&
                                        per.Permit_SMS_Text_for_this_study__c
                                    ) {
                                        /*Study Level Delegate*/
                                        welcomemsgnotifications.addAll(
                                            ContactService.addwelcomeNotifications(
                                                conId,
                                                per.Id,
                                                NotificationCatalog.MSG_TO_DELEGATE_STUDY_LEVEL_WELCOME_MSG,
                                                true
                                            )
                                        );
                                        //Create jonction object record between PER and Patient Delegate contact records
                                        ParticipantEnrollmentPatientDelJunction__c perPDJunObj = new ParticipantEnrollmentPatientDelJunction__c();
                                        perPDJunObj.Participant_Enrollment__c = per.Id;
                                        perPDJunObj.Patient_Delegate_Contact__c = conId;
                                        perPDJunObj.Process_Type__c = 'Welcome Message';
                                        perDelJunctionRecList.Add(perPDJunObj);
                                    }
                                    break;
                                }
                            }
                        }
                    }
                }
                if (perDelJunctionRecList != null) {
                    insert perDelJunctionRecList;
                }
            }
        } else if (perJunctionIdMap != null && !perJunctionIdMap.isEmpty()) {
            for (ParticipantEnrollmentPatientDelJunction__c per : perJunctionIdMap.values()) {
                if (!per.Welcome_Message_Sent__c) {
                    /*Study Level Welcome Msg to Delegate*/
                    welcomemsgnotifications.addAll(
                        ContactService.addwelcomeNotifications(
                            per.Patient_Delegate_Contact__c,
                            per.Participant_Enrollment__c,
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
                WHERE ID IN :participantsByDelContId.keyset()
            ]
        );
        if (perJunctionIdMap != null && !participantsByDelContId.isEmpty()) {
            for (Id delCont : participantsByDelContId.keySet()) {
                if (
                    !proccessedPlatDelCon.contains(delCont) &&
                    delconMaplst.containskey(delCont) &&
                    !delconMaplst.get(delCont).Welcome_Message_Sent__c &&
                    participantsByDelContId.get(delCont) != null
                ) {
                    proccessedPlatDelCon.add(delCont);
                    for (Id parId : participantsByDelContId.get(delCont)) {
                        //Platform Level Delegates
                        Boolean isDelegateActiveNotification =
                            ContactService.patientdelList.containskey(delCont) &&
                            ContactService.patientdelList.get(delCont)
                                .Contact__r.Participant_Opt_In_Status_SMS__c &&
                            !(ContactService.patientdelList.get(delCont)
                                .Contact__r.Welcome_Message_Sent__c);
                        if (isDelegateActiveNotification) {
                            //changes as part of PEH-7633
                            welcomemsgnotifications.addAll(
                                ContactService.addwelcomeNotifications(
                                    delCont,
                                    parId,
                                    NotificationCatalog.MSG_TO_DELEGATE_PLATFORM_LVL_WELCME_MSG,
                                    true
                                )
                            );
                        }
                    }
                }
            }
        }
        return welcomemsgnotifications;
    }
    private static void createNotifications(
        List<Patient_Delegate__c> patientDelegates,
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
        for (Patient_Delegate__c delegate : patientDelegates) {
            if (!participantsByDelContId.containsKey(delegate.Contact__c)) {
                participantsByDelContId.put(delegate.Contact__c, new List<Participant__c>());
            }
            participantsByDelContId.get(delegate.Contact__c).add(delegate.Participant__r);
            participantContacts.add(delegate.Participant__r.Contact__c);
        }

        //For minor participants
        List<Participant_Enrollment__c> enrollments = [
            SELECT Clinical_Trial_Profile__r.CommunityTemplate__c, Participant__c
            FROM Participant_Enrollment__c
            WHERE Participant_Contact__c IN :participantContacts
        ];
        Map<Id, List<String>> communityTemplatesByParticipant = new Map<Id, List<String>>();
        for (Participant_Enrollment__c pe : enrollments) {
            if (!communityTemplatesByParticipant.containsKey(pe.Participant__c)) {
                communityTemplatesByParticipant.put(pe.Participant__c, new List<String>());
            }
            communityTemplatesByParticipant.get(pe.Participant__c)
                .add(pe.Clinical_Trial_Profile__r.CommunityTemplate__c);
        }

        List<PermissionSetAssignment> permissionSetAssignments = [
            SELECT Assignee.ContactId, PermissionSet.Name
            FROM PermissionSetAssignment
            WHERE
                (Assignee.ContactId IN :participantsByDelContId.keySet()
                OR Assignee.ContactId IN :participantContacts)
                AND PermissionSet.Name IN :CommunityTemplateService.getAllPermissionSets()
        ];
        Map<Id, Set<String>> permissionsByContact = new Map<Id, Set<String>>();
        for (PermissionSetAssignment assignment : permissionSetAssignments) {
            if (!permissionsByContact.containsKey(assignment.Assignee.ContactId)) {
                permissionsByContact.put(assignment.Assignee.ContactId, new Set<String>());
            }
            permissionsByContact.get(assignment.Assignee.ContactId)
                .add(assignment.PermissionSet.Name);
        }

        for (Id delCont : participantsByDelContId.keySet()) {
            if (!permissionsByContact.containsKey(delCont))
                continue;

            Set<String> delPermissions = permissionsByContact.get(delCont);
            for (Participant__c participant : participantsByDelContId.get(delCont)) {
                List<CommunityTemplate> communityTemplates = new List<CommunityTemplate>();
                if (permissionsByContact.containsKey(participant.Contact__c)) {
                    for (String partPerm : permissionsByContact.get(participant.Contact__c)) {
                        communityTemplates.add(
                            CommunityTemplateService.getTemplateByPermissionSetName(partPerm)
                        );
                    }
                } else {
                    for (
                        String templateName : communityTemplatesByParticipant.get(participant.Id)
                    ) {
                        communityTemplates.add(CommunityTemplateService.getTemplate(templateName));
                    }
                }
                for (CommunityTemplate template : communityTemplates) {
                    if (delPermissions.contains(template.permissionSet)) {
                        system.debug(
                            'template.properties.get(templateProperty)' +
                            template.properties.get(templateProperty)
                        );
                        notifications.add(
                            new Notification__c(
                                Notification_Type__c = template.properties.get(templateProperty),
                                Recipient__c = delCont,
                                WhatId__c = participant.Id
                            )
                        );
                    }
                }
            }
        }

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

    public static void checkPrimaryDelegate(List<Patient_Delegate__c> patientDelegates) {
        Map<Id, List<Patient_Delegate__c>> pdMap = new Map<Id, List<Patient_Delegate__c>>();
        List<Patient_Delegate__c> updatedList = new List<Patient_Delegate__c>();
        Set<Id> participantIdList = new Set<Id>();
        for (Patient_Delegate__c pd : patientDelegates) {
            participantIdList.add(pd.Participant__c);
        }
        for (Participant__c pList : [
            SELECT Id, Adult__c, (SELECT Id, Primary_Delegate__c FROM Participants__r)
            FROM Participant__c
            WHERE Id IN :participantIdList
        ]) {
            pdMap.put(pList.Id, pList.Participants__r);
        }
        for (Id p : pdMap.keySet()) {
            for (Patient_Delegate__c pdel : pdMap.get(p)) {
                for (Patient_Delegate__c pdList : patientDelegates) {
                    if (pdList.Primary_Delegate__c == true && pdList.Participant__c == p) {
                        pdel.Primary_Delegate__c = false;
                        updatedList.add(pdel);
                    }
                }
                /*else if(pdMap.get(p).size()==0){
                    pdList.Primary_Delegate__c = True;
                }*/
            }
        }
        update updatedList;
    }
    //Method to update the delegate particiapnt Field , REF-3858
    public static void updateDelegateParticipant(
        List<Patient_Delegate__c> lstpatientDelegates,
        Map<Id, Patient_Delegate__c> oldMap
    ) {
        List<Id> lstContactId = new List<Id>();
        Map<Id, Id> mapDelConToDelPart = new Map<Id, Id>();
        Map<String, Id> mapParticipantToContact = new Map<String, Id>();
        List<Patient_Delegate__c> lstpatientDelegatesUpdated = new List<Patient_Delegate__c>();

        if (oldMap != null) {
            for (Patient_Delegate__c objPatientDel : lstpatientDelegates) {
                if (objPatientDel.Contact__c != oldMap.get(objPatientDel.Id).Contact__c)
                    lstpatientDelegatesUpdated.add(objPatientDel);
            }
        }

        if ((oldMap != null && !lstpatientDelegatesUpdated.isEmpty()) || oldMap == null) {
            for (Patient_Delegate__c objPatientDel : lstpatientDelegates) {
                String strUniqueKey = objPatientDel.Participant__c + '_' + objPatientDel.Contact__c;
                lstContactId.add(objPatientDel.Contact__c);
                mapParticipantToContact.put(strUniqueKey, objPatientDel.Contact__c);
            }
            for (Participant__c objParticipant : [
                SELECT ID, Contact__c
                FROM participant__c
                WHERE Contact__c IN :lstContactId
            ]) {
                mapDelConToDelPart.put(objParticipant.contact__c, objParticipant.id);
            }
            for (Patient_Delegate__c objPatientDel : lstpatientDelegates) {
                String strUniqueKey = objPatientDel.Participant__c + '_' + objPatientDel.Contact__c;
                objPatientDel.Participant_Delegate__c = mapDelConToDelPart.get(
                    mapParticipantToContact.get(strUniqueKey)
                );
            }
        }
    }

    public static void notDeletePrimaryDelegate(List<Patient_Delegate__c> patientDelegates) {
        for (Patient_Delegate__c pd : patientDelegates) {
            if (pd.Primary_Delegate__c == true) {
                pd.addError('Cannot delete Primary Delegate');
            }
        }
    }

    public static void updatePrimaryDelegate(
        List<Patient_Delegate__c> patientDelegates,
        Map<Id, Patient_Delegate__c> oldMap
    ) {
        Map<Id, List<Patient_Delegate__c>> pdMap = new Map<Id, List<Patient_Delegate__c>>();
        List<Patient_Delegate__c> updatedList = new List<Patient_Delegate__c>();
        List<Patient_Delegate__c> errorList = new List<Patient_Delegate__c>();
        Set<Id> participantIdList = new Set<Id>();
        for (Patient_Delegate__c pd : patientDelegates) {
            participantIdList.add(pd.Participant__c);
        }
        for (Participant__c pList : [
            SELECT Id, Adult__c, (SELECT Id, Primary_Delegate__c FROM Participants__r)
            FROM Participant__c
            WHERE Id IN :participantIdList
        ]) {
            pdMap.put(pList.Id, pList.Participants__r);
        }
        for (Id p : pdMap.keySet()) {
            for (Patient_Delegate__c pdList : patientDelegates) {
                if (pdList.Primary_Delegate__c == true) {
                    if (oldMap.get(pdList.Id).Primary_Delegate__c == false) {
                        for (Patient_Delegate__c pdel : pdMap.get(p)) {
                            pdel.Primary_Delegate__c = false;
                            updatedList.add(pdel);
                        }
                    }
                } else {
                    if (oldMap.get(pdList.Id).Primary_Delegate__c == true) {
                        pdList.addError('Select any other primary delegate');
                        break;
                    }
                }
                if (updatedList.contains(pdList)) {
                    integer a = updatedList.indexOf(pdList);
                    updatedList.remove(a);
                }
            }
        }
        if (!updatedList.isEmpty()) {
            update updatedList;
        }
    }
}
