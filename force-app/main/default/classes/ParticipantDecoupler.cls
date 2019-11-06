public without sharing class ParticipantDecoupler {

    @TestVisible
    private static Map<Id, List<Therapeutic_Area_Patient__c>> therapeuticAreaPatientsByParticipantIds = new Map<Id, List<Therapeutic_Area_Patient__c>>();
    @TestVisible
    private static Map<Id, List<Resource_Action__c>> resourceActionsByParticipantIds = new Map<Id, List<Resource_Action__c>>();

    public static List<Therapeutic_Area_Patient__c> getTherapeuticAreaPatients(Participant__c participant) {
        if (!therapeuticAreaPatientsByParticipantIds.containsKey(participant.Id)) {
            List<Therapeutic_Area_Patient__c> areaPatient = [
                    SELECT Therapeutic_Area__c FROM Therapeutic_Area_Patient__c WHERE Participant__c = :participant.Id
            ];

            therapeuticAreaPatientsByParticipantIds.put(participant.Id, areaPatient);
        }
        return therapeuticAreaPatientsByParticipantIds.get(participant.Id);
    }
    public static List<Resource_Action__c> getResourceActions(Participant__c participant) {
        return resourceActionsByParticipantIds.get(participant.Id) == null ?
                participant.Resource_Actions__r :
                resourceActionsByParticipantIds.get(participant.Id);
    }
}