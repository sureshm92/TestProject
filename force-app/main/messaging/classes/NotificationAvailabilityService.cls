/**
 * Created by Olga Skrynnikova on 11/29/2019.
 */

public without sharing class NotificationAvailabilityService {
    private static final String PARTICIPANT_ENROLLMENT_OBJ_NAME = 'Participant_Enrollment__c';
    private static final String CLINICAL_TRIAL_PROFILE_OBJ_NAME = 'Clinical_Trial_Profile__c';
    private static final String STUDY_SITE_OBJ_NAME = 'Study_Site__c';
    private static final String HCP_ENROLLMENT_OBJ_NAME = 'HCP_Enrollment__c';
    private static final String SURVEY_INVITATION_OBJ_NAME = 'SurveyInvitation';
    private static final String CONTACT = 'Contact';
    private static final String TASK_OBJ_NAME = 'Task';
    private static final String PARTICIPANT_OBJ_NAME = 'Participant__c';
    private static final String CASE_OBJ_NAME = 'Case';
    private static final String TELEVISIT_OBJ_NAME = 'Televisit__c';
    private static final String TELEVISIT_ATTN_OBJ_NAME = 'Televisit_Attendee__c';
    private Map<Id, Contact> contactByIdMap;
    private List<String> allPermissions;
    private Map<Id, List<String>> permissionSetsByConIdMap;

    private Map<Id, SObject> objectsByIds;

    private Map<Id, Boolean> piHasSiteWithEnabledEmailMap;
    private Map<Id, Boolean> piDelegateHasSiteWithEnabledEmailMap;
    private Map<String, List<String>> countryDialCodeMap;
    public Map<Id, String> contactLangZoneMap;
    public Set<Id> notificationRecipientIds;
    public Map<string, Participant_Enrollment__c> ctpContactToPer;
    public Map<string, List<Id>> parCTPRecrd;
    public Map<Id, Id> partPerDelegateIds;
    public Set<Id> studyConsentAvailableAtParRecrd;

    public NotificationAvailabilityService(List<Id> recipientIds, List<String> whatIds) {
        contactByIdMap = new Map<Id, Contact>();
        contactLangZoneMap = new Map<Id, String>();
        List<Contact> contacts = [
            SELECT
                Id,
                Participant_Opt_In_Status_Emails__c,
                Participant_Opt_In_Status_SMS__c,
                UserCommunityIsDelegate__c,
                userCommunityMode__c,
                Language__c,
                MailingCountryCode,
                Is_Invalid_Number__c,
                (SELECT TimeZoneSidKey FROM Users)
            FROM Contact
            WHERE Id IN :recipientIds
        ];
        for (Contact con : contacts)
            contactByIdMap.put(con.Id, con);

        allPermissions = new List<String>(CommunityTemplateService.getAllPermissionSets());
        if (recipientIds != null) {
            notificationRecipientIds = new Set<Id>(recipientIds);
        }
        permissionSetsByConIdMap = new Map<Id, List<String>>();
        List<User> users = new List<User>();
        List<PermissionSetAssignment> userPerSetAssignments = new List<PermissionSetAssignment>();
        if (!contacts.isEmpty())
            users = [SELECT Id, ContactId FROM User WHERE ContactId = :contacts];
        if (!users.isEmpty()) {
            userPerSetAssignments = [
                SELECT
                    Id,
                    AssigneeId,
                    Assignee.ContactId,
                    PermissionSet.Name,
                    Assignee.TimeZoneSidKey
                FROM PermissionSetAssignment
                WHERE AssigneeId IN :users AND PermissionSet.Name IN :allPermissions
            ];
        }
        for (PermissionSetAssignment perAssign : userPerSetAssignments) {
            contactLangZoneMap.put(perAssign.Assignee.ContactId, perAssign.Assignee.TimeZoneSidKey);
            Id assigneeContactId = perAssign.Assignee.ContactId;
            if (!permissionSetsByConIdMap.containsKey(assigneeContactId))
                permissionSetsByConIdMap.put(assigneeContactId, new List<String>());
            permissionSetsByConIdMap.get(assigneeContactId).add(perAssign.PermissionSet.Name);
        }

        Map<String, List<Id>> objectsByStrings = new Map<String, List<Id>>();
        objectsByIds = new Map<Id, SObject>();
        ctpContactToPer = new Map<string, Participant_Enrollment__c>();
        parCTPRecrd = new Map<String, List<Id>>();
        partPerDelegateIds = new Map<Id, Id>();
        studyConsentAvailableAtParRecrd = new Set<Id>();
        //Map for WhatIds Map(HCP, List<Id>)
        for (String str : whatIds) {
            Id whatId;
            try {
                whatId = Id.valueOf(str);
            } catch (Exception e) {
                System.debug('WhatId is not Id of SObject: ' + e.getMessage());
            }
            if (whatId == null)
                continue;

            String objKey = String.valueOf(whatId.getSobjectType());
            System.debug(objKey);

            if (!objectsByStrings.containsKey(objKey))
                objectsByStrings.put(objKey, new List<Id>());
            objectsByStrings.get(objKey).add(whatId);
        }

        //Map <Id, SObject>
        for (String objType : objectsByStrings.keySet()) {
            if (objType == PARTICIPANT_ENROLLMENT_OBJ_NAME) {
                List<Participant_Enrollment__c> listPE = getPEList(
                    new Set<Id>(objectsByStrings.get(objType))
                );
                for (Participant_Enrollment__c pe : listPE) {
                    objectsByIds.put(pe.Id, pe);
                }
            }
            if (objType == PARTICIPANT_OBJ_NAME) {
                List<Participant__c> participants = getParticipantList(
                    new Set<Id>(objectsByStrings.get(objType))
                );
                for (Participant__c participant : participants) {
                    objectsByIds.put(participant.Id, participant);
                }
            }
            if (objType == CLINICAL_TRIAL_PROFILE_OBJ_NAME) {
                List<Clinical_Trial_Profile__c> listCTP = [
                    SELECT
                        Id,
                        Suppress_Participant_Emails__c,
                        Suppress_PI_Emails__c,
                        CommunityTemplate__c
                    FROM Clinical_Trial_Profile__c
                    WHERE Id IN :objectsByStrings.get(objType)
                ];
                for (Clinical_Trial_Profile__c ctp : listCTP) {
                    objectsByIds.put(ctp.Id, ctp);
                }
                for (Participant_Enrollment__c objPer : [
                    SELECT
                        Id,
                        Clinical_Trial_Profile__c,
                        Participant__c,
                        Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                        Participant__r.IsCountry_NOT_Eligible_for_Emails__c,
                        Participant_Contact__c,
                        Permit_Mail_Email_contact_for_this_study__c,
                        Study_Site__r.Suppress_Participant_Emails__c
                    FROM Participant_Enrollment__c
                    WHERE Clinical_Trial_Profile__c IN :objectsByIds.keyset()
                ]) {
                    string str =
                        string.valueOf(objPer.Clinical_Trial_Profile__c) +
                        '~' +
                        string.valueOf(objPer.Participant_Contact__c);
                    ctpContactToPer.put(str, objPer);
                }
            }
            if (objType == SURVEY_INVITATION_OBJ_NAME) {
                List<SurveyInvitation> survInvList = [
                    SELECT
                        Id,
                        IsTrialSurvey__c,
                        Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                        Participant_Enrollment__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                        Participant_Enrollment__r.Permit_Mail_Email_contact_for_this_study__c,
                        Participant_Enrollment__r.Study_Site__r.Suppress_Participant_Emails__c,
                        Participant_Enrollment__r.Participant__r.IsCountry_NOT_Eligible_for_Emails__c
                    FROM SurveyInvitation
                    WHERE Id IN :objectsByStrings.get(objType)
                ];
                for (SurveyInvitation sur : survInvList) {
                    objectsByIds.put(sur.Id, sur);
                }
            }
            if (objType == TASK_OBJ_NAME) {
                Map<Id, Task> taskList = new Map<Id, Task>(
                    [
                        SELECT
                            Id,
                            Community_Template_Name__c,
                            WhatId,
                            CreatedByAdmin__c,
                            Originator__c,
                            Task_Type__c,
                            Ecoa_Task_Configuration_del__c,
                            Ecoa_Task_Configuration_del__r.Participant_Enrollment__c,
                            Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Permit_Mail_Email_contact_for_this_study__c,
                            Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                            Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Study_Site__c,
                            Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Study_Site__r.Suppress_Participant_Emails__c
                        FROM Task
                        WHERE Id IN :objectsByStrings.get(objType)
                    ]
                );
                Set<Id> peIds = new Set<Id>();
                Set<Id> participantId = new Set<Id>();
                for (Task tsk : taskList.values()) {
                    Id whatId = tsk.WhatId;
                    if (
                        whatId != null &&
                        whatId.getSobjectType() == Participant_Enrollment__c.getSObjectType()
                    ) {
                        peIds.add(whatId);
                    } else if (
                        whatId != null &&
                        whatId.getSobjectType() == Participant__c.getSObjectType()
                    ) {
                        participantId.add(whatId);
                    }
                    objectsByIds.put(tsk.Id, tsk);
                }
                if (peIds != null) {
                    List<Participant_Enrollment__c> peList = getPEList(peIds);
                    for (Participant_Enrollment__c pe : peList) {
                        objectsByIds.put(pe.Id, pe);
                    }
                }
                if (participantId != null) {
                    List<Patient_Delegate__c> delegatesList = [
                        SELECT
                            Id,
                            Participant__c,
                            Participant_Delegate__c,
                            Contact__c,
                            Contact__r.Participant_Opt_In_Status_SMS__c,
                            Contact__r.Welcome_Message_Sent__c,
                            Contact__r.Welcome_Message_Delivered__c
                        FROM Patient_Delegate__c
                        WHERE Participant_Delegate__c IN :participantId AND Status__c = 'Active'
                    ];
                    for (Patient_Delegate__c pd : delegatesList) {
                        partPerDelegateIds.put(pd.Participant_Delegate__c, pd.Participant__c);
                        participantId.add(pd.Participant__c);
                    }
                    List<Participant__c> participants = getParticipantList(participantId);
                    studyConsentAvailableAtParRecrd = getParPERList(participantId);
                    for (Participant__c par : participants) {
                        objectsByIds.put(par.Id, par);
                    }
                }
            }
            if (objType == HCP_ENROLLMENT_OBJ_NAME) {
                List<HCP_Enrollment__c> hcpeList = [
                    SELECT
                        Id,
                        HCP_Contact__r.HCP_Opt_In_Referral_Status_Emails__c,
                        Study_Site__r.Suppress_Study_Site_PI_Emails__c
                    FROM HCP_Enrollment__c
                    WHERE Id IN :objectsByStrings.get(objType)
                ];
                for (HCP_Enrollment__c hcpe : hcpeList) {
                    objectsByIds.put(hcpe.Id, hcpe);
                }
            }
            if (objType == CONTACT) {
                List<Contact> contactByObject = [
                    SELECT Id
                    FROM Contact
                    WHERE Id IN :objectsByStrings.get(objType)
                ];
                for (Contact con : contactByObject) {
                    objectsByIds.put(con.Id, con);
                }
            }
            if (objType == CASE_OBJ_NAME) {
                List<Case> cases = [SELECT Id FROM Case WHERE Id IN :objectsByStrings.get(objType)];
                for (Case cs : cases) {
                    objectsByIds.put(cs.Id, cs);
                }
            }
            if (objType == STUDY_SITE_OBJ_NAME) {
                List<Study_Site__c> studySites = [
                    SELECT
                        Id,
                        Suppress_Study_Site_PI_Emails__c,
                        Clinical_Trial_Profile__r.CommunityTemplate__c
                    FROM Study_Site__c
                    WHERE Id IN :objectsByStrings.get(objType)
                ];
                for (Study_Site__c ss : studySites) {
                    objectsByIds.put(ss.Id, ss);
                }
            }
            if (objType == TELEVISIT_OBJ_NAME) {
                List<Televisit__c> teleVisitsList = [
                    SELECT
                        Id,
                        Participant_Enrollment__r.Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c,
                        Participant_Enrollment__r.Study_Site__r.Suppress_Participant_Emails__c,
                        Participant_Enrollment__r.Permit_Mail_Email_contact_for_this_study__c,
                        Participant_Enrollment__r.Study_Site__r.Principal_Investigator__r.Participant_Opt_In_Status_Emails__c,
                        Participant_Enrollment__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                        Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                        Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c,
                        Participant_Enrollment__r.Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                        Participant_Enrollment__r.Study_Site__r.Suppress_Study_Site_PI_Emails__c,
                        Participant_Enrollment__r.Participant__r.IsCountry_NOT_Eligible_for_Emails__c,
                        Participant_Enrollment__r.HCP__r.HCP_Contact__r.HCP_Opt_In_Patient_Status_Emails__c
                    FROM Televisit__c
                    WHERE Id IN :objectsByStrings.get(objType)
                    ALL ROWS
                ];
                for (Televisit__c tv : teleVisitsList) {
                    objectsByIds.put(tv.Id, tv);
                }
            }
            //As part of RH-6577
            if (objType == TELEVISIT_ATTN_OBJ_NAME) {
                List<Televisit_Attendee__c> televisitAttendees = [
                    SELECT
                        Id,
                        Attendee_Type__c,
                        Contact__c,
                        Firstname__c,
                        Lastname__c,
                        Televisit_Scheduled_Date__c,
                        User__c,
                        Televisit__r.Visit_Date_Time__c,
                        Televisit__r.Status__c,
                        Televisit__r.Title__c,
                        Televisit__r.Participant_Enrollment__r.Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c,
                        Televisit__r.Participant_Enrollment__r.Permit_Mail_Email_contact_for_this_study__c,
                        Televisit__r.Participant_Enrollment__r.Study_Site__r.Suppress_Participant_Emails__c,
                        Televisit__r.Participant_Enrollment__r.Study_Site__r.Principal_Investigator__r.Participant_Opt_In_Status_Emails__c,
                        Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                        Televisit__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                        Televisit__r.Participant_Enrollment__r.Study_Site__r.SMS_Are_Available__c,
                        Televisit__r.Participant_Enrollment__r.Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                        Televisit__r.Participant_Enrollment__r.Study_Site__r.Suppress_Study_Site_PI_Emails__c,
                        Televisit__r.Participant_Enrollment__r.Participant__r.IsCountry_NOT_Eligible_for_Emails__c,
                        Televisit__r.Participant_Enrollment__r.HCP__r.HCP_Contact__r.HCP_Opt_In_Patient_Status_Emails__c
                    FROM Televisit_Attendee__c
                    WHERE Id IN :objectsByStrings.get(objType)
                    ALL ROWS
                ];
                for (Televisit_Attendee__c ta : televisitAttendees) {
                    objectsByIds.put(ta.Id, ta);
                }
            }
            //End

            //TODO for other objects passing in WhatID
        }
        piHasSiteWithEnabledEmailMap = checkIfPIContactsHaveSitesWithEnabledEmails(recipientIds);
        piDelegateHasSiteWithEnabledEmailMap = checkIfPIContactsHasDelegatedSitesWithEnabledEmails(
            recipientIds
        );

        countryDialCodeMap = new Map<String, List<String>>();
        for (Dialing_Country_Code__mdt mdt : [
            SELECT Id, DeveloperName, Dialing_Code__c, Enabled_for_SMS__c
            FROM Dialing_Country_Code__mdt
            WHERE Enabled_for_SMS__c = TRUE
        ]) {
            countryDialCodeMap.put(mdt.DeveloperName, mdt.Dialing_Code__c.split(','));
        }
    }

    public Boolean isEmailtoSend(
        String whatId,
        String recipientType,
        String notificationTarget,
        Id contactId,
        Notification_Type__mdt notificationType,
        String objType
    ) {
        Boolean isEmailAvailableAtPER = false;
        if (notificationType.IsStudyLevel__c) {
            if (objType == PARTICIPANT_ENROLLMENT_OBJ_NAME) {
                Participant_Enrollment__c pe = (Participant_Enrollment__c) objectsByIds.get(
                    Id.valueOf(whatId)
                );
                Boolean perEmailToSend = isPEREmailtoSend(pe);
                if (perEmailToSend) {
                    isEmailAvailableAtPER = true;
                }
            } else if (objType == TASK_OBJ_NAME) {
                isEmailAvailableAtPER = isTaskEmailToSend(
                    objectsByIds,
                    whatId,
                    notificationType,
                    contactId
                );
            } else if (objType == TELEVISIT_OBJ_NAME) {
                Televisit__c tv = (Televisit__c) objectsByIds.get(Id.valueOf(whatId));
                Participant_Enrollment__c pe = tv.Participant_Enrollment__r;
                Boolean perEmailToSend = isPEREmailtoSend(pe);
                if (perEmailToSend) {
                    isEmailAvailableAtPER = true;
                }
            } else if (objType == TELEVISIT_ATTN_OBJ_NAME) {
                Televisit_Attendee__c ta = (Televisit_Attendee__c) objectsByIds.get(
                    Id.valueOf(whatId)
                );
                Participant_Enrollment__c pe = ta.Televisit__r.Participant_Enrollment__r;
                //Contact contact = contactByIdMap.get(contactId);
                Boolean perEmailToSend = isPEREmailtoSend(pe);
                if (perEmailToSend) {
                    isEmailAvailableAtPER = true;
                }
            } else if (objType == CLINICAL_TRIAL_PROFILE_OBJ_NAME) {
                Clinical_Trial_Profile__c ctp = (Clinical_Trial_Profile__c) objectsByIds.get(
                    Id.valueOf(whatId)
                );
                if (!ctp.Suppress_Participant_Emails__c && ctpContactToPer != null) {
                    String strkey = string.valueOf(ctp.Id) + '~' + string.valueOf(contactId);
                    isEmailAvailableAtPER = ctpContactToPer.containsKey(strkey)
                        ? isPEREmailtoSend(ctpContactToPer.get(strkey))
                        : false;
                }
            }
        } else {
            if (objType == SURVEY_INVITATION_OBJ_NAME) {
                SurveyInvitation surveyInvitation = (SurveyInvitation) objectsByIds.get(
                    Id.valueOf(whatId)
                );
                if (surveyInvitation.IsTrialSurvey__c) {
                    Boolean perEmailToSend =
                        surveyInvitation != null &&
                        surveyInvitation.Participant_Enrollment__r.Permit_Mail_Email_contact_for_this_study__c &&
                        !surveyInvitation.Participant_Enrollment__r.Study_Site__r.Suppress_Participant_Emails__c &&
                        !surveyInvitation.Participant_Enrollment__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c &&
                        !surveyInvitation.Participant_Enrollment__r.Participant__r.IsCountry_NOT_Eligible_for_Emails__c;
                    if (perEmailToSend) {
                        isEmailAvailableAtPER = true;
                    }
                } else {
                    Contact contact = contactByIdMap.get(contactId);
                    if (contact.Participant_Opt_In_Status_Emails__c)
                        isEmailAvailableAtPER = true;
                }
            } else if (objType == TASK_OBJ_NAME) {
                isEmailAvailableAtPER = isTaskEmailToSend(
                    objectsByIds,
                    whatId,
                    notificationType,
                    contactId
                );
            } else if (objType == CLINICAL_TRIAL_PROFILE_OBJ_NAME) {
                Clinical_Trial_Profile__c ctp = (Clinical_Trial_Profile__c) objectsByIds.get(
                    Id.valueOf(whatId)
                );
                if (
                    !ctp.Suppress_Participant_Emails__c &&
                    contactByIdMap.get(contactId).Participant_Opt_In_Status_Emails__c
                )
                    isEmailAvailableAtPER = true;
            } else if (objType == CASE_OBJ_NAME) {
                ///Platform Level
                Contact contact = contactByIdMap.get(contactId);
                if (contact.Participant_Opt_In_Status_Emails__c)
                    isEmailAvailableAtPER = true;
            } else if (objType == null) {
                // Platform Level
                Contact contact = contactByIdMap.get(contactId);
                if (contact.Participant_Opt_In_Status_Emails__c)
                    isEmailAvailableAtPER = true;
            }
        }

        return isEmailAvailableAtPER;
    }
    public Boolean isTaskEmailToSend(
        Map<Id, SObject> objectsByIds,
        String whatIdrecrd,
        Notification_Type__mdt notificationType,
        Id contactId
    ) {
        Boolean isEmailAvailableAtPER = false;
        Boolean isStudyLevelEcoaPar = false;
        Boolean isPlatformLevelPar = false;
        if (!objectsByIds.isEmpty()) {
            Id whatId = Id.valueOf(whatIdrecrd);
            Task taskrecrd = (Task) objectsByIds.get(whatId);
            String objType = String.valueOf(taskrecrd.whatId.getSobjectType());
            isStudyLevelEcoaPar =
                notificationType.IsStudyLevel__c &&
                objType == 'Participant__c' &&
                taskrecrd.Task_Type__c == 'Ecoa';
            isPlatformLevelPar = !notificationType.IsStudyLevel__c && objType == 'Participant__c';
            Boolean taskTriggerEmail =
                !taskrecrd.CreatedByAdmin__c &&
                (taskrecrd.Originator__c == 'Participant' ||
                taskrecrd.Originator__c == 'Delegate');
            Boolean pertriggerEmail = false;
            Boolean partriggerEmail = false;
            if (taskrecrd != null) {
                if (taskTriggerEmail) {
                    Contact contact = contactByIdMap.get(contactId);
                    if (objType == 'Participant_Enrollment__c') {
                        Participant_Enrollment__c pe = (Participant_Enrollment__c) objectsByIds.get(
                            taskrecrd.whatId
                        );
                        pertriggerEmail = isPEREmailtoSend(pe);
                    } else if (objType == 'Participant__c') {
                        Participant__c pe = (Participant__c) objectsByIds.get(taskrecrd.WhatId);
                        if (
                            studyConsentAvailableAtParRecrd != null &&
                            (studyConsentAvailableAtParRecrd.contains(pe.Id) ||
                            partPerDelegateIds.containsKey(pe.Id))
                        ) {
                            partriggerEmail = true;
                        }
                    }
                    if (
                        pertriggerEmail ||
                        partriggerEmail ||
                        contact.Participant_Opt_In_Status_Emails__c
                    ) {
                        isEmailAvailableAtPER = true;
                    }
                } else {
                    if (objType == 'Participant_Enrollment__c') {
                        Participant_Enrollment__c pe = (Participant_Enrollment__c) objectsByIds.get(
                            taskrecrd.whatId
                        );
                        Boolean perEmailToSend = isPEREmailtoSend(pe);
                        if (perEmailToSend) {
                            isEmailAvailableAtPER = true;
                        }
                    } else if (isStudyLevelEcoaPar) {
                        Participant__c pe = (Participant__c) objectsByIds.get(taskrecrd.WhatId);
                        Boolean perEmailToSend =
                            taskrecrd.Ecoa_Task_Configuration_del__r.Participant_Enrollment__r
                                .Permit_Mail_Email_contact_for_this_study__c &&
                            !taskrecrd.Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Study_Site__r.Suppress_Participant_Emails__c &&
                            !taskrecrd.Ecoa_Task_Configuration_del__r.Participant_Enrollment__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c &&
                            !pe.IsCountry_NOT_Eligible_for_Emails__c;
                        if (perEmailToSend) {
                            isEmailAvailableAtPER = true;
                        }
                    } else if (isPlatformLevelPar) {
                        //Write for platform Level
                        Contact contact = contactByIdMap.get(contactId);
                        if (contact.Participant_Opt_In_Status_Emails__c)
                            isEmailAvailableAtPER = true;
                    }
                }
            }
        }
        return isEmailAvailableAtPER;
    }
    public Boolean isPEREmailtoSend(Participant_Enrollment__c pe) {
        Boolean perEmailToSend = false;
        if (pe != null) {
            perEmailToSend =
                pe.Permit_Mail_Email_contact_for_this_study__c &&
                !pe.Study_Site__r.Suppress_Participant_Emails__c &&
                !pe.Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c &&
                !pe.Participant__r.IsCountry_NOT_Eligible_for_Emails__c;
        }
        return perEmailToSend;
    }
    public Boolean isAvailable(
        String whatId,
        String recipientType,
        String notificationTarget,
        Id contactId,
        Notification_Type__mdt notificationType
    ) {
        if (whatId != null && objectsByIds.get(Id.valueOf(whatId)) == null)
            return false;
        Boolean checkForNotification = false;
        String objType = null;
        Id objId;
        if (whatId != null) {
            objId = whatId;
            objType = String.valueOf(objId.getSobjectType());
        }
        if (recipientType == NotificationService.NOTIFICATION_RECIPIENT_TYPE_PARTICIPANT) {
            checkForNotification = isEmailtoSend(
                whatId,
                recipientType,
                notificationTarget,
                contactId,
                notificationType,
                objType
            );
        }
        if (recipientType == NotificationService.NOTIFICATION_RECIPIENT_TYPE_HCP) {
            if (objType == PARTICIPANT_ENROLLMENT_OBJ_NAME) {
                Participant_Enrollment__c pe = (Participant_Enrollment__c) objectsByIds.get(
                    Id.valueOf(whatId)
                );
                if (pe.HCP__r.HCP_Contact__r.HCP_Opt_In_Patient_Status_Emails__c) {
                    checkForNotification = true;
                }
            } else if (objType == HCP_ENROLLMENT_OBJ_NAME) {
                HCP_Enrollment__c hcpe = (HCP_Enrollment__c) objectsByIds.get(Id.valueOf(whatId));
                if (hcpe.HCP_Contact__r.HCP_Opt_In_Referral_Status_Emails__c) {
                    checkForNotification = true;
                }
            } else if (objType == CONTACT || objType == STUDY_SITE_OBJ_NAME) {
                checkForNotification = true;
            }
        }
        if (recipientType == NotificationService.NOTIFICATION_RECIPIENT_TYPE_PI) {
            if (objType == PARTICIPANT_ENROLLMENT_OBJ_NAME) {
                Participant_Enrollment__c pe = (Participant_Enrollment__c) objectsByIds.get(
                    Id.valueOf(whatId)
                );
                if (
                    pe == null ||
                    pe.Study_Site__r == null ||
                    pe.Study_Site__r.Principal_Investigator__r == null ||
                    pe.Study_Site__r.Suppress_Study_Site_PI_Emails__c
                ) {
                    checkForNotification = false;
                } else {
                    checkForNotification = true;
                }
            } else if (objType == STUDY_SITE_OBJ_NAME) {
                Study_Site__c site = (Study_Site__c) objectsByIds.get(Id.valueOf(whatId));
                if (site.Suppress_Study_Site_PI_Emails__c) {
                    checkForNotification = false;
                } else {
                    checkForNotification = true;
                }
            } else if (objType == CONTACT) {
                checkForNotification =
                    (piDelegateHasSiteWithEnabledEmailMap.containsKey(contactId) &&
                    piDelegateHasSiteWithEnabledEmailMap.get(contactId)) ||
                    (piHasSiteWithEnabledEmailMap.containsKey(contactId) &&
                    piHasSiteWithEnabledEmailMap.get(contactId));
            } else if (objType == TELEVISIT_ATTN_OBJ_NAME) {
                Televisit_Attendee__c teleAttendee = (Televisit_Attendee__c) objectsByIds.get(
                    Id.valueOf(whatId)
                );
                checkForNotification =
                    (piDelegateHasSiteWithEnabledEmailMap.containsKey(teleAttendee.Contact__c) &&
                    piDelegateHasSiteWithEnabledEmailMap.get(teleAttendee.Contact__c)) ||
                    (piHasSiteWithEnabledEmailMap.containsKey(teleAttendee.Contact__c) &&
                    piHasSiteWithEnabledEmailMap.get(teleAttendee.Contact__c));
            } else if (objType == TELEVISIT_OBJ_NAME) {
                checkForNotification =
                    (piDelegateHasSiteWithEnabledEmailMap.containsKey(contactId) &&
                    piDelegateHasSiteWithEnabledEmailMap.get(contactId)) ||
                    (piHasSiteWithEnabledEmailMap.containsKey(contactId) &&
                    piHasSiteWithEnabledEmailMap.get(contactId));
            }
        }
        return checkForNotification;
    }

    public Boolean isAvailableForSMS(Id contactId, String whatId) {
        Boolean isAvailable = true;
        Id objId = whatId;
        Contact contact = contactByIdMap.get(contactId);
        isAvailable = isAvailable && contact.Participant_Opt_In_Status_SMS__c;
        return isAvailable;
    }

    /**
     * @description: This Method will check if contact Phone number is invalid.
     * @author: Krishna Mahto
     * @param: contactId
     * @return: Boolean
     **/
    public Boolean isInvalidNumber(Id contactId) {
        Boolean isInvalid = true;
        Contact contact = contactByIdMap.get(contactId);
        isInvalid = isInvalid && Contact.Is_Invalid_Number__c;

        return isInvalid;
    }

    /**
     * @description: This Method will check if Platform level Welcome message send and Delivered status for the delegate.
     * @author: Krishna Mahto
     * @param: contactId
     * @return: Boolean
     **/
    public Boolean isPlaformLevelWelmMssgSendAndDeliveredToDel(Id contactId) {
        Boolean isInvalid = true;
        Contact contact = contactByIdMap.get(contactId);
        isInvalid = isInvalid && Contact.Is_Invalid_Number__c;

        return isInvalid;
    }

    /**
     * @description:  This method checks if the SMS notification is eligible to send depending upon the different notification types and SMS availablility flags
     * @author: Krishna Mahto
     * @param:  n
     * @return: Boolean
     **/
    public Boolean checkSMSIsEligibleToSkip(Notification__c n, String recipientType) {
        Boolean skipSMS = false;
        //If Notification is for Participant or Delegate
        if (recipientType == NotificationService.NOTIFICATION_RECIPIENT_TYPE_PARTICIPANT) {
            skipSMS = checkParticipantDelSMSSkipEligibility(n);
        } else {
            //TODO: Implement logic as per the need based on the recipientType.
        }
        return skipSMS;
    }
    /**
     * @description:  This method checks if the SMS notification is eligible to send or skip for Paricipants/Delegates.
     * @author: Krishna Mahto
     * @param:  n
     * @return: Boolean
     **/
    public Boolean checkParticipantDelSMSSkipEligibility(notification__c n) {
        //Boolean skipSMS = false;
        String perIdRecipientIdKey = n?.WhatId__c + '_' + n?.Recipient__c;

        //If Number is Invalid at contact then skip the SMS.
        if (isInvalidNumber(n.Recipient__c)) {
            return true;
        }

        //If any of the AWS details are not available for the notification then skip the SMS.
        if (
            NotificationService.awsDetailsAreAvailable.containsKey(n.Id) &&
            !NotificationService.awsDetailsAreAvailable.get(n.Id)
        ) {
            return true;
        }

        //Check if SMS are neither navailable to send for Platform level nor available to send for Study level then Skip the SMS
        Boolean isSMSAvailableAtPlatformLevel =
            NotificationService.platfomLevelSMSSet.contains(n.Id) &&
            isAvailableForSMS(n.Recipient__c, n.WhatId__c);
        Boolean isSMSAvailableAtStudyLevel = NotificationService.studyLevelSMSSet.contains(n.Id);

        //Check if Notification is platform level or study level and available to send else skip the SMS.
        if (isSMSAvailableAtPlatformLevel) {
            //Process Platform level SMS notification eligibility check.
            Boolean skipSMS = skipPlatformLevelSMSCheck(n);
            if (skipSMS)
                return true;
        } else if (isSMSAvailableAtStudyLevel) {
            //Process Study level SMS notification eligibility check.
            Boolean skipSMS = skipStudyLevelSMSCheck(n);
            if (skipSMS)
                return true;
        } else {
            return true;
        }
        return false;
    }
    /**
     * @description:  This method checks if the Study level SMS notification is eligible to send SMS.
     * @author: Krishna Mahto
     * @param:  n
     * @return: Boolean
     **/
    public Boolean skipStudyLevelSMSCheck(Notification__c n) {
        String perIdRecipientIdKey = n?.WhatId__c + '_' + n?.Recipient__c;

        if (n.Notification_Type__c == NotificationCatalog.MSG_TO_DELEGATE_STUDY_LEVEL_WELCOME_MSG) {
            // If SMS Type is Welcome Message for Patient Delegate and welcome message is sent to Patient delegate then skip the non welcome SMS.
            Boolean welcomeMessageSendToDel =
                NotificationService.perIdDelConIdWelcomeMessageSentMap.containsKey(
                    perIdRecipientIdKey
                ) &&
                NotificationService.perIdDelConIdWelcomeMessageSentMap.get(perIdRecipientIdKey);

            if (welcomeMessageSendToDel) {
                return true;
            }
        } else if (
            n.Notification_Type__c == NotificationCatalog.MESSAGE_TO_PT_STUDY_LEVEL_WELCOME_MSG
        ) {
            //If SMS Type is Welcome Message for Participant and welcome message is sent  to participant then skip SMS.
            Boolean isWelcomeMessageSendToParticipant =
                NotificationService.welcomemsgSent.containsKey(n.Id) &&
                NotificationService.welcomemsgSent.get(n.Id);
            if (isWelcomeMessageSendToParticipant) {
                return true;
            }
        } else if (
            NotificationCatalog.nonWelcomeNoticationTypesForDelegate.contains(
                n.Notification_Type__c
            )
        ) {
            //If SMS Type is Study Level non welcome Message for Patient Delegate and any of the welcomeMessageSend and welcomeMessageDelivered Flag for
            //Patient delegate is not true then skip the SMS.
            Boolean isWelcomeMessageSentAndDeliveredToDel =
                NotificationService.perIdDelConIdWelcomeMessageSentMap.containsKey(
                    perIdRecipientIdKey
                ) &&
                NotificationService.perIdDelConIdWelcomeMessageSentMap.get(perIdRecipientIdKey) &&
                NotificationService.perIdDelConIdWelcomeMessageDeleveredMap.containsKey(
                    perIdRecipientIdKey
                ) &&
                NotificationService.perIdDelConIdWelcomeMessageDeleveredMap.get(
                    perIdRecipientIdKey
                );
            if (!isWelcomeMessageSentAndDeliveredToDel) {
                return true;
            }
        } else if (
            !NotificationCatalog.nonWelcomeNoticationTypesForDelegate.contains(
                n.Notification_Type__c
            ) && !NotificationService.welcomemsgNoticationtypes.Contains(n.Notification_Type__c)
        ) {
            //If SMS Type is Study Level Non welcome Message for Participant and welcomeMessageSend and welcomeMessageDelivered Flag for
            //Participant is not true then skip the SMS.
            Boolean isWelcomeMessageSentAndDeliveredPar =
                NotificationService.welcomemsgSent.containsKey(n.Id) &&
                NotificationService.welcomemsgSent.get(n.Id) &&
                NotificationService.welcomemsgDelivered.containsKey(n.Id) &&
                NotificationService.welcomemsgDelivered.get(n.Id);
            if (!isWelcomeMessageSentAndDeliveredPar) {
                return true;
            }
        }
        return false;
    }
    /**
     * @description:  This method checks if the Platform level SMS notification is eligible to send SMS.
     * @author: Krishna Mahto
     * @param:  n
     * @return: Boolean
     **/
    public Boolean skipPlatformLevelSMSCheck(Notification__c n) {
        //TODO: Implement logic if we have to handle the Platform level SMS for participant and delegate separatly.
        //If Notification is welcome message and welcome message is already sent, skip the SMS.
        if (NotificationService.welcomemsgNoticationtypes.Contains(n.Notification_Type__c)) {
            Boolean iSPlatformLevelWelcomeMessageSent =
                NotificationService.welcomemsgSent.containsKey(n.Id) &&
                NotificationService.welcomemsgSent.get(n.Id);

            if (iSPlatformLevelWelcomeMessageSent) {
                return true;
            }
        } else {
            //If SMS Type is Study Level Non welcome Message  welcomeMessageSend and welcomeMessageDelivered Flag for
            //Participant is not true then skip the SMS.
            Boolean iSPlatformLevelWelcomeMessageSent =
                NotificationService.welcomemsgSent.containsKey(n.Id) &&
                NotificationService.welcomemsgSent.get(n.Id) &&
                NotificationService.welcomemsgDelivered.containsKey(n.Id) &&
                NotificationService.welcomemsgDelivered.get(n.Id);
            if (!iSPlatformLevelWelcomeMessageSent) {
                return true;
            }
        }

        return false;
    }

    public Boolean isAvailableForPush(Id contactId, String whatId) {
        //TODO
        return true;
    }

    public Boolean isDeferNotification(Id contactId, String whatId) {
        if (!permissionSetsByConIdMap.containsKey(contactId))
            return true;

        List<String> userCommunityPerms = permissionSetsByConIdMap.get(contactId);
        return !userCommunityPerms.contains(getCommunityTemplate(contactId, whatId).permissionSet);
    }

    public String getOrgWideEmail(Id contactId, String whatId, String orgWideEmailTarget) {
        if (orgWideEmailTarget != EmailService.COMMUNITY_ORG_WIDE_ADDRESS_ST_SPECIFIC)
            return orgWideEmailTarget;
        return getCommunityTemplate(contactId, whatId)
            .properties.get(CommunityTemplateService.PROPERTY_ORG_WIDE_EMAIL_ADDRESS);
    }

    public CommunityTemplate getCommunityTemplate(Id contactId, String whatId) {
        if (whatId != null && objectsByIds.get(Id.valueOf(whatId)) == null)
            return CommunityTemplateService.getDefaultTemplate();
        String objType = whatId != null ? String.valueOf(((Id) whatId).getSobjectType()) : null;

        CommunityTemplate communityTemplate;
        if (objType == PARTICIPANT_ENROLLMENT_OBJ_NAME) {
            Participant_Enrollment__c pe = (Participant_Enrollment__c) objectsByIds.get(
                Id.valueOf(whatId)
            );
            communityTemplate = CommunityTemplateService.getTemplate(
                pe.Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c
            );
        } else if (objType == CLINICAL_TRIAL_PROFILE_OBJ_NAME) {
            Clinical_Trial_Profile__c ctp = (Clinical_Trial_Profile__c) objectsByIds.get(
                Id.valueOf(whatId)
            );
            communityTemplate = CommunityTemplateService.getTemplate(ctp.CommunityTemplate__c);
        } else if (objType == STUDY_SITE_OBJ_NAME) {
            Study_Site__c ss = (Study_Site__c) objectsByIds.get(Id.valueOf(whatId));
            communityTemplate = CommunityTemplateService.getTemplate(
                ss.Clinical_Trial_Profile__r.CommunityTemplate__c
            );
        } else if (objType == TASK_OBJ_NAME) {
            Task task = (Task) objectsByIds.get(Id.valueOf(whatId));
            if (task.Community_Template_Name__c != null) {
                communityTemplate = CommunityTemplateService.getTemplate(
                    task.Community_Template_Name__c
                );
            } else if (
                task.WhatId != null &&
                task.WhatId.getSobjectType() == Participant_Enrollment__c.getSObjectType()
            ) {
                Participant_Enrollment__c pe = (Participant_Enrollment__c) objectsByIds.get(
                    Id.valueOf(task.WhatId)
                );
                communityTemplate = CommunityTemplateService.getTemplate(
                    pe.Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c
                );
            }
        } else if (objType == SURVEY_INVITATION_OBJ_NAME) {
            SurveyInvitation surveyInv = (SurveyInvitation) objectsByIds.get(Id.valueOf(whatId));
            if (surveyInv.Participant_Enrollment__c != null) {
                communityTemplate = CommunityTemplateService.getTemplate(
                    surveyInv.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c
                );
            }
        } else if (objType == null || objType == CONTACT || objType == PARTICIPANT_OBJ_NAME) {
            //TODO: for future functionality
        }

        if (communityTemplate == null) {
            List<String> permSet = permissionSetsByConIdMap.get(contactId);
            if (
                permSet != null &&
                !permSet.contains(CommunityTemplateService.PERMISSION_COMMUNITY_DEFAULT_NAME)
            ) {
                communityTemplate = CommunityTemplateService.getTemplateByPermissionSetName(
                    permSet[0]
                );
            } else {
                communityTemplate = CommunityTemplateService.getDefaultTemplate();
            }
        }
        return communityTemplate;
    }

    private List<Participant_Enrollment__c> getPEList(Set<Id> peIds) {
        return [
            SELECT
                Id,
                Permit_Mail_Email_contact_for_this_study__c,
                Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c,
                Study_Site__r.Suppress_Participant_Emails__c,
                Study_Site__r.Principal_Investigator__r.Participant_Opt_In_Status_Emails__c,
                Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                Study_Site__r.SMS_Are_Available__c,
                Study_Site__r.Suppress_Study_Site_PI_Emails__c,
                Participant__r.IsCountry_NOT_Eligible_for_Emails__c,
                HCP__r.HCP_Contact__r.HCP_Opt_In_Patient_Status_Emails__c
            FROM Participant_Enrollment__c
            WHERE Id IN :peIds
        ];
    }

    private List<Participant__c> getParticipantList(Set<Id> parIds) {
        return [
            SELECT
                Id,
                Contact__r.Participant_Opt_In_Status_Emails__c,
                Contact__r.Participant_Opt_In_Status_SMS__c,
                IsCountry_NOT_Eligible_for_Emails__c
            FROM Participant__c
            WHERE Id IN :parIds
        ];
    }
    private Set<Id> getParPERList(Set<Id> parIds) {
        Set<Id> studyConsentAvailableForPar = new Set<Id>();
        List<Participant_Enrollment__c> availablePEs = [
            SELECT
                Id,
                Permit_Mail_Email_contact_for_this_study__c,
                Participant__c,
                participant_Contact__c,
                Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c,
                Study_Site__r.Suppress_Participant_Emails__c,
                Study_Site__r.Principal_Investigator__r.Participant_Opt_In_Status_Emails__c,
                Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                Study_Site__r.SMS_Are_Available__c,
                Study_Site__r.Suppress_Study_Site_PI_Emails__c,
                Participant__r.IsCountry_NOT_Eligible_for_Emails__c,
                HCP__r.HCP_Contact__r.HCP_Opt_In_Patient_Status_Emails__c
            FROM Participant_Enrollment__c
            WHERE Participant__c IN :parIds AND Permit_Mail_Email_contact_for_this_study__c = TRUE
        ];
        if (availablePEs != null) {
            for (Participant_Enrollment__c per : availablePEs) {
                studyConsentAvailableForPar.add(per.Participant__c);
            }
        }
        return studyConsentAvailableForPar;
    }

    private Map<Id, Boolean> checkIfPIContactsHaveSitesWithEnabledEmails(List<Id> contactIds) {
        Map<Id, Boolean> resultMap = new Map<Id, Boolean>();
        for (Id contactId : contactIds) {
            resultMap.put(contactId, false);
        }
        if (!contactIds.isEmpty()) {
            for (Study_Site__c site : [
                SELECT Id, Principal_Investigator__c
                FROM Study_Site__c
                WHERE
                    Suppress_Study_Site_PI_Emails__c = FALSE
                    AND Principal_Investigator__c IN :contactIds
            ]) {
                resultMap.put(site.Principal_Investigator__c, true);
            }
        }
        return resultMap;
    }

    private Map<Id, Boolean> checkIfPIContactsHasDelegatedSitesWithEnabledEmails(
        List<Id> contactIds
    ) {
        Map<Id, Boolean> resultMap = new Map<Id, Boolean>();
        for (Id contactId : contactIds) {
            resultMap.put(contactId, false);
        }
        if (!contactIds.isEmpty()) {
            for (Site_Staff__c staff : [
                SELECT Id, Site_Contact__c
                FROM Site_Staff__c
                WHERE
                    Study_Site__r.Suppress_Study_Site_PI_Emails__c = FALSE
                    AND Site_Contact__c IN :contactIds
            ]) {
                resultMap.put(staff.Site_Contact__c, true);
            }
        }
        return resultMap;
    }

    public Boolean compareParticipantTimeZone(Notification__c n) {
        if (n.StartDate__c != null) {
            Contact contact = contactByIdMap.get(n.Recipient__c);
            //String triggerDate = n.StartDate__c.format();
            Datetime notificationstartDateTime = n.StartDate__c;
            datetime gmtDateTime = datetime.now();
            string triggerDate = notificationstartDateTime.format('yyyy-MM-dd');
            if (contact.Users.size() > 0) {
                String userTimeZone = contact.Users[0].TimeZoneSidKey;
                if (userTimeZone != null) {
                    string participantDate = gmtDateTime.format('yyyy-MM-dd', userTimeZone);
                    list<String> participantSplitDate = participantDate.split('-');
                    Date participantDateObj = date.newinstance(
                        Integer.valueOf(participantSplitDate[0]),
                        Integer.valueOf(participantSplitDate[1]),
                        Integer.valueOf(participantSplitDate[2])
                    );
                    list<String> triggerSplitDate = triggerDate.split('-');
                    Date triggerDateObj = date.newinstance(
                        Integer.valueOf(triggerSplitDate[0]),
                        Integer.valueOf(triggerSplitDate[1]),
                        Integer.valueOf(triggerSplitDate[2])
                    );

                    if (triggerDateObj > participantDateObj) {
                        return false;
                    }
                }
            }
        }
        return true;
    }

    public Boolean isUpdatedPPTemplate(String whatId, String contactId) {
        Boolean isValid = false;
        String communityTemplate;
        if (whatId != null && objectsByIds.get(Id.valueOf(whatId)) == null)
            return isValid;
        String objType = String.valueOf(((Id) whatId).getSobjectType());
        if (objType == PARTICIPANT_ENROLLMENT_OBJ_NAME) {
            Participant_Enrollment__c pe = (Participant_Enrollment__c) objectsByIds.get(
                Id.valueOf(whatId)
            );
            communityTemplate = pe.Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c;
            isValid = pe.Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c ==
                CommunityTemplateService.TEMPLATE_PP
                ? true
                : false;
        } else if (objType == CLINICAL_TRIAL_PROFILE_OBJ_NAME) {
            Clinical_Trial_Profile__c ctp = (Clinical_Trial_Profile__c) objectsByIds.get(
                Id.valueOf(whatId)
            );
            communityTemplate = ctp.CommunityTemplate__c;
            isValid = ctp.CommunityTemplate__c == CommunityTemplateService.TEMPLATE_PP
                ? true
                : false;
        } else if (objType == STUDY_SITE_OBJ_NAME) {
            Study_Site__c ss = (Study_Site__c) objectsByIds.get(Id.valueOf(whatId));
            communityTemplate = ss.Clinical_Trial_Profile__r.CommunityTemplate__c;
            isValid = ss.Clinical_Trial_Profile__r.CommunityTemplate__c ==
                CommunityTemplateService.TEMPLATE_PP
                ? true
                : false;
        } else if (objType == TASK_OBJ_NAME) {
            Task task = (Task) objectsByIds.get(Id.valueOf(whatId));
            if (task.Community_Template_Name__c != null) {
                communityTemplate = task.Community_Template_Name__c;
                isValid = task.Community_Template_Name__c == CommunityTemplateService.TEMPLATE_PP
                    ? true
                    : false;
            } else if (
                task.WhatId != null &&
                task.WhatId.getSobjectType() == Participant_Enrollment__c.getSObjectType()
            ) {
                Participant_Enrollment__c pe = (Participant_Enrollment__c) objectsByIds.get(
                    Id.valueOf(task.WhatId)
                );
                communityTemplate = pe.Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c;
                isValid = pe.Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c ==
                    CommunityTemplateService.TEMPLATE_PP
                    ? true
                    : false;
            }
        } else if (objType == SURVEY_INVITATION_OBJ_NAME) {
            SurveyInvitation surveyInv = (SurveyInvitation) objectsByIds.get(Id.valueOf(whatId));
            if (surveyInv.Participant_Enrollment__c != null) {
                communityTemplate = surveyInv.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c;
                isValid = surveyInv.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c ==
                    CommunityTemplateService.TEMPLATE_PP
                    ? true
                    : false;
            }
        }
        if (communityTemplate == null) {
            List<String> permSet = permissionSetsByConIdMap.get(contactId);
            CommunityTemplate communityTemp;
            if (permSet != null) {
                communityTemp = CommunityTemplateService.getTemplateByPermissionSetName(permSet[0]);
                isValid = communityTemp.templateName == CommunityTemplateService.TEMPLATE_PP
                    ? true
                    : false;
            }
        }
        return isValid;
    }
}
