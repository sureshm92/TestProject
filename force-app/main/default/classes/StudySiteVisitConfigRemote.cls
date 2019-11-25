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
            initData.searchResponse = new SSVisitConfigSearchResponse(initData.filter, null);
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
                List<ApprovedLangRemote.StudySiteItem> studySiteItems =
                        (List<ApprovedLangRemote.StudySiteItem>) JSON.deserialize(ssItemsJSON, List<ApprovedLangRemote.StudySiteItem>.class);
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
            List<ApprovedLangRemote.StudySiteItem> allSSItems = SSVisitConfigSearchResponse.convertToSSItems(ApprovedLangRemote.getCtpStudySites(filter), visitPlanId);
            for(ApprovedLangRemote.StudySiteItem ssItem : allSSItems){
                for (ApprovedLangRemote.ValueStateItem assigment : ssItem.assignments) assigment.state = state;
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
    
    
    private static void save(List<ApprovedLangRemote.StudySiteItem> studySiteItems) {
        List<StudySiteVisitPlan__c> toDelete = new List<StudySiteVisitPlan__c>();
        List<StudySiteVisitPlan__c> toInsert = new List<StudySiteVisitPlan__c>();
        for (ApprovedLangRemote.StudySiteItem ssItem : studySiteItems) {
            for (ApprovedLangRemote.ValueStateItem assigment : ssItem.assignments) {
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

}