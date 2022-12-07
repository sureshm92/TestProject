/**
 * Created by AlexKetch on 4/16/2019.
 */

public with sharing class ClinicalTrialProfileTriggerHandler {
    public class UpdateClinicalTrialProfile extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            overrideStatusChangedBy(newList, null);
            populateOverrideFields(newList);
            updateShortCommunityName(newList, null);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            overrideStatusChangedBy(newList, (Map<Id, Clinical_Trial_Profile__c>) oldMap);
            populateOverrideFields(newList);
            populateDateOnTrialComplete(newList, (Map<Id, Clinical_Trial_Profile__c>) oldMap);
            updateShortCommunityName(newList, (Map<Id, Clinical_Trial_Profile__c>) oldMap);
        }

        public override void afterInsert(List<SObject> newList) {
            updateNextNotifyDateByCTP((List<Clinical_Trial_Profile__c>) newList, null);
            updateStudySitesCCSupport(newList, null);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updateClinicalTrialProfile(newList, (Map<Id, Clinical_Trial_Profile__c>) oldMap);
            deleteTravelVendors(newList, (Map<Id, Clinical_Trial_Profile__c>) oldMap);
            updateNextNotifyDateByCTP(
                (List<Clinical_Trial_Profile__c>) newList,
                (Map<Id, Clinical_Trial_Profile__c>) oldMap
            );
            updateStudySitesSuppressPIEmails(newList, (Map<Id, Clinical_Trial_Profile__c>) oldMap);
            updateStudySitesCCSupport(newList, (Map<Id, Clinical_Trial_Profile__c>) oldMap);
            createPreEnrollmentPatientVisits(newList, (Map<Id, Clinical_Trial_Profile__c>) oldMap);
        }

        public override void beforeDelete(List<SObject> oldList) {
        }
    }
    public class manageBypassedFieldsForTMDH extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            if (UserInfo.getName() != label.IQVIA_Integrations_User) {
                manageTMDHSyncForBypassedFields(newList, null);
            }
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            if (UserInfo.getName() != label.IQVIA_Integrations_User) {
                manageTMDHSyncForBypassedFields(
                    newList,
                    (Map<Id, Clinical_Trial_Profile__c>) oldMap
                );
            }
        }
    }
    private static void updateClinicalTrialProfile(
        List<SObject> newList,
        Map<Id, Clinical_Trial_Profile__c> oldMap
    ) {
        ClinicalTrialProfileService service = (ClinicalTrialProfileService) ClassFactory.newInstance(
            ClinicalTrialProfileService.class
        );
        service.deleteRelatedToStudyDocuments(
            (List<Clinical_Trial_Profile__c>) newList,
            (Map<Id, Clinical_Trial_Profile__c>) oldMap
        );
        service.addDeleteTherapeuticAreasOnParticipants(
            (List<Clinical_Trial_Profile__c>) newList,
            (Map<Id, Clinical_Trial_Profile__c>) oldMap
        );
    }

    private static void overrideStatusChangedBy(
        List<SObject> newList,
        Map<Id, Clinical_Trial_Profile__c> oldMap
    ) {
        Profile profile = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
        String profileName = profile.Name;
        for (Clinical_Trial_Profile__c ctp : (List<Clinical_Trial_Profile__c>) newList) {
            if (
                (oldMap == null && ctp.Override_Recruitment_Status__c != null) ||
                (oldMap != null &&
                oldMap.get(ctp.Id).Override_Recruitment_Status__c !=
                ctp.Override_Recruitment_Status__c)
            ) {
                ctp.Override_Status_Updated_By__c = profileName;
            }
        }
    }

    private static void populateOverrideFields(List<Clinical_Trial_Profile__c> newList) {
        for (Clinical_Trial_Profile__c ctp : newList) {
            if (
                ctp.Recruitment_Status__c == 'Enrolling' ||
                ctp.Recruitment_Status__c == 'Open to Enrollment'
            ) {
                ctp.Override_Recruitment_Status__c = 'Actively Enrolling';
            } else if (
                ctp.Recruitment_Status__c == 'Closed Follow-up / In Analysis' ||
                ctp.Recruitment_Status__c == 'Completed' ||
                ctp.Recruitment_Status__c == 'Closed to Enrollment'
            ) {
                ctp.Override_Recruitment_Status__c = 'Enrollment Closed';
            } else if (ctp.Recruitment_Status__c == 'Discontinued') {
                ctp.Override_Recruitment_Status__c = TrialService.STATUS_NO_LONGER_ENROLLING;
            } else if (
                ctp.Recruitment_Status__c == 'In Development' ||
                ctp.Recruitment_Status__c == 'On Hold' ||
                ctp.Recruitment_Status__c == 'Planning'
            ) {
                ctp.Override_Recruitment_Status__c = 'On Hold';
            }
            if (ctp.Detailed_Description__c != null && ctp.Override_Description__c == null) {
                ctp.Override_Description__c = ctp.Detailed_Description__c;
            }
        }
    }

    private static void deleteTravelVendors(
        List<Clinical_Trial_Profile__c> newList,
        Map<Id, Clinical_Trial_Profile__c> oldMap
    ) {
        List<Id> ctpIdsForUpdate = new List<Id>();
        for (Clinical_Trial_Profile__c ctp : newList) {
            Clinical_Trial_Profile__c ctpOld = oldMap.get(ctp.Id);
            if (!ctp.Travel_Vendor_Is_Available__c && ctpOld.Travel_Vendor_Is_Available__c) {
                ctpIdsForUpdate.add(ctp.Id);
            }
        }

        List<TravelVendorSettings__c> travelVendorSettingsToDelete = [
            SELECT Id
            FROM TravelVendorSettings__c
            WHERE Study_Site__r.Clinical_Trial_Profile__c IN :ctpIdsForUpdate
        ];
        delete travelVendorSettingsToDelete;
        SettingStoreService.deleteSettings('TravelVendorSetupFilter', ctpIdsForUpdate);
    }

    private static void updateNextNotifyDateByCTP(
        List<Clinical_Trial_Profile__c> trialProfiles,
        Map<Id, Clinical_Trial_Profile__c> oldMap
    ) {
        List<Clinical_Trial_Profile__c> trialProfilesList = new List<Clinical_Trial_Profile__c>();
        for (Clinical_Trial_Profile__c objCTP : trialProfiles) {
            if (objCTP.Logged_Out_Days_Notification__c != null) {
                if (
                    oldMap == null ||
                    (oldMap != null &&
                    oldMap.containsKey(objCTP.Id) &&
                    oldMap.get(objCTP.Id).Logged_Out_Days_Notification__c !=
                    objCTP.Logged_Out_Days_Notification__c)
                ) {
                    trialProfilesList.add(objCTP);
                }
            }
        }
        List<Participant_Enrollment__c> enrollments = new List<Participant_Enrollment__c>();
        if (trialProfilesList.size() > 0) {
            enrollments = [
                SELECT Participant__r.Contact__c
                FROM Participant_Enrollment__c
                WHERE
                    Clinical_Trial_Profile__c IN :trialProfilesList
                    AND Participant_Status__c IN :PEStatusState.PE_STATUS_GROUP_IN_PROGRESS_ALL
                    AND Clinical_Trial_Profile__r.Logged_Out_Days_Notification__c != NULL
            ];
        }
        List<Id> allContactsIds = new List<Id>();
        List<Id> participantContIds = new List<Id>();
        for (Participant_Enrollment__c pe : enrollments) {
            Id contactId = pe.Participant__r.Contact__c;
            allContactsIds.add(contactId);
            participantContIds.add(contactId);
        }

        List<Patient_Delegate__c> patientDelegates = [
            SELECT Id, Contact__c, Contact__r.Next_Notify_Date__c, Participant__r.Contact__c
            FROM Patient_Delegate__c
            WHERE Participant__r.Contact__c IN :participantContIds
        ];

        Map<Id, Id> partCntByDelegateCnt = new Map<Id, Id>();
        for (Patient_Delegate__c pd : patientDelegates) {
            partCntByDelegateCnt.put(pd.Contact__c, pd.Participant__r.Contact__c);
            allContactsIds.add(pd.Contact__c);
        }

        List<User> users = [
            SELECT Id, ContactId, Contact.UserCommunityIsDelegate__c, LastLoginDate
            FROM User
            WHERE
                IsActive = TRUE
                AND LastLoginDate != NULL
                AND ContactId != NULL
                AND ContactId IN :allContactsIds
        ];

        Map<Id, Integer> nearestNotificationByContactIds = ParticipantService.getNearestLogOutNotification(
            participantContIds
        );
        List<Contact> forUpdateContacts = new List<Contact>();
        for (User user : users) {
            Integer daysToNotify;
            if (
                user.Contact.UserCommunityIsDelegate__c &&
                partCntByDelegateCnt.containsKey(user.ContactId)
            ) {
                if (
                    nearestNotificationByContactIds.containsKey(
                        partCntByDelegateCnt.get(user.ContactId)
                    )
                ) {
                    daysToNotify = nearestNotificationByContactIds.get(
                        partCntByDelegateCnt.get(user.ContactId)
                    );
                }
            } else if (nearestNotificationByContactIds.containsKey(user.ContactId)) {
                daysToNotify = nearestNotificationByContactIds.get(user.ContactId);
            }

            if (daysToNotify == null)
                continue;
            Date nextNotifyDate = System.now().addDays(daysToNotify).dateGmt();
            forUpdateContacts.add(
                new Contact(Id = user.ContactId, Next_Notify_Date__c = nextNotifyDate)
            );
        }

        if (!forUpdateContacts.isEmpty())
            update forUpdateContacts;
    }

    private static void populateDateOnTrialComplete(
        List<SObject> newList,
        Map<Id, Clinical_Trial_Profile__c> oldMap
    ) {
        for (Object obj : newList) {
            Clinical_Trial_Profile__c ctp = (Clinical_Trial_Profile__c) obj;
            if (
                oldMap != null &&
                ctp.Status__c == ClinicalTrialProfileService.STATUS_COMPLETED &&
                oldMap.get(ctp.Id).Status__c != ctp.Status__c
            ) {
                ctp.Trial_Complete__c = Date.today();
            }
        }
    }

    private static void updateShortCommunityName(
        List<SObject> newList,
        Map<Id, Clinical_Trial_Profile__c> oldMap
    ) {
        for (Clinical_Trial_Profile__c ctp : (List<Clinical_Trial_Profile__c>) newList) {
            if (
                (oldMap == null &&
                String.isEmpty(ctp.ShortCommunityName__c) &&
                String.isNotEmpty(ctp.CommunityTemplate__c)) ||
                (oldMap != null &&
                oldMap.get(ctp.Id).CommunityTemplate__c != ctp.CommunityTemplate__c)
            ) {
                CommunityTemplate template = CommunityTemplateService.getTemplate(
                    ctp.CommunityTemplate__c
                );
                ctp.ShortCommunityName__c = template.shortCommunityName;
            }
        }
    }

    private static void updateStudySitesSuppressPIEmails(
        List<Clinical_Trial_Profile__c> newList,
        Map<Id, Clinical_Trial_Profile__c> oldMap
    ) {
        Map<Id, Clinical_Trial_Profile__c> ctpIdsWithSitesToUpdateMap = new Map<Id, Clinical_Trial_Profile__c>();
        for (Clinical_Trial_Profile__c ctp : newList) {
            if (
                oldMap != null &&
                ctp.Suppress_PI_Emails__c != oldMap.get(ctp.Id).Suppress_PI_Emails__c
            ) {
                ctpIdsWithSitesToUpdateMap.put(ctp.Id, ctp);
            }
        }
        List<Study_Site__c> sitesToUpdate = [
            SELECT Id, Suppress_Study_Site_PI_Emails__c, Clinical_Trial_Profile__c
            FROM Study_Site__c
            WHERE Clinical_Trial_Profile__c IN :ctpIdsWithSitesToUpdateMap.keySet()
        ];
        for (Study_Site__c site : sitesToUpdate) {
            site.Suppress_Study_Site_PI_Emails__c = ctpIdsWithSitesToUpdateMap.get(
                    site.Clinical_Trial_Profile__c
                )
                .Suppress_PI_Emails__c;
        }
        if (!sitesToUpdate.isEmpty()) {
            update sitesToUpdate;
        }
    }

    private static void updateStudySitesCCSupport(
        List<Clinical_Trial_Profile__c> newList,
        Map<Id, Clinical_Trial_Profile__c> oldMap
    ) {
        Map<Id, Clinical_Trial_Profile__c> ctpIdsWithSitesToUpdateMap = new Map<Id, Clinical_Trial_Profile__c>();
        for (Clinical_Trial_Profile__c ctp : newList) {
            if (
                oldMap != null &&
                ctp.Enable_for_Call_Center_Support__c !=
                oldMap.get(ctp.Id).Enable_for_Call_Center_Support__c
            ) {
                ctpIdsWithSitesToUpdateMap.put(ctp.Id, ctp);
            }
        }
        List<Study_Site__c> sitesToUpdate = [
            SELECT Id, Enable_for_Call_Center_Support__c, Clinical_Trial_Profile__c
            FROM Study_Site__c
            WHERE Clinical_Trial_Profile__c IN :ctpIdsWithSitesToUpdateMap.keySet()
        ];
        for (Study_Site__c site : sitesToUpdate) {
            site.Enable_for_Call_Center_Support__c = ctpIdsWithSitesToUpdateMap.get(
                    site.Clinical_Trial_Profile__c
                )
                .Enable_for_Call_Center_Support__c;
        }
        if (!sitesToUpdate.isEmpty()) {
            update sitesToUpdate;
        }
    }
    public static void manageTMDHSyncForBypassedFields(
        List<Clinical_Trial_Profile__c> newList,
        Map<Id, Clinical_Trial_Profile__c> oldMap
    ) {
        Id profileId = userinfo.getProfileId();
        String profileName = [SELECT Id, Name FROM Profile WHERE Id = :profileId].Name;
        List<String> TMDHBypassedFieldsList = label.TMDHBypassedFieldsforCTP.split(';');
        for (Clinical_Trial_Profile__c ctp : newList) {
            String bypassFieldStr = ctp.Bypass_Fields_for_TMDH__c == null
                ? ''
                : ctp.Bypass_Fields_for_TMDH__c;
            List<String> BypassFieldsforTMDHList = ctp.Bypass_Fields_for_TMDH__c == null
                ? null
                : ctp.Bypass_Fields_for_TMDH__c.Split(';');
            for (String strfield : TMDHBypassedFieldsList) {
                //if non IQVAI user updates the list of bypass fields except Recruitment_Status__c then add the filed in bypass custom field
                if (!strfield.equalsIgnoreCase('Recruitment_Status__c')) {
                    if (
                        (oldMap == null && ctp.get(strfield) != null) ||
                        (oldMap != null &&
                        ctp.get(strfield) != oldMap.get(ctp.Id).get(strfield))
                    ) {
                        if (
                            (BypassFieldsforTMDHList == null) ||
                            (BypassFieldsforTMDHList != null &&
                            !BypassFieldsforTMDHList.contains(strfield))
                        ) {
                            bypassFieldStr = bypassFieldStr + ';' + strfield;
                        }
                    }
                } else {
                    //If non IQVAI and Non System admin user is updating Recruitment_Status__c field then add the filed in bypass custom field
                    if (!profileName.equalsIgnoreCase(label.SystemAdminProfile)) {
                        if (
                            (oldMap == null && ctp.get(strfield) != null) ||
                            (oldMap != null &&
                            ctp.get(strfield) != oldMap.get(ctp.Id).get(strfield))
                        ) {
                            if (
                                (BypassFieldsforTMDHList == null) ||
                                (BypassFieldsforTMDHList != null &&
                                !BypassFieldsforTMDHList.contains(strfield))
                            ) {
                                bypassFieldStr = bypassFieldStr + ';' + strfield;
                            }
                        }
                    } else if (
                        (oldMap != null && ctp.get(strfield) != oldMap.get(ctp.Id).get(strfield)) &&
                        (BypassFieldsforTMDHList != null &&
                        BypassFieldsforTMDHList.contains('Recruitment_Status__c'))
                    ) {
                        //If System Admin user is upadating the Recruitment_Status__c field and if this field is already added in bypass custom field
                        //then remove this field
                        bypassFieldStr = bypassFieldStr.remove('Recruitment_Status__c');
                    }
                }
            }
            bypassFieldStr = bypassFieldStr.removeStart(';');
            bypassFieldStr = bypassFieldStr.removeEnd(';');
            bypassFieldStr = bypassFieldStr.replace(';;', ';');
            ctp.Bypass_Fields_for_TMDH__c = bypassFieldStr;
        }
    }

    /**
     * @description: This mehtod will lanch a batch to create Pre Enrollment Patient Visist records for Existing Participants when
     *               any of the Pre Enrollment Toggles at CTP will be On.
     * @author Krishna Mahto
     * @param newList
     * @param oldMap
     **/
    private static void createPreEnrollmentPatientVisits(
        List<Clinical_Trial_Profile__c> newList,
        Map<Id, Clinical_Trial_Profile__c> oldMap
    ) {
        Map<Id, Clinical_Trial_Profile__c> ctpIdsWithSitesToUpdateMap = new Map<Id, Clinical_Trial_Profile__c>();
        boolean lauchBatch = false;
        set<id> ctpIds = new Set<id>();
        for (Clinical_Trial_Profile__c ctp : newList) {
            if (oldMap != null) {
                if (
                    //If for "Pre-consent" Toggle at CTP is is On.
                    ctp.Received_Until_Consent_Is_Available__c !=
                    oldMap.get(ctp.Id).Received_Until_Consent_Is_Available__c &&
                    ctp.Received_Until_Consent_Is_Available__c == true
                ) {
                    lauchBatch = true;
                    ctpIds.Add(ctp.Id);
                } else if (
                    //If "Consent through Enrolled/Randomized toggle at CTP" is On.
                    ctp.Enrolled_Or_Randomized_Consent_Available__c !=
                    oldMap.get(ctp.Id).Enrolled_Or_Randomized_Consent_Available__c &&
                    ctp.Enrolled_Or_Randomized_Consent_Available__c == true
                ) {
                    lauchBatch = true;
                    ctpIds.Add(ctp.Id);
                }
            }
        }
        //Launch batch to Create Pre Enrollment Patient Visits for Participants.
        if (lauchBatch) {
            Batch_CreatePreEnrollVistsForExtngPERs objBatch = new Batch_CreatePreEnrollVistsForExtngPERs(
                ctpIds
            );
            Database.executeBatch(objBatch, 50);
        }
    }
}
