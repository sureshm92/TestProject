/**
 * Created by Leonid Bartenev
 */

public without sharing class ParticipantDuplicateService {
    
    public Map<Integer, Participant__c> resultMap = new Map<Integer, Participant__c>();
    
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
        List<Participant__c> existedParticipants = [
                SELECT Id, First_Name__c, Email__c, Phone__c, Birth_Year__c, Date_of_Birth__c
                FROM Participant__c
                WHERE Email__c IN: emails OR Phone__c IN: phones
        ];
        Map<String, Participant__c> participantsByEmailMap = new Map<String, Participant__c>();
        Map<String, Participant__c> participantsByPhoneMap = new Map<String, Participant__c>();
        for(Participant__c participant : existedParticipants){
            if(participant.Email__c != null) participantsByEmailMap.put(participant.Email__c.toLowerCase(), participant);
            if(participant.Phone__c != null) participantsByPhoneMap.put(participant.Phone__c, participant);
        }
    
        for(Participant__c participant : newParticipants){
            Participant__c participantInTheSystem;
            if(participant.Email__c != null && participantsByEmailMap.get(participant.Email__c.toLowerCase()) != null){
                participantInTheSystem = participantsByEmailMap.get(participant.Email__c.toLowerCase());
            }else if(participant.Phone__c != null && participantsByPhoneMap.get(participant.Phone__c) != null){
                participantInTheSystem = participantsByPhoneMap.get(participant.Phone__c);
            }
            if(participantInTheSystem != null){
                Integer birthYear = getYearOfBirth(participant);
                if(birthYear != null){
                    Integer participantAge = System.today().year() - birthYear;
                    Integer birthYearInTheSystem = getYearOfBirth(participantInTheSystem);
                    if(birthYearInTheSystem != null){
                        if(birthYear == birthYearInTheSystem && participantInTheSystem.First_Name__c == participant.First_Name__c){
                            setDuplicateParticipant(participant, participantInTheSystem);
                            continue;
                        }
                    }else if(participantAge > 18 && participantInTheSystem.First_Name__c == participant.First_Name__c){
                        setDuplicateParticipant(participant, participantInTheSystem);
                        continue;
                    }
                }else{
                    if(participantInTheSystem.First_Name__c == participant.First_Name__c) {
                        setDuplicateParticipant(participant, participantInTheSystem);
                        continue;
                    }
                }
            
            }
        }
    }
    
    public Participant__c findDuplicate(Participant__c participant){
        Integer participantId = JSON.serialize(participant).hashCode();
        Participant__c participantFromDatabase = resultMap.get(participantId);
        mergeParticipants(participantFromDatabase, participant);
        return participantFromDatabase;
    }
    
    private void setDuplicateParticipant(Participant__c newParticipant, Participant__c sourceParticipant){
        Integer participantId = JSON.serialize(newParticipant).hashCode();
        mergeParticipants(sourceParticipant, newParticipant);
        resultMap.put(participantId, sourceParticipant);
    }
    
    private static Integer getYearOfBirth(Participant__c participant){
        if(!String.isEmpty(participant.Birth_Year__c)) return Integer.valueOf(participant.Birth_Year__c);
        if(!String.isEmpty(participant.Date_of_Birth__c)) return Integer.valueOf(participant.Date_of_Birth__c.substring(6));
        return null;
    }
    
    private static void mergeParticipants(Participant__c sourceParticipant, Participant__c newParticipant){
        if(sourceParticipant == null || newParticipant == null) return;
        if(sourceParticipant.Phone__c == null && newParticipant.Phone__c != null) sourceParticipant.Phone__c = newParticipant.Phone__c;
        //TODO add fields
    }



}