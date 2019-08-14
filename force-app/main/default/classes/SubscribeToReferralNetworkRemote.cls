/**
 * Created by RAMukhamadeev on 2019-04-17.
 */

public without sharing class SubscribeToReferralNetworkRemote {

    public class ReferralNetworkWrapper {
        @AuraEnabled
        public String Name;

        @AuraEnabled
        public Id Id;

        @AuraEnabled
        public Boolean isSelected;
    }

    private static List<SObject> getCurrentReferralNetworks(SObjectType currType) {

        List<SObject> currReferralNetworks = new List<SObject>();
        if (currType == Referral_Network__c.getSObjectType()) {
            currReferralNetworks = [
                    SELECT Id, Name
                    FROM Referral_Network__c
                    WHERE Id IN (
                            SELECT ReferralNetworkId__c
                            FROM Contact_Referral_Network__c
                            WHERE ContactId__c = :CommunityService.getUserContact().Id
                    )
                    ORDER BY Name ASC
            ];
        } else if (currType == Therapeutic_Area__c.getSObjectType()) {
            currReferralNetworks = [
                    SELECT Id, Name
                    FROM Therapeutic_Area__c
                    WHERE Id IN (
                            SELECT TherapeuticAreaId__c
                            FROM Contact_Therapeutic_Area__c
                            WHERE ContactId__c = :CommunityService.getUserContact().Id
                    )
                    ORDER BY Name ASC
            ];
        }

        TranslateHelper.translate(currReferralNetworks);

        return currReferralNetworks;
    }

    @AuraEnabled
    public static List<ReferralNetworkWrapper> getReferralNetworkRecords(String sObjectType) {
        List<ReferralNetworkWrapper> result = new List<ReferralNetworkWrapper>();
        try {
            Schema.SObjectType currType = Schema.getGlobalDescribe().get(sObjectType);
            List<SObject> currReferralNetworks = getCurrentReferralNetworks(currType);
            result = getReferralNetworkWrappers(currReferralNetworks, null);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return result;
    }

    private static void deleteRecords(List<Id> recordIds) {
        try {
            if (recordIds != null && !recordIds.isEmpty()) {
                List<SObject> records = new List<SObject>();
                Id firstId = recordIds[0];
                if (firstId.getSobjectType() == Referral_Network__c.getSObjectType()) {
                    records = [
                            SELECT Id
                            FROM Contact_Referral_Network__c
                            WHERE ContactId__c = :CommunityService.getUserContact().Id
                            AND ReferralNetworkId__c IN :recordIds
                    ];
                } else if (firstId.getSobjectType() == Therapeutic_Area__c.getSObjectType()) {
                    records = [
                            SELECT Id
                            FROM Contact_Therapeutic_Area__c
                            WHERE ContactId__c = :CommunityService.getUserContact().Id
                            AND TherapeuticAreaId__c IN :recordIds
                    ];
                }
                Database.delete(records);
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static List<ReferralNetworkWrapper> searchForReferralNetworks(String term, String sObjectType) {
        List<ReferralNetworkWrapper> wrappers = new List<ReferralNetworkWrapper>();
        try {
            Schema.SObjectType currType = Schema.getGlobalDescribe().get(sObjectType);
            if (term == null) {
                term = '';
            }
            String searchTerm = '%' + String.escapeSingleQuotes(term.trim()) + '%';

            List<SObject> foundRecords = new List<SObject>();
            if (currType == Referral_Network__c.getSObjectType()) {
                foundRecords = [
                        SELECT Id, Name
                        FROM Referral_Network__c
                        WHERE Name LIKE :searchTerm
                        ORDER BY Name ASC
                ];
            } else if (currType == Therapeutic_Area__c.getSObjectType()) {
                TherapeuticAreaService taService = (TherapeuticAreaService) ClassFactory.newInstance(TherapeuticAreaService.class);
                foundRecords = taService.getTherapeuticAreas(searchTerm);/*[
                        SELECT Id, Name
                        FROM Therapeutic_Area__c
                        WHERE Name LIKE :searchTerm
                        ORDER BY Name ASC
                ];*/
            }
            TranslateHelper.translate(foundRecords);

            wrappers = getReferralNetworkWrappers(foundRecords, getCurrentReferralNetworks(currType));
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return wrappers;
    }

    @AuraEnabled
    public static void saveReferralNetworks(String referralNetworkJSON) {
        ReferralNetworkWrapper referralNetwork = (ReferralNetworkWrapper) JSON.deserializeStrict(referralNetworkJSON, ReferralNetworkWrapper.class);

        Id recordId = referralNetwork.Id;
        if (recordId.getSobjectType() == Referral_Network__c.getSObjectType()) {
            Contact_Referral_Network__c currReferralNetwork = new Contact_Referral_Network__c();
            currReferralNetwork.ContactId__c = CommunityService.getUserContact().Id;
            currReferralNetwork.ReferralNetworkId__c = referralNetwork.Id;

            if (referralNetwork.isSelected) {
                insert currReferralNetwork;
            } else {
                Contact_Referral_Network__c toDelete = [
                        SELECT Id
                        FROM Contact_Referral_Network__c
                        WHERE ContactId__c = :currReferralNetwork.ContactId__c
                        AND ReferralNetworkId__c = :currReferralNetwork.ReferralNetworkId__c
                ];
                delete toDelete;
            }
        } else if (recordId.getSobjectType() == Therapeutic_Area__c.getSObjectType()) {
            Contact_Therapeutic_Area__c currReferralNetwork = new Contact_Therapeutic_Area__c();
            currReferralNetwork.ContactId__c = CommunityService.getUserContact().Id;
            currReferralNetwork.TherapeuticAreaId__c = referralNetwork.Id;

            if (referralNetwork.isSelected) {
                insert currReferralNetwork;
            } else {
                Contact_Therapeutic_Area__c toDelete = [
                        SELECT Id
                        FROM Contact_Therapeutic_Area__c
                        WHERE ContactId__c = :currReferralNetwork.ContactId__c
                        AND TherapeuticAreaId__c = :currReferralNetwork.TherapeuticAreaId__c
                ];
                delete toDelete;
            }
        }
    }

    private static List<ReferralNetworkWrapper> getReferralNetworkWrappers(List<SObject> refNetworks, List<SObject> currentReferralNetworks) {
        Set<Id> currentRefIds = new Set<Id>();
        if (currentReferralNetworks != null) {
            for (SObject currNetwork : currentReferralNetworks) {
                currentRefIds.add(currNetwork.Id);
            }
        }

        List<ReferralNetworkWrapper> results = new List<ReferralNetworkWrapper>();
        for (SObject currSObject : refNetworks) {
            ReferralNetworkWrapper currRefNetwork = new ReferralNetworkWrapper();
            currRefNetwork.Id = (Id) currSObject.get('Id');
            currRefNetwork.Name = (String) currSObject.get('Name');
            currRefNetwork.isSelected = currentRefIds.contains(currRefNetwork.Id);

            results.add(currRefNetwork);
        }

        return results;
    }

    @AuraEnabled
    public static List<ReferralNetworkWrapper> deleteAndGetRefferalNetworks(String sObjectType, List<Id> recordIds) {
        deleteRecords(recordIds);
        return getReferralNetworkRecords(sObjectType);
    }
}