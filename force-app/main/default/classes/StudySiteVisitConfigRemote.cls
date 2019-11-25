/**
 * Created by Igor Malyuta on 18.09.2019.
 */

public without sharing class StudySiteVisitConfigRemote {

    public static final String FEATURE_SS_VISIT_CONFIG = 'Visits_Configuration';

    public class InitData {
        @AuraEnabled public StudySiteFilter.StudySiteSearchWrapper searchWrapper;
        @AuraEnabled public List<LabelValueItem> visitPlans;
        @AuraEnabled public List<StudySiteItem> studySiteItems;
        @AuraEnabled public String viewMode;

        public InitData() {
            searchWrapper = new StudySiteFilter.StudySiteSearchWrapper(new StudySiteFilter(), new PaginationData());
            visitPlans = getVisitPlansLV();
        }
    }

    @AuraEnabled
    public static InitData getInitData(Id ctpId) {
        try {
            InitData initData = new InitData();
            initData.searchWrapper.filter.ctpId = ctpId;
            init(initData);
            initData.viewMode = GetPermissions.getViewMode(FEATURE_SS_VISIT_CONFIG);
            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static InitData getNextData(String data) {
        try {
            InitData initData = save(data);
            initPageItems(initData);
            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static InitData getFilteredItems(String data) {
        try {
            InitData initData = (InitData) JSON.deserialize(data, InitData.class);
            List<String> visitPlansIds = StudySiteFilter.getListByString(initData.searchWrapper.filter.pageFeatureIds);

            initData.visitPlans = new List<LabelValueItem>();
            for (LabelValueItem vp : getVisitPlansLV()) {
                if (visitPlansIds.isEmpty() || (!visitPlansIds.isEmpty() && visitPlansIds.contains(vp.value))) {
                    initData.visitPlans.add(vp);
                }
            }

            List<Study_Site__c> studySites =
                    (List<Study_Site__c>) SearchService.search(initData.searchWrapper.filter, initData.searchWrapper.pagination);
            initData.studySiteItems = getStudySiteItems(studySites, visitPlansIds);

            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static InitData getSortedItems(String data) {
        try {
            InitData initData = (InitData) JSON.deserialize(data, InitData.class);

            String selectedSSIds = '';
            if(!String.isEmpty(initData.searchWrapper.filter.selectedSSIds)) {
                selectedSSIds = initData.searchWrapper.filter.selectedSSIds;
            }

            //For sorting only for current page items
            String pageSSIds = '';
            for (StudySiteItem item : initData.studySiteItems) pageSSIds += item.ss.Id + ';';

            initData.searchWrapper.filter.selectedSSIds = pageSSIds.removeEnd(';');
            List<Study_Site__c> studySites =
                    (List<Study_Site__c>) SearchService.search(initData.searchWrapper.filter, initData.searchWrapper.pagination);
            initData.studySiteItems =
                    getStudySiteItems(studySites, StudySiteFilter.getListByString(initData.searchWrapper.filter.pageFeatureIds));

            initData.searchWrapper.filter.selectedSSIds = selectedSSIds;
            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void setVisitPlanForAll(String data, String visitPlanId, Boolean state) {
        try {
            InitData initData = (InitData) JSON.deserialize(data, InitData.class);
            List<Study_Site__c> ctpStudySites = ApprovedLangRemote.getCtpStudySites(initData.searchWrapper.filter);

            List<Id> ssIds = new List<Id>();
            for (Study_Site__c ss : ctpStudySites) ssIds.add(ss.Id);

            if (state) {
                Map<Id, Map<Id, StudySiteVisitPlan__c>> ssVPsByStudySiteIds = getStudySiteVisitPlansMap(ssIds);
                List<StudySiteVisitPlan__c> studySiteVisitPlans = new List<StudySiteVisitPlan__c>();
                for (Id ssId : ssIds) {
                    Map<Id, StudySiteVisitPlan__c> ssVPByIds = ssVPsByStudySiteIds.get(ssId);
                    if (ssVPByIds != null && ssVPByIds.containsKey(visitPlanId)) continue;

                    studySiteVisitPlans.add(new StudySiteVisitPlan__c(
                            Study_Site__c = ssId,
                            Visit_Plan__c = visitPlanId
                    ));
                }

                if (!studySiteVisitPlans.isEmpty()) insert studySiteVisitPlans;
            } else {
                delete [SELECT Id FROM StudySiteVisitPlan__c WHERE Visit_Plan__c = :visitPlanId AND Study_Site__c IN:ssIds];
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static InitData save(String data) {
        try {
            InitData initData = (InitData) JSON.deserialize(data, InitData.class);

            List<Id> ctpStudySiteIds = new List<Id>();
            for (Study_Site__c ss : ApprovedLangRemote.getCtpStudySites(initData.searchWrapper.filter)) ctpStudySiteIds.add(ss.Id);

            List<StudySiteVisitPlan__c> deselectedSSVPs = new List<StudySiteVisitPlan__c>();
            List<StudySiteVisitPlan__c> newSSVPs = new List<StudySiteVisitPlan__c>();

            Map<Id, Map<Id, StudySiteVisitPlan__c>> ssVisitPlansByIds = getStudySiteVisitPlansMap(ctpStudySiteIds);
            for (StudySiteItem item : initData.studySiteItems) {
                Map<Id, StudySiteVisitPlan__c> siteVisitPlans = ssVisitPlansByIds.get(item.ss.Id) != null
                        ? ssVisitPlansByIds.get(item.ss.Id) : new Map<Id, StudySiteVisitPlan__c>();
                for (ValueStateItem assigment : item.assignments) {
                    if (assigment.state && !siteVisitPlans.containsKey(assigment.value)) {
                        newSSVPs.add(new StudySiteVisitPlan__c(
                                Study_Site__c = item.ss.Id,
                                Visit_Plan__c = assigment.value
                        ));
                    } else if (!assigment.state && siteVisitPlans.containsKey(assigment.value)) {
                        deselectedSSVPs.add(siteVisitPlans.get(assigment.value));
                    }
                }
            }

            if (!deselectedSSVPs.isEmpty()) delete deselectedSSVPs;
            if (!newSSVPs.isEmpty()) insert newSSVPs;

            initData.searchWrapper.haveEmptyAssigment =
                    getStudySiteVisitPlansMap(ctpStudySiteIds).keySet().size() != ctpStudySiteIds.size();
            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static InitData deleteVisitPlan(String data, String planId) {
        try {
            delete VisitPlanRemote.getVisitPlan(planId);

            return init((InitData) JSON.deserialize(data, InitData.class));
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    //Inner logic: -----------------------------------------------------------------------------------------------------
    private static InitData init(InitData initData) {
        List<Study_Site__c> ctpStudySites = SearchService.search(initData.searchWrapper.filter, initData.searchWrapper.pagination);
        if (!ctpStudySites.isEmpty()) {
            loadInitData(initData.searchWrapper, ctpStudySites);
            initPageItems(initData);
        }

        return initData;
    }

    private static void loadInitData(StudySiteFilter.StudySiteSearchWrapper searchWrapper, List<Study_Site__c> ctpStudySites) {
        List<Id> ssIds = new List<Id>();
        for (Study_Site__c ss : ctpStudySites) {
            if (ss.Site__r.BillingCountryCode != null && !searchWrapper.filter.countryCodes.contains(ss.Site__r.BillingCountryCode)) {
                searchWrapper.filter.countryCodes += ss.Site__r.BillingCountryCode + ';';
            }
            ssIds.add(ss.Id);
        }

        searchWrapper.haveEmptyAssigment = getStudySiteVisitPlansMap(ssIds).keySet().size() != ssIds.size();
        searchWrapper.filter.countryCodes = searchWrapper.filter.countryCodes.removeEnd(';');
    }

    private static void initPageItems(InitData initData) {
        initData.studySiteItems = getStudySiteItems(
                (List<Study_Site__c>) SearchService.search(initData.searchWrapper.filter, initData.searchWrapper.pagination),
                StudySiteFilter.getListByString(initData.searchWrapper.filter.pageFeatureIds)
        );
    }

    private static List<StudySiteItem> getStudySiteItems(List<Study_Site__c> studySites, List<String> selectedVPIds) {
        List<Id> ssIds = new List<Id>();
        for (Study_Site__c ss : studySites) ssIds.add(ss.Id);
        Map<Id, Map<Id, StudySiteVisitPlan__c>> ssVisitPlansBySSId = getStudySiteVisitPlansMap(ssIds);

        Map<Id, Visit_Plan__c> visitPlans = getVisitPlansMap();
        List<StudySiteItem> studySiteItems = new List<StudySiteItem>();
        for (Study_Site__c ss : studySites) {
            String countryName = ss.Site__r.BillingCountry;
            String countryCode = ss.Site__r.BillingCountryCode;
            StudySiteItem item =
                    new StudySiteItem(new LabelValueItem(countryName, countryCode), ss.Name, ss);

            List<StudySiteVisitPlan__c> studySiteVisitPlans = ssVisitPlansBySSId.containsKey(ss.Id)
                    ? ssVisitPlansBySSId.get(ss.Id).values() : new List<StudySiteVisitPlan__c>();
            item.emptyAssignments = studySiteVisitPlans.isEmpty();

            for (Id vpId : visitPlans.keySet()) {
                if (selectedVPIds.isEmpty() || (!selectedVPIds.isEmpty() && selectedVPIds.contains(String.valueOf(vpId)))) {
                    Boolean selected = false;
                    for (StudySiteVisitPlan__c ssVP : studySiteVisitPlans) {
                        if (ssVP.Visit_Plan__c == vpId) {
                            selected = true;
                            break;
                        }
                    }

                    item.assignments.add(new ValueStateItem(vpId, selected));
                }
            }

            studySiteItems.add(item);
        }
        return studySiteItems;
    }

    private static Map<Id, Map<Id, StudySiteVisitPlan__c>> getStudySiteVisitPlansMap(List<Id> ssIds) {
        List<StudySiteVisitPlan__c> studySiteVisitPlans = [
                SELECT Id, Visit_Plan__c, Study_Site__c
                FROM StudySiteVisitPlan__c
                WHERE Study_Site__c IN:ssIds
        ];

        Map<Id, Map<Id, StudySiteVisitPlan__c>> ssVisitPlansBySSId = new Map<Id, Map<Id, StudySiteVisitPlan__c>>();
        for (StudySiteVisitPlan__c ssVP : studySiteVisitPlans) {
            if (!ssVisitPlansBySSId.containsKey(ssVP.Study_Site__c)) {
                ssVisitPlansBySSId.put(ssVP.Study_Site__c, new Map<Id, StudySiteVisitPlan__c>());
            }
            ssVisitPlansBySSId.get(ssVP.Study_Site__c).put(ssVP.Visit_Plan__c, ssVP);
        }

        return ssVisitPlansBySSId;
    }

    public static List<LabelValueItem> getVisitPlansLV() {
        List<LabelValueItem> visitPlans = new List<LabelValueItem>();
        for (Visit_Plan__c vp : getVisitPlansMap().values()) {
            visitPlans.add(new LabelValueItem(vp.Name, vp.Id));
        }

        return visitPlans;
    }

    public static Map<Id, Visit_Plan__c> getVisitPlansMap() {
        return new Map<Id, Visit_Plan__c>([SELECT Id, Name FROM Visit_Plan__c]);
    }
}