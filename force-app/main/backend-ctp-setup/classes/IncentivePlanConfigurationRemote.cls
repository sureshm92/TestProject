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
        @AuraEnabled public List<IncentivePlanConfigurationRemote.IPWrapper> listWrapper;
        @AuraEnabled public Clinical_Trial_Profile__c infoStudy;
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
            List<IncentivePlanConfigurationRemote.IPWrapper> wrap = getIPWrap();
            initData.listWrapper = wrap;
            Clinical_Trial_Profile__c study = getStudyInfo(ctpId);
            initData.infoStudy = study;
            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static List<IncentivePlanConfigurationRemote.IPWrapper> getIPWrap() {
        List<Incentive_Task_Catalog__mdt> listTasks = [SELECT Id, Title_Label__c, Description_Label__c, Default_Number_of_Points__c FROM Incentive_Task_Catalog__mdt];

        List<IncentivePlanConfigurationRemote.IPWrapper> wrapIP = new List<IncentivePlanConfigurationRemote.IPWrapper>();
        for (Incentive_Task_Catalog__mdt task : listTasks) {
            wrapIP.add(new IPWrapper(task.Title_Label__c, task.Description_Label__c, false, false, task.Default_Number_of_Points__c));

        }
        return wrapIP;
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
    /*@AuraEnabled
    public static List<Incentive_Task_Catalog__mdt> getIncentiveTasks() {
        return [SELECT Id, Title_Label__c, Description_Label__c, Default_Number_of_Points__c FROM Incentive_Task_Catalog__mdt];
    }*/

    @AuraEnabled
    public static Clinical_Trial_Profile__c getStudyInfo(String id) {
        return [SELECT Id, Name, Study_Code_Name__c, Protocol_ID__c, Study_Sponsor__c, OwnerId, Owner.Name, CreatedById, CreatedBy.Name, LastModifiedById, LastModifiedBy.Name FROM Clinical_Trial_Profile__c WHERE Id = :id];
    }

    @AuraEnabled
    public static String createIncentivePlan(String tasksString, String planName) {
        List<IncentivePlanConfigurationRemote.IPWrapper> tasks = (List<IncentivePlanConfigurationRemote.IPWrapper>) JSON.deserialize(tasksString, List<IncentivePlanConfigurationRemote.IPWrapper>.class);
        Incentive_Plan__c plan = new Incentive_Plan__c(Plan_Name__c = planName);
        insert plan;
        List<Incentive_Plan_Task__c> newTask = new List<Incentive_Plan_Task__c>();
        for (IncentivePlanConfigurationRemote.IPWrapper task : tasks) {
            newTask.add(new Incentive_Plan_Task__c(Incentive_Plan__c = plan.Id, Incentive_Task_Catalog__c = task.taskName, Points__c = task.points,
                    Enabled__c = task.checkOn, IQVIA_Supported__c = task.checkIQVIA));
        }
        insert newTask;
        return plan.Id;

    }

    @AuraEnabled
    public static Boolean checkNamePlan(String namePlan) {
        List<Incentive_Plan__c> result = [SELECT Id FROM Incentive_Plan__c WHERE Plan_Name__c = :namePlan];
        if (result.size() >= 1) {
            return true;
        } else {
            return false;
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
                } else if (assigment.sourceId == null && assigment.state) {
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

    private static void saveFilter(StudySiteFilter filter) {
        SettingStoreService.saveOrgDefault(STUDY_SITES_INCENTIVE_PLANS_SETUP_FILTER + filter.ctpId, filter, StudySiteFilter.class);
    }

    public class IPWrapper {
        @AuraEnabled public String taskName;
        @AuraEnabled public String taskDescription;
        @AuraEnabled public Boolean checkOn;
        @AuraEnabled public Boolean checkIQVIA;
        @AuraEnabled public Decimal points;

        public IPWrapper(String taskName, String taskDescription, Boolean checkOn, Boolean checkIQVIA, Decimal points) {
            this.taskName = taskName;
            this.taskDescription = taskDescription;
            this.checkOn = checkOn;
            this.checkIQVIA = checkIQVIA;
            this.points = points;
        }
        public IPWrapper() {

        }
    }

}