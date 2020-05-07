/**
 * Created by Alexey Moseev on 5/7/20.
 */

public without sharing class IncentivePlanConfigurationRemote {

    public static final String FEATURE_SS_INCENTIVE_CONFIG = 'Incentive_Program';
    public static final String STUDY_SITES_INCENTIVE_PLANS_SETUP_FILTER = 'StudySitesIncentivePlansSetupFilter';

    public class InitData {
        @AuraEnabled public String viewMode = GetPermissions.getViewMode(FEATURE_SS_INCENTIVE_CONFIG);
        @AuraEnabled public StudySiteFilter filter;
        @AuraEnabled public SSIncentiveConfigSearchResponse searchResponse;
    }

    @AuraEnabled
    public static InitData getInitData(Id ctpId) {
        try {
            InitData initData = new InitData();
            StudySiteFilter filter = (StudySiteFilter) SettingStoreService.getOrgDefault(STUDY_SITES_INCENTIVE_PLANS_SETUP_FILTER + ctpId);
            if (filter == null) {
                filter = new StudySiteFilter(ctpId);
            }
            initData.filter = filter;
            initData.searchResponse = new SSIncentiveConfigSearchResponse(initData.filter, new PaginationData(15));
            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static SSIncentiveConfigSearchResponse getItems(String ssItemsJSON, String filterJSON, String paginationJSON) {
        try {
            StudySiteFilter filter = (StudySiteFilter) JSON.deserialize(filterJSON, StudySiteFilter.class);
            PaginationData pagination = (PaginationData) JSON.deserialize(paginationJSON, PaginationData.class);
            save(ssItemsJSON);
            saveFilter(filter);
            return new SSIncentiveConfigSearchResponse(filter, pagination);
        } catch (Exception e) {
            return (SSIncentiveConfigSearchResponse) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static SSIncentiveConfigSearchResponse setIncentivePlanForAll(String visitPlanId, Boolean state, String filterJSON, String paginationJSON, String ssItemsJSON) {
        try {
            save(ssItemsJSON);
            StudySiteFilter filter = (StudySiteFilter) JSON.deserialize(filterJSON, StudySiteFilter.class);
            saveFilter(filter);
            PaginationData pagination = (PaginationData) JSON.deserialize(paginationJSON, PaginationData.class);
            List<StudySiteItem> allSSItems = SSVisitConfigSearchResponse.convertToSSItems(SearchService.search(filter), visitPlanId);
            for (StudySiteItem ssItem : allSSItems) {
                for (ValueStateItem assigment : ssItem.assignments) assigment.state = state;
            }
            save(allSSItems);
            return new SSIncentiveConfigSearchResponse(filter, pagination);
        } catch (Exception e) {
            return (SSIncentiveConfigSearchResponse) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static SSIncentiveConfigSearchResponse deleteIncentivePlan(String planId, String filterJSON, String paginationJSON) {
        try {
            delete new Incentive_Plan__c(Id = planId);
            StudySiteFilter filter = (StudySiteFilter) JSON.deserialize(filterJSON, StudySiteFilter.class);
            PaginationData pagination = (PaginationData) JSON.deserialize(paginationJSON, PaginationData.class);
            saveFilter(filter);
            return new SSIncentiveConfigSearchResponse(filter, pagination);
        } catch (Exception e) {
            return (SSIncentiveConfigSearchResponse) AuraHelper.throwException(e);
        }
    }

    private static void save(String ssItemsJSON) {
        if (String.isEmpty(ssItemsJSON)) return;
        List<StudySiteItem> studySiteItems = (List<StudySiteItem>) JSON.deserialize(ssItemsJSON, List<StudySiteItem>.class);
        save(studySiteItems);
    }

    private static void save(List<StudySiteItem> studySiteItems) {
        List<Study_Incentive_Plan__c> toDelete = new List<Study_Incentive_Plan__c>();
        List<Study_Incentive_Plan__c> toInsert = new List<Study_Incentive_Plan__c>();
        for (StudySiteItem ssItem : studySiteItems) {
            for (ValueStateItem assigment : ssItem.assignments) {
                if (assigment.sourceId != null && !assigment.state) {
                    toDelete.add(new Study_Incentive_Plan__c(Id = assigment.sourceId));
                } else if (assigment.sourceId == null && assigment.state){
                    toInsert.add(new Study_Incentive_Plan__c(
                            Study_Site__c = ssItem.ss.Id,
                            Incentive_Plan__c = assigment.value
                    ));
                }
            }
        }
        delete toDelete;
        insert toInsert;
    }

    private static void saveFilter(StudySiteFilter filter){
        SettingStoreService.saveOrgDefault(STUDY_SITES_INCENTIVE_PLANS_SETUP_FILTER + filter.ctpId, filter, StudySiteFilter.class);
    }

}