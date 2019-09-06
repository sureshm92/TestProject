/**
 * Created by Leonid Bartenev
 */

public without sharing class ContactService {
    
    public static void updateCurrentPEOnContacts(List<Id> contactIds){
        List<Contact> contacts = [
                SELECT Id, Current_Participant_Enrollment__c
                FROM Contact
                WHERE Id IN: contactIds
        ];
        Map<Id, List<Id>> availablePEIdsByContactIdMap = PatientDelegateService.getAvailablePEIdsListByContactIdMap(contactIds);
        for(Contact contact : contacts){
            List<Id> peIds = availablePEIdsByContactIdMap.get(contact.Id);
            System.debug('>>> PE IDS: ' + peIds);
            if(peIds == null) peIds = new List<Id>();
            if(peIds.size() > 0){
                System.debug('>>> Cur PE: ' + contact.Current_Participant_Enrollment__c);
                System.debug('>>> Contains: ' + peIds.contains(contact.Current_Participant_Enrollment__c));
                if(contact.Current_Participant_Enrollment__c == null ||
                        (contact.Current_Participant_Enrollment__c != null &&
                                !peIds.contains(contact.Current_Participant_Enrollment__c))) {
                    System.debug('>>> update current');
                    contact.Current_Participant_Enrollment__c = peIds[0];
                }
            }else{
                contact.Current_Participant_Enrollment__c = null;
            }
        }
        update contacts;
    }

}