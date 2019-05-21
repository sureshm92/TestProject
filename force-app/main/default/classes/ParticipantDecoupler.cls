public with sharing class ParticipantDecoupler {

    @TestVisible
    private static Map<Id, List<Therapeutic_Area_Patient__c>> therapeuticAreaPatientsByParticipantIds = new Map<Id, List<Therapeutic_Area_Patient__c>>();
    @TestVisible
    private static Map<Id, List<Resource_Action__c>> resourceActionsByParticipantIds = new Map<Id, List<Resource_Action__c>>();

    public static List<Therapeutic_Area_Patient__c> getTherapeuticAreaPatients(Participant__c participant) {
        return therapeuticAreaPatientsByParticipantIds.get(participant.Id) == null ?
                participant.Therapeutic_Area_Patients__r :
                therapeuticAreaPatientsByParticipantIds.get(participant.Id);
    }
    public static List<Resource_Action__c> getResourceActions(Participant__c participant) {
        return resourceActionsByParticipantIds.get(participant.Id) == null ?
                participant.Resource_Actions__r :
                resourceActionsByParticipantIds.get(participant.Id);
    }
}