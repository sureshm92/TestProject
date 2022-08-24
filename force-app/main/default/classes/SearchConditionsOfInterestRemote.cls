/**
 * Created by Yehor Dobrovolskyi
 */

public without sharing class SearchConditionsOfInterestRemote {
    @AuraEnabled
    public static List<TherapeuticAreaService.CAWrapper> searchConditionOfInterest(String nameTA) {
        List<TherapeuticAreaService.CAWrapper> caWrappers = new List<TherapeuticAreaService.CAWrapper>();
        try {
            TherapeuticAreaService taService = (TherapeuticAreaService) ClassFactory.newInstance(
                TherapeuticAreaService.class
            );
            List<Therapeutic_Area__c> therapeuticAreas = taService.getTherapeuticAreas(nameTA);
            if (!therapeuticAreas.isEmpty()) {
                caWrappers = taService.getCOIWrappers(therapeuticAreas);
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return caWrappers;
    }

    @AuraEnabled
    public static void deleteCOI(List<Id> coiIds) {
        try {
            Database.delete(coiIds);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static List<TherapeuticAreaService.CAWrapper> getConditionOfInterest() {
        List<TherapeuticAreaService.CAWrapper> caWrappers = new List<TherapeuticAreaService.CAWrapper>();
        try {
            List<Therapeutic_Area_Patient__c> areaPatients = ParticipantDecoupler.getTherapeuticAreaPatients();
            if (!areaPatients.isEmpty()) {
                for (Therapeutic_Area_Patient__c coi : areaPatients) {
                    TherapeuticAreaService.CAWrapper caWrapper = new TherapeuticAreaService.CAWrapper();
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
    public static List<Therapeutic_Area_Patient__c> upsertListCoi(
        List<Therapeutic_Area_Patient__c> cois
    ) {
        try {
            if (!cois.isEmpty()) {
                ((DatabaseProxy) (ClassFactory.newInstance(DatabaseProxy.class)))
                    .upsertRecords(cois, true);
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return cois;
    }
    @AuraEnabled
    public static void createSubscribeConnection(List<Therapeutic_Area_Patient__c> cois) {
        try {
            TrialSearchHelper helper = (TrialSearchHelper) ClassFactory.newInstance(
                TrialSearchHelper.class
            );
            helper.createSubscribeConnectionByCOI(cois);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void saveReferralNetworksNew(String referralNetworkJSON) {
        SubscribeToReferralNetworkRemote.saveReferralNetworksNew(referralNetworkJSON);
    }
}
