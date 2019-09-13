/**
 * Created by Leonid Bartenev
 */

public without sharing class ParticipantDuplicateService {
    
    public class ParticipantDuplicateServiceException extends Exception{}
    
    public Map<Integer, DuplicateContainer> duplicatesMap = new Map<Integer, DuplicateContainer>();
    
    private class DuplicateContainer{
        public Object duplicate;
        
        public DuplicateContainer(Object duplicate){
            this.duplicate = duplicate;
        }
        
        public Boolean isParticipant(){
            return duplicate instanceof Participant__c;
        }
        
        public String getFirstName(){
            if(isParticipant()){
                return ((Participant__c)duplicate).First_Name__c;
            }
            return ((Contact)duplicate).FirstName;
        }
    
        public Integer getYearOfBirth(){
            if(isParticipant()){
                Participant__c participant = (Participant__c)duplicate;
                return getYearOfBirthForParticipant(participant);
            }
            return null;
        }
    
        public Participant__c getParticipant(){
            if(isParticipant()) return (Participant__c)duplicate;
            return null;
        }
    
        public Contact getContact(){
            if(!isParticipant()) return (Contact)duplicate;
            return null;
        }

    }
    
    public ParticipantDuplicateService(Participant__c participant){
        this(new List<Participant__c>{participant});
    }
    
    public ParticipantDuplicateService(List<Participant__c> newParticipants){
        List<String> emails = new List<String>();
        List<String> phones = new List<String>();
        for(Participant__c participant : newParticipants){
            if(!String.isEmpty(participant.Phone__c)) phones.add(participant.Phone__c);
            if(!String.isEmpty(participant.Email__c)) emails.add(participant.Email__c);
        }
        //Find participants
        List<Participant__c> existedParticipants = [
                SELECT Id, First_Name__c, Last_Name__c, Email__c, Phone__c, Birth_Year__c, Date_of_Birth__c, Secondary_Source__c
                FROM Participant__c
                WHERE Email__c IN: emails OR Phone__c IN: phones
        ];
        Map<String, Participant__c> participantsByEmailMap = new Map<String, Participant__c>();
        Map<String, Participant__c> participantsByPhoneMap = new Map<String, Participant__c>();
        for(Participant__c participant : existedParticipants){
            if(participant.Email__c != null) participantsByEmailMap.put(participant.Email__c.toLowerCase(), participant);
            if(participant.Phone__c != null) participantsByPhoneMap.put(participant.Phone__c, participant);
        }
        
        //Find contacts:
        List<Contact> existedContacts = [
                SELECT Id, FirstName, Email, Phone, Birthdate
                FROM Contact
                WHERE Email IN: emails OR Phone IN: phones
        ];
        Map<String, Contact> contactsByEmailMap = new Map<String, Contact>();
        Map<String, Contact> contactsByPhoneMap = new Map<String, Contact>();
        for(Contact contact : existedContacts){
            if(contact.Email != null) contactsByEmailMap.put(contact.Email.toLowerCase(), contact);
            if(contact.Phone != null) contactsByPhoneMap.put(contact.Phone, contact);
        }
    
        for(Participant__c participant : newParticipants){
            DuplicateContainer duplicate;
            if(participant.Email__c != null && participantsByEmailMap.get(participant.Email__c.toLowerCase()) != null){
                duplicate = new DuplicateContainer(participantsByEmailMap.get(participant.Email__c.toLowerCase()));
            }else if(participant.Phone__c != null && participantsByPhoneMap.get(participant.Phone__c) != null){
                duplicate = new DuplicateContainer(participantsByPhoneMap.get(participant.Phone__c));
            }else if(participant.Email__c != null && contactsByEmailMap.get(participant.Email__c.toLowerCase()) != null){
                duplicate = new DuplicateContainer(contactsByEmailMap.get(participant.Email__c.toLowerCase()));
            }else if(participant.Phone__c != null && contactsByPhoneMap.get(participant.Phone__c) != null){
                duplicate = new DuplicateContainer(contactsByPhoneMap.get(participant.Phone__c));
            }

            if(duplicate != null){
                Integer birthYear = getYearOfBirthForParticipant(participant);
                System.debug('>>> BY: ' + birthYear);
                if(birthYear != null){
                    Integer participantAge = System.today().year() - birthYear;
                    System.debug('>>> Participant age: ' + participantAge);
                    Integer birthYearInTheSystem = duplicate.getYearOfBirth();
                    if(birthYearInTheSystem != null){
                        System.debug('>>> BY in the system: ' + birthYearInTheSystem);
                        if(birthYear == birthYearInTheSystem && duplicate.getFirstName() == participant.First_Name__c){
                            setDuplicate(participant, duplicate);
                            continue;
                        }
                    }else if(participantAge > 18 && duplicate.getFirstName() == participant.First_Name__c){
                        setDuplicate(participant, duplicate);
                        continue;
                    }
                }else{
                    if(duplicate.getFirstName() == participant.First_Name__c) {
                        setDuplicate(participant, duplicate);
                        continue;
                    }
                }
            
            }
        }
    }
    
    public Participant__c findDuplicate(Participant__c participant){
        Integer participantId = JSON.serialize(participant).hashCode();
        DuplicateContainer duplicate = duplicatesMap.get(participantId);
        if(duplicate != null) return duplicate.getParticipant();
        return null;
    }
    
    public Contact findDuplicateContact(Participant__c participant){
        Integer participantId = JSON.serialize(participant).hashCode();
        DuplicateContainer duplicate = duplicatesMap.get(participantId);
        if(duplicate != null) return duplicate.getContact();
        return null;
    }
    
    private void setDuplicate(Participant__c newParticipant, DuplicateContainer duplicate){
        Integer participantId = JSON.serialize(newParticipant).hashCode();
        if(duplicate.isParticipant()){
            mergeParticipants(duplicate.getParticipant(), newParticipant);
        }
        duplicatesMap.put(participantId, duplicate);
    }
    
    private static Integer getYearOfBirthForParticipant(Participant__c participant){
        if(!String.isEmpty(participant.Birth_Year__c)) return getYearFromString(participant.Birth_Year__c);
        if(!String.isEmpty(participant.Date_of_Birth__c)) return getYearFromString(participant.Date_of_Birth__c);
        return null;
    }
    
    private static Integer getYearFromString(String str){
        try{
            return Integer.valueOf(str.mid(0, 4));
        }catch (Exception e){}
        try {
            return Integer.valueOf(str.substring(6, 10));
        }catch (Exception e){
            throw new ParticipantDuplicateServiceException('Can not extract year from field value: ' + str);
        }
    }
    
    private static void mergeParticipants(Participant__c sourceParticipant, Participant__c newParticipant){
        if(sourceParticipant == null || newParticipant == null) return;
        //if(newParticipant.Phone__c != null) sourceParticipant.Phone__c = newParticipant.Phone__c;
        //if(newParticipant.Email__c == null) sourceParticipant.Email__c = newParticipant.Email__c;
        if(newParticipant.Mailing_Country_Code__c != null) sourceParticipant.Mailing_Country_Code__c = newParticipant.Mailing_Country_Code__c;
        if(newParticipant.Mailing_State_Code__c != null) sourceParticipant.Mailing_State_Code__c = newParticipant.Mailing_State_Code__c;
        if(newParticipant.Mailing_Zip_Postal_Code__c != null) sourceParticipant.Mailing_Zip_Postal_Code__c = newParticipant.Mailing_Zip_Postal_Code__c;
        //if(newParticipant.Last_Name__c != null) sourceParticipant.Last_Name__c = newParticipant.Last_Name__c;
        if(newParticipant.Middle_Name__c != null) sourceParticipant.Middle_Name__c = newParticipant.Middle_Name__c;
        if(newParticipant.Date_of_Birth__c != null) sourceParticipant.Date_of_Birth__c = newParticipant.Date_of_Birth__c;
        if(newParticipant.Birth_Year__c != null) sourceParticipant.Birth_Year__c = newParticipant.Birth_Year__c;
    }
    



}