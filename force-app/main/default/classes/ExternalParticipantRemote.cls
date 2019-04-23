/**
 * Created by user on 23-Apr-19.
 */

public with sharing class ExternalParticipantRemote {


    public static List<ExternalParticipantsService.ExternalParticipant> getExternalParticipants(String participantId){
        return ExternalParticipantsService.getParticipants('USA', participantId);
    }
}