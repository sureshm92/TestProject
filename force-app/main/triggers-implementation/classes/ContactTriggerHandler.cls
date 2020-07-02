/**
* Created by D.Yasinskyi on 05.05.2018
* Refactored by Leonid Bartenev
*/

public without sharing class ContactTriggerHandler {

    // Handlers: -------------------------------------------------------------------------------------------------------

    public class UpdateParticipantAndUserEmailsOnEmailChangeHandler extends TriggerHandler {

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updateParticipantAndUserEmailsOnEmailChange(newList, (Map<Id, Contact>) oldMap);
        }
    }

    public class CreateUserForDelegateContactHandler extends TriggerHandler {

        public override void afterInsert(List<SObject> newList) {
            createUserForDelegateContact(newList);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createUserForDelegateContact(newList);
        }
    }

    public class SetShowTourDefaultHandler extends TriggerHandler {

        public override void beforeInsert(List<SObject> newList) {
            setShowTourDefault(newList);
        }
    }

    public class PopulateOverrideFields extends TriggerHandler {

        public override void beforeInsert(List<SObject> newList) {
            populateOverrideFields(newList);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            populateOverrideFields(newList);
        }
    }

    public class CreateUserForCCContactHandler extends TriggerHandler {

        public override void afterInsert(List<SObject> newList) {
            createUserForCCContact(newList);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createUserForCCContact(newList);
        }
    }

    // Logic: ----------------------------------------------------------------------------------------------------------

    @TestVisible
    private static void updateParticipantAndUserEmailsOnEmailChange(List<Contact> newList, Map<Id, Contact> oldMap) {
        Boolean needUpdate = false;
        for (Contact cnt : newList) {
            needUpdate = (oldMap.get(cnt.Id).Email != cnt.Email);
            if (needUpdate) break;
        }
        if (needUpdate) {
            //prepare participants map:
            List<Participant__c> participants = [SELECT Id, Contact__c FROM Participant__c WHERE Contact__c IN:newList];
            Map<Id, Participant__c> participantsByContactMap = new Map<Id, Participant__c>();
            for (Participant__c participant : participants) participantsByContactMap.put(participant.Contact__c, participant);
            //prepare users map:
            List<User> users = [SELECT Id, ContactId FROM User WHERE ContactId IN:newList];
            Map<Id, User> usersByContactMap = new Map<Id, User>();
            for (User user : users) usersByContactMap.put(user.ContactId, user);
            //process contacts:
            List<Participant__c> participantsForUpdate = new List<Participant__c>();
            List<User> usersForUpdate = new List<User>();
            for (Contact cnt : newList) {
                Contact oldCnt = oldMap.get(cnt.Id);
                if (oldCnt.Email != cnt.Email) {
                    Participant__c participant = participantsByContactMap.get(cnt.Id);
                    if (participant != null) {
                        participant.Email__c = cnt.Email;
                        participantsForUpdate.add(participant);
                    }
                    User user = usersByContactMap.get(cnt.Id);
                    if (user != null) {
                        user.Email = cnt.Email;
                        usersForUpdate.add(user);
                    }
                }
            }
            update usersForUpdate;
            update participantsForUpdate;
        }
    }

    @TestVisible
    private static void createUserForDelegateContact(List<Contact> newList) {
        Map<Id, Contact> filteredContactsByIds = new Map<Id, Contact>();

        for (Contact cont : newList) {
            if (cont.Email != null && cont.primaryContact__c != null) {
                filteredContactsByIds.put(cont.Id, cont);

            }
        }

        if (filteredContactsByIds.isEmpty()) return;

        //get users if exist
        Map<Id, User> communityUsers = new Map<Id, User>();
        for (User usr : CommunityService.getCommunityUsersByContactIds(filteredContactsByIds.keySet())) {
            if (communityUsers.containsKey(usr.ContactId)) {
                System.debug('Several users for contact Id= ' + usr.Id);
            } else {
                communityUsers.put(usr.ContactId, usr);
            }
        }
        Set<Id> toCreateUser = new Set<Id>();
        for (Id contactId : filteredContactsByIds.keySet()) {
            if (!communityUsers.containsKey(contactId)) toCreateUser.add(contactId);
        }
        if (!toCreateUser.isEmpty()) ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createPortalUsers(toCreateUser);

    }

    @TestVisible
    private static void setShowTourDefault(List<Contact> newList) {
        List<String> defaultModes = new List<String>{
                CommunityService.USER_MODE_PI,
                CommunityService.USER_MODE_HCP,
                CommunityService.USER_MODE_PARTICIPANT
        };
        for (Contact contact : newList) contact.userCommunity_ShowTour__c = String.join(defaultModes, ';');
    }

    private static void populateOverrideFields(List<Contact> newList) {
        for (Contact contact : newList) {
            if (contact.LastName != null && String.isBlank(contact.Override_Mailing_Address__c)) {
                //MailingStreet & BR() & MailingCity & ", " & MailingState & " " &MailingPostalCode
                contact.Override_Mailing_Address__c = contact.MailingStreet + '\n' + contact.MailingCity + ', ' + contact.MailingState + ' ' + contact.MailingPostalCode;
            }
            if (contact.LastName != null && String.isBlank(contact.Override_Phone__c)) {
                contact.Override_Phone__c = contact.Phone;
            }
            if (contact.userCommunityMode__c == 'CC')
            {
                if (contact.userCommunytyType__c == null)
                {
                   contact.userCommunytyType__c ='CC';
                }
                else if(contact.userCommunytyType__c.contains('CC'))
                {
                  contact.userCommunytyType__c =contact.userCommunytyType__c;
                }else
                {
                   contact.userCommunytyType__c =contact.userCommunytyType__c+';CC';
                }
           }
            contact.Next_Profile_Update_DT__c = Datetime.now().addYears(1);
        }
    }

    @TestVisible
    private static void createUserForCCContact(List<Contact> newList) {
        Map<Id, Contact> filteredCCContactsByIds = new Map<Id, Contact>();
        List<Id> DeactivateCCContact = new List<Id>();

        for (Contact cont : newList) {
            if(cont.userCommunityMode__c == 'CC'){
                if (cont.Email != null && cont.CC_Staff_Status__c) {
                    filteredCCContactsByIds.put(cont.Id, cont);
                }
                if (!cont.CC_Staff_Status__c ) {
                    DeactivateCCContact.add(cont.Id);
                }
            }
        }
        if(!DeactivateCCContact.isEmpty()) CommunityService.deactivateUsers(DeactivateCCContact);
        
        //get users if exist
        Map<Id, User> communityUsers = new Map<Id, User>();
        for (User usr : CommunityService.getCommunityUsersByContactIds(filteredCCContactsByIds.keySet())) {
            if (communityUsers.containsKey(usr.ContactId)) {
                System.debug('Several users for contact Id= ' + usr.Id);
            } else {
                communityUsers.put(usr.ContactId, usr);
            }
        }

        Set<Id> toActivateUser = new Set<Id>();
        Set<Id> toCreateUser = new Set<Id>();
        for (Id contactId : filteredCCContactsByIds.keySet()) {
            if (!communityUsers.containsKey(contactId)) toCreateUser.add(contactId); else toActivateUser.add(contactId);
        }
        if (!toCreateUser.isEmpty()) ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createPortalUsers(toCreateUser);

        if (!toActivateUser.isEmpty()) CommunityService.ActivateUsers(toActivateUser);

    }


}