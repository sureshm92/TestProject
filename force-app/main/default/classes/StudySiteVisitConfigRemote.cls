/**
 * Created by Igor Malyuta on 18.09.2019.
 */

public without sharing class StudySiteVisitConfigRemote {
    
    public static final String FEATURE_SS_VISIT_CONFIG = 'Visits_Configuration';
    
    public class InitData {
        @AuraEnabled public String viewMode = GetPermissions.getViewMode(FEATURE_SS_VISIT_CONFIG);
        @AuraEnabled public StudySiteFilter filter;
        @AuraEnabled public SSVisitConfigSearchResponse searchResponse;
    }
    
    @AuraEnabled
    public static InitData getInitData(Id ctpId) {
        try {
            InitData initData = new InitData();
            initData.filter = new StudySiteFilter(ctpId);
            initData.searchResponse = new SSVisitConfigSearchResponse(initData.filter, new PaginationData(15));
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
            if(ssItemsJSON != null) {
                List<StudySiteItem> studySiteItems =
                        (List<StudySiteItem>) JSON.deserialize(ssItemsJSON, List<StudySiteItem>.class);
                save(studySiteItems);
            }
            return new SSVisitConfigSearchResponse(filter, pagination);
        } catch (Exception e) {
            return (SSVisitConfigSearchResponse) AuraHelper.throwException(e);
        }
    }
    
    @AuraEnabled
    public static SSVisitConfigSearchResponse setVisitPlanForAll(String visitPlanId, Boolean state, String filterJSON, String paginationJSON) {
        try {
            StudySiteFilter filter = (StudySiteFilter) JSON.deserialize(filterJSON, StudySiteFilter.class);
            PaginationData pagination = (PaginationData) JSON.deserialize(paginationJSON, PaginationData.class);
            List<StudySiteItem> allSSItems = SSVisitConfigSearchResponse.convertToSSItems(getCtpStudySites(filter), visitPlanId);
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
            return new SSVisitConfigSearchResponse(filter, pagination);
        } catch (Exception e) {
            return (SSVisitConfigSearchResponse) AuraHelper.throwException(e);
        }
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

    public static List<Study_Site__c> getCtpStudySites(StudySiteFilter filter) {
        List<Study_Site__c> ctpStudySites = (List<Study_Site__c>) DatabaseService.query(
                filter.getFields(),
                filter.getSObjectType(),
                filter.getFilterString());
        return ctpStudySites;
    }
}