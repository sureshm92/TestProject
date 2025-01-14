/**
 * Created by Nargiz Mamedova on 11/26/2019.
 */

public without sharing class SettingStoreService {
    public static Object get(String developerName, Id userId) {
        List<Setting_Store__c> settingStores = [
            SELECT Id, Developer_Name__c, User__c, Type__c, Body__c
            FROM Setting_Store__c
            WHERE User__c = :userId AND Developer_Name__c = :developerName
        ];

        if (settingStores.size() > 0) {
            Object value = JSON.deserialize(
                settingStores.get(0).Body__c,
                Type.forName(settingStores.get(0).Type__c)
            );
            return value;
        } else {
            return null;
        }
    }

    public static Object getOrgDefault(String developerName) {
        return get(developerName, null);
    }

    public static Object get(String developerName) {
        return get(developerName, UserInfo.getUserId());
    }

    public static void save(String developerName, Id userId, Object sourceObject, Type type) {
        List<Setting_Store__c> settingStores = [
            SELECT Id, Developer_Name__c, User__c, Type__c, Body__c
            FROM Setting_Store__c
            WHERE User__c = :userId AND Developer_Name__c = :developerName
        ];

        if (settingStores.isEmpty()) {
            Setting_Store__c settingStore = new Setting_Store__c(
                Developer_Name__c = developerName,
                Body__c = JSON.serialize(sourceObject),
                Type__c = type.getName(),
                User__c = userId
            );
            settingStores.add(settingStore);
        } else {
            settingStores.get(0).Body__c = JSON.serialize(sourceObject);
        }
        upsert settingStores;
    }

    public static void saveOrgDefault(String developerName, Object sourceObject, Type type) {
        save(developerName, null, sourceObject, type);
    }

    public static void save(String developerName, Object sourceObject, Type type) {
        save(developerName, UserInfo.getUserId(), sourceObject, type);
    }

    public static void deleteSettings(List<String> settingIds, Boolean orgDefault) {
        Id userId = orgDefault ? null : UserInfo.getUserId();
        List<Setting_Store__c> settings = [
            SELECT Id, Developer_Name__c, User__c, Type__c, Body__c
            FROM Setting_Store__c
            WHERE Developer_Name__c IN :settingIds AND User__c = :userId
        ];
        delete settings;
    }

    public static void deleteSettings(List<String> settingIds) {
        deleteSettings(settingIds, false);
    }

    public static void deleteSettingsOrgDefault(List<String> settingIds) {
        deleteSettings(settingIds, true);
    }

    public static void deleteSettingOrgDefault(String settingId) {
        deleteSettingsOrgDefault(new List<String>{ settingId });
    }

    //TODO REMOVE THIS:
    public static void deleteSettings(String featureName, List<Id> recordIds) {
        List<String> developerNames = new List<String>();
        for (Id id : recordIds) {
            developerNames.add(featureName + id);
        }
        List<Setting_Store__c> settingStores = [
            SELECT Id, Developer_Name__c, User__c, Type__c, Body__c
            FROM Setting_Store__c
            WHERE Developer_Name__c IN :developerNames
        ];
        delete settingStores;
    }
}
