/**
 * Created by Yehor Dobrovolskyi
 */

public with sharing class SearchConditionsOfInterestRemote {

    @AuraEnabled
    public static List<TherapeuticAreaService.CAWrapper> searchConditionOfInterest(String nameTA) {
        try {
            TherapeuticAreaService taService = (TherapeuticAreaService) ClassFactory.newInstance(TherapeuticAreaService.class);
            List<Therapeutic_Area__c> therapeuticAreas = taService.getTherapeuticAreas(nameTA);
            if (!therapeuticAreas.isEmpty()) {
                List<TherapeuticAreaService.CAWrapper> caWrappers = taService.getCOIWrappers(therapeuticAreas);
                return caWrappers;
            }
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