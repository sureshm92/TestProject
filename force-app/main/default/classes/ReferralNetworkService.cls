/**
 * Created by RAMukhamadeev on 2019-04-18.
 */

public class ReferralNetworkService {
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

        update toUpdateContacts;
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
}