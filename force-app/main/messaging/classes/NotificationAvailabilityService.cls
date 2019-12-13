/**
 * Created by Olga Skrynnikova on 11/29/2019.
 */

public without sharing class NotificationAvailabilityService {

    private Map<Id, Contact> contactByIdMap;

    private Map<Id, SObject> objectsByIds;

    public NotificationAvailabilityService(List<String> whatIds) {
        contactByIdMap = new Map<Id, Contact>();
        List<Contact> contacts = [
                SELECT Id,
                        Participant_Opt_In_Status_Emails__c
                FROM Contact];
        for (Contact con : contacts) contactByIdMap.put(con.Id, con);

        Map<String, List<Id>> objectsByStrings;
        objectsByIds = new Map<Id, SObject>();
        objectsByStrings = new Map<String, List<Id>>();
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
        for (String st : objectsByStrings.keySet()) {
            if (st == 'Participant_Enrollment__c') {
                List<Participant_Enrollment__c> listPE = [
                        SELECT Id, Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c,
                                Study_Site__r.Suppress_Participant_Emails__c,
                                Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                                Participant__r.IsCountry_NOT_Eligible_for_Emails__c,
                                HCP__r.HCP_Contact__r.HCP_Opt_In_Patient_Status_Emails__c
                        FROM Participant_Enrollment__c
                        WHERE Id IN:objectsByStrings.get(st)
                ];
                for (Participant_Enrollment__c pe : listPE) {
                    objectsByIds.put(pe.Id, pe);
                }
            }
            if (st == 'Clinical_Trial_Profile__c') {
                List<Clinical_Trial_Profile__c> listCTP = [
                        SELECT Id,
                                Suppress_Participant_Emails__c
                        FROM Clinical_Trial_Profile__c
                        WHERE Id IN:objectsByStrings.get(st)
                ];
                for (Clinical_Trial_Profile__c ctp : listCTP) {
                    objectsByIds.put(ctp.Id, ctp);
                }
            }
            //TODO for other objects passing in WhatID
        }
    }

    public Boolean isAvailable(String whatId, String recipientType, String notificationTarget, Id contactId) {
        Boolean checkForNotification = false;
        String objType = null;
        Id objId;
        if (whatId != null) {
            objId = whatId;
            objType = String.valueOf(objId.getSobjectType());
        }
        if (recipientType == NotificationService.NOTIFICATION_RECIPIENT_TYPE_PARTICIPANT) {
            if (objType == 'Participant_Enrollment__c') {
                Participant_Enrollment__c pe = (Participant_Enrollment__c) objectsByIds.get(Id.valueOf(whatId));
                if (pe.Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c
                        && !pe.Study_Site__r.Suppress_Participant_Emails__c
                        && !pe.Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c
                        && !pe.Participant__r.IsCountry_NOT_Eligible_for_Emails__c) {
                    checkForNotification = true;
                }
            } else if (objType == 'Clinical_Trial_Profile__c') {
                Clinical_Trial_Profile__c ctp = (Clinical_Trial_Profile__c) objectsByIds.get(Id.valueOf(whatId));
                if (!ctp.Suppress_Participant_Emails__c) checkForNotification = true;
            } else if (objType == null) {
                Contact contact = contactByIdMap.get(contactId);
                if (contact.Participant_Opt_In_Status_Emails__c) checkForNotification = true;
            }
        }
        if (recipientType == NotificationService.NOTIFICATION_RECIPIENT_TYPE_HCP) {
            if (objType == 'Participant_Enrollment__c') {
                Participant_Enrollment__c pe = (Participant_Enrollment__c) objectsByIds.get(Id.valueOf(whatId));
                if (pe.HCP__r.HCP_Contact__r.HCP_Opt_In_Patient_Status_Emails__c) {
                    checkForNotification = true;
                }
            }
        }
        return checkForNotification;
    }
}