/**
 * Created by D.Yasinskyi on 05.05.2018
 * Refactored by Leonid Bartenev
 */

public without sharing class ContactTriggerHandler {
    // Handlers: -------------------------------------------------------------------------------------------------------
	//public static Boolean noUpdateOnParticipantRecord = false;
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
            if (!Test.isrunningTest()) {
                createUserForCCContact(newList);
            }
        }
    }

    public class UpdateParticipantDetailsHandler extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updateParticipantDetailsHandler((List<Contact>)newList, (Map<Id, Contact>) oldMap);
        }
    }
    
    // Logic: ----------------------------------------------------------------------------------------------------------

    @TestVisible
    private static void updateParticipantDetailsHandler(List<Contact> newList, Map<Id, Contact> oldMap){
        Map<ID, Contact> updatedContactsMap = new Map<Id, Contact>();
        for(Contact c : newList){
            Boolean isUpdateNeeded= false;
            if(c.MailingCountry!= oldMap.get(c.Id).MailingCountry){
                isUpdateNeeded = true;
            }
            if(c.MailingCountryCode!= oldMap.get(c.Id).MailingCountryCode){
                isUpdateNeeded = true;
            }
            if(c.MailingState!= oldMap.get(c.Id).MailingState){
                isUpdateNeeded = true;
            }
            if(c.MailingStateCode!= oldMap.get(c.Id).MailingStateCode){
                isUpdateNeeded = true;
            }
            if(c.MailingPostalCode!= oldMap.get(c.Id).MailingPostalCode){
                isUpdateNeeded = true;
            } 
            /*if(c.Language__c != oldMap.get(c.Id).Language__c){
                isUpdateNeeded = true;
            }*/ 
            if(c.Phone != oldMap.get(c.Id).Phone){
                isUpdateNeeded = true;
            }                            
            if(isUpdateNeeded){
                updatedContactsMap.put(c.Id,c);                                  
            }
        }
        if(updatedContactsMap.size()>0){
            List<Participant__c> participantsToUpdate = new List<Participant__c>();
            for(Participant__c participant: [SELECT Id,Contact__c,Mailing_Country_Code__c,Preferred_Language__c,Phone__c,
                                             Mailing_State_Code__c,Mailing_Zip_Postal_Code__c 
                                             FROM Participant__c WHERE Contact__c IN :updatedContactsMap.keySet()]){
                Boolean isUpdateNeeded= false;
                if(participant.Mailing_Country_Code__c!= updatedContactsMap.get(participant.Contact__c).MailingCountryCode){
                    participant.Mailing_Country_Code__c = updatedContactsMap.get(participant.Contact__c).MailingCountryCode;
                    isUpdateNeeded = true;
                }
                if(participant.Mailing_State_Code__c!= updatedContactsMap.get(participant.Contact__c).MailingStateCode){
                    participant.Mailing_State_Code__c = updatedContactsMap.get(participant.Contact__c).MailingStateCode;
                    isUpdateNeeded = true;
                }
                if(participant.Mailing_Zip_Postal_Code__c!= updatedContactsMap.get(participant.Contact__c).MailingPostalCode){
                    participant.Mailing_Zip_Postal_Code__c = updatedContactsMap.get(participant.Contact__c).MailingPostalCode;
                    isUpdateNeeded = true;
                } 
                /*if(participant.Preferred_Language__c != updatedContactsMap.get(participant.Contact__c).Language__c){
                    participant.Preferred_Language__c = updatedContactsMap.get(participant.Contact__c).Language__c;
                    isUpdateNeeded = true;
                }*/ 
                if(participant.Phone__c != updatedContactsMap.get(participant.Contact__c).Phone){
                    participant.Phone__c = updatedContactsMap.get(participant.Contact__c).Phone;
                    isUpdateNeeded = true;
                }                             
                if(isUpdateNeeded){
                    participantsToUpdate.add(participant);                                  
                }
            }
            if(participantsToUpdate.size()>0){
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantTriggerHandler.UpdateContactDetailsFromParticipant.class
                );
                update participantsToUpdate;
            }
        }
    }
    
