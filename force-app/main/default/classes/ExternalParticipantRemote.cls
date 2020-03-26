/**
 * Created by Slav on 23-Apr-19.
 */

public with sharing class ExternalParticipantRemote {

    @AuraEnabled
    public static List<ExternalParticipantsService.ExternalParticipant> getExternalParticipants(String participantId){
        return ExternalParticipantsService.getParticipants('USA', participantId);
    }

    @AuraEnabled
    public static ExternalParticipantsService.ExternalParticipant init(){
        return new ExternalParticipantsService.ExternalParticipant();
    }

    @AuraEnabled
    public static List<ExternalParticipantsService.ExternalParticipant> saveParticipant(String participantJSON){
        System.debug(participantJSON);
        ExternalParticipantsService.ExternalParticipant participant = new ExternalParticipantsService.ExternalParticipant();
        participant = (ExternalParticipantsService.ExternalParticipant) JSON.deserialize(participantJSON,ExternalParticipantsService.ExternalParticipant.class);
        System.debug(participant);
        participant.countryCode = 'USA';
        participant.dob = ExternalParticipantsService.formatDate(participant.dob);
        ExternalParticipantsService.upsertParticipants(JSON.serialize(participant), participant.patientId);
        return ExternalParticipantsService.getParticipants('USA', null);
    }
}