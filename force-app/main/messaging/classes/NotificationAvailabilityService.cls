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

    private Map<Id, Contact> contactByIdMap;
    private List<String> allPermissions;
    private Map<Id, List<String>> permissionSetsByConIdMap;

    private Map<Id, SObject> objectsByIds;

    public NotificationAvailabilityService(List<Id> recipientIds, List<String> whatIds) {
        contactByIdMap = new Map<Id, Contact>();
        List<Contact> contacts = [
                SELECT Id,
                        Participant_Opt_In_Status_Emails__c,
                        Participant_Opt_In_Status_SMS__c,
                        UserCommunityIsDelegate__c,
                        userCommunityMode__c
                FROM Contact
                WHERE Id IN:recipientIds
        ];
        for (Contact con : contacts) contactByIdMap.put(con.Id, con);

        allPermissions = new List<String>(CommunityTemplateService.getAllPermissionSets());

        permissionSetsByConIdMap = new Map<Id, List<String>>();
        List<User> users = [
                SELECT Id, ContactId
                FROM User
                WHERE ContactId = :contacts
        ];
        List<PermissionSetAssignment> userPerSetAssignments = [
                SELECT Id, AssigneeId, Assignee.ContactId, PermissionSet.Name
                FROM PermissionSetAssignment
                WHERE AssigneeId IN :users AND PermissionSet.Name IN:allPermissions
        ];


        for (PermissionSetAssignment perAssign : userPerSetAssignments) {
            Id assigneeContactId = perAssign.Assignee.ContactId;
            if (!permissionSetsByConIdMap.containsKey(assigneeContactId)) permissionSetsByConIdMap.put(assigneeContactId, new List<String>());
            permissionSetsByConIdMap.get(assigneeContactId).add(perAssign.PermissionSet.Name);
        }

        Map<String, List<Id>> objectsByStrings = new Map<String, List<Id>>();
        objectsByIds = new Map<Id, SObject>();
        //Map for WhatIds Map(HCP, List<Id>)
        for (String str : whatIds) {
            Id whatId;
            try {
                whatId = Id.valueOf(str);
            } catch (Exception e) {
                System.debug('WhatId is not Id of SObject: ' + e.getMessage());
            }
            if (whatId == null) continue;

            String objKey = String.valueOf(whatId.getSobjectType());
            System.debug(objKey);

            if (!objectsByStrings.containsKey(objKey)) objectsByStrings.put(objKey, new List<Id>());
            objectsByStrings.get(objKey).add(whatId);
        }

        //Map <Id, SObject>
        for (String objType : objectsByStrings.keySet()) {
            if (objType == PARTICIPANT_ENROLLMENT_OBJ_NAME) {
                List<Participant_Enrollment__c> listPE = getPEList(new Set<Id>(objectsByStrings.get(objType)));
                for (Participant_Enrollment__c pe : listPE) {
                    objectsByIds.put(pe.Id, pe);
                }
            }
            if (objType == PARTICIPANT_OBJ_NAME) {
                List<Participant__c> participants = [
                        SELECT Id,
                                Contact__r.Participant_Opt_In_Status_Emails__c,
                                Contact__r.Participant_Opt_In_Status_SMS__c,
                                IsCountry_NOT_Eligible_for_Emails__c
                        FROM Participant__c
                        WHERE Id IN:objectsByStrings.get(objType)
                ];
                for (Participant__c participant : participants) {
                    objectsByIds.put(participant.Id, participant);
                }
            }
            if (objType == CLINICAL_TRIAL_PROFILE_OBJ_NAME) {
                List<Clinical_Trial_Profile__c> listCTP = [
                        SELECT Id,
                                Suppress_Participant_Emails__c,
                                CommunityTemplate__c
                        FROM Clinical_Trial_Profile__c
                        WHERE Id IN:objectsByStrings.get(objType)
                ];
                for (Clinical_Trial_Profile__c ctp : listCTP) {
                    objectsByIds.put(ctp.Id, ctp);
                }
            }
            if (objType == SURVEY_INVITATION_OBJ_NAME) {
                List<SurveyInvitation> survInvList = [
                        SELECT Id,
                                Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c
                        FROM SurveyInvitation
                        WHERE Id IN:objectsByStrings.get(objType)
                ];
                for (SurveyInvitation sur : survInvList) {
                    objectsByIds.put(sur.Id, sur);
                }
            }
            if (objType == TASK_OBJ_NAME) {
                List<Task> taskList = [
                        SELECT Id,
                                Community_Template_Name__c,
                                WhatId
                        FROM Task
                        WHERE Id IN:objectsByStrings.get(objType)
                ];
                Set<Id> peIds = new Set<Id>();
                for (Task tsk : taskList) {
                    Id whatId = tsk.WhatId;
                    if (whatId != null && whatId.getSobjectType() == Participant_Enrollment__c.getSObjectType()) peIds.add(whatId);
                    objectsByIds.put(tsk.Id, tsk);
                }
                List<Participant_Enrollment__c> peList = getPEList(peIds);
                for (Participant_Enrollment__c pe : peList) {
                    objectsByIds.put(pe.Id, pe);
                }
            }
            if (objType == HCP_ENROLLMENT_OBJ_NAME) {
                List<HCP_Enrollment__c> hcpeList = [
                        SELECT Id,
                                HCP_Contact__r.HCP_Opt_In_Referral_Status_Emails__c
                        FROM HCP_Enrollment__c
                        WHERE Id IN:objectsByStrings.get(objType)
                ];
                for (HCP_Enrollment__c hcpe : hcpeList) {
                    objectsByIds.put(hcpe.Id, hcpe);
                }
            }
            if (objType == CONTACT) {
                //TODO if Contact needs additional fields
            }
            if (objType == CASE_OBJ_NAME) {
                //TODO if Contact needs additional fields
            }

            //TODO for other objects passing in WhatID
        }
    }

    public Boolean isAvailable(String whatId, String recipientType, String notificationTarget, Id contactId) {
        if(whatId != null && objectsByIds.get(whatId) == null) return false;
        Boolean checkForNotification = false;
        String objType = null;
        Id objId;
        if (whatId != null) {
            objId = whatId;
            objType = String.valueOf(objId.getSobjectType());
        }
        if (recipientType == NotificationService.NOTIFICATION_RECIPIENT_TYPE_PARTICIPANT) {
            if (objType == PARTICIPANT_ENROLLMENT_OBJ_NAME) {
                Participant_Enrollment__c pe = (Participant_Enrollment__c) objectsByIds.get(Id.valueOf(whatId));
                Contact contact = contactByIdMap.get(contactId);
                if (pe != null && contact != null &&
                        ((contact.UserCommunityIsDelegate__c && contact.Participant_Opt_In_Status_Emails__c)
                                || (!contact.UserCommunityIsDelegate__c && pe.Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c))
                        && !pe.Study_Site__r.Suppress_Participant_Emails__c
                        && !pe.Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c
                        && !pe.Participant__r.IsCountry_NOT_Eligible_for_Emails__c) {

                    checkForNotification = true;
                }
            } else if (objType == PARTICIPANT_OBJ_NAME) {
                Participant__c participant = (Participant__c) objectsByIds.get(Id.valueOf(whatId));
                if (participant != null && participant.Contact__r.Participant_Opt_In_Status_Emails__c
                        && !participant.IsCountry_NOT_Eligible_for_Emails__c) {
                    checkForNotification = true;
                }
            } else if (objType == CLINICAL_TRIAL_PROFILE_OBJ_NAME) {
                Clinical_Trial_Profile__c ctp = (Clinical_Trial_Profile__c) objectsByIds.get(Id.valueOf(whatId));
                if (!ctp.Suppress_Participant_Emails__c && contactByIdMap.get(contactId).Participant_Opt_In_Status_Emails__c) checkForNotification = true;
            } else if (objType == SURVEY_INVITATION_OBJ_NAME || objType == TASK_OBJ_NAME) {
                Contact contact = contactByIdMap.get(contactId);
                if (contact.Participant_Opt_In_Status_Emails__c) checkForNotification = true;
            } else if (objType == CASE_OBJ_NAME) {
                Contact contact = contactByIdMap.get(contactId);
                if (contact.Participant_Opt_In_Status_Emails__c) checkForNotification = true;
            } else if (objType == null) {
                Contact contact = contactByIdMap.get(contactId);
                if (contact.Participant_Opt_In_Status_Emails__c) checkForNotification = true;
            }
        }
        if (recipientType == NotificationService.NOTIFICATION_RECIPIENT_TYPE_HCP) {
            if (objType == PARTICIPANT_ENROLLMENT_OBJ_NAME) {
                Participant_Enrollment__c pe = (Participant_Enrollment__c) objectsByIds.get(Id.valueOf(whatId));
                if (pe.HCP__r.HCP_Contact__r.HCP_Opt_In_Patient_Status_Emails__c) {
                    checkForNotification = true;
                }
            } else if (objType == HCP_ENROLLMENT_OBJ_NAME) {
                HCP_Enrollment__c hcpe = (HCP_Enrollment__c) objectsByIds.get(Id.valueOf(whatId));
                if (hcpe.HCP_Contact__r.HCP_Opt_In_Referral_Status_Emails__c) {
                    checkForNotification = true;
                }
            } else if (objType == CONTACT) {
                checkForNotification = true;
            }

        }
        if (recipientType == NotificationService.NOTIFICATION_RECIPIENT_TYPE_PI) {
            if (objType == PARTICIPANT_ENROLLMENT_OBJ_NAME) {
                Participant_Enrollment__c pe = (Participant_Enrollment__c) objectsByIds.get(Id.valueOf(whatId));
                if (pe == null || pe.Study_Site__r == null || pe.Study_Site__r.Principal_Investigator__r == null) {
                    checkForNotification = false;
                } else{
                    checkForNotification = true;
                }
            } else if (objType == CONTACT || objType == STUDY_SITE_OBJ_NAME) {
                checkForNotification = true;
            }
        }
        return checkForNotification;
    }

    public Boolean isAvailableForSMS(Id contactId, String whatId) {
        Boolean isAvailable = true;
        Id objId = whatId;
        Contact contact = contactByIdMap.get(contactId);
        isAvailable = isAvailable && contact.Participant_Opt_In_Status_SMS__c;
        if (objId.getSobjectType() == Participant_Enrollment__c.getSObjectType()) {
            Participant_Enrollment__c pe = (Participant_Enrollment__c) objectsByIds.get(Id.valueOf(whatId));
            isAvailable = isAvailable && pe.Study_Site__r.SMS_Are_Available__c;
        }
        return isAvailable;
    }

    public Boolean isDeferNotification(Id contactId, String whatId){
        if(!permissionSetsByConIdMap.containsKey(contactId)) return true;
        
        List<String> userCommunityPerms = permissionSetsByConIdMap.get(contactId);
        return !userCommunityPerms.contains(getCommunityTemplate(contactId, whatId).permissionSet);
    }

    public String getOrgWideEmail(Id contactId, String whatId, String orgWideEmailTarget) {
        if (orgWideEmailTarget != EmailService.COMMUNITY_ORG_WIDE_ADDRESS_ST_SPECIFIC) return orgWideEmailTarget;
        return getCommunityTemplate(contactId, whatId).properties.get(CommunityTemplateService.PROPERTY_ORG_WIDE_EMAIL_ADDRESS);
    }

    public CommunityTemplate getCommunityTemplate(Id contactId, String whatId) {
        if(whatId != null && objectsByIds.get(whatId) == null) return CommunityTemplateService.getDefaultTemplate();
        String objType = whatId != null ? String.valueOf(((Id)whatId).getSobjectType()) : null;

        CommunityTemplate communityTemplate;
        if (objType == PARTICIPANT_ENROLLMENT_OBJ_NAME) {
            Participant_Enrollment__c pe = (Participant_Enrollment__c) objectsByIds.get(Id.valueOf(whatId));
            communityTemplate = CommunityTemplateService.getTemplate(pe.Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c);
        } else if (objType == CLINICAL_TRIAL_PROFILE_OBJ_NAME) {
            Clinical_Trial_Profile__c ctp = (Clinical_Trial_Profile__c) objectsByIds.get(Id.valueOf(whatId));
            communityTemplate = CommunityTemplateService.getTemplate(ctp.CommunityTemplate__c);
        } else if (objType == TASK_OBJ_NAME) {
            Task task = (Task) objectsByIds.get(Id.valueOf(whatId));
            if(task.Community_Template_Name__c != null) {
                communityTemplate = CommunityTemplateService.getTemplate(task.Community_Template_Name__c);
            } else if (task.WhatId != null && task.WhatId.getSobjectType() == Participant_Enrollment__c.getSObjectType()) {
                Participant_Enrollment__c pe = (Participant_Enrollment__c) objectsByIds.get(Id.valueOf(task.WhatId));
                communityTemplate = CommunityTemplateService.getTemplate(pe.Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c);
            }
        } else if (objType == SURVEY_INVITATION_OBJ_NAME) {
            SurveyInvitation surveyInv = (SurveyInvitation) objectsByIds.get(Id.valueOf(whatId));
            if (surveyInv.Participant_Enrollment__c != null) {
                communityTemplate = CommunityTemplateService.getTemplate(surveyInv.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c);
            }
        }else if (objType == null || objType == CONTACT || objType == PARTICIPANT_OBJ_NAME) {
            //TODO: for future functionality
        }

        if(communityTemplate == null) {
            List<String> permSet = permissionSetsByConIdMap.get(contactId);
            if (permSet != null && !permSet.contains(CommunityTemplateService.PERMISSION_COMMUNITY_DEFAULT_NAME)) {
                communityTemplate = CommunityTemplateService.getTemplateByPermissionSetName(permSet[0]);
            } else {
                communityTemplate = CommunityTemplateService.getDefaultTemplate();
            }
        }
        return communityTemplate;
    }

    private List<Participant_Enrollment__c> getPEList(Set<Id> peIds) {
        return [
                SELECT Id, Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c,
                        Study_Site__r.Suppress_Participant_Emails__c,
                        Study_Site__r.Principal_Investigator__r.Participant_Opt_In_Status_Emails__c,
                        Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                        Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                        Study_Site__r.SMS_Are_Available__c,
                        Participant__r.IsCountry_NOT_Eligible_for_Emails__c,
                        HCP__r.HCP_Contact__r.HCP_Opt_In_Patient_Status_Emails__c
                FROM Participant_Enrollment__c
                WHERE Id IN:peIds
        ];
    }

}