@TestVisible
    private static void updateParticipantAndUserEmailsOnEmailChange(
        List<Contact> newList,
        Map<Id, Contact> oldMap
    ) {
        Boolean needUpdate = false;
        for (Contact cnt : newList) {
            needUpdate = ((oldMap.get(cnt.Id).Email != cnt.Email) || (oldMap.get(cnt.Id).Language__c != cnt.Language__c));
            if (needUpdate)
                break;
        }
        if (needUpdate) {
            //prepare participants map:
            List<Participant__c> participants = [
                SELECT Id, Contact__c
                FROM Participant__c
                WHERE Contact__c IN :newList
            ];
            Map<Id, Participant__c> participantsByContactMap = new Map<Id, Participant__c>();
            for (Participant__c participant : participants)
                participantsByContactMap.put(participant.Contact__c, participant);
            //prepare users map:
            List<User> users = [SELECT Id, ContactId FROM User WHERE ContactId IN :newList];
            Map<Id, User> usersByContactMap = new Map<Id, User>();
            for (User user : users)
                usersByContactMap.put(user.ContactId, user);
            //process contacts:
            List<Participant__c> participantsForUpdate = new List<Participant__c>();
            List<User> usersForUpdate = new List<User>();
            for (Contact cnt : newList) {
                Contact oldCnt = oldMap.get(cnt.Id);
                if ((oldCnt.Email != cnt.Email) || (oldCnt.Language__c != cnt.Language__c)) {
                    Participant__c participant = participantsByContactMap.get(cnt.Id);
                    if (participant != null) {
                        participant.Email__c = cnt.Email;
                        participant.Preferred_Language__c = cnt.Language__c;
                        participantsForUpdate.add(participant);
                    }
                    User user = usersByContactMap.get(cnt.Id);
                    if (user != null) {
                        user.Email = cnt.Email;
                        user.LanguageLocaleKey = cnt.Language__c;
                        usersForUpdate.add(user);
                    }
                }
            }
            if(!usersForUpdate.isEmpty()){
            update usersForUpdate;
                }
             if(!participantsForUpdate.isEmpty()){
            update participantsForUpdate;
             }
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
        if (filteredContactsByIds.isEmpty())
            return;

        //get users if exist
        Map<Id, User> communityUsers = new Map<Id, User>();
        for (
            User usr : CommunityService.getCommunityUsersByContactIds(
                filteredContactsByIds.keySet()
            )
        ) {
            if (communityUsers.containsKey(usr.ContactId)) {
            } else {
                communityUsers.put(usr.ContactId, usr);
            }
        }
        Set<Id> toCreateUser = new Set<Id>();
        for (Id contactId : filteredContactsByIds.keySet()) {
            if (!communityUsers.containsKey(contactId))
                toCreateUser.add(contactId);
        }
        if (!toCreateUser.isEmpty())
            ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                .createPortalUsers(toCreateUser);
    }

    @TestVisible
    private static void setShowTourDefault(List<Contact> newList) {
        List<String> defaultModes = new List<String>{
            CommunityService.USER_MODE_PI,
            CommunityService.USER_MODE_HCP,
            CommunityService.USER_MODE_PARTICIPANT
        };
        for (Contact contact : newList)
            contact.userCommunity_ShowTour__c = String.join(defaultModes, ';');
    }

    private static void populateOverrideFields(List<Contact> newList) {
        for (Contact contact : newList) {
            if (contact.LastName != null && String.isBlank(contact.Override_Mailing_Address__c)) {
                //MailingStreet & BR() & MailingCity & ", " & MailingState & " " &MailingPostalCode
                contact.Override_Mailing_Address__c =
                    contact.MailingStreet +
                    '\n' +
                    contact.MailingCity +
                    ', ' +
                    contact.MailingState +
                    ' ' +
                    contact.MailingPostalCode;
            }
            if (contact.LastName != null && String.isBlank(contact.Override_Phone__c)) {
                contact.Override_Phone__c = contact.Phone;
            }
            if (contact.userCommunityMode__c == 'CC') {
                contact.userCommunytyType__c = 'CC';
            }
            contact.Next_Profile_Update_DT__c = Datetime.now().addYears(1);
        }
    }

    @TestVisible
    private static void createUserForCCContact(List<Contact> newList) {
        Map<Id, Contact> filteredCCContactsByIds = new Map<Id, Contact>();
        List<Id> DeactivateCCContact = new List<Id>();

        for (Contact cont : newList) {
            if (cont.userCommunityMode__c == 'CC') {
                if (cont.Email != null && cont.CC_Staff_Status__c) {
                    filteredCCContactsByIds.put(cont.Id, cont);
                }
                if (!cont.CC_Staff_Status__c) {
                    DeactivateCCContact.add(cont.Id);
                }
            }
        }
        if (!DeactivateCCContact.isEmpty())
            CommunityService.deactivateUsers(DeactivateCCContact);

        //get users if exist
        Map<Id, User> communityUsers = new Map<Id, User>();
        for (
            User usr : CommunityService.getCommunityUsersByContactIds(
                filteredCCContactsByIds.keySet()
            )
        ) {
            if (communityUsers.containsKey(usr.ContactId)) {
                System.debug('Several users for contact Id= ' + usr.Id);
            } else {
                communityUsers.put(usr.ContactId, usr);
            }
        }

        Set<Id> toActivateUser = new Set<Id>();
        Set<Id> toCreateUser = new Set<Id>();
        for (Id contactId : filteredCCContactsByIds.keySet()) {
            if (!communityUsers.containsKey(contactId))
                toCreateUser.add(contactId);
            else
                toActivateUser.add(contactId);
        }
        if (!toCreateUser.isEmpty())
            ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                .createCCPortalUsers(toCreateUser);

        if (!toActivateUser.isEmpty())
            CommunityService.ActivateUsers(toActivateUser);
    }
}
