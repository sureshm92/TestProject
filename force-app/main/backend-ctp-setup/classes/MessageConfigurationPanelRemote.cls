/**
 * Created by Nargiz Mamedova on 1/15/2020.
 */

public with sharing class MessageConfigurationPanelRemote {

    public static final String FEATURE_MESSAGE_CONFIGURATION = 'Message_Configuration';
    public static final String MESSAGE_CONFIGURATION_SETUP_FILTER = 'MessageConfigurationSetupFilter';

    public class InitData {
        @AuraEnabled public String viewMode = GetPermissions.getViewMode(FEATURE_MESSAGE_CONFIGURATION);
        @AuraEnabled public StudySiteFilter filter;
        @AuraEnabled public SSMessageConfigResponse searchResponse;
    }

    @AuraEnabled
    public static InitData getInitData(Id ctpId) {
        try {
            InitData initData = new InitData();
            StudySiteFilter filter = (StudySiteFilter) SettingStoreService.getOrgDefault(MESSAGE_CONFIGURATION_SETUP_FILTER + ctpId);
            if(filter == null) filter = new StudySiteFilter(ctpId);
            initData.filter = filter;
            initData.searchResponse = new SSMessageConfigResponse(initData.filter, new PaginationData(15));
            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static SSMessageConfigResponse getItems(String ssItemsJSON, String filterJSON, String paginationJSON) {
        try {
            StudySiteFilter filter = (StudySiteFilter) JSON.deserialize(filterJSON, StudySiteFilter.class);
            PaginationData pagination = (PaginationData) JSON.deserialize(paginationJSON, PaginationData.class);
            save(ssItemsJSON);
            saveFilter(filter);
            return new SSMessageConfigResponse(filter, pagination);
        } catch (Exception e) {
            return (SSMessageConfigResponse) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static SSMessageConfigResponse selectAllInColumn(Boolean state, String filterJSON, String paginationJSON,
            String ssItemsJSON, String feature) {
        try {
            save(ssItemsJSON);
            StudySiteFilter filter = (StudySiteFilter) JSON.deserialize(filterJSON, StudySiteFilter.class);
            saveFilter(filter);
            PaginationData pagination = (PaginationData) JSON.deserialize(paginationJSON, PaginationData.class);
            List<StudySiteItem> allSSItems = SSMessageConfigResponse.convertToSSItems(SearchService.search(filter), feature);
            for(StudySiteItem ssItem : allSSItems){
                for (ValueStateItem assigment : ssItem.assignments) assigment.state = state;
            }
            save(allSSItems);
            return new SSMessageConfigResponse(filter, pagination);
        } catch (Exception e) {
            return (SSMessageConfigResponse) AuraHelper.throwException(e);
        }
    }

    private static void save(String ssItemsJSON) {
        if(String.isEmpty(ssItemsJSON)) return;
        List<StudySiteItem> studySiteItems = (List<StudySiteItem>) JSON.deserialize(ssItemsJSON, List<StudySiteItem>.class);
        save(studySiteItems);
    }

    private static void save(List<StudySiteItem> studySiteItems) {
        Map<Id, StudySiteItem> ssItemsByIds = new Map<Id, StudySiteItem>();
        for (StudySiteItem ssItem : studySiteItems) {
            ssItemsByIds.put(ssItem.ss.Id, ssItem);
        }
        List<Study_Site__c> toUpdate = [
                SELECT Id, SMS_Are_Available__c, Messages_Are_Available__c
                FROM Study_Site__c
                WHERE Id IN: ssItemsByIds.keySet()
        ];
        for (Study_Site__c ss : toUpdate) {
            for (ValueStateItem assigment : ssItemsByIds.get(ss.Id).assignments) {
                if(assigment.value == SSMessageConfigResponse.TYPE_SMS) ss.SMS_Are_Available__c = assigment.state;
                if(assigment.value == SSMessageConfigResponse.TYPE_MESSAGE) ss.Messages_Are_Available__c = assigment.state;
            }
        }
        update toUpdate;
    }

    private static void saveFilter( StudySiteFilter filter){
        SettingStoreService.saveOrgDefault(MESSAGE_CONFIGURATION_SETUP_FILTER + filter.ctpId, filter, StudySiteFilter.class);
    }
}