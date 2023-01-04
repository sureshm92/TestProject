public with sharing class PatientDelegateEnrolTriggerHandler {
    public static final String PATIENT_DELEGATE_ACTIVE_STATUS = 'Active';
    public static final String PATIENT_DELEGATE_ONHOLD_STATUS = 'On Hold';
    public static final String PATIENT_DELEGATE_DISCONNECTED_STATUS = 'Disconnected';

    public class CreateNewAssignmentNotification extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            Set<Id> pdeIdSet = new set<Id>();
            for(SObject pde: newList ){
                pdeIdSet.add(pde.Id);
            }
            //createDelegateAssignmentNotification(newList);
            if (System.isFuture() || System.isBatch()) {
                createDelegateAssignmentNotification(pdeIdSet);
            }
            else{
                createDelegateAssignmentNotificationFuture(pdeIdSet);
            }
        }
    }
    public class CreateReactivatedNotification extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createDelegateReactivatedNotification(newList, (Map<Id, Patient_Delegate_Enrollment__c>) oldMap);
        }
    }
    public class SetDefaultPatientDelegateStatusHandler extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            setDefaultPatientStatus(newList);
        }
    }
    public class UpdateConsentTimeStamps extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            updateConsentTimeStamps((List<Patient_Delegate_Enrollment__c>) newList);
        }
        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updateConsentTimeStamps((List<Patient_Delegate_Enrollment__c>) newList, (Map<Id, Patient_Delegate_Enrollment__c>) oldMap);
        }
    }
    public class UpdateDelegateConsent extends TriggerHandler {
        Boolean isPortalUser = checkCurrentusrProfile();
        public override void beforeInsert(List<SObject> newList) {
            if (isPortalUser) {
                delegateConsentUpdate((List<Patient_Delegate_Enrollment__c>) newList, null);
            }
        }
        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            if (isPortalUser) {
                delegateConsentUpdate(
                    (List<Patient_Delegate_Enrollment__c>) newList,
                    (Map<Id, Patient_Delegate_Enrollment__c>) oldMap
                );
            }
        }
    }
    public class CreatePrimaryDelegateForMinor extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            checkPrimaryDelegate(newList);
        }

        public override void beforeDelete(List<SObject> newList) {
            notDeletePrimaryDelegate(newList);
        }

        
    }
    public class AssignCommunityPermissionSets extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            Set<Id> pdeIdSet = new set<Id>();
            for(SObject pde: newList ){
                pdeIdSet.add(pde.Id);
            }
            
            if (!System.isFuture() && !System.isBatch()) {
                updatePermissionSetsAsync(pdeIdSet);
            }
            else{
                updatePermissionSets(pdeIdSet);
            }
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
        set<Id> pdeIdset
    )  {
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
            WHERE Id IN :pdeIdset AND Status__c = :PATIENT_DELEGATE_ACTIVE_STATUS
        ];
        createNotifications(patientDelegateEnrollRecrds, 'DelNewAssignNotifType');
    }
    @TestVisible
    @Future
    private static void createDelegateAssignmentNotificationFuture(
        set<Id> pdeIdset
    )  {
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
            WHERE Id IN :pdeIdset AND Status__c = :PATIENT_DELEGATE_ACTIVE_STATUS
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
    
    @TestVisible
    private static void setDefaultPatientStatus(List<Patient_Delegate_Enrollment__c> newList) {
        for (Patient_Delegate_Enrollment__c participantDelegate : newList) {
            if (participantDelegate.Status__c == null) {
                participantDelegate.Status__c = PATIENT_DELEGATE_ACTIVE_STATUS;
            }
        }
    }

    //This method is to make existing PDER primary as false if new primary PDER added
    public static void checkPrimaryDelegate(List<Patient_Delegate_Enrollment__c> patientDelegates) {
        List<Patient_Delegate_Enrollment__c> updatedList = new List<Patient_Delegate_Enrollment__c>();
        Set<Id> perIdList = new Set<Id>();
        for (Patient_Delegate_Enrollment__c pd : patientDelegates) {
            perIdList.add(pd.Participant_Enrollment__c);
        }
        for (Patient_Delegate_Enrollment__c pderList : [
            SELECT Id, Primary_Delegate__c,Participant_Enrollment__c 
            FROM Patient_Delegate_Enrollment__c
            WHERE Participant_Enrollment__c IN :perIdList
        ]) {
            if (pderList.Primary_Delegate__c == true ) {
                pderList.Primary_Delegate__c = false;
                updatedList.add(pderList);
            }
        }
       
        update updatedList;
    }
    //This method is to prevent deleting Primary PDER
    public static void notDeletePrimaryDelegate(List<Patient_Delegate_Enrollment__c> patientDelegates) {
        for (Patient_Delegate_Enrollment__c pd : patientDelegates) {
            if (pd.Primary_Delegate__c == true) {
                pd.addError('Cannot delete Primary Delegate Enrollment');
            }
        }
    }
    @TestVisible
    //This method check what consents where given and stamps the current time
    private static void updateConsentTimeStamps(List<Patient_Delegate_Enrollment__c> newList) {
        for (Patient_Delegate_Enrollment__c pder : newList) {
            
            pder.Study_SMS_Consent_Time__c = (pder.Study_SMS_Consent__c	
                                             ? Datetime.now()
                                             : null);
            pder.Study_Pre_recorded_Calls_Consent_Time__c = (pder.Study_Pre_recorded_Voice_Consent__c
                                                            ? Datetime.now()
                                                            : null);
            pder.Study_Storage_Consent_Time__c = (pder.Study_info_storage_consent__c
                                                    ? Datetime.now()
                                                    : null);
            pder.Study_Phone_Consent_Time__c = (pder.Study_Phone_Consent__c
                                               ? Datetime.now()
                                               : null);
            pder.Study_Email_Consent_Time__c = (pder.Study_Email_Consent__c
                                               ? Datetime.now()
                                               : null);
            pder.Study_Direct_Mail_Consent_Time__c = (pder.Study_Direct_Mail_Consent__c
                                                     ? Datetime.now()
                                                     : null);
            pder.Study_Assisted_Dialing_Consent_Time__c = (pder.Study_Assisted_Dialing_Consent__c
                                                          ? Datetime.now()
                                                          : null);
            pder.Study_Artificial_Voice_Consent_Time__c = (pder.Study_Artificial_Voice_Consent__c
                                                          ? Datetime.now()
                                                          : null);
        }
    }

    @TestVisible
    //This method check what consents where given and stamps the current time
    private static void updateConsentTimeStamps(List<Patient_Delegate_Enrollment__c> newList, Map<Id, Patient_Delegate_Enrollment__c> oldMap) {
        for (Patient_Delegate_Enrollment__c pder : newList) {
            Patient_Delegate_Enrollment__c oldPder = oldMap.get(pder.Id);
           
            
            if (
                pder.Study_SMS_Consent__c != oldPder.Study_SMS_Consent__c
            ) {
                pder.Study_SMS_Consent_Time__c = Datetime.now();
            }
            if (
                pder.Study_Pre_recorded_Voice_Consent__c !=
                oldPder.Study_Pre_recorded_Voice_Consent__c
            ) {
                pder.Study_Pre_recorded_Calls_Consent_Time__c = Datetime.now();
            }
            if (
                pder.Study_info_storage_consent__c !=
                oldPder.Study_info_storage_consent__c
            ) {
                pder.Study_Storage_Consent_Time__c = Datetime.now();
            }
            if (
                pder.Study_Phone_Consent__c !=
                oldPder.Study_Phone_Consent__c
            ) {
                pder.Study_Phone_Consent_Time__c = Datetime.now();
            }
            if (
                pder.Study_Email_Consent__c !=
                oldPder.Study_Email_Consent__c
            ) {
                pder.Study_Email_Consent_Time__c = Datetime.now();
            }
            if (pder.Study_Direct_Mail_Consent__c != oldPder.Study_Direct_Mail_Consent__c) {
                pder.Study_Direct_Mail_Consent_Time__c = Datetime.now();
            }
            if (
                pder.Study_Assisted_Dialing_Consent__c !=
                oldPder.Study_Assisted_Dialing_Consent__c
            ) {
                pder.Study_Assisted_Dialing_Consent_Time__c = Datetime.now();
            }
            if (
                pder.Study_Artificial_Voice_Consent__c !=
                oldPder.Study_Artificial_Voice_Consent__c
            ) {
                pder.Study_Artificial_Voice_Consent_Time__c = Datetime.now();
            }
        }
    }

    @TestVisible
    private static void delegateConsentUpdate(
        List<Patient_Delegate_Enrollment__c> newList,
        Map<Id, Patient_Delegate_Enrollment__c> oldMap
    ) {
        for (Patient_Delegate_Enrollment__c pdNew : newList) {
            if (oldMap == null) {
                pdNew.Study_Assisted_Dialing_Consent__c = (pdNew.Study_Phone_Consent__c
                    ? true
                    : false);
                pdNew.Study_Artificial_Voice_Consent__c = (pdNew.Study_Phone_Consent__c
                    ? true
                    : false);
                pdNew.Study_Pre_recorded_Voice_Consent__c = (pdNew.Study_Phone_Consent__c
                    ? true
                    : false);
            } else {
                Patient_Delegate_Enrollment__c pdOld = oldMap.get(pdNew.Id);
                if (
                    pdNew.Study_Phone_Consent__c !=
                    pdOld.Study_Phone_Consent__c &&
                    pdNew.Study_Phone_Consent__c
                ) {
                    // check 3 checkboxes
                    pdNew.Study_Assisted_Dialing_Consent__c = true;
                    pdNew.Study_Artificial_Voice_Consent__c = true;
                    pdNew.Study_Pre_recorded_Voice_Consent__c = true;
                } else if (
                    pdNew.Study_Phone_Consent__c !=
                    pdOld.Study_Phone_Consent__c &&
                    !pdNew.Study_Phone_Consent__c
                ) {
                    // uncheck 3 checkboxes
                    pdNew.Study_Assisted_Dialing_Consent__c = false;
                    pdNew.Study_Artificial_Voice_Consent__c = false;
                    pdNew.Study_Pre_recorded_Voice_Consent__c = false;
                }
            }
        }
    }

    public static List<Profile> currentUserProfile;
    public static boolean checkCurrentusrProfile() {
        List<Profile> profiles;
        if(currentUserProfile==null){
            Id profileId = userinfo.getProfileId();
            currentUserProfile = [SELECT Id, Name FROM Profile WHERE Id = :profileId];
        }
        profiles = currentUserProfile;
        if (profiles != null && !profiles.isEmpty()) {
            String profileName = profiles[0].Name;
            if (profileName == System.Label.PortalUserProfile) {
                return true;
            } else {
                return false;
            }
        }else{
            return false;
        }
    }

    @Future
    private static void updatePermissionSetsAsync(Set<Id> pdeIdSet) {
        updatePermissionSets(pdeIdSet)
    }

    //This Method will update the permission set to the patient Delegate.
    private static void updatePermissionSets(Set<Id> pdeIdSet) {
        List<Patient_Delegate_Enrollment__c> pdeList = [select id,Patient_Delegate__r.Participant__r.Contact__c,Patient_Delegate__r.Contact__c,Patient_Delegate__r.Participant__c,Participant_Enrollment__r.Id,Participant_Enrollment__r.Participant__c,Participant_Enrollment__r.Participant_Contact__c,Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,Participant_Enrollment__r.Clinical_Trial_Profile__r.Id,Participant_Enrollment__r.Clinical_Trial_Profile__r.ShortCommunityName__c
                                                  from Patient_Delegate_Enrollment__c where id in: pdeIdSet and Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c NOT IN :CommunityModeService.rhSponsorsByCommunity.keySet()
                                                  and Participant_Enrollment__r.Study_Site__r.Study_Site_Type__c != 'Virtual' and Participant_Enrollment__r.Study_Site__r.Study_Site_Type__c != 'Hybrid'
                                                  and  Participant_Enrollment__r.Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c = FALSE
                                                  and Participant_Enrollment__r.Study_Site__r.Suppress_Participant_Emails__c = FALSE
                                                  and Participant_Enrollment__r.Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = TRUE]; 

        Set<Id> contactIds = new Set<Id>();
        Set<Id> perIds = new Set<Id>();
        List<Id> delegatedContacts = new List<Id>();
        Set<Id> allDelegatedParticipantIds = new Set<Id>();
        Map<Id, String> mapPERToShortCommName=new Map<Id,String>();
        Map<String, String> mapShortCommNameToPermissName=new map<String,String>();
        Map<String,Id> mapStudyContactToDel=new Map<String,Id>();//StudyId+contactId is key
        set<String> permissionNames=new Set<String>();
        Map<String,Id> permissionNameToId=new Map<String,Id>();
        Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
        for (Patient_Delegate_Enrollment__c pde : pdeList){
            //contactIds.add(pde.Patient_Delegate__r.Contact__c);
            //perIds.add(pde.Participant_Enrollment__c);pde.
            
            String keys=pde.Participant_Enrollment__r.Clinical_Trial_Profile__r.Id+'~'+pde.Participant_Enrollment__r.Participant_Contact__c;
            mapStudyContactToDel.put(keys,pde.Patient_Delegate__r.Contact__c);  
            allDelegatedParticipantIds.add(pde.Patient_Delegate__r.Participant__c);
            delegatedContacts.add(pde.Patient_Delegate__r.Participant__r.Contact__c);                                          
            contactIds.add(pde.Patient_Delegate__r.Contact__c);
            mapPERToShortCommName.put(pde.Participant_Enrollment__r.Id,pde.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c);
        }
        for(Community_Template__mdt commTemp:[SELECT
                Id,
                DeveloperName,
                Community_Name__c,
                Label,
                Permission_Set_Developer_Name__c,
                ShortCommunityName__c,Community_Template__c
                                              FROM Community_Template__mdt]){
                       mapShortCommNameToPermissName.put(commTemp.Community_Template__c,commTemp.Permission_Set_Developer_Name__c) ;
                         permissionNames.add(commTemp.Permission_Set_Developer_Name__c);                         
           }
        for(PermissionSet  pp:[select id,Name from PermissionSet where name in:permissionNames]){
            permissionNameToId.put(pp.Name,pp.Id);
        }
        for (Patient_Delegate_Enrollment__c pde : pdeList){
            Set<String> psaNames=new set<String>();
            Id ContactId=pde.Patient_Delegate__r.Contact__c;
            String PerId=pde.Participant_Enrollment__r.Id;
            String shortCommTemp=mapPERToShortCommName.get(PerId);
            String permissionName=mapShortCommNameToPermissName.get(shortCommTemp);
            psaNames.add(permissionName);
            Id permissionId=permissionNameToId.get(permissionName);
            actionAssignContactPermissions.addPermissions(ContactId,psaNames);
        }
        System.debug('XXX_ACTION: ' + JSON.serializePretty(actionAssignContactPermissions));
        if (!actionAssignContactPermissions.isEmpty()) {
            ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
        }
        /*System.debug('CONTACTS FOR UPDATE PERMISSIONS:' + contactIds);
        //PatientDelegateEnrollmentService.updatePermissionSets(contactIds, perIds);
        Map<Id, Set<String>> participantPermissions = new Map<Id, Set<String>>();
        for(Patient_Delegate_Enrollment__c pde :pdeList){
            Set<String> permissions = participantPermissions.get(pde.Patient_Delegate__r.Participant__c);
            if (permissions == null)
                permissions = new Set<String>();
            permissions.add(CommunityTemplateService.getTemplate(pde.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c).permissionSet);
            participantPermissions.put(pde.Patient_Delegate__r.Participant__c, permissions);
        }
        Set<String> communityPermissionSets = CommunityTemplateService.getAllPermissionSets();*/
        
    }

}