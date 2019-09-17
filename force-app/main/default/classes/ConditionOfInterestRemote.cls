/**
 * Created by AlexKetch on 3/21/2019.
 */

public without sharing class ConditionOfInterestRemote {

    @AuraEnabled
    public static List<TherapeuticAreaService.CAWrapper> getConditionOfInterest() {
        List<TherapeuticAreaService.CAWrapper> caWrappers = new List<TherapeuticAreaService.CAWrapper>();
        try {
            TherapeuticAreaService taService = (TherapeuticAreaService) ClassFactory.newInstance(TherapeuticAreaService.class);
            Participant__c participant = taService.getParticipant();
            if (!ParticipantDecoupler.getTherapeuticAreaPatients(participant).isEmpty()) {
                for (Therapeutic_Area_Patient__c coi : ParticipantDecoupler.getTherapeuticAreaPatients(participant)) {
                    TherapeuticAreaService.CAWrapper caWrapper = new TherapeuticAreaService.CAWrapper ();
                    caWrapper.isSelected = true;
                    caWrapper.coi = coi;
                    caWrappers.add(caWrapper);
                }
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return caWrappers;
    }

    @AuraEnabled
    public static List<Therapeutic_Area_Patient__c> upsertListCoi(List<Therapeutic_Area_Patient__c> cois) {
        try {
            if (!cois.isEmpty()) {
                upsert cois;
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return cois;
    }

    @AuraEnabled
    public static void deleteCOI(List<Id> coiIds) {
        try {
            Database.delete(coiIds);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }
}