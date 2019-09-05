/**
 * Created by dmytro.fedchyshyn on 02.09.2019.
 */

public with sharing class TravelSupportService {

    public List<TravelVendor__c> getVendors(Id ) {
        try {
            String vendorsQuery = 'SELECT ' +
                    'Id, ' +
                    'TravelVendor__c, ' +
                    'TravelVendor__r.Name, ' +
                    'TravelVendor__r.Link_Vendor__c, ' +
                    'TravelVendor__r.Disclosure__c, ' +
                    'FROM TravelVendorSettings__c '+
                    'WHERE Study_Site__c '+
            ;
            return ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class)).query(vendorsQuery, true);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }
}