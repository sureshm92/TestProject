/**
 * Created by Leonid Bartenev
 */

public without sharing class ParticipantDuplicateService {
    public class ParticipantDuplicateServiceException extends Exception {
    }

    public Map<Integer, DuplicateContainer> duplicatesMap = new Map<Integer, DuplicateContainer>();
    public Map<String, Contact> duplicateDelegatesContactMap = new Map<String, Contact>();
    public Map<String, Participant__c> duplicateDelegatesParticipantMap = new Map<String, Participant__c>();

    public class ParticipantWithDelegate {
        public Participant__c participant;
        public Participant__c delegate;
    }

    private class DuplicateContainer {
        public Object duplicate;

        public DuplicateContainer(Object duplicate) {
            this.duplicate = duplicate;
        }

        public Boolean isParticipant() {
            return duplicate instanceof Participant__c;
        }

        public String getFirstName() {
            if (isParticipant()) {
                return ((Participant__c) duplicate).First_Name__c;
            }
            return ((Contact) duplicate).FirstName;
        }

        public String getLastName() {
            if (isParticipant()) {
            return ((Participant__c) duplicate).Last_Name__c;
            }
            return null;
           }

        public Integer getYearOfBirth() {
            if (isParticipant()) {
                Participant__c participant = (Participant__c) duplicate;
                return getYearOfBirthForParticipant(participant);
            }
            return null;
        }

        public Participant__c getParticipant() {
            if (isParticipant())
                return (Participant__c) duplicate;
            return null;
        }

        public Contact getContact() {
            if (!isParticipant())
                return (Contact) duplicate;
            return null;
        }
    }

    public ParticipantDuplicateService(Participant__c participant) {
        ParticipantWithDelegate partWithDelegate = new ParticipantWithDelegate();
        partWithDelegate.participant = participant;
        prepareDuplicates(new List<ParticipantWithDelegate>{ partWithDelegate });
    }

    public ParticipantDuplicateService(List<Participant__c> newParticipants) {
        List<ParticipantWithDelegate> partsWithDelegates = new List<ParticipantWithDelegate>();
        for (Participant__c participant : newParticipants) {
            ParticipantWithDelegate partWithDelegate = new ParticipantWithDelegate();
            partWithDelegate.participant = participant;
            PartsWithDelegates.add(partWithDelegate);
        }
        prepareDuplicates(PartsWithDelegates);
    }

    public ParticipantDuplicateService(ParticipantWithDelegate partWithDelegate) {
        prepareDuplicates(new List<ParticipantWithDelegate>{ partWithDelegate });
    }

    public ParticipantDuplicateService(List<ParticipantWithDelegate> partsWithDelegates) {
        prepareDuplicates(partsWithDelegates);
    }

    public void prepareDuplicates(List<ParticipantWithDelegate> partsWithDelegates) {
        List<String> emails = new List<String>();
        List<String> phones = new List<String>();
        Set<String> zipCodes = new Set<String>();
        Set<Date> birthDates = new Set<Date>();
        Set<String> birthDateStrings = new Set<String>();
        Set<String> lastNames = new Set<String>();

        List<String> delegatesFirstName = new List<String>();
        List<String> delegatesLastName = new List<String>();
        List<String> delegatesEmail = new List<String>();
        Set<Id> delegatesContactIs = new Set<Id>();

        for (ParticipantWithDelegate partWithDelegate : partsWithDelegates) {
            if (!String.isBlank(partWithDelegate.participant.Phone__c))
                phones.add(partWithDelegate.participant.Phone__c);
            if (!String.isBlank(partWithDelegate.participant.Email__c))
                emails.add(partWithDelegate.participant.Email__c);
            if (!String.isBlank(partWithDelegate.participant.Last_Name__c))
                lastNames.add(partWithDelegate.participant.Last_Name__c);
            if (!String.isBlank(partWithDelegate.participant.Date_of_Birth__c)) {
                birthDates.add(Date.valueOf(partWithDelegate.participant.Date_of_Birth__c));
                birthDateStrings.add(partWithDelegate.participant.Date_of_Birth__c);
            }
            if (!String.isBlank(partWithDelegate.participant.ZIP_Code__c))
                zipCodes.add(partWithDelegate.participant.ZIP_Code__c);
            if (!String.isBlank(partWithDelegate.participant.Mailing_Zip_Postal_Code__c))
                zipCodes.add(partWithDelegate.participant.Mailing_Zip_Postal_Code__c);

            if (partWithDelegate.delegate != null) {
                //if (!String.isBlank(partWithDelegate.delegate.Phone__c)) phones.add(partWithDelegate.delegate.Phone__c);
                if (!String.isBlank(partWithDelegate.delegate.First_Name__c))
                    delegatesFirstName.add(partWithDelegate.delegate.First_Name__c);
                if (!String.isBlank(partWithDelegate.delegate.Last_Name__c))
                    delegatesLastName.add(partWithDelegate.delegate.Last_Name__c);
                if (!String.isBlank(partWithDelegate.delegate.Email__c))
                    delegatesEmail.add(partWithDelegate.delegate.Email__c);
                /*if (!String.isBlank(partWithDelegate.delegate.Date_of_Birth__c)) {
                    birthDates.add(Date.valueOf(partWithDelegate.delegate.Date_of_Birth__c));
                    birthDateStrings.add(partWithDelegate.delegate.Date_of_Birth__c);
                }
                if (!String.isBlank(partWithDelegate.delegate.ZIP_Code__c)) zipCodes.add(partWithDelegate.delegate.ZIP_Code__c);
                if (!String.isBlank(partWithDelegate.delegate.Mailing_Zip_Postal_Code__c)) zipCodes.add(partWithDelegate.delegate.Mailing_Zip_Postal_Code__c);*/
            }
        }

        //Find participants
        List<Participant__c> existedParticipants = [
            SELECT
                Id,
                Contact__c,
                First_Name__c,
                Last_Name__c,
                Email__c,
                Phone__c,
               /* Day_of_Birth__c REF-3113*/
                Age__c,
                Birth_Day__c,
                Birth_Month__c,
                Birth_Year__c,
                Date_of_Birth__c,
                Secondary_Source__c,
                ZIP_Code__c,
                Adult__c,
                Mailing_Zip_Postal_Code__c,
                Preferred_Contact_Time__c,
                Site__c, Middle_Name__c, Nickname__c, Suffix__c, Gender__c, Phone_Type__c, Alternative_Phone_Number__c, Mailing_State__c, Mailing_Country__c, Mailing_Country_Code__c, Mailing_State_Code__c, Mailing_City__c, Mailing_Street__c, Preferred_Language__c, BMI__c
            FROM Participant__c
            WHERE
                Email__c IN :emails
                OR Phone__c IN :phones
                /*OR Day_of_Birth__c IN :birthDates REF-3113*/
                OR ZIP_Code__c IN :zipCodes
                OR Last_Name__c IN :lastNames
        ];
        /*for(Participant__c partici: participantExistedInSystem){
            if(partici.Date_of_Birth__c != null){
                existedParticipants.add(partici);
            }
        }*/
        List<Participant__c> existedParticipantDelegates = new List<Participant__c>();
        if (
            !delegatesEmail.isEmpty() &&
            !delegatesFirstName.isEmpty() &&
            !delegatesLastName.isEmpty()
        ) {
            existedParticipantDelegates = [
                SELECT
                    Id,
                    Contact__c,
                    First_Name__c,
                    Last_Name__c,
                    Email__c,
                    Phone__c,
                    /* Day_of_Birth__c REF-3113*/
                    Age__c,
                    Birth_Day__c,
                    Birth_Month__c,
                    Birth_Year__c,
                    Date_of_Birth__c,
                    Secondary_Source__c,
                    ZIP_Code__c,
                    Adult__c,
                    Mailing_Zip_Postal_Code__c,
                    Preferred_Contact_Time__c,
                    Site__c, Middle_Name__c, Nickname__c, Suffix__c, Gender__c, Phone_Type__c, Alternative_Phone_Number__c, Mailing_State__c, Mailing_Country__c, Mailing_Country_Code__c, Mailing_State_Code__c, Mailing_City__c, Mailing_Street__c, Preferred_Language__c, BMI__c
                FROM Participant__c
                WHERE
                    Email__c IN :delegatesEmail
                    OR First_Name__c IN :delegatesFirstName
                    OR Last_Name__c IN :delegatesLastName
            ];
        }
        Map<Id, Participant__c> participantsByIds = new Map<Id, Participant__c>(
            existedParticipants
        );

        Map<String, Participant__c> participantsByEmailMap = new Map<String, Participant__c>();
        Map<String, Participant__c> participantsByPhoneMap = new Map<String, Participant__c>();
        Map<Date, List<Participant__c>> participantsByDoBMap = new Map<Date, List<Participant__c>>();
        //Map<String, List<Participant__c>> participantsByDoBStringsMap = new Map<String, List<Participant__c>>();
        Map<String, List<Participant__c>> participantsByZipMap = new Map<String, List<Participant__c>>();
        Map<String,Map<String,Map<String,list<Participant__c>>>> dobPartMap = new Map<String,Map<String,Map<String,list<Participant__c>>>>();
        for (Participant__c participant : existedParticipants) {
            if (!String.isBlank(participant.Email__c))
                participantsByEmailMap.put(participant.Email__c.toLowerCase() + participant.First_Name__c + participant.Last_Name__c, participant);
            if (!String.isBlank(participant.Phone__c))
                //participantsByPhoneMap.put(participant.Phone__c, participant);
                  participantsByPhoneMap.put(participant.Phone__c + participant.First_Name__c + participant.Last_Name__c, participant);
            if (!String.isBlank(participant.ZIP_Code__c)) {
                List<Participant__c> zipParticipants = participantsByZipMap.get(
                    participant.ZIP_Code__c
                );
                if (zipParticipants == null)
                    zipParticipants = new List<Participant__c>();
                zipParticipants.add(participant);
                participantsByZipMap.put(participant.ZIP_Code__c, zipParticipants);
            }
            /*if (participant.Day_of_Birth__c != null) {
                List<Participant__c> doBParticipants = participantsByDoBMap.get(
                    participant.Day_of_Birth__c
                );
                if (doBParticipants == null)
                    doBParticipants = new List<Participant__c>();
                doBParticipants.add(participant);
                participantsByDoBMap.put(participant.Day_of_Birth__c, doBParticipants);
            } REF-3113*/
            // if (!String.isBlank(participant.Date_of_Birth__c)) {
            //     List<Participant__c> doBParticipants = participantsByDoBStringsMap.get(
            //         participant.Date_of_Birth__c
            //     );
            //     if (doBParticipants == null)
            //         doBParticipants = new List<Participant__c>();
            //     doBParticipants.add(participant);
            //     participantsByDoBStringsMap.put(participant.Date_of_Birth__c, doBParticipants);
            // }
            //DOb Changes
            if(!String.isBlank(participant.Birth_Year__c)){
                String dd = '--';
                String mm = '--';
                String yyyy = participant.Birth_Year__c;
                if(!String.isBlank(participant.Birth_Month__c)) mm = participant.Birth_Month__c;
                if(!String.isBlank(participant.Birth_Day__c)) dd = participant.Birth_Day__c;
                
                // fetch existing part list 
                if(dobPartMap.containsKey(yyyy)){
                    if(dobPartMap.get(yyyy).containsKey(mm)){
                        if(dobPartMap.get(yyyy).get(mm).containsKey(dd)){
                            dobPartMap.get(yyyy).get(mm).get(dd).add(participant);
                        }
                        else{
                            dobPartMap.get(yyyy).get(mm).put(dd, new list<Participant__c>{participant});
                        }
                    }
                    else{
                        dobPartMap.get(yyyy).put(mm, new Map<String,list<Participant__c>>{dd => new list<Participant__c>{participant}} );
                    }
                }        
                else{
                    dobPartMap.put(yyyy, new Map<String,Map<String,list<Participant__c>>>{mm => new Map<String,list<Participant__c>>{dd => new list<Participant__c>{participant}}});
                }
            }
        }

        for (Participant__c delParticipant : existedParticipantDelegates) {
            duplicateDelegatesParticipantMap.put(
                delParticipant.First_Name__c +
                ',' +
                delParticipant.Last_Name__c +
                ',' +
                delParticipant.Email__c,
                delParticipant
            );
        }
        //Find contacts:
        List<Contact> existedContacts = [
            SELECT Id, FirstName, LastName, Email, Phone, Birthdate, MailingPostalCode
            FROM Contact
            WHERE (Email IN :emails OR Phone IN :phones OR MailingPostalCode IN :zipCodes) AND userCommunityMode__c != 'CC'
        ];/* REF-3113*/
        List<Contact> existedDelegateContacts = [
            SELECT Id, FirstName, LastName, Email, Phone, Birthdate, MailingPostalCode
            FROM Contact
            WHERE
            (Email IN :delegatesEmail
            OR FirstName IN :delegatesFirstName
            OR LastName IN :delegatesLastName)
            AND userCommunityMode__c != 'CC'
        ];/* REF-3113*/
        Map<String, Contact> contactsByEmailMap = new Map<String, Contact>();
        Map<String, Contact> contactsByPhoneMap = new Map<String, Contact>();
        Map<String, List<Contact>> contactsByZipMap = new Map<String, List<Contact>>();
        Map<Date, List<Contact>> contactsByDoBMap = new Map<Date, List<Contact>>();
        for (Contact contact : existedContacts) {
            if (contact.Email != null)
                contactsByEmailMap.put(contact.Email.toLowerCase(), contact);
            if (contact.Phone != null)
                contactsByPhoneMap.put(contact.Phone, contact);
            if (!String.isBlank(contact.MailingPostalCode)) {
                List<Contact> zipContacts = contactsByZipMap.get(contact.MailingPostalCode);
                if (zipContacts == null)
                    zipContacts = new List<Contact>();
                zipContacts.add(contact);
                contactsByZipMap.put(contact.MailingPostalCode, zipContacts);
            }
            if (contact.Birthdate != null) {
                List<Contact> dobContacts = contactsByDoBMap.get(contact.Birthdate);
                if (dobContacts == null)
                    dobContacts = new List<Contact>();
                dobContacts.add(contact);
                contactsByDoBMap.put(contact.Birthdate, dobContacts);
            }
        }

        for (Contact delContact : existedDelegateContacts) {
            duplicateDelegatesContactMap.put(
                delContact.FirstName +
                ',' +
                delContact.LastName +
                ',' +
                delContact.Email +
                ',',
                delContact
            );
            delegatesContactIs.add(delContact.Id);
        }

        //Find Participant Delegates
         List<Patient_Delegate__c> patientDelegates = new List<Patient_Delegate__c>();
        if(participantsByIds.keySet().size() != 0){
            patientDelegates = [
            SELECT Id, Participant__c, Contact__c
            FROM Patient_Delegate__c
            WHERE Participant__c IN :participantsByIds.keySet()
            ORDER BY LastModifiedDate DESC
        ];
        }
        Map<Id, List<Id>> delegateContactIdsByPatientIds = new Map<Id, List<Id>>();
        for (Patient_Delegate__c pt : patientDelegates) {
            if (!delegateContactIdsByPatientIds.containsKey(pt.Participant__c))
                delegateContactIdsByPatientIds.put(
                    pt.Participant__c,
                    new List<Id>{ pt.Contact__c }
                );
            else
                delegateContactIdsByPatientIds.get(pt.Participant__c).add(pt.Contact__c);
            delegatesContactIs.add(pt.Contact__c);
        }
        List<Participant__c> delegateParticipants =new List<Participant__c>();
        if(!delegatesContactIs.isEmpty()){
         delegateParticipants = [
            SELECT
                Id,
                Contact__c,
                First_Name__c,
                Last_Name__c,
                Email__c,
                Phone__c,
                //Day_of_Birth__c,
                Age__c,
                Birth_Day__c,
                Birth_Month__c,
                Birth_Year__c,
                Date_of_Birth__c,
                Secondary_Source__c,
                ZIP_Code__c,
                Adult__c,
                Mailing_Zip_Postal_Code__c,
                Site__c, Middle_Name__c, Nickname__c, Suffix__c, Gender__c, Phone_Type__c, Alternative_Phone_Number__c, Mailing_State__c, Mailing_Country__c, Mailing_Country_Code__c, Mailing_State_Code__c, Mailing_City__c, Mailing_Street__c, Preferred_Language__c, BMI__c
            FROM Participant__c
            WHERE Contact__c IN :delegatesContactIs
        ];
        }
        Map<Id, Participant__c> delegatesByContactIds = new Map<Id, Participant__c>();
        for (Participant__c delegate : delegateParticipants) {
            delegatesByContactIds.put(delegate.Contact__c, delegate);
        }

        for (ParticipantWithDelegate partWithDelegate : partsWithDelegates) {
            Participant__c participant = partWithDelegate.participant;
            Participant__c delegate = partWithDelegate.delegate;
            DuplicateContainer duplicate;

            if (
                participant.Adult__c &&
                (!String.isBlank(participant.Email__c) || !String.isBlank(participant.Phone__c))
            ) {
                System.debug('Adult with phone or email');

                if (
                    participant.Email__c != null &&
                    participantsByEmailMap.get(participant.Email__c.toLowerCase() + participant.First_Name__c + participant.Last_Name__c) != null
                ) {
                    duplicate = new DuplicateContainer(
                        participantsByEmailMap.get(participant.Email__c.toLowerCase() + participant.First_Name__c + participant.Last_Name__c)
                    );
                } else if (
                    participant.Email__c != null &&
                    contactsByEmailMap.get(participant.Email__c.toLowerCase()) != null
                ) {
                    duplicate = new DuplicateContainer(
                        contactsByEmailMap.get(participant.Email__c.toLowerCase())
                    );
                } else if (
                    participant.Phone__c != null &&
                    participantsByPhoneMap.get(participant.Phone__c + participant.First_Name__c + participant.Last_Name__c) != null
                ) {
                    duplicate = new DuplicateContainer(
                        participantsByPhoneMap.get(participant.Phone__c + participant.First_Name__c + participant.Last_Name__c)
                    );
                } else if (
                    participant.Phone__c != null &&
                    contactsByPhoneMap.get(participant.Phone__c) != null
                ) {
                    duplicate = new DuplicateContainer(
                        contactsByPhoneMap.get(participant.Phone__c)
                    );
                }
                    if (duplicate != null) {
                    Integer birthYear = getYearOfBirthForParticipant(participant);
                    //System.debug('>>> BY:' + birthYear);
                    if (birthYear != null) {
                        Integer participantAge = System.today().year() - birthYear;
                        //System.debug('>>> Participant age: ' + participantAge);
                        Integer birthYearInTheSystem = duplicate.getYearOfBirth();
                        if (birthYearInTheSystem != null) {
                            if (
                                birthYear == birthYearInTheSystem &&
                                duplicate.getFirstName().toLowerCase() == participant.First_Name__c.toLowerCase() && duplicate.getLastName().toLowerCase() == participant.Last_Name__c.toLowerCase()
                            ) {
                                setDuplicate(participant, duplicate);
                                continue;
                            }
                        } 
                        else if (participantAge > 18 && duplicate.getFirstName() == participant.First_Name__c) 
                        {
                            setDuplicate(participant, duplicate);
                            continue;
                        }
                    } else {
                        if (duplicate.getFirstName() == participant.First_Name__c) {
                            setDuplicate(participant, duplicate);
                            continue;
                        }
                    }
                }
            } else {
                System.debug('Pediatric or Adult without phone/email');
                Integer birthYear = getYearOfBirthForParticipant(participant);
                System.debug('>>> BY: ' + birthYear);
                if (
                    // participantsByDoBStringsMap.containsKey(participant.Date_of_Birth__c) ||
                    dobPartMap.containsKey(participant.Birth_Year__c) ||
                    participant.Date_of_Birth__c != null &&
                    contactsByDoBMap.containsKey(Date.valueOf(participant.Date_of_Birth__c))
                ) {
                    List<Participant__c> participantsByDoB = getAllParticipantsByDOB(dobPartMap,participant);
                    List<Contact> contactsByDoB = participant.Date_of_Birth__c != null
                        ? contactsByDoBMap.get(Date.valueOf(participant.Date_of_Birth__c))
                        : new List<Contact>();
                    Boolean participantsByDoBExist = participantsByDoB == null;
                    Boolean contactsByDoBExist = contactsByDoB == null;
                    if (
                        participantsByDoBExist && contactsByDoBExist ||
                        !participantsByDoBExist &&
                        participantsByDoB.isEmpty() &&
                        !contactsByDoBExist && contactsByDoB.isEmpty()
                    ) {
                        continue;
                    }

                    Boolean isAdultAndHasEmailOrPhone =
                        participant.Adult__c &&
                        (!String.isBlank(participant.Email__c) ||
                        !String.isBlank(participant.Phone__c));
                    Participant__c paticipantInfoToCheck = (delegate == null ||
                        isAdultAndHasEmailOrPhone
                        ? participant
                        : delegate);
                    if (!participantsByDoBExist) {
                        for (Participant__c dupParticipant : participantsByDoB) {
                            if (
                                dupParticipant != null &&
                                dupParticipant.Last_Name__c != null &&
                                dupParticipant.Last_Name__c == participant.Last_Name__c
                            ) {
                                Participant__c dupParticipantDelegate;
                                if (delegateContactIdsByPatientIds.containsKey(dupParticipant.Id)) {
                                    for (
                                        Id contactId : delegateContactIdsByPatientIds.get(
                                            dupParticipant.Id
                                        )
                                    ) {
                                        if (delegatesByContactIds.containsKey(contactId)) {
                                            dupParticipantDelegate = delegatesByContactIds.get(
                                                contactId
                                            );
                                        }
                                    }
                                }
                                Boolean isDupParticipantDelegateCoincide =
                                    dupParticipantDelegate != null &&
                                    (dupParticipantDelegate.Email__c != null &&
                                    paticipantInfoToCheck.Email__c != null &&
                                    dupParticipantDelegate.Email__c.toLowerCase() ==
                                    paticipantInfoToCheck.Email__c.toLowerCase() &&
                                    dupParticipantDelegate.First_Name__c != null &&
                                    dupParticipantDelegate.First_Name__c ==
                                    paticipantInfoToCheck.First_Name__c &&
                                    dupParticipantDelegate.Last_Name__c != null &&
                                    dupParticipantDelegate.Last_Name__c ==
                                    paticipantInfoToCheck.Last_Name__c);
                                if (
                                    dupParticipant.Email__c != null &&
                                    paticipantInfoToCheck.Email__c != null &&
                                    dupParticipant.Email__c.toLowerCase() ==
                                    paticipantInfoToCheck.Email__c.toLowerCase() ||
                                    dupParticipant.Phone__c != null &&
                                    dupParticipant.Phone__c == paticipantInfoToCheck.Phone__c ||
                                    dupParticipant.ZIP_Code__c != null &&
                                    dupParticipant.ZIP_Code__c == participant.ZIP_Code__c ||
                                    dupParticipant.Mailing_Zip_Postal_Code__c != null &&
                                    dupParticipant.Mailing_Zip_Postal_Code__c ==
                                    participant.Mailing_Zip_Postal_Code__c ||
                                    isDupParticipantDelegateCoincide
                                ) {
                                    if (
                                        dupParticipant.First_Name__c != null &&
                                        dupParticipant.First_Name__c == participant.First_Name__c
                                    ) {
                                        if(dupParticipant.Age__c == participant.Age__c){
                                            duplicate = new DuplicateContainer(dupParticipant);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if (duplicate == null && !contactsByDoBExist) {
                        for (Contact dupContact : contactsByDoB) {
                            if (
                                dupContact != null &&
                                dupContact.LastName != null &&
                                dupContact.LastName == participant.Last_Name__c
                            ) {
                                if (
                                    dupContact.Email != null &&
                                    paticipantInfoToCheck.Email__c != null &&
                                    dupContact.Email.toLowerCase() ==
                                    paticipantInfoToCheck.Email__c.toLowerCase() ||
                                    dupContact.Phone != null &&
                                    dupContact.Phone == paticipantInfoToCheck.Phone__c ||
                                    dupContact.MailingPostalCode != null &&
                                    (dupContact.MailingPostalCode == participant.ZIP_Code__c ||
                                    dupContact.MailingPostalCode ==
                                    participant.Mailing_Zip_Postal_Code__c)
                                ) {
                                    if (
                                        dupContact.FirstName != null &&
                                        dupContact.FirstName == participant.First_Name__c
                                    ) {
                                        duplicate = new DuplicateContainer(dupContact);
                                    }
                                }
                            }
                        }
                    }

                    if (duplicate != null) {
                        setDuplicate(participant, duplicate);
                    }
                }
            }
        }
    }

    public Participant__c findDuplicate(Participant__c participant) {
        Integer participantId = JSON.serialize(participant).hashCode();
        DuplicateContainer duplicate = duplicatesMap.get(participantId);
        if (duplicate != null)
            return duplicate.getParticipant();
        return null;
    }

    public Participant__c findDuplicateDelegate(Participant__c participant) {
        String duplicateDelegateKey =
            participant.First_Name__c +
            ',' +
            participant.Last_Name__c +
            ',' +
            participant.Email__c;
        if (duplicateDelegatesParticipantMap.containsKey(duplicateDelegateKey))
            return duplicateDelegatesParticipantMap.get(duplicateDelegateKey);
        return null;
    }

    public Contact findDuplicateContact(Participant__c participant) {
        Integer participantId = JSON.serialize(participant).hashCode();
        DuplicateContainer duplicate = duplicatesMap.get(participantId);
        if (duplicate != null)
            return duplicate.getContact();
        return null;
    }

    public Contact findDuplicateDelegateContact(Participant__c participant) {
        String duplicateContactDelegateKey =
            participant.First_Name__c +
            ',' +
            participant.Last_Name__c +
            ',' +
            participant.Email__c;
        if (duplicateDelegatesContactMap.containsKey(duplicateContactDelegateKey))
            return duplicateDelegatesContactMap.get(duplicateContactDelegateKey);
        return null;
    }

    private void setDuplicate(Participant__c newParticipant, DuplicateContainer duplicate) {
        Integer participantId = JSON.serialize(newParticipant).hashCode();
        if (duplicate.isParticipant()) {
            mergeParticipants(duplicate.getParticipant(), newParticipant);
        }
        duplicatesMap.put(participantId, duplicate);
    }

    private static Integer getYearOfBirthForParticipant(Participant__c participant) {
        if (!String.isEmpty(participant.Birth_Year__c))
            return getYearFromString(participant.Birth_Year__c);
        if (!String.isEmpty(participant.Date_of_Birth__c))
            return getYearFromString(participant.Date_of_Birth__c);
        return null;
    }

    private static Integer getYearFromString(String str) {
        try {
            return Integer.valueOf(str.mid(0, 4));
        } catch (Exception e) {
        }
        try {
            return Integer.valueOf(str.substring(6, 10));
        } catch (Exception e) {
            throw new ParticipantDuplicateServiceException(
                'Can not extract year from field value: ' + str
            ); 
        }
    }

    private static void mergeParticipants(
        Participant__c sourceParticipant,
        Participant__c newParticipant
    ) {
        if (sourceParticipant == null || newParticipant == null)
            return;
        if (String.isNotBlank(newParticipant.Phone__c)) sourceParticipant.Phone__c = newParticipant.Phone__c;
        if (String.isNotBlank(newParticipant.Email__c)) sourceParticipant.Email__c = newParticipant.Email__c;
        if (String.isNotBlank(newParticipant.First_Name__c)) sourceParticipant.First_Name__c = newParticipant.First_Name__c;
        if (String.isNotBlank(newParticipant.Last_Name__c)) sourceParticipant.Last_Name__c = newParticipant.Last_Name__c;
        if (String.isNotBlank(newParticipant.Middle_Name__c)) sourceParticipant.Middle_Name__c = newParticipant.Middle_Name__c;
        if (String.isNotBlank(newParticipant.Nickname__c)) sourceParticipant.Nickname__c = newParticipant.Nickname__c;
        if (String.isNotBlank(newParticipant.Suffix__c)) sourceParticipant.Suffix__c = newParticipant.Suffix__c;
        if (String.isNotBlank(newParticipant.Gender__c)) sourceParticipant.Gender__c = newParticipant.Gender__c;
        if (String.isNotBlank(newParticipant.Date_of_Birth__c)) sourceParticipant.Date_of_Birth__c = newParticipant.Date_of_Birth__c;
        if (String.isNotBlank(newParticipant.Phone_Type__c)) sourceParticipant.Phone_Type__c = newParticipant.Phone_Type__c;   
        if (String.isNotBlank(newParticipant.Alternative_Phone_Number__c)) sourceParticipant.Alternative_Phone_Number__c = newParticipant.Alternative_Phone_Number__c;
        if (String.isNotBlank(newParticipant.Mailing_State__c)) sourceParticipant.Mailing_State__c = newParticipant.Mailing_State__c; 
        if (String.isNotBlank(newParticipant.Mailing_Country__c)) sourceParticipant.Mailing_Country__c = newParticipant.Mailing_Country__c;
        if (String.isNotBlank(newParticipant.Mailing_Country_Code__c)) sourceParticipant.Mailing_Country_Code__c = newParticipant.Mailing_Country_Code__c;
        if (String.isNotBlank(newParticipant.Mailing_State_Code__c)) sourceParticipant.Mailing_State_Code__c = newParticipant.Mailing_State_Code__c;
        if (String.isNotBlank(newParticipant.Mailing_Zip_Postal_Code__c)) sourceParticipant.Mailing_Zip_Postal_Code__c = newParticipant.Mailing_Zip_Postal_Code__c;
       // if (String.isNotBlank(newParticipant.Birth_Year__c)) sourceParticipant.Birth_Year__c = newParticipant.Birth_Year__c;
        if (String.isNotBlank(newParticipant.Mailing_City__c)) sourceParticipant.Mailing_City__c = newParticipant.Mailing_City__c;
        if (String.isNotBlank(newParticipant.Mailing_Street__c)) sourceParticipant.Mailing_Street__c = newParticipant.Mailing_Street__c;
        if (String.isNotBlank(newParticipant.Secondary_Source__c)) sourceParticipant.Secondary_Source__c = newParticipant.Secondary_Source__c; 
        //if (String.isNotBlank(newParticipant.Language_Preference_Code__c)) sourceParticipant.Language_Preference_Code__c = newParticipant.Language_Preference_Code__c;
        if (String.isNotBlank(newParticipant.Preferred_Language__c)) sourceParticipant.Preferred_Language__c = newParticipant.Preferred_Language__c;
        if (newParticipant.BMI__c != null) sourceParticipant.BMI__c = newParticipant.BMI__c;
    }
    public static List<Participant__c> getAllParticipantsByDOB(Map<String,Map<String,Map<String,list<Participant__c>>>> dobPartMap, Participant__c participant){
        if(dobPartMap.containsKey(participant.Birth_Year__c)){
            String dd = '--';
            String mm = '--';
            String yyyy = participant.Birth_Year__c;
            if(!String.isBlank(participant.Birth_Month__c)) mm = participant.Birth_Month__c;
            if(!String.isBlank(participant.Birth_Day__c)) dd = participant.Birth_Day__c; 
            List<Participant__c> pList = new List<Participant__c>();  
            if(mm!='--'){
                if(dd!='--'){                    
                    if(dobPartMap.get(yyyy).containsKey(mm)){
                        // all part with new part full DOB
                        if(dobPartMap.get(yyyy).get(mm).containsKey(dd)){
                            pList.addAll(dobPartMap.get(yyyy).get(mm).get(dd)); 
                        }
                        //all part with new part month and year but empty day 
                        if(dobPartMap.get(yyyy).get(mm).containsKey('--')){
                            pList.addAll(dobPartMap.get(yyyy).get(mm).get('--'));  
                        }                        
                    }   
                    //all part with new part year but empty day and month
                    if(dobPartMap.get(yyyy).containsKey('--')){
                        if(dobPartMap.get(yyyy).get('--').containsKey('--')){
                            pList.addAll(dobPartMap.get(yyyy).get('--').get('--'));  
                        }
                    }         
                }
                else{
                    //all part with new part month and year and all days 
                    if(dobPartMap.get(yyyy).containsKey(mm)){
                        for(List<Participant__c> pls: dobPartMap.get(yyyy).get(mm).values()){
                            pList.addAll(pls);                    
                        }
                    }
                    //all part with new part year but empty day and month
                    if(dobPartMap.get(yyyy).containsKey('--')){
                        if(dobPartMap.get(yyyy).get('--').containsKey('--')){
                            pList.addAll(dobPartMap.get(yyyy).get('--').get('--'));  
                        }
                    }                       
                }          
            }
            else{
                //all part with new part year but all day and all months
                for(Map<String,List<Participant__c>> day : dobPartMap.get(yyyy).values()){
                    for(List<Participant__c> partList : day.values()){
                        pList.addAll(partList);
                    }
                }
            }
            if(pList.size()>0)
                return pList;
        }
        return null;                                                     
    }
}