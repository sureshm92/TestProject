/**
 * Created by Yehor Dobrovolskyi
 */

public with sharing class SearchConditionsOfInterestRemote {

    @AuraEnabled
    public static List<TherapeuticAreaService.CAWrapper> searchConditionOfInterest(String nameTA) {
        List<TherapeuticAreaService.CAWrapper> caWrappers = new List<TherapeuticAreaService.CAWrapper>();
        try {
            TherapeuticAreaService taService = (TherapeuticAreaService) ClassFactory.newInstance(TherapeuticAreaService.class);
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


}