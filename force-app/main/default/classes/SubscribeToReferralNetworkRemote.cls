/**
 * Created by RAMukhamadeev on 2019-04-17.
 */

public with sharing class SubscribeToReferralNetworkRemote {

    public class ReferralNetworkWrapper {
        @AuraEnabled
        public String Name;

        @AuraEnabled
        public String Id;

        @AuraEnabled
        public Boolean isSelected;
    }

    @AuraEnabled
    public static List<ReferralNetworkWrapper> getReferralNetworkRecords() {
        List<ReferralNetworkWrapper> wrapper = new List<ReferralNetworkWrapper>();
        try {
            ReferralNetworkWrapper t1 = new ReferralNetworkWrapper();
            t1.Name = 'Test 1';
            t1.Id = '1234';
            wrapper.add(t1);

            ReferralNetworkWrapper t2 = new ReferralNetworkWrapper();
            t2.Name = 'Test 2';
            t2.Id = '1235';
            wrapper.add(t2);

            ReferralNetworkWrapper t3 = new ReferralNetworkWrapper();
            t3.Name = 'Test 3';
            t3.Id = '1236';
            wrapper.add(t3);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return wrapper;
    }

    @AuraEnabled
    public static void deleteRecords(List<Id> recordIds) {
        try {
            Database.delete(recordIds);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static List<ReferralNetworkWrapper> searchForReferralNetworks(String term) {
        List<Therapeutic_Area__c> foundTAs = new List<Therapeutic_Area__c>();
        try {
            if (String.isNotBlank(term)) {
                String searchTerm = '%' + String.escapeSingleQuotes(term) + '%';
                foundTAs = [
                        SELECT Id, Name
                        FROM Therapeutic_Area__c
                        WHERE Name LIKE :searchTerm
                ];
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return getReferralNetworkWrappers(foundTAs);
    }

    private static List<ReferralNetworkWrapper> getReferralNetworkWrappers(List<SObject> refNetworks) {
        List<ReferralNetworkWrapper> results = new List<ReferralNetworkWrapper>();
        for (SObject currSObject : refNetworks) {
            ReferralNetworkWrapper currRefNetwork = new ReferralNetworkWrapper();
            currRefNetwork.Id = (Id) currSObject.get('Id');
            currRefNetwork.Name = (String) currSObject.get('Name');
            results.add(currRefNetwork);
        }

        return results;
    }
}