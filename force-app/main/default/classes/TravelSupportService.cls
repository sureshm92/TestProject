/**
 * Created by dmytro.fedchyshyn on 02.09.2019.
 */

public with sharing class TravelSupportService {

    public List<TravelVendor__c> getVendors() {
        try {
            String vendorsQuery = 'SELECT ' +
                    'Name, ' +
                    'Id, ' +
                    'Link_Vendor__c, ' +
                    'Disclosure__c ' +
                    'FROM TravelVendor__c ';
            return ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class)).query(vendorsQuery, true);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }
}