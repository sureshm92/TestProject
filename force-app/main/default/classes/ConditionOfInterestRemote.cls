/**
 * Created by AlexKetch on 3/21/2019.
 */

public with sharing class ConditionOfInterestRemote {

    @AuraEnabled
    public static List<TherapeuticAreaService.CAWrapper> getConditionOfInterest() {
        List<TherapeuticAreaService.CAWrapper> caWrappers = new List<TherapeuticAreaService.CAWrapper>();
        try {
            TherapeuticAreaService taService = (TherapeuticAreaService) ClassFactory.newInstance(TherapeuticAreaService.class);
            Participant__c participant = taService.getParticipant();
            if (!participant.Therapeutic_Area_Patients__r.isEmpty()) {
                for (Therapeutic_Area_Patient__c coi : participant.Therapeutic_Area_Patients__r) {
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
            upsert cois;
            return cois;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
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