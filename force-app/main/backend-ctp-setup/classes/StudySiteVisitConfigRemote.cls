/**
 * Created by Igor Malyuta on 18.09.2019.
 */

public without sharing class StudySiteVisitConfigRemote {
    public static final String FEATURE_SS_VISIT_CONFIG = 'Visits_Configuration';
    public static final String STUDY_SITES_VISITS_SETUP_FILTER = 'StudySitesVisitsSetupFilter';

    public class InitData {
        @AuraEnabled
        public String viewMode = GetPermissions.getViewMode(FEATURE_SS_VISIT_CONFIG);
        @AuraEnabled
        public StudySiteFilter filter;
        @AuraEnabled
        public SSVisitConfigSearchResponse searchResponse;
        @AuraEnabled
        public Map<String, String> studySiteVisitPlan;
    }

    @AuraEnabled
    public static InitData getInitData(Id ctpId) {
        try {
            InitData initData = new InitData();
            StudySiteFilter filter = (StudySiteFilter) SettingStoreService.getOrgDefault(
                STUDY_SITES_VISITS_SETUP_FILTER + ctpId
            );
            if (filter == null)
                filter = new StudySiteFilter(ctpId);
            initData.filter = filter;
            initData.searchResponse = new SSVisitConfigSearchResponse(
                initData.filter,
                new PaginationData(15)
            );
            initData.studySiteVisitPlan = new Map<String, String>();
            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static CountAndLimit totalPEs(Id ctpId, String filterJSON) {
        List<Id> ssIds = new List<Id>();
        Integer count = 0;
        Boolean limitReached = false;
        StudySiteFilter filter = (StudySiteFilter) JSON.deserialize(
            filterJSON,
            StudySiteFilter.class
        );
        List<Study_Site__c> ssList = SearchService.search(filter);
        for (Study_Site__c ss : ssList) {
            ssIds.add(ss.Id);
        }
        Integer limitRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
        Boolean isProgram = false;
        if(ctpId!=null){
            List<Clinical_Trial_Profile__c> ctpList = [SELECT Id,Is_Program__c FROM Clinical_Trial_Profile__c WHERE id=:ctpId];
            if(ctpList.size()>0){
                isProgram =  ctpList[0].Is_Program__c;
            }
        }
        if (ssIds != null && !ssIds.isEmpty() && ctpId != null) {
            List<Participant_Enrollment__c> totalParticipants = new List<Participant_Enrollment__c>();
            totalParticipants = [
                SELECT Id
                FROM Participant_Enrollment__c
                WHERE
                    Clinical_Trial_Profile__c = :ctpId
                    AND Study_Site__c IN :ssIds
                    AND Participant_Status__c IN :PEStatusState.PE_STATUS_GROUP_POST_ENROLLMENT_VISIT_RELATED
                    AND Visit_Plan__c = NULL
                LIMIT :limitRows
            ];
            if (totalParticipants.size() > 0) {
                count = totalParticipants.size();
                if (limitRows == count) {
                    limitReached = true;
                }
            }
        }
        CountAndLimit cl = new CountAndLimit();
        cl.count = count;
        cl.limitReached = limitReached;
        cl.isProgram = isProgram;
        return cl;
    }
    @TestVisible
    class CountAndLimit {
        @AuraEnabled
        public Integer count;
        @AuraEnabled
        public Boolean limitReached;
        @AuraEnabled
        public Boolean isProgram;
    }

    @AuraEnabled
    public static SSVisitConfigSearchResponse getItems(
        String ssItemsJSON,
        String filterJSON,
        String paginationJSON,
        String studySiteVisitPlanJSON,
        Id ctpId
    ) {
        try {
            StudySiteFilter filter = (StudySiteFilter) JSON.deserialize(
                filterJSON,
                StudySiteFilter.class
            );
            PaginationData pagination = (PaginationData) JSON.deserialize(
                paginationJSON,
                PaginationData.class
            );
            save(ssItemsJSON);
            saveFilter(filter);
            Map<String, Object> studySiteVisitPlan = new Map<String, Object>();
            if (!String.isEmpty(studySiteVisitPlanJSON) && studySiteVisitPlanJSON != '{}') {
                studySiteVisitPlan = (Map<String, Object>) JSON.deserializeUntyped(
                    studySiteVisitPlanJSON
                );
            }
            updatePEsAndStartBatch(studySiteVisitPlan, ctpId);
            return new SSVisitConfigSearchResponse(filter, pagination);
        } catch (Exception e) {
            return (SSVisitConfigSearchResponse) AuraHelper.throwException(e);
        }
    }
    @TestVisible
    private static void updatePEsAndStartBatch(Map<String, Object> studySiteVisitPlan, Id ctpId) {
        if (studySiteVisitPlan != null && !studySiteVisitPlan.isEmpty() && ctpId != null) {
            List<Study_Site__c> ssList = new List<Study_Site__c>();
            for (String ssId : studySiteVisitPlan.keySet()) {
                Study_Site__c ss = new Study_Site__c();
                ss.Id = Id.valueOf(ssId);
                ss.Is_Patient_Visit_Batch_Running__c = true;
                ssList.add(ss);
            }
            if (!ssList.isEmpty()) {
                update ssList;
                Database.executeBatch(
                    new Batch_UpdateVisitPlanCreatePatientVisits(studySiteVisitPlan, ctpId),
                    400
                );
            }
        }
    }

    @TestVisible
    private static void updatePEsAndStartBatch(Id visitPlanId, List<Id> ssIds, Id ctpId) {
        if (visitPlanId != null && ctpId != null) {
            Map<String, Object> studySiteVisitPlan = new Map<String, Object>();
            List<Study_Site__c> ssList = [
                SELECT Id, Is_Patient_Visit_Batch_Running__c
                FROM Study_Site__c
                WHERE
                    Clinical_Trial_Profile__c = :ctpId
                    AND Is_Patient_Visit_Batch_Running__c = FALSE
                    AND Id IN :ssIds
            ];
            for (Study_Site__c ss : ssList) {
                ss.Is_Patient_Visit_Batch_Running__c = true;
                studySiteVisitPlan.put(ss.Id, visitPlanId);
            }
            if (!ssList.isEmpty()) {
                update ssList;
                Database.executeBatch(
                    new Batch_UpdateVisitPlanCreatePatientVisits(studySiteVisitPlan, ctpId),
                    400
                );
            }
        }
    }

    @AuraEnabled
    public static SSVisitConfigSearchResponse setVisitPlanForAll(
        String visitPlanId,
        Boolean state,
        String filterJSON,
        String paginationJSON,
        String ssItemsJSON,
        String studySiteVisitPlanJSON,
        String ctpId,
        List<Id> ssIdsWithoutChangetoVisitPlan,
        Boolean runBatch
    ) {
        try {
            save(ssItemsJSON);
            StudySiteFilter filter = (StudySiteFilter) JSON.deserialize(
                filterJSON,
                StudySiteFilter.class
            );
            saveFilter(filter);
            PaginationData pagination = (PaginationData) JSON.deserialize(
                paginationJSON,
                PaginationData.class
            );
            List<StudySiteItem> allSSItems = SSVisitConfigSearchResponse.convertToSSItems(
                SearchService.search(filter),
                visitPlanId
            );
            List<Id> ssId1 = new List<Id>();
            List<Id> ssId2 = new List<Id>();
            List<Id> ssIds = new List<Id>();
            for (StudySiteItem ssItem : allSSItems) {
                ssIds.add(ssItem.ss.Id);
                for (ValueStateItem assigment : ssItem.assignments) {
                    ssId1.add(ssItem.ss.Id);
                    if (
                        ssIdsWithoutChangetoVisitPlan == null ||
                        ssIdsWithoutChangetoVisitPlan.isEmpty() ||
                        !ssIdsWithoutChangetoVisitPlan.contains(ssItem.ss.Id)
                    ) {
                        assigment.state = state;
                        ssId2.add(ssItem.ss.Id);
                    }
                }
            }
            save(allSSItems);
            Map<String, Object> studySiteVisitPlan = new Map<String, Object>();
            if (!String.isEmpty(studySiteVisitPlanJSON) && studySiteVisitPlanJSON != '{}') {
                studySiteVisitPlan = (Map<String, Object>) JSON.deserializeUntyped(
                    studySiteVisitPlanJSON
                );
            }
            if (state && runBatch) {
                updatePEsAndStartBatch(visitPlanId, ssIds, ctpId);
            }
            return new SSVisitConfigSearchResponse(filter, pagination);
        } catch (Exception e) {
            return (SSVisitConfigSearchResponse) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static List<Id> getLatestBatchStatusForStudySites(
        List<Id> ssIdsWithoutChangetoVisitPlan
    ) {
        List<Id> result = new List<Id>();
        result.addAll(
            new Map<Id, Study_Site__c>(
                    [
                        SELECT Id
                        FROM Study_Site__c
                        WHERE
                            Is_Patient_Visit_Batch_Running__c = TRUE
                            AND Id IN :ssIdsWithoutChangetoVisitPlan
                    ]
                )
                .keySet()
        );
        return result;
    }

    @AuraEnabled
    public static List<Id> getLatestBatchStatusForStudy(Id ctpId, String filterJSON) {
        List<Id> result = new List<Id>();
        StudySiteFilter filter = (StudySiteFilter) JSON.deserialize(
            filterJSON,
            StudySiteFilter.class
        );
        List<Study_Site__c> ssList = SearchService.search(filter);
        for (Study_Site__c ss : ssList) {
            if (ss.Is_Patient_Visit_Batch_Running__c == true) {
                result.add(ss.Id);
            }
        }
        return result;
    }

    @AuraEnabled
    public static SSVisitConfigSearchResponse deleteVisitPlan(
        String planId,
        String filterJSON,
        String paginationJSON
    ) {
        try {
            delete new Visit_Plan__c(Id = planId);
            StudySiteFilter filter = (StudySiteFilter) JSON.deserialize(
                filterJSON,
                StudySiteFilter.class
            );
            PaginationData pagination = (PaginationData) JSON.deserialize(
                paginationJSON,
                PaginationData.class
            );
            saveFilter(filter);
            return new SSVisitConfigSearchResponse(filter, pagination);
        } catch (Exception e) {
            return (SSVisitConfigSearchResponse) AuraHelper.throwException(e);
        }
    }

    private static void save(String ssItemsJSON) {
        if (String.isEmpty(ssItemsJSON))
            return;
        List<StudySiteItem> studySiteItems = (List<StudySiteItem>) JSON.deserialize(
            ssItemsJSON,
            List<StudySiteItem>.class
        );
        save(studySiteItems);
    }

    private static void save(List<StudySiteItem> studySiteItems) {
        List<StudySiteVisitPlan__c> toDelete = new List<StudySiteVisitPlan__c>();
        List<StudySiteVisitPlan__c> toInsert = new List<StudySiteVisitPlan__c>();
        for (StudySiteItem ssItem : studySiteItems) {
            for (ValueStateItem assigment : ssItem.assignments) {
                if (assigment.sourceId != null && !assigment.state) {
                    toDelete.add(new StudySiteVisitPlan__c(Id = assigment.sourceId));
                } else if (assigment.sourceId == null && assigment.state) {
                    toInsert.add(
                        new StudySiteVisitPlan__c(
                            Study_Site__c = ssItem.ss.Id,
                            Visit_Plan__c = assigment.value
                        )
                    );
                }
            }
        }
        delete toDelete;
        insert toInsert;
    }

    private static void saveFilter(StudySiteFilter filter) {
        SettingStoreService.saveOrgDefault(
            STUDY_SITES_VISITS_SETUP_FILTER + filter.ctpId,
            filter,
            StudySiteFilter.class
        );
    }
}
