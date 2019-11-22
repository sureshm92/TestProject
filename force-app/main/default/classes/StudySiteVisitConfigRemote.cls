/**
 * Created by Igor Malyuta on 18.09.2019.
 */

public without sharing class StudySiteVisitConfigRemote {

    public static final String FEATURE_SS_VISIT_CONFIG = 'Visits_Configuration';

    public static List<Study_Site__c> ctpStudySites;

    public class InitData {
        @AuraEnabled public List<LabelValueItem> visitPlans;
        @AuraEnabled public String countryCodes;
        @AuraEnabled public String selectedSSIds;
        @AuraEnabled public Id ctpId;
        @AuraEnabled public List<ApprovedLangRemote.StudySiteItem> studySiteItems;
        @AuraEnabled public Boolean haveEmptyVPSS;
        @AuraEnabled public PaginationData paginationData;
        @AuraEnabled public Map<String, String> countryBySSId;
        @AuraEnabled public String viewMode;

        public InitData() {
            paginationData = new PaginationData();
            countryCodes = '';
            haveEmptyVPSS = false;

            countryBySSId = new Map<String, String>();
            visitPlans = getVisitPlansLV();
        }
    }

    @AuraEnabled
    public static InitData getInitData(Id ctpId) {
        try {
            InitData intData = init(ctpId);
            intData.viewMode = GetPermissions.getViewMode(FEATURE_SS_VISIT_CONFIG);
            return intData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static InitData getNextData(String data, String countryCodes, String selectedVPIds, String ssId) {
        try {
            InitData initData = save(data);
            initData.paginationData.reCalc();
            initPageItems(initData, countryCodes, selectedVPIds, ssId);
            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static InitData getFilteredItems(String data, String countryCodes, String selectedVPIds, String ssId) {
        try {
            InitData initData = (InitData) JSON.deserialize(data, InitData.class);

            List<String> countries = ApprovedLangRemote.getListByString(countryCodes);
            List<String> vpIds = ApprovedLangRemote.getListByString(selectedVPIds);
            List<String> studyIds = ApprovedLangRemote.getListByString(ssId);

            initData.visitPlans = new List<LabelValueItem>();
            for (LabelValueItem vp : getVisitPlansLV()) {
                if (vpIds.isEmpty() || (!vpIds.isEmpty() && vpIds.contains(vp.value))) {
                    initData.visitPlans.add(vp);
                }
            }

            List<Study_Site__c> studySites = ApprovedLangRemote.getStudySites(
                    initData.ctpId, countries, studyIds, null, 'ASC', -1, 0
            );
            initData.paginationData.setRecordsCount(studySites.size());

            List<Study_Site__c> ssPart = new List<Study_Site__c>();
            for (Integer i = 0; i < studySites.size(); i++) {
                if (ssPart.size() - 1 < ApprovedLangRemote.QUERY_LIMIT) {
                    if (countries.isEmpty() || countries.contains(studySites.get(i).Site__r.BillingCountryCode)) {
                        ssPart.add(studySites.get(i));
                    }
                } else {
                    break;
                }
            }

            initData.studySiteItems = getStudySiteItems(ssPart, vpIds);
            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static InitData getSortedItems(String data, String selectedVPIds, String sortOrder, Boolean sortDirection) {
        try {
            InitData initData = (InitData) JSON.deserialize(data, InitData.class);

            List<String> ssIds = new List<String>();
            for (ApprovedLangRemote.StudySiteItem item : initData.studySiteItems) ssIds.add(item.ss.Id);

            String direction = sortDirection ? 'ASC' : 'DESC';

            List<Study_Site__c> studySites = ApprovedLangRemote.getStudySites(
                    initData.ctpId, null, ssIds, sortOrder, direction, -1, ApprovedLangRemote.QUERY_LIMIT
            );
            initData.studySiteItems = getStudySiteItems(studySites, ApprovedLangRemote.getListByString(selectedVPIds));

            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void setVisitPlanForAll(String data, String vpId, Boolean state) {
        try {
            InitData initData = (InitData) JSON.deserialize(data, InitData.class);
            if (ctpStudySites == null) {
                ctpStudySites = ApprovedLangRemote.getStudySites(ApprovedLangRemote.QUERY_MAIN_FILTER.replace('ctpId', initData.ctpId));
            }
            List<Id> ssIds = new List<Id>();
            for (Study_Site__c ss : ctpStudySites) ssIds.add(ss.Id);

            if (state) {
                Map<Id, Map<Id, StudySiteVisitPlan__c>> ssVPsByStudySiteIds = getStudySiteVisitPlansMap(ssIds);
                List<StudySiteVisitPlan__c> studySiteVisitPlans = new List<StudySiteVisitPlan__c>();
                for (Id ssId : ssIds) {
                    Map<Id, StudySiteVisitPlan__c> ssVPByIds = ssVPsByStudySiteIds.get(ssId);
                    if (ssVPByIds != null && ssVPByIds.containsKey(vpId)) continue;

                    studySiteVisitPlans.add(new StudySiteVisitPlan__c(
                            Study_Site__c = ssId,
                            Visit_Plan__c = vpId
                    ));
                }

                if (!studySiteVisitPlans.isEmpty()) insert studySiteVisitPlans;
            } else {
                delete [SELECT Id FROM StudySiteVisitPlan__c WHERE Visit_Plan__c = :vpId AND Study_Site__c IN:ssIds];
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static InitData save(String data) {
        try {
            InitData initData = (InitData) JSON.deserialize(data, InitData.class);

            if (ctpStudySites == null) {
                ctpStudySites = ApprovedLangRemote.getStudySites(ApprovedLangRemote.QUERY_MAIN_FILTER.replace('ctpId', initData.ctpId));
            }
            List<Id> ctpStudySiteIds = new List<Id>();
            for (Study_Site__c ss : ctpStudySites) ctpStudySiteIds.add(ss.Id);

            List<StudySiteVisitPlan__c> deselectedSSVPs = new List<StudySiteVisitPlan__c>();
            List<StudySiteVisitPlan__c> newSSVPs = new List<StudySiteVisitPlan__c>();

            Map<Id, Map<Id, StudySiteVisitPlan__c>> ssVisitPlansByIds = getStudySiteVisitPlansMap(ctpStudySiteIds);
            for (ApprovedLangRemote.StudySiteItem item : initData.studySiteItems) {
                Map<Id, StudySiteVisitPlan__c> siteVisitPlans = ssVisitPlansByIds.get(item.ss.Id) != null
                        ? ssVisitPlansByIds.get(item.ss.Id) : new Map<Id, StudySiteVisitPlan__c>();
                for (ApprovedLangRemote.ValueStateItem assigment : item.assignments) {
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

            initData.haveEmptyVPSS = getStudySiteVisitPlansMap(ctpStudySiteIds).keySet().size() != ctpStudySiteIds.size();
            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static InitData deleteVisitPlan(String planId, String ctpId) {
        try {
            Visit_Plan__c plan = VisitPlanRemote.getVisitPlan(planId);
            delete plan;

            return init(ctpId);
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    //Inner logic: -----------------------------------------------------------------------------------------------------
    private static InitData init(Id ctpId) {
        InitData initData = new InitData();
        initData.ctpId = ctpId;
        ctpStudySites = ApprovedLangRemote.getStudySites(ApprovedLangRemote.QUERY_MAIN_FILTER.replace('ctpId', ctpId));
        if (!ctpStudySites.isEmpty()) {
            loadInitData(initData);
            initPageItems(initData, initData.countryCodes, null, null);
        }

        return initData;
    }

    private static void loadInitData(InitData initData) {
        List<Id> ssIds = new List<Id>();
        for (Study_Site__c ss : ctpStudySites) {
            if (ss.Site__r.BillingCountryCode != null && !initData.countryCodes.contains(ss.Site__r.BillingCountryCode)) {
                initData.countryCodes += ss.Site__r.BillingCountryCode + ';';
            }
            ssIds.add(ss.Id);
        }

        initData.haveEmptyVPSS = getStudySiteVisitPlansMap(ssIds).keySet().size() != ssIds.size();

        initData.countryCodes = initData.countryCodes.removeEnd(';');
        initData.paginationData.setRecordsCount(ctpStudySites.size());
    }

    private static void initPageItems(InitData initData, String countryCodes, String selectedVPIds, String ssId) {
        initData.studySiteItems = getStudySiteItems(
                ApprovedLangRemote.getStudySites(initData.ctpId,
                        ApprovedLangRemote.getListByString(countryCodes), ApprovedLangRemote.getListByString(ssId),
                        null, 'ASC',
                        initData.paginationData.offset, ApprovedLangRemote.QUERY_LIMIT
                ),
                ApprovedLangRemote.getListByString(selectedVPIds)
        );
        initData.paginationData.pageRecordsCount = initData.studySiteItems.size();
    }

    private static List<ApprovedLangRemote.StudySiteItem> getStudySiteItems(List<Study_Site__c> studySites, List<String> selectedVPIds) {
        List<Id> ssIds = new List<Id>();
        for (Study_Site__c ss : studySites) ssIds.add(ss.Id);
        Map<Id, Map<Id, StudySiteVisitPlan__c>> ssVisitPlansBySSId = getStudySiteVisitPlansMap(ssIds);

        Map<Id, Visit_Plan__c> visitPlans = getVisitPlansMap();
        List<ApprovedLangRemote.StudySiteItem> studySiteItems = new List<ApprovedLangRemote.StudySiteItem>();
        for (Study_Site__c ss : studySites) {
            String countryName = ss.Site__r.BillingCountry;
            String countryCode = ss.Site__r.BillingCountryCode;
            ApprovedLangRemote.StudySiteItem item =
                    new ApprovedLangRemote.StudySiteItem(new LabelValueItem(countryName, countryCode), ss.Name, ss);

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

                    item.assignments.add(new ApprovedLangRemote.ValueStateItem(vpId, selected));
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