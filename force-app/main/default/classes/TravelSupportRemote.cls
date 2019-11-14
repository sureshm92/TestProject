/**
 * Created by dmytro.fedchyshyn on 06.09.2019.
 */

public without sharing class TravelSupportRemote {
    @AuraEnabled
    public static List<TravelVendorSettings__c> getVendors(String studySiteId) {
        try {
            TravelSupportHelper service = (TravelSupportHelper) ClassFactory.newInstance(TravelSupportHelper.class);
            return service.getVendors(studySiteId);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static String getInitData(){
        try{
            return JSON.serialize(ParticipantService.getInstance().getState());
        }catch (Exception e){
            return (String) AuraHelper.throwException(e);
        }
    }
}