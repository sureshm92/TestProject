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
            List<StudySiteItem> allSSItems = SSIncentiveConfigSearchResponse.convertToSSItems(SearchService.search(filter), visitPlanId);
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
    @AuraEnabled
    public static List<Incentive_Task_Catalog__mdt> getIncentiveTasks() {
        return [SELECT Id, Title_Label__c, Description_Label__c, Default_Number_of_Points__c FROM Incentive_Task_Catalog__mdt];
    }

    @AuraEnabled
    public static Clinical_Trial_Profile__c getStudyInfo(String id) {
        return [SELECT Id, Name, Study_Code_Name__c, Protocol_ID__c, Study_Sponsor__c, OwnerId, Owner.Name, CreatedById, CreatedBy.Name, LastModifiedById, LastModifiedBy.Name FROM Clinical_Trial_Profile__c WHERE Id =: id];
    }

    @AuraEnabled
    public static String createIncentivePlan(Incentive_Task_Catalog__mdt task, Boolean checkON, Boolean checkIQVIA, String planName) {
        Incentive_Plan__c plan = new Incentive_Plan__c(Plan_Name__c = planName);
        insert plan;
        Incentive_Plan_Task__c newTask = new Incentive_Plan_Task__c(Incentive_Plan__c = plan.Id,
                                                                 Incentive_Task_Catalog__c = task.Title_Label__c,
                                                                 Points__c = task.Default_Number_of_Points__c,
                                                                 Enabled__c = checkON, IQVIA_Supported__c = checkIQVIA);
        insert newTask;
        return plan.Id;

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