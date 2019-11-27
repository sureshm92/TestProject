/**
 * Created by dmytro.fedchyshyn on 06.09.2019.
 */

public without sharing class TravelSupportRemote {
    @AuraEnabled
    public static List<TravelVendor__c> getVendors(String studySiteId) {
        try {
            TravelSupportHelper helper = new TravelSupportHelper();
            return helper.getVendors(studySiteId);
        } catch (Exception e) {
            return (List<TravelVendor__c>) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getInitData() {
        try {
            return JSON.serialize(ParticipantService.getInstance().getState());
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }
}