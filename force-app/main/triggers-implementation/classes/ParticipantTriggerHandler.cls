/**
 * Created by Leonid Bartenev
 */

public without sharing class ParticipantTriggerHandler {
	
    // Handlers: -------------------------------------------------------------------------------------------------------

    public class CreateContactsForParticipantsHandler extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            if(!Batch_UpsertEprParticipantAndPE.eprBatchRunning)createContactsForParticipants(newList);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            if(!Batch_UpsertEprParticipantAndPE.eprBatchRunning)createContactsForParticipants(newList);
        }
    }

    public class UpdateContactDetailsFromParticipant extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updateContactDetailsFromParticipant((List<Participant__c>)newList, (Map<Id, Participant__c>)oldMap);
        }
        public override void afterInsert(List<SObject> newList) {
            updateContactDetailsFromParticipant((List<Participant__c>)newList, new Map<Id, Participant__c>());
        }
    }
    
    public class UpdatePEAndContactLastNameHandler extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            updatePEAndContactLastName(newList);
        }
    }

    public class ChangeUserEmailOnParticipantEmailChangeHandler extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            if (System.isFuture() || System.isBatch() || test.isRunningTest()) {
                changeUserEmailOnParticipantEmailChange(newList, (Map<Id, Participant__c>) oldMap);
            } else {
                changeUserEmailOnParticipantEmailChangeAsync(
                    JSON.serialize(newList),
                    JSON.serialize((Map<Id, Participant__c>) oldMap)
                );
            }
        }
    }

    public class PrepareCityStateFieldsHandler extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            prepareCityStateFields(newList, null);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            prepareCityStateFields(newList, (Map<Id, Participant__c>) oldMap);
        }
    }

    public class CheckDuplicatesHandler extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            checkDuplicates(newList);
        }
    }

    public class UpdateParticipantAge extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            updateAge(newList, null);
        }
        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updateAge(newList, (Map<Id, Participant__c>) oldMap);
        }
    }

    public class CheckBecomesAdultHandler extends TriggerHandler {
        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            checkBecomesAdult(newList, (Map<Id, Participant__c>) oldMap);
        }
    }

    public class UpdateNameOnPE extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            copyNameToPE((List<Participant__c>) newList, (Map<Id, Participant__c>) oldMap);
        }
    }

    // Logic: ----------------------------------------------------------------------------------------------------------

    @TestVisible
    private static void createContactsForParticipants(List<Participant__c> newList) {
        // Id participantAccountId = getParticipantAccountId();
        Map<String, Participant__c> participantsByEmail = new Map<String, Participant__c>();
        List<Contact> contactsToInsert = new List<Contact>();
        List<String> emails = new List<String>();
        newList = ParticipantService.checkParticipantsAgeOfMajority(newList);
        for (Participant__c participant : newList) {
            if (participant.Contact__c == null) {
                emails.add(participant.Email__c);
                Contact newContact = new Contact();
                newContact.LastName = participant.Last_Name__c;
                newContact.Email = participant.Email__c;
                newContact.AccountId = participant.Site__c;
                newContact.Language__c = participant.Preferred_Language__c;
                newContact.Second_Choice_Language__c = '';
                newContact.Third_Choice_Language__c = '';
                newContact.userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT;
                newContact.userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT;
				newContact.MailingCity = participant.Mailing_City__c;
                newContact.MailingCountryCode = participant.Mailing_Country_Code__c;
                newContact.MailingStateCode = participant.Mailing_State_Code__c;
                newContact.MailingPostalCode = participant.Mailing_Zip_Postal_Code__c;
                contactsToInsert.add(newContact);
                participantsByEmail.put(participant.Email__c, participant);
            }
        }
        System.debug('CONTACTS TO INSERT: ' + contactsToInsert);
        insert contactsToInsert;

        for (Contact newContact : contactsToInsert) {
            Participant__c participant = participantsByEmail.get(newContact.Email);
            if (participant != null)
                participant.Contact__c = newContact.Id;
        }
    }

    @TestVisible
    private static void updateContactDetailsFromParticipant(List<Participant__c> newList, Map<Id,Participant__c> oldMap){
        List<Contact> updateContacts = new List<Contact>();
        List<User> updateUsers = new List<User>();
        Map<Id,Participant__c> updateContactsMap = new Map<Id,Participant__c>();
        Map<Id,Participant__c> updateUsersMap = new Map<Id,Participant__c>();
        Map<Id,String> contIdoldLanguageMap = new Map<Id,String>();
        Boolean isOldMapEmpty = oldMap.isEmpty();
        for(Participant__c part : newList){
            if(part.Contact__c!=null){
                if(isOldMapEmpty){
                    updateContactsMap.put(part.Contact__c,part);
                }else {
                    if(!oldMap.containsKey(part.Id)){
                        updateContactsMap.put(part.Contact__c,part);
                    }else if(oldMap.get(part.Id)!=null && part.Mailing_Country_Code__c != oldMap.get(part.Id).Mailing_Country_Code__c){
                        updateContactsMap.put(part.Contact__c,part);
                    }else if(oldMap.get(part.Id)!=null && part.Mailing_Country__c != oldMap.get(part.Id).Mailing_Country__c){
                        updateContactsMap.put(part.Contact__c,part);
                    }else if(oldMap.get(part.Id)!=null && part.Mailing_State_Code__c != oldMap.get(part.Id).Mailing_State_Code__c){
                        updateContactsMap.put(part.Contact__c,part);
                    }else if(oldMap.get(part.Id)!=null && part.Mailing_State__c != oldMap.get(part.Id).Mailing_State__c){
                        updateContactsMap.put(part.Contact__c,part);
                    }else if(oldMap.get(part.Id)!=null && part.Mailing_Zip_Postal_Code__c != oldMap.get(part.Id).Mailing_Zip_Postal_Code__c){
                        updateContactsMap.put(part.Contact__c,part);
                    }else if(oldMap.get(part.Id)!=null && part.Phone__c != oldMap.get(part.Id).Phone__c){
                        updateContactsMap.put(part.Contact__c,part);
                    }
                    if(oldMap.get(part.Id)!=null && part.Email__c != oldMap.get(part.Id).Email__c){
                        updateContactsMap.put(part.Contact__c,part);
                    }
                    if(oldMap.get(part.Id)!=null && part.First_Name__c != oldMap.get(part.Id).First_Name__c){
                        updateUsersMap.put(part.Contact__c,part);
                    }else if(oldMap.get(part.Id)!=null && part.Last_Name__c != oldMap.get(part.Id).Last_Name__c){
                        updateUsersMap.put(part.Contact__c,part);
                    }
                     if(oldMap.get(part.Id)!=null && part.Preferred_Language__c != oldMap.get(part.Id).Preferred_Language__c){
                        updateContactsMap.put(part.Contact__c,part);
                        contIdoldLanguageMap.put(part.Contact__c,oldMap.get(part.Id).Preferred_Language__c);
                    }
                }
            }
        }

        if(!updateContactsMap.isEmpty()){
			for(Contact con: [SELECT Id,MailingStateCode,MailingCountryCode,MailingPostalCode,Email,Phone,Language__c,Second_Choice_Language__c,Third_Choice_Language__c FROM Contact WHERE Id IN:updateContactsMap.keySet()]){
					Boolean updateNeeded= false;
					if(con.MailingCountryCode != updateContactsMap.get(con.Id).Mailing_Country_Code__c){
						con.MailingCountryCode = updateContactsMap.get(con.Id).Mailing_Country_Code__c;
						updateNeeded= true;
					}if(con.MailingStateCode != updateContactsMap.get(con.Id).Mailing_State_Code__c){
						con.MailingStateCode = updateContactsMap.get(con.Id).Mailing_State_Code__c;
						updateNeeded= true;
					}if(con.MailingPostalCode != updateContactsMap.get(con.Id).Mailing_Zip_Postal_Code__c){
						con.MailingPostalCode = updateContactsMap.get(con.Id).Mailing_Zip_Postal_Code__c;
						updateNeeded= true;
					}if(con.Phone != updateContactsMap.get(con.Id).Phone__c){
						con.Phone = updateContactsMap.get(con.Id).Phone__c;
						updateNeeded= true;
					}if(con.Email != updateContactsMap.get(con.Id).Email__c){
						con.Email = updateContactsMap.get(con.Id).Email__c;
						updateNeeded= true;
					}
                     if(con.Language__c != updateContactsMap.get(con.Id).Preferred_Language__c && String.isEmpty(con.Second_Choice_Language__c)){
                        con.Language__c = updateContactsMap.get(con.Id).Preferred_Language__c;
                        con.Second_Choice_Language__c = contIdoldLanguageMap.get(con.Id);
						updateNeeded= true;
                    }
                    if(con.Language__c != updateContactsMap.get(con.Id).Preferred_Language__c && !String.isEmpty(con.Second_Choice_Language__c)){
                        con.Language__c = updateContactsMap.get(con.Id).Preferred_Language__c;
                        con.Third_Choice_Language__c = con.Second_Choice_Language__c;
                        con.Second_Choice_Language__c = contIdoldLanguageMap.get(con.Id);
						updateNeeded= true;
					}
					if(updateNeeded == true){
						updateContacts.add(con);
					}
				}
			if(updateContacts.size()>0){
				update updateContacts;   
			}
        }
        if(!updateUsersMap.isEmpty()){
			for(User u: [SELECT Id,ContactId,FirstName,LastName FROM User WHERE ContactId IN:updateUsersMap.keySet()]){
					Boolean updateNeeded= false;
					if(u.FirstName != updateUsersMap.get(u.ContactId).First_Name__c){
						u.FirstName = updateUsersMap.get(u.ContactId).First_Name__c;
						updateNeeded= true;
					}if(u.LastName != updateUsersMap.get(u.ContactId).Last_Name__c){
						u.LastName = updateUsersMap.get(u.ContactId).Last_Name__c;
						updateNeeded= true;
					}
					if(updateNeeded == true){
						updateUsers.add(u);
					}
				}
			if(updateUsers.size()>0){
				update updateUsers;   
			}
        }
        
    }
    
    @TestVisible
    private static void updatePEAndContactLastName(List<Participant__c> newList) {
        List<Contact> contacts = new List<Contact>();
        Map<Id, Participant__c> participantMap = new Map<Id, Participant__c>(newList);
        for (Participant__c participant : newList) {
            if (participant.Contact__c != null) {
                contacts.add(
                    new Contact(
                        Id = participant.Contact__c,
                        FirstName = null,
                        LastName = participant.Name
                    )
                );
            }
        }
        if (!contacts.isEmpty()) {
            update contacts;
        }
        List<Participant_Enrollment__c> peList = new  List<Participant_Enrollment__c>();
        if(!newList.isEmpty()){         
           peList =[ SELECT Id, Participant__c, Participant_Name__c, Participant_Surname__c
            FROM Participant_Enrollment__c 
            WHERE Participant__c IN :newList
        ];
        }
        if (!peList.isEmpty()) {
            for (Participant_Enrollment__c pe : peList) {
                pe.Participant_Name__c = participantMap.get(pe.Participant__c).First_Name__c;
                pe.Participant_Surname__c = participantMap.get(pe.Participant__c).Last_Name__c;
            }
            update peList;
        }
    }

    @TestVisible
    private static void copyNameToPE(List<Participant__c> newList, Map<Id, Participant__c> oldMap) {
        Map<Id, Participant_Enrollment__c> partcipantIdEnrollmentMap = new Map<Id, Participant_Enrollment__c>();
        for (Participant_Enrollment__c pe : [
            SELECT Id, Participant__c, Participant_Name__c, Participant_Surname__c
            FROM Participant_Enrollment__c
            WHERE Participant__c IN :newList
        ]) {
            partcipantIdEnrollmentMap.put(pe.Participant__c, pe);
        }
        Boolean updateRecords = false;
        for (Participant__c part : newList) {
            if (
                (part.First_Name__c != oldMap.get(part.Id).First_Name__c ||
                part.Last_Name__c != oldMap.get(part.Id).Last_Name__c) &&
                partcipantIdEnrollmentMap.containsKey(part.Id)
            ) {
                partcipantIdEnrollmentMap.get(part.Id).Participant_Name__c = part.First_Name__c;
                partcipantIdEnrollmentMap.get(part.Id).Participant_Surname__c = part.Last_Name__c;
                updateRecords = true;
            }
        }

        if (!partcipantIdEnrollmentMap.isEmpty() && updateRecords) {
            update partcipantIdEnrollmentMap.values();
        }
    }

    @TestVisible
    @Future
    private static void changeUserEmailOnParticipantEmailChangeAsync(
        String newListJSON,
        String oldMapJSON
    ) {
        List<Participant__c> newList = (List<Participant__c>) JSON.deserialize(
            newListJSON,
            List<Participant__c>.class
        );
        Map<Id, Participant__c> oldMap = (Map<Id, Participant__c>) JSON.deserialize(
            oldMapJSON,
            Map<Id, Participant__c>.class
        );
        changeUserEmailOnParticipantEmailChange(newList, oldMap);
    }

    @TestVisible
    private static void changeUserEmailOnParticipantEmailChange(
        List<Participant__c> newList,
        Map<Id, Participant__c> oldMap
    ) {
        Set<Id> contactIds = new Set<Id>();
        for (Participant__c participant : newList) {
            if (participant.Contact__c != null)
                contactIds.add(participant.Contact__c);
        }
        List<User> users = [SELECT Id, ContactId, Email FROM User WHERE ContactId IN :contactIds];
        Map<Id, Contact> contactsByContactIdMap = new Map<Id, Contact>(
            [SELECT Id, Email FROM Contact WHERE Id IN :contactIds]
        );

        Map<Id, User> usersByContactIdMap = new Map<Id, User>();
        for (User user : users) {
            usersByContactIdMap.put(user.ContactId, user);
        }
        List<User> usersForUpdate = new List<User>();
        List<Contact> contactForUpdate = new List<Contact>();
        for (Participant__c participant : newList) {
            Participant__c oldParticipant = oldMap.get(participant.Id);
            if (
                oldParticipant.Email__c != participant.Email__c &&
                Participant__c.Contact__c != null
            ) {
                User user = usersByContactIdMap.get(participant.Contact__c);
                Contact cont = contactsByContactIdMap.get(participant.Contact__c);
                if (cont != null) {
                    cont.Email = participant.Email__c;
                    contactForUpdate.add(cont);
                }
                if (user != null) {
                    user.Email = participant.Email__c;
                    usersForUpdate.add(user);
                }
            }
        }
        update usersForUpdate;
        update contactForUpdate;
    }

    @TestVisible
    private static void prepareCityStateFields(
        List<Participant__c> newList,
        Map<Id, Participant__c> oldMap
    ) {
        for (Participant__c participant : newList) {
            String countryName = participant.Mailing_Country__c;
            String countryCode = participant.Mailing_Country_Code__c;
            String stateName = participant.Mailing_State__c;
            String stateCode = participant.Mailing_State_Code__c;
			//Changes are done to fetch the country Code VS Country Name and State Code VS State name
			//From Custome meta data to fix the language translation issue for State and country
            if (oldMap == null) {
                if(countryCode == null && countryName != null) {
                    if(CountryStateUtil.COUNTRY_CODE_BY_NAME_MAP_Mdt.containsKey(countryName)){ 
                        participant.Mailing_Country_Code__c = CountryStateUtil.COUNTRY_CODE_BY_NAME_MAP_Mdt.get(countryName);
                    }
					if(participant.Mailing_Country_Code__c == null) {
						participant.addError('Invalid Country');
					}
				}else if (countryCode != null && countryName == null) {
                    if(CountryStateUtil.COUNTRY_NAME_By_CODE_MAP_Mdt.containsKey(countryCode)){  
                        participant.Mailing_Country__c = CountryStateUtil.COUNTRY_NAME_By_CODE_MAP_Mdt.get(countryCode); 
                    }
					if(participant.Mailing_Country__c == null) {
						participant.addError('Invalid Country Code');
					}
				}else if (countryCode != null && countryName != null) {
					if(CountryStateUtil.COUNTRY_CODE_BY_NAME_MAP_Mdt.containsKey(countryName) && countryCode != CountryStateUtil.COUNTRY_CODE_BY_NAME_MAP_Mdt.get(countryName)) { 
						participant.addError('Invalid County and Country Code');
					}
				}
                if(stateCode == null && stateName != null) {
                    if(CountryStateUtil.STATES_CODE_BY_NAME_MAP_Mdt.containsKey(participant.Mailing_Country_Code__c) && CountryStateUtil.STATES_CODE_BY_NAME_MAP_Mdt.get(participant.Mailing_Country_Code__c).containsKey(stateName)){
                        participant.Mailing_State_Code__c =CountryStateUtil.STATES_CODE_BY_NAME_MAP_Mdt.get(participant.Mailing_Country_Code__c).get(stateName);
                    }
                    if(participant.Mailing_State_Code__c == null) {
                        participant.addError('Invalid State Province');
                    }
                    
				}else if (stateCode != null && stateName == null) {
					if(CountryStateUtil.STATES_NAME_By_CODE_MAP_Mdt.containsKey(participant.Mailing_Country_Code__c) && CountryStateUtil.STATES_NAME_By_CODE_MAP_Mdt.get(participant.Mailing_Country_Code__c).containsKey(stateCode)){ 
                        participant.Mailing_State__c =CountryStateUtil.STATES_NAME_By_CODE_MAP_Mdt.get(participant.Mailing_Country_Code__c).get(stateCode);
                    }
					if(participant.Mailing_State__c == null) {
						participant.addError('Invalid State Province Code');
					}
				}else if (stateCode != null && stateName != null) {
					 if(CountryStateUtil.STATES_CODE_BY_NAME_MAP_Mdt.containsKey(participant.Mailing_Country_Code__c) && CountryStateUtil.STATES_CODE_BY_NAME_MAP_Mdt.get(participant.Mailing_Country_Code__c).containsKey(stateName) && stateCode != CountryStateUtil.STATES_CODE_BY_NAME_MAP_Mdt.get(participant.Mailing_Country_Code__c).get(stateName)){
						participant.addError('Invalid State Province and State Province Code');
					}
                    if(participant.Mailing_State_Code__c != null){
                    participant.Mailing_State__c =CountryStateUtil.STATES_NAME_By_CODE_MAP_Mdt.get(participant.Mailing_Country_Code__c).get(participant.Mailing_State_Code__c);
                    }
				}
            }
            if (oldMap != null) {
                String countryCodeTemp = CountryStateUtil.getCountryCode(countryName);
                Boolean countryNameChanged =
                    oldMap.get(participant.Id).Mailing_Country__c != countryName;
                Boolean countryCodeChanged =
                    oldMap.get(participant.Id).Mailing_Country_Code__c != countryCode;
                Boolean stateNameChanged = oldMap.get(participant.Id).Mailing_State__c != stateName;
                Boolean stateCodeChanged =
                    oldMap.get(participant.Id).Mailing_State_Code__c != stateCode;
                
                if (countryCodeChanged && !countryNameChanged) {
                    if(CountryStateUtil.COUNTRY_NAME_By_CODE_MAP_Mdt.containsKey(countryCode)){
                        participant.Mailing_Country__c = CountryStateUtil.COUNTRY_NAME_By_CODE_MAP_Mdt.get(countryCode);
                        //participant.Mailing_Country_Code__c = CountryStateUtil.COUNTRY_CODE_BY_NAME_MAP_Mdt.get(CountryStateUtil.getCountryName(countryCode));
                    }else{
                        if (participant.Mailing_Country__c == null && countryCode != null) {
                        participant.addError('Invalid Country Code');
                        }
                    }
                } else if (!countryCodeChanged && countryNameChanged) {
                    if(CountryStateUtil.COUNTRY_NAME_By_CODE_MAP_Mdt.containsKey(countryCodeTemp)){
                        participant.Mailing_Country__c = CountryStateUtil.COUNTRY_NAME_By_CODE_MAP_Mdt.get(countryCodeTemp);
                        participant.Mailing_Country_Code__c = countryCodeTemp;
                    }else{
                        if (participant.Mailing_Country_Code__c == null && countryName != null) {
                        participant.addError('Invalid Country');
                    }
                    }
                } else if (countryCodeChanged && countryNameChanged) {
                    if (countryCode != CountryStateUtil.getCountryCode(countryName)) {
                        participant.addError('Invalid County and Country Code');
                    }else{
                        if(CountryStateUtil.COUNTRY_NAME_By_CODE_MAP_Mdt.containsKey(countryCodeTemp)) { 
                        participant.Mailing_Country__c = CountryStateUtil.COUNTRY_NAME_By_CODE_MAP_Mdt.get(countryCodeTemp);
                        }
                        
                    }
                }
                
                // state change has started
                if (stateCodeChanged && !stateNameChanged) {
                    if(participant.Mailing_State_Code__c != null){
                    participant.Mailing_State__c =CountryStateUtil.STATES_NAME_By_CODE_MAP_Mdt.get(participant.Mailing_Country_Code__c).get(participant.Mailing_State_Code__c);
                    }
                    if (participant.Mailing_State__c == null && stateCode != null) {
                        participant.addError('Invalid State Province Code');
                    }
                } else if (!stateCodeChanged && stateNameChanged) {
                    participant.Mailing_State_Code__c = CountryStateUtil.getStateCode(
                        participant.Mailing_Country_Code__c,
                        stateName
                    );
                    //Getting the mailing state code by passing the state Name
                    if(participant.Mailing_State_Code__c != null){
                    participant.Mailing_State__c =CountryStateUtil.STATES_NAME_By_CODE_MAP_Mdt.get(participant.Mailing_Country_Code__c).get(participant.Mailing_State_Code__c);
                    }
                    if (participant.Mailing_State_Code__c == null && stateName != null) {
                        participant.addError('Invalid State Province');
                    }
                } else if (stateCodeChanged && stateNameChanged) {
                    if (
                        stateCode !=
                        CountryStateUtil.getStateCode(
                            participant.Mailing_Country_Code__c,
                            stateName
                        )
                    ) {
                        participant.addError('Invalid State Province and State Province Code');
                    }
                }
            }
        }
    }



    @TestVisible
    private static Id getParticipantAccountId() {
        return [
            SELECT Id
            FROM Account
            WHERE Name = :CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
            LIMIT 1
        ]
        .Id;
    }

    @TestVisible
    private static void checkDuplicates(List<Participant__c> newList) {
        ParticipantDuplicateService duplicateService = new ParticipantDuplicateService(newList);
        for (Participant__c participant : newList) {
            Participant__c duplicateParticipant = duplicateService.findDuplicate(participant);
            if (duplicateParticipant != null) {
                participant.addError('Duplicate found: ' + duplicateParticipant.Id);
            }
        }
    }

    @TestVisible
    private static void updateAge(List<Participant__c> newList, Map<Id, Participant__c> oldMap) {
        List<Participant__c> pList = new List<Participant__c>();

        for (Participant__c p : newList) {
            if (!String.isBlank(p.Date_of_Birth__c)) {
                Date birthDate = Date.newInstance(
                    Integer.valueOf(p.Date_of_Birth__c.substring(0, 4)),
                    Integer.valueOf(p.Date_of_Birth__c.substring(5, 7)),
                    Integer.valueOf(p.Date_of_Birth__c.substring(8, 10))
                );

                Integer participantAge = Date.newInstance(
                        2000,
                        birthDate.month(),
                        birthDate.day()
                    ) <= Date.newInstance(2000, Date.today().month(), Date.today().day())
                    ? Date.today().year() - birthDate.year()
                    : Date.today().year() - birthDate.year() - 1;
                Integer dt1 = (system.today())
                    .daysBetween(
                        Date.valueOf(
                            Date.newInstance(
                                Date.today().year(),
                                birthDate.month(),
                                birthDate.day()
                            )
                        )
                    );
                dt1 = dt1 > 0 ? dt1 : Math.abs(dt1);
                String strDaysLeft = '';

                strDaysLeft = dt1 <= 9
                    ? String.valueOf('00' + dt1)
                    : dt1 > 9 && dt1 <= 99 ? String.valueOf('0' + dt1) : String.valueOf(dt1);
                Decimal decParticipantAge = Decimal.valueOf(participantAge + '.' + strDaysLeft);
                p.Age__c = decParticipantAge;
                if (p.Gender__c == 'Male')
                    p.Gender_Technical__c = 'M';
                else if (p.Gender__c == 'Female')
                    p.Gender_Technical__c = 'F';
                else
                    p.Gender_Technical__c = '';
                pList.add(p);
            }
        }
    }

    @TestVisible
    private static void checkBecomesAdult(
        List<Participant__c> newList,
        Map<Id, Participant__c> oldMap
    ) {
        Map<Id, Participant__c> participantsByContactId = new Map<Id, Participant__c>();
        Set<Id> patientIsAdult = new Set<Id>();

        for (Participant__c participant : newList) {
            if (
                participant.Adult__c && participant.Adult__c != oldMap.get(participant.Id).Adult__c
            ) {
                if (participant.Contact__c != null) {
                    participantsByContactId.put(participant.Contact__c, participant);
                } else {
                    participant.Emancipation_in_progress__c = true;
                }
                patientIsAdult.add(participant.Contact__c);
            }
        }

        if (!participantsByContactId.isEmpty()) {
            List<User> participantUsers = [
                SELECT Id, ContactId
                FROM User
                WHERE ContactId IN :participantsByContactId.keySet()
            ];
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
        List<Patient_Delegate__c> patientDelegates = PatientDelegateService.getPDelegates(
            new List<Id>(patientIsAdult)
        );
        for (Patient_Delegate__c patientDelegate : patientDelegates) {
            if (
                PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS ==
                patientDelegate.Status__c &&
                patientIsAdult.contains(patientDelegate.Participant__r.Contact__c)
            ) {
                patientDelegate.Status__c = PatientDelegateTriggerHandler.PATIENT_DELEGATE_ONHOLD_STATUS;
                patientDelegatesToUpdate.add(patientDelegate);
            }
        }
        if (!patientDelegatesToUpdate.isEmpty()) {
            update patientDelegatesToUpdate;
        }
    }
}