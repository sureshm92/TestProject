/**
 * Created by dmytro.fedchyshyn on 06.09.2019.
 */

public without sharing class TravelSupportRemote {

    @AuraEnabled
    public static List<String> getTitleFiltered() {
        try {
            List<AggregateResult> results = [SELECT Title__c Label FROM Booking__c GROUP BY Title__c];
            List<String> titles = new List<String>();
            for(AggregateResult result : results){
                titles.add((String)result.get('Label'));
            }
            return titles;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static List<TravelVendor__c> getVendors() {
        try {
            ParticipantService.ParticipantState ps = ParticipantService.getInstance().getState();
            return TravelSupportHelper.getVendors(ps.pe.Study_Site__c);
        } catch (Exception e) {
            return (List<TravelVendor__c>) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static List<PatientTravelService.TravelWrapper> getParticipantTravels(String travelMode) {
        try {
            return ((PatientTravelService) ClassFactory.newInstance(PatientTravelService.class)).getTravelWrappers(travelMode);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }
}