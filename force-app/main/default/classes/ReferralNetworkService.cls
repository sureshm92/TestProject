/**
 * Created by RAMukhamadeev on 2019-04-18.
 */

public without sharing class ReferralNetworkService {
    private static Set<Id> getContactIds(List<SObject> touchedJunctions) {
        Set<Id> contactIds = new Set<Id>();
        for (SObject currJunction : touchedJunctions) {
            contactIds.add((Id) currJunction.get('ContactId__c'));
        }

        return contactIds;
    }

    private static String getSiteNamesString(List<Contact_Referral_Network__c> referralNetworks) {
        Set<String> names = new Set<String>();
        for (Contact_Referral_Network__c currReferralNetwork : referralNetworks) {
            names.add(currReferralNetwork.ReferralNetworkId__r.Name);
        }
        List<String> namesList = new List<String>(names);
        namesList.sort();
        String namesString = String.join(namesList, ';');

        return namesString;
    }

    public static void syncContactInterestedSites(List<Contact_Referral_Network__c> touchedJunctions) {
        Set<Id> contactIds = getContactIds(touchedJunctions);
        List<Contact> touchedContacts = [
                SELECT Id, (SELECT Id, ReferralNetworkId__r.Name FROM Contact_Referral_Networks__r)
                FROM Contact
                WHERE Id IN :contactIds
        ];

        List<Contact> toUpdateContacts = new List<Contact>();
        for (Contact currContact : touchedContacts) {
            Contact toUpdateContact = new Contact(
                    Id = currContact.Id,
                    SitesInterested__c = getSiteNamesString(currContact.Contact_Referral_Networks__r)
            );
            toUpdateContacts.add(toUpdateContact);
        }
        System.debug('toUpdateContacts' + toUpdateContacts);
        if(!toUpdateContacts.isEmpty()){
            update toUpdateContacts;
        }
    }

    private static String getTopicNamesString(List<Contact_Therapeutic_Area__c> referralNetworks) {
        Set<String> names = new Set<String>();
        for (Contact_Therapeutic_Area__c currReferralNetwork : referralNetworks) {
            names.add(currReferralNetwork.TherapeuticAreaId__r.Name);
        }
        List<String> namesList = new List<String>(names);
        namesList.sort();
        String namesString = String.join(namesList, ';');

        return namesString;
    }

    public static void syncContactInterestedTopics(List<Contact_Therapeutic_Area__c> touchedJunctions) {
        Set<Id> contactIds = getContactIds(touchedJunctions);
        List<Contact> touchedContacts = [
                SELECT Id, (SELECT Id, TherapeuticAreaId__r.Name FROM Contact_Therapeutic_Areas__r)
                FROM Contact
                WHERE Id IN :contactIds
        ];

        List<Contact> toUpdateContacts = new List<Contact>();
        for (Contact currContact : touchedContacts) {
            Contact toUpdateContact = new Contact(
                    Id = currContact.Id,
                    TopicsInterested__c = getTopicNamesString(currContact.Contact_Therapeutic_Areas__r)
            );
            toUpdateContacts.add(toUpdateContact);
        }

        update toUpdateContacts;
    }

    public static void sendEmails(List<Study_Site__c> newSites, Map<Id, Study_Site__c> oldSites) {
        // fetch new study sites with referral networks
        Map<Id, List<Id>> networkIdToStudySiteList = new Map<Id, List<Id>>();
        for (Study_Site__c currStudySite : newSites) {
            if (currStudySite.ReferralNetworkId__c != null && (oldSites == null || oldSites.get(currStudySite.Id).ReferralNetworkId__c == null)) {
                if (!networkIdToStudySiteList.containsKey(currStudySite.ReferralNetworkId__c)) {
                    networkIdToStudySiteList.put(currStudySite.ReferralNetworkId__c, new List<Id>());
                }
                networkIdToStudySiteList.get(currStudySite.ReferralNetworkId__c).add(currStudySite.Id);
            }
        }

        if (!networkIdToStudySiteList.isEmpty()) {

            // fetch subscribed contacts
            List<Referral_Network__c> referralNetworks = [
                    SELECT Id, Name
                    FROM Referral_Network__c
                    WHERE Id IN :networkIdToStudySiteList.keySet()
            ];

            Map<String, Id> networkNamesMap = new Map<String, Id>();
            for (Referral_Network__c currReferralNetwork : [
                    SELECT Id, Name
                    FROM Referral_Network__c
                    WHERE Id IN :networkIdToStudySiteList.keySet()
            ]) {
                networkNamesMap.put(currReferralNetwork.Name, currReferralNetwork.Id);
            }

            String networkNamesString = String.join(new List<String>(networkNamesMap.keySet()), ';');
            Map<Id, Set<Id>> contactIdByStudySiteIds = new Map<Id, Set<Id>>();
            for (Contact currContact : [
                    SELECT Id, SitesInterested__c
                    FROM Contact
                    WHERE (SitesInterested__c != NULL)
                    AND (SitesInterested__c INCLUDES (:networkNamesString))
            ]) {
                contactIdByStudySiteIds.put(currContact.Id, new Set<Id>());
                for (String networkName : currContact.SitesInterested__c.split(';')) {
                    if (networkNamesMap.containsKey(networkName)) {
                        Id networkId = networkNamesMap.get(networkName);
                        List<Id> studySiteIds = networkIdToStudySiteList.get(networkId);
                        contactIdByStudySiteIds.get(currContact.Id).addAll(studySiteIds);
                    }
                }
            }

            List<Notification__c> notifications = new List<Notification__c>();
            for (Id contactId : contactIdByStudySiteIds.keySet()) {
                for (Id SSId : contactIdByStudySiteIds.get(contactId)) {
                    notifications.add(new Notification__c(
                            Recipient__c = contactId,
                            WhatId__c = SSId,
                            Notification_Type__c = NotificationCatalog.MESSAGE_TO_HCP_REFERRAL_NETWORK_TYPE
                    ));
                }
            }

            insert notifications;
        }
    }
}