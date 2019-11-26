/**
 * Created by dmytro.fedchyshyn on 06.09.2019.
 */

public without sharing class TravelSupportRemote {
    @AuraEnabled
    public static List<TravelVendor__c> getVendors(String studySiteId) {
        try {
            String filter = 'Study_Site__c =  \'' + studySiteId + '\' AND isEnable__c = TRUE';
            List<TravelVendorSettings__c> vendorSettings =
                    (List<TravelVendorSettings__c>) DatabaseService.query(new List<String>{
                            'TravelVendor__c',
                            'TravelVendor__r.Name',
                            'TravelVendor__r.Link_Vendor__c',
                            'TravelVendor__r.Disclosure__c'
                    }, TravelVendorSettings__c.getSObjectType(), filter);

            Set<TravelVendor__c> vendorsUniq = new Set<TravelVendor__c>();
            for (TravelVendorSettings__c vendorSetting : vendorSettings) vendorsUniq.add(vendorSetting.TravelVendor__r);

            List<TravelVendor__c> vendors = new List<TravelVendor__c>();
            if(!vendorsUniq.isEmpty()) vendors.addAll(vendorsUniq);

            return vendors;
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