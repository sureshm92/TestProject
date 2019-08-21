/**
 * Created by Leonid Bartenev
 */

public without sharing class ParticipantDuplicateService {
    
    Map<Integer, Participant__c> resultMap = new Map<Integer, Participant__c>();
    
    public ParticipantDuplicateService(List<Participant__c> newParticipants){
    
        List<String> emails = new List<String>();
        List<String> phones = new List<String>();
        for(Participant__c participant : newParticipants){
            if(!String.isEmpty(participant.Phone__c)) phones.add(participant.Phone__c);
            if(!String.isEmpty(participant.Email__c)) emails.add(participant.Email__c);
        }
        
        List<Participant__c> existedParticipants = [
                SELECT Id, Email__c, Phone__c
                FROM Participant__c
                WHERE Email__c IN: emails OR Phone__c IN: phones
        ];
        Map<String, Participant__c> participantsByEmailMap = new Map<String, Participant__c>();
        Map<String, Participant__c> participantsByPhoneMap = new Map<String, Participant__c>();
        for(Participant__c participant : existedParticipants){
            participantsByEmailMap.put(participant.Email__c, participant);
            participantsByPhoneMap.put(participant.Phone__c, participant);
        }
        for(Participant__c participant : newParticipants){
            Participant__c foundParticipant;
            if(participant.Email__c != null && participantsByEmailMap.get(participant.Email__c) != null){
                foundParticipant = participantsByEmailMap.get(participant.Email__c);
            }else if(participant.Phone__c != null && participantsByPhoneMap.get(participant.Phone__c) != null){
                foundParticipant = participantsByPhoneMap.get(participant.Phone__c);
            }
            if(foundParticipant != null){
            
            }
        }
    }
    
    public Participant__c findDuplicate(Participant__c participant){
        Integer participantId = JSON.serialize(participant).hashCode();
        return resultMap.get(participantId);
    }
    
    private void setParticipantResult(Participant__c participant){
        Integer participantId = JSON.serialize(participant).hashCode();
        resultMap.put(participantId, participant);
    }
    
    private static String getYearOfBirth(String birthDate){
        if(birthDate.indexOf('-') == 2 || birthDate.indexOf('/') == 2){
            return birthDate.substring(6);
        }
        return birthDate.substring(0,4);
    }


}