/**
 * Created by Olga Skrynnikova on 11/29/2019.
 */

public without sharing class NotificationAvailabilityService {

    private Map<Id, SObject> objectsByIds;

    public NotificationAvailabilityService(List<String> whatIds) {
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
            //TODO for other objects passing in WhatID
        }


    }

    public Boolean isAvailable(String whatId, String recipientType) {
        Boolean checkForNotification = false;
        if (recipientType == 'Participant') {
            Participant_Enrollment__c pe = (Participant_Enrollment__c) objectsByIds.get(Id.valueOf(whatId));
            if (pe.Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c
                    && !pe.Study_Site__r.Suppress_Participant_Emails__c
                    && !pe.Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c
                    && !pe.Participant__r.IsCountry_NOT_Eligible_for_Emails__c) {
                checkForNotification = true;
            }
        }
        if (recipientType == 'HCP') {
            Participant_Enrollment__c pe = (Participant_Enrollment__c) objectsByIds.get(Id.valueOf(whatId));
            if (pe.HCP__r.HCP_Contact__r.HCP_Opt_In_Patient_Status_Emails__c) {
                checkForNotification = true;
            }
        }
        return checkForNotification;
    }
}