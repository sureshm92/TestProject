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
    public static SSVisitConfigSearchResponse getItems(String ssItemsJSON, String filterJSON, String paginationJSON) {
        try {
            StudySiteFilter filter = (StudySiteFilter) JSON.deserialize(filterJSON, StudySiteFilter.class);
            PaginationData pagination = (PaginationData) JSON.deserialize(paginationJSON, PaginationData.class);
            save(ssItemsJSON);
            saveFilter(filter);
            return new SSVisitConfigSearchResponse(filter, pagination);
        } catch (Exception e) {
            return (SSVisitConfigSearchResponse) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static SSVisitConfigSearchResponse setVisitPlanForAll(String visitPlanId, Boolean state, String filterJSON, String paginationJSON, String ssItemsJSON) {
        try {
            save(ssItemsJSON);
            StudySiteFilter filter = (StudySiteFilter) JSON.deserialize(filterJSON, StudySiteFilter.class);
            saveFilter(filter);
            PaginationData pagination = (PaginationData) JSON.deserialize(paginationJSON, PaginationData.class);
            List<StudySiteItem> allSSItems = SSVisitConfigSearchResponse.convertToSSItems(SearchService.search(filter), visitPlanId);
            for(StudySiteItem ssItem : allSSItems){
                for (ValueStateItem assigment : ssItem.assignments) assigment.state = state;
            }
            save(allSSItems);
            return new SSVisitConfigSearchResponse(filter, pagination);
        } catch (Exception e) {
            return (SSVisitConfigSearchResponse) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static SSVisitConfigSearchResponse deleteVisitPlan(String planId, String filterJSON, String paginationJSON) {
        try {
            delete new Visit_Plan__c(Id = planId);
            StudySiteFilter filter = (StudySiteFilter) JSON.deserialize(filterJSON, StudySiteFilter.class);
            PaginationData pagination = (PaginationData) JSON.deserialize(paginationJSON, PaginationData.class);
            saveFilter(filter);
            return new SSVisitConfigSearchResponse(filter, pagination);
        } catch (Exception e) {
            return (SSVisitConfigSearchResponse) AuraHelper.throwException(e);
        }
    }

    private static void save(String ssItemsJSON) {
        if(String.isEmpty(ssItemsJSON)) return;
        List<StudySiteItem> studySiteItems = (List<StudySiteItem>) JSON.deserialize(ssItemsJSON, List<StudySiteItem>.class);
        save(studySiteItems);
    }

    private static void save(List<StudySiteItem> studySiteItems) {
        List<StudySiteVisitPlan__c> toDelete = new List<StudySiteVisitPlan__c>();
        List<StudySiteVisitPlan__c> toInsert = new List<StudySiteVisitPlan__c>();
        for (StudySiteItem ssItem : studySiteItems) {
            for (ValueStateItem assigment : ssItem.assignments) {
                if (assigment.sourceId != null && !assigment.state) {
                    toDelete.add(new StudySiteVisitPlan__c(Id = assigment.sourceId));
                }else if(assigment.sourceId == null && assigment.state){
                    toInsert.add(new StudySiteVisitPlan__c(
                            Study_Site__c = ssItem.ss.Id,
                            Visit_Plan__c = assigment.value
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