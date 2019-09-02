/**
 * Created by dmytro.fedchyshyn on 28.08.2019.
 */

public without sharing class TravelSupportRemote {
//    private TravelSupportWrapper TravelSupportWrapper;


    @AuraEnabled
    public static List<TravelSupportDTO> getVendors() {
        List<TravelSupportDTO> wrappers = new List<TravelSupportDTO>();

        try {
            List<TravelVendor__c> vendors = [SELECT Id, Name, Link_Vendor__c, Disclosure__c FROM TravelVendor__c];
            for (TravelVendor__c travelVendor : vendors) {
                wrappers.add(new TravelSupportDTO(
                        travelVendor, travelVendor.Default_Country__c != null
                ));
            }
            return wrappers;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }


    public class TravelSupportDTO {

        @AuraEnabled
        public TravelVendor__c travelVendor;
        @AuraEnabled
        public Boolean isDefault;

        public TravelSupportWrapper(TravelVendor__c travelVendor, Boolean isDefault) {
            this.travelVendor = travelVendor;
            this.isDefault = isDefault;
        }

        public TravelSupportWrapper() {
        }
    }
}