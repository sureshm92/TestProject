public with sharing class ParticipantDecoupler {

    @TestVisible
    private static Map<Id, List<Therapeutic_Area_Patient__c>> therapeuticAreaPatientsByParticipantIds = new Map<Id, List<Therapeutic_Area_Patient__c>>();

    public static List<Therapeutic_Area_Patient__c> getTherapeuticAreaPatients(Participant__c participant) {
        return therapeuticAreaPatientsByParticipantIds.get(participant.Id) == null ?
                participant.Therapeutic_Area_Patients__r :
                therapeuticAreaPatientsByParticipantIds.get(participant.Id);
    }
}