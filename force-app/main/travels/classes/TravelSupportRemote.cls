/**
 * Created by dmytro.fedchyshyn on 06.09.2019.
 */

public without sharing class TravelSupportRemote {
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
    public static List<PatientTravelService.TravelWrapper> getParticipantTravels(String visitMode) {
        try {
            return ((PatientTravelService) ClassFactory.newInstance(PatientTravelService.class)).getTravelWrappers(visitMode);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }
}