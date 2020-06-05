/**
 * Created by Leonid Bartenev
 */

public without sharing class ParticipantDuplicateService {

    public class ParticipantDuplicateServiceException extends Exception {}

    public Map<Integer, DuplicateContainer> duplicatesMap = new Map<Integer, DuplicateContainer>();

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
                return ((Participant__c)duplicate).First_Name__c;
            }
            return ((Contact)duplicate).FirstName;
        }

        public String getLastName() {
            if (isParticipant()) {
                return ((Participant__c)duplicate).Last_Name__c;
            }
            return ((Contact)duplicate).LastName;
        }

        public String getZipCode() {
            if (isParticipant()) {
                return ((Participant__c)duplicate).ZIP_Code__c;
            }
            return ((Contact)duplicate).MailingPostalCode;
        }

        public Date getDateOfBirth() {
            if (isParticipant()) {
                Participant__c participant = (Participant__c)duplicate;
                return Date.valueOf(participant.Date_of_Birth__c);
            }
            return null;
        }

        public Integer getYearOfBirth() {
            if (isParticipant()) {
                Participant__c participant = (Participant__c)duplicate;
                return getYearOfBirthForParticipant(participant);
            }
            return null;
        }

        public Boolean isAdult() {
            if (isParticipant()) {
                return ((Participant__c)duplicate).Adult__c;
            }
            return true;
        }

        public Participant__c getParticipant() {
            if (isParticipant()) return (Participant__c)duplicate;
            return null;
        }

        public Contact getContact() {
            if (!isParticipant()) return (Contact)duplicate;
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
        Map<Participant__c, Participant__c> participantsByDelegates = new Map<Participant__c, Participant__c>();
        for (ParticipantWithDelegate partWithDelegate : partsWithDelegates) {
            if (!String.isBlank(partWithDelegate.participant.Phone__c)) phones.add(partWithDelegate.participant.Phone__c);
            if (!String.isBlank(partWithDelegate.participant.Email__c)) emails.add(partWithDelegate.participant.Email__c);
            if (!String.isBlank(partWithDelegate.participant.Date_of_Birth__c)) {
                birthDates.add(Date.valueOf(partWithDelegate.participant.Date_of_Birth__c));
                birthDateStrings.add(partWithDelegate.participant.Date_of_Birth__c);
            }
            if (!String.isBlank(partWithDelegate.participant.ZIP_Code__c)) zipCodes.add(partWithDelegate.participant.ZIP_Code__c);

            if (partWithDelegate.delegate != null) {
                participantsByDelegates.put(partWithDelegate.participant, partWithDelegate.delegate);

                if (!String.isBlank(partWithDelegate.delegate.Phone__c)) phones.add(partWithDelegate.delegate.Phone__c);
                if (!String.isBlank(partWithDelegate.delegate.Email__c)) emails.add(partWithDelegate.delegate.Email__c);
                if (!String.isBlank(partWithDelegate.delegate.Date_of_Birth__c)) {
                    birthDates.add(Date.valueOf(partWithDelegate.delegate.Date_of_Birth__c));
                    birthDateStrings.add(partWithDelegate.delegate.Date_of_Birth__c);
                }
                if (!String.isBlank(partWithDelegate.delegate.ZIP_Code__c)) zipCodes.add(partWithDelegate.delegate.ZIP_Code__c);
            }
        }

        //Find participants
        List<Participant__c> existedParticipants = [
                SELECT Id, First_Name__c, Last_Name__c, Email__c, Phone__c, Day_of_Birth__c, Birth_Year__c, Date_of_Birth__c, Secondary_Source__c, ZIP_Code__c, Mailing_Zip_Postal_Code__c
                FROM Participant__c
                WHERE Email__c IN :emails OR Phone__c IN :phones OR Day_of_Birth__c IN :birthDates OR ZIP_Code__c IN :zipCodes
        ];
        List<List<SObject>> participantsSearchList = [FIND 'Wingo OR SFDC' IN ALL FIELDS
                RETURNING Account(Name),Contact(FirstName,LastName,Department)];
        Map<String, Participant__c> participantsByEmailMap = new Map<String, Participant__c>();
        Map<String, Participant__c> participantsByPhoneMap = new Map<String, Participant__c>();
        Map<Date, List<Participant__c>> participantsByDoBMap = new Map<Date, List<Participant__c>>();
        Map<String, List<Participant__c>> participantsByDoBStringsMap = new Map<String, List<Participant__c>>();
        Map<String, List<Participant__c>> participantsByZipMap = new Map<String, List<Participant__c>>();
        for (Participant__c participant : existedParticipants) {
            if (!String.isBlank(participant.Email__c)) participantsByEmailMap.put(participant.Email__c.toLowerCase(), participant);
            if (!String.isBlank(participant.Phone__c)) participantsByPhoneMap.put(participant.Phone__c, participant);
            if (!String.isBlank(participant.ZIP_Code__c)) {
                List<Participant__c> zipParticipants = participantsByZipMap.get(participant.ZIP_Code__c);
                if (zipParticipants == null) zipParticipants = new List<Participant__c>();
                zipParticipants.add(participant);
                participantsByZipMap.put(participant.ZIP_Code__c, zipParticipants);
            }
            if (participant.Day_of_Birth__c != null) {
                List<Participant__c> doBParticipants = participantsByDoBMap.get(participant.Day_of_Birth__c);
                if (doBParticipants == null) doBParticipants = new List<Participant__c>();
                doBParticipants.add(participant);
                participantsByDoBMap.put(participant.Day_of_Birth__c, doBParticipants);
            }
            if (!String.isBlank(participant.Date_of_Birth__c)) {
                List<Participant__c> doBParticipants = participantsByDoBStringsMap.get(participant.Date_of_Birth__c);
                if (doBParticipants == null) doBParticipants = new List<Participant__c>();
                doBParticipants.add(participant);
                participantsByDoBStringsMap.put(participant.Date_of_Birth__c, doBParticipants);
            }
        }

        //Find contacts:
        List<Contact> existedContacts = [
                SELECT Id, FirstName, Email, Phone, Birthdate, MailingPostalCode
                FROM Contact
                WHERE Email IN :emails OR Phone IN :phones OR MailingPostalCode IN :zipCodes
        ];
        Map<String, Contact> contactsByEmailMap = new Map<String, Contact>();
        Map<String, Contact> contactsByPhoneMap = new Map<String, Contact>();
        Map<String, List<Contact>> contactsByZipMap = new Map<String, List<Contact>>();
        Map<Date, List<Contact>> contactsByDoBMap = new Map<Date, List<Contact>>();
        for(Contact contact : existedContacts){
            if (contact.Email != null) contactsByEmailMap.put(contact.Email.toLowerCase(), contact);
            if (contact.Phone != null) contactsByPhoneMap.put(contact.Phone, contact);
            if (!String.isBlank(contact.MailingPostalCode)) {
                List<Contact> zipContacts = contactsByZipMap.get(contact.MailingPostalCode);
                if (zipContacts == null) zipContacts = new List<Contact>();
                zipContacts.add(contact);
                contactsByZipMap.put(contact.MailingPostalCode, zipContacts);
            }
            if (contact.Birthdate != null) {
                List<Contact> dobContacts = contactsByDoBMap.get(contact.Birthdate);
                if (dobContacts == null) dobContacts = new List<Contact>();
                dobContacts.add(contact);
                contactsByDoBMap.put(contact.Birthdate, dobContacts);
            }
        }

        for (ParticipantWithDelegate partWithDelegate : partsWithDelegates) {
            Participant__c participant = partWithDelegate.participant;
            Participant__c delegate = partWithDelegate.delegate;
            DuplicateContainer duplicate;

            if (participant.Adult__c && (!String.isBlank(participant.Email__c) || !String.isBlank(participant.Phone__c))) {
                System.debug('Adult with phone or email');

                if (participant.Email__c != null && participantsByEmailMap.get(participant.Email__c.toLowerCase()) != null) {
                    duplicate = new DuplicateContainer(participantsByEmailMap.get(participant.Email__c.toLowerCase()));
                } else if (participant.Email__c != null && contactsByEmailMap.get(participant.Email__c.toLowerCase()) != null) {
                    duplicate = new DuplicateContainer(contactsByEmailMap.get(participant.Email__c.toLowerCase()));
                } else if (participant.Phone__c != null && participantsByPhoneMap.get(participant.Phone__c) != null) {
                    duplicate = new DuplicateContainer(participantsByPhoneMap.get(participant.Phone__c));
                } else if (participant.Phone__c != null && contactsByPhoneMap.get(participant.Phone__c) != null) {
                    duplicate = new DuplicateContainer(contactsByPhoneMap.get(participant.Phone__c));
                }

                if (duplicate != null) {
                    Integer birthYear = getYearOfBirthForParticipant(participant);
                    System.debug('>>> BY: ' + birthYear);
                    if (birthYear != null) {
                        Integer participantAge = System.today().year() - birthYear;
                        System.debug('>>> Participant age: ' + participantAge);
                        Integer birthYearInTheSystem = duplicate.getYearOfBirth();
                        if (birthYearInTheSystem != null) {
                            System.debug('>>> BY in the system: ' + birthYearInTheSystem);
                            if (birthYear == birthYearInTheSystem && duplicate.getFirstName() == participant.First_Name__c) {
                                setDuplicate(participant, duplicate);
                                continue;
                            }
                        } else if (participantAge > 18 && duplicate.getFirstName() == participant.First_Name__c) {
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
                if (birthYear != null && (participantsByDoBStringsMap.containsKey(participant.Date_of_Birth__c) ||
                        participant.Date_of_Birth__c != null && contactsByDoBMap.containsKey(Date.valueOf(participant.Date_of_Birth__c)))) {
                    List<Participant__c> participantsByDoB = participantsByDoBStringsMap.get(participant.Date_of_Birth__c);
                    List<Contact> contactsByDoB = participant.Date_of_Birth__c != null ? contactsByDoBMap.get(Date.valueOf(participant.Date_of_Birth__c)) : new List<Contact>();
                    if (participantsByDoB == null && contactsByDoB == null ||
                            participantsByDoB.isEmpty() && contactsByDoB.isEmpty()) {
                        continue;
                    }

                    if (participantsByDoB != null && delegate != null) {
                        for (Participant__c dupParticipant : participantsByDoB) {
                            if (dupParticipant != null && dupParticipant.Last_Name__c != null && dupParticipant.Last_Name__c.toLowerCase() == participant.Last_Name__c.toLowerCase()) {
                                if (dupParticipant.Email__c != null && delegate.Email__c != null && dupParticipant.Email__c.toLowerCase() == delegate.Email__c.toLowerCase() ||
                                        dupParticipant.Phone__c != null && dupParticipant.Phone__c == delegate.Phone__c ||
                                        dupParticipant.ZIP_Code__c != null && dupParticipant.ZIP_Code__c == delegate.ZIP_Code__c) {
                                    if (dupParticipant.First_Name__c != null && delegate.First_Name__c != null && dupParticipant.First_Name__c.toLowerCase() == delegate.First_Name__c.toLowerCase()) {
                                        duplicate = new DuplicateContainer(dupParticipant);
                                    }
                                }
                            }
                        }
                    }
                    if (contactsByDoB != null && delegate != null) {
                        for (Contact dupContact : contactsByDoB) {
                            if (dupContact != null && dupContact.LastName != null && dupContact.LastName.toLowerCase() == participant.Last_Name__c.toLowerCase()) {
                                if (dupContact.Email != null && delegate.Email__c != null && dupContact.Email.toLowerCase() == delegate.Email__c.toLowerCase() ||
                                        dupContact.Phone != null && dupContact.Phone == delegate.Phone__c ||
                                        dupContact.MailingPostalCode != null && dupContact.MailingPostalCode == delegate.ZIP_Code__c) {
                                    if (dupContact.FirstName != null && delegate.First_Name__c != null && dupContact.FirstName.toLowerCase() == delegate.First_Name__c.toLowerCase()) {
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

    public Participant__c findDuplicate(Participant__c participant){
        Integer participantId = JSON.serialize(participant).hashCode();
        DuplicateContainer duplicate = duplicatesMap.get(participantId);
        if (duplicate != null) return duplicate.getParticipant();
        return null;
    }

    public Contact findDuplicateContact(Participant__c participant){
        Integer participantId = JSON.serialize(participant).hashCode();
        DuplicateContainer duplicate = duplicatesMap.get(participantId);
        if (duplicate != null) return duplicate.getContact();
        return null;
    }

    private void setDuplicate(Participant__c newParticipant, DuplicateContainer duplicate){
        Integer participantId = JSON.serialize(newParticipant).hashCode();
        if (duplicate.isParticipant()) {
            mergeParticipants(duplicate.getParticipant(), newParticipant);
        }
        duplicatesMap.put(participantId, duplicate);
    }
    
    private static Integer getYearOfBirthForParticipant(Participant__c participant){
        if (!String.isEmpty(participant.Birth_Year__c)) return getYearFromString(participant.Birth_Year__c);
        if (!String.isEmpty(participant.Date_of_Birth__c)) return getYearFromString(participant.Date_of_Birth__c);
        return null;
    }
    
    private static Integer getYearFromString(String str){
        try {
            return Integer.valueOf(str.mid(0, 4));
        } catch (Exception e) {}
        try {
            return Integer.valueOf(str.substring(6, 10));
        } catch (Exception e) {
            throw new ParticipantDuplicateServiceException('Can not extract year from field value: ' + str);
        }
    }
    
    private static void mergeParticipants(Participant__c sourceParticipant, Participant__c newParticipant){
        if (sourceParticipant == null || newParticipant == null) return;
        //if (newParticipant.Phone__c != null) sourceParticipant.Phone__c = newParticipant.Phone__c;
        //if (newParticipant.Email__c == null) sourceParticipant.Email__c = newParticipant.Email__c;
        if (newParticipant.Mailing_Country_Code__c != null) sourceParticipant.Mailing_Country_Code__c = newParticipant.Mailing_Country_Code__c;
        if (newParticipant.Mailing_State_Code__c != null) sourceParticipant.Mailing_State_Code__c = newParticipant.Mailing_State_Code__c;
        if (newParticipant.Mailing_Zip_Postal_Code__c != null) sourceParticipant.Mailing_Zip_Postal_Code__c = newParticipant.Mailing_Zip_Postal_Code__c;
        //if (newParticipant.Last_Name__c != null) sourceParticipant.Last_Name__c = newParticipant.Last_Name__c;
        if (newParticipant.Middle_Name__c != null) sourceParticipant.Middle_Name__c = newParticipant.Middle_Name__c;
        if (newParticipant.Date_of_Birth__c != null) sourceParticipant.Date_of_Birth__c = newParticipant.Date_of_Birth__c;
        if (newParticipant.Birth_Year__c != null) sourceParticipant.Birth_Year__c = newParticipant.Birth_Year__c;
    }

}