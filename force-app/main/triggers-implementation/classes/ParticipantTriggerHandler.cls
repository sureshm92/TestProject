/**
 * Created by Leonid Bartenev
 */

public without sharing class ParticipantTriggerHandler {

    // Handlers: -------------------------------------------------------------------------------------------------------

    public class CreateContactsForParticipantsHandler extends TriggerHandler{

        public override void beforeInsert(List<SObject> newList) {
            createContactsForParticipants(newList);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createContactsForParticipants(newList);
        }
    }

    public class UpdatePEAndContactLastNameHandler extends TriggerHandler{

        public override void afterInsert(List<SObject> newList) {
            updatePEAndContactLastName(newList);
        }
    }

    public class ChangeUserEmailOnParticipantEmailChangeHandler extends TriggerHandler{

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            changeUserEmailOnParticipantEmailChange(newList, (Map<Id, Participant__c>)oldMap);
        }
    }

    public class PrepareCityStateFieldsHandler extends TriggerHandler{

        public override void beforeInsert(List<SObject> newList) {
            prepareCityStateFields(newList, null);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            prepareCityStateFields(newList, (Map<Id, Participant__c>)oldMap);
        }
    }
    
    public class CheckDuplicatesHandler extends TriggerHandler{
        
        public override void beforeInsert(List<SObject> newList) {
            checkDuplicates(newList);
        }
    }

    public class CheckBecomesAdultHandler extends TriggerHandler{

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            checkBecomesAdult(newList, (Map<Id, Participant__c>)oldMap);
        }
    }
    
    
    // Logic: ----------------------------------------------------------------------------------------------------------

    @TestVisible
    private static void createContactsForParticipants(List<Participant__c> newList){
        Id participantAccountId = getParticipantAccountId();
        Map<String, Participant__c> participantsByEmail = new Map<String, Participant__c>();
        List<Contact> contactsToInsert = new List<Contact>();
        List<String> emails = new List<String>();
        newList = ParticipantService.checkParticipantsAgeOfMajority(newList);
        for(Participant__c participant : newList){
            if(participant.Contact__c == null){
                emails.add(participant.Email__c);
                Contact newContact = new Contact();
                newContact.LastName = participant.Last_Name__c;
                newContact.Email = participant.Email__c;
                newContact.AccountId = participantAccountId;
                newContact.Language__c = participant.Preferred_Language__c;
                newContact.Second_Choice_Language__c = '';
                newContact.Third_Choice_Language__c = '';
                newContact.userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT;
                newContact.userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT;

                contactsToInsert.add(newContact);
                participantsByEmail.put(participant.Email__c, participant);

            }
        }
        System.debug('CONTACTS TO INSERT: ' + contactsToInsert);
        insert contactsToInsert;

        for(Contact newContact : contactsToInsert){
            Participant__c participant = participantsByEmail.get(newContact.Email);
            if(participant != null) participant.Contact__c = newContact.Id;
        }
    }

    @TestVisible
    private static void updatePEAndContactLastName(List<Participant__c> newList){
        List<Contact> contacts = new List<Contact>();
        for(Participant__c participant : newList){
            if(participant.Contact__c != null){
                contacts.add(new Contact(
                        Id = participant.Contact__c,
                        FirstName = null,
                        LastName = participant.Name
                ));
            }

        }
        if(!contacts.isEmpty()){
            update contacts;
        }
        update [SELECT Id FROM Participant_Enrollment__c WHERE Participant__c IN: newList];
    }

    @TestVisible
    private static void changeUserEmailOnParticipantEmailChange(List<Participant__c> newList, Map<Id, Participant__c> oldMap){
        Set<Id> contactIds = new Set<Id>();
        for(Participant__c participant : newList) {
            if(participant.Contact__c != null) contactIds.add(participant.Contact__c);
        }
        List<User> users = [SELECT Id, ContactId, Email FROM User WHERE ContactId IN: contactIds];
        Map<Id, User> usersByContactIdMap = new Map<Id, User>();
        for(User user : users){
            usersByContactIdMap.put(user.ContactId, user);
        }
        List<User> usersForUpdate = new List<User>();
        for(Participant__c participant : newList){
            Participant__c oldParticipant = oldMap.get(participant.Id);
            if(oldParticipant.Email__c != participant.Email__c && Participant__c.Contact__c != null){
                User user = usersByContactIdMap.get(participant.Contact__c);
                if(user != null){
                    user.Email = participant.Email__c;
                    usersForUpdate.add(user);
                }
            }
        }
        update usersForUpdate;
    }

    @TestVisible
    private static void prepareCityStateFields(List<Participant__c> newList, Map<Id, Participant__c> oldMap){
        for(Participant__c participant : newList){
            String countryName = participant.Mailing_Country__c;
            String countryCode = participant.Mailing_Country_Code__c;
            String stateName = participant.Mailing_State__c;
            String stateCode = participant.Mailing_State_Code__c;

            if(oldMap == null){

                if(countryCode == null && countryName != null){
                    participant.Mailing_Country_Code__c = CountryStateUtil.getCountryCode(countryName);
                    if(participant.Mailing_Country_Code__c == null){
                        participant.addError('Invalid Country');
                    }
                }else if (countryCode != null && countryName == null){
                    participant.Mailing_Country__c = CountryStateUtil.getCountryName(countryCode);
                    if(participant.Mailing_Country__c == null){
                        participant.addError('Invalid Country Code');
                    }
                }else if (countryCode != null && countryName != null){
                    if(countryCode != CountryStateUtil.getCountryCode(countryName)){
                        participant.addError('Invalid County and Country Code');
                    }
                }
                if(stateCode == null && stateName != null){
                    participant.Mailing_State_Code__c = CountryStateUtil.getStateCode(participant.Mailing_Country_Code__c, stateName);
                    if(participant.Mailing_State_Code__c == null){
                        participant.addError('Invalid State Province');
                    }
                }else if (stateCode != null && stateName == null){
                    participant.Mailing_State__c = CountryStateUtil.getStateName(participant.Mailing_Country_Code__c, stateCode);
                    if(participant.Mailing_State__c == null){
                        participant.addError('Invalid State Province Code');
                    }
                }else if (stateCode != null && stateName != null){
                    if(stateCode != CountryStateUtil.getStateCode(participant.Mailing_Country_Code__c, stateName)){
                        participant.addError('Invalid State Province and State Province Code');
                    }
                }
            }
            if(oldMap != null){
                Boolean countryNameChanged = oldMap.get(participant.Id).Mailing_Country__c != countryName;
                Boolean countryCodeChanged = oldMap.get(participant.Id).Mailing_Country_Code__c != countryCode;
                Boolean stateNameChanged = oldMap.get(participant.Id).Mailing_State__c != stateName;
                Boolean stateCodeChanged = oldMap.get(participant.Id).Mailing_State_Code__c != stateCode;

                if(countryCodeChanged && !countryNameChanged){
                    participant.Mailing_Country__c = CountryStateUtil.getCountryName(countryCode);
                    if(participant.Mailing_Country__c == null && countryCode != null){
                        participant.addError('Invalid Country Code');
                    }
                }else if(!countryCodeChanged && countryNameChanged){
                    participant.Mailing_Country_Code__c = CountryStateUtil.getCountryCode(countryName);
                    if(participant.Mailing_Country_Code__c == null && countryName != null){
                        participant.addError('Invalid Country');
                    }
                }else if(countryCodeChanged && countryNameChanged){
                    if(countryCode != CountryStateUtil.getCountryCode(countryName)){
                        participant.addError('Invalid County and Country Code');
                    }
                }

                if(stateCodeChanged && !stateNameChanged){
                    participant.Mailing_State__c = CountryStateUtil.getStateName(participant.Mailing_Country_Code__c, stateCode);
                    if(participant.Mailing_State__c == null && stateCode != null){
                        participant.addError('Invalid State Province Code');
                    }
                }else if(!stateCodeChanged && stateNameChanged){
                    participant.Mailing_State_Code__c = CountryStateUtil.getStateCode(participant.Mailing_Country_Code__c, stateName);
                    if(participant.Mailing_State_Code__c == null && stateName != null){
                        participant.addError('Invalid State Province');
                    }
                }else if(stateCodeChanged && stateNameChanged){
                    if(stateCode != CountryStateUtil.getStateCode(participant.Mailing_Country_Code__c, stateName)){
                        participant.addError('Invalid State Province and State Province Code');
                    }
                }
            }
        }
    }

    @TestVisible
    private static Id getParticipantAccountId(){
        return [SELECT Id FROM Account WHERE Name =: CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME LIMIT 1 FOR UPDATE].Id;
    }
    
    private static void checkDuplicates(List<Participant__c> newList){
        ParticipantDuplicateService duplicateService = new ParticipantDuplicateService(newList);
        for(Participant__c participant : newList){
            Participant__c duplicateParticipant = duplicateService.findDuplicate(participant);
            if(duplicateParticipant != null){
                participant.addError('Duplicate found: ' + duplicateParticipant.Id);
            }
        }
    }

    @TestVisible
    private static void checkBecomesAdult(List<Participant__c> newList, Map<Id, Participant__c> oldMap) {
        Map<Id, Participant__c> participantsByContactId = new Map<Id, Participant__c>();
        Set<Id> patientIsAdult = new Set<Id>();

        for (Participant__c participant : newList) {
            if (participant.Adult__c && participant.Adult__c != oldMap.get(participant.Id).Adult__c) {
                if (participant.Contact__c != null) {
                    participantsByContactId.put(participant.Contact__c, participant);
                } else {
                    participant.Emancipation_in_progress__c = true;
                }
                patientIsAdult.add(participant.Id);
            }
        }

        if (!participantsByContactId.isEmpty()) {
            List<User> participantUsers = [SELECT Id, ContactId FROM User WHERE ContactId IN :participantsByContactId.keySet()];
            Map<Id, User> userByContactId = new Map<Id, User>();
            for (User usr : participantUsers) {
                userByContactId.put(usr.ContactId, usr);
            }
            for (Id contactId : participantsByContactId.keySet()) {
                if (!userByContactId.containsKey(contactId)) {
                    participantsByContactId.get(contactId).Emancipation_in_progress__c = true;
                }
            }
        }

        List<Patient_Delegate__c> patientDelegatesToUpdate = new List<Patient_Delegate__c>();
        List<Patient_Delegate__c> patientDelegates = PatientDelegateService.getPDelegates(new List<Id>(patientIsAdult));
        for (Patient_Delegate__c patientDelegate : patientDelegates) {
            if (PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS == patientDelegate.Status__c &&
                    patientIsAdult.contains(patientDelegate.Participant__c)) {
                patientDelegate.Status__c = PatientDelegateTriggerHandler.PATIENT_DELEGATE_ONHOLD_STATUS;
                patientDelegatesToUpdate.add(patientDelegate);
            }
        }
        if (!patientDelegatesToUpdate.isEmpty()) {
            update patientDelegatesToUpdate;
        }
    }

}