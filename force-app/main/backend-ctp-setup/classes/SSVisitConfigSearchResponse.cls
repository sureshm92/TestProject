/**
 * Created by Leonid Bartenev
 */

public without sharing class SSVisitConfigSearchResponse {
    @AuraEnabled
    public PaginationData pagination;
    @AuraEnabled
    public List<StudySiteItem> studySiteItems;
    @AuraEnabled
    public List<LabelValueItem> visitPlans;
    @AuraEnabled
    public Boolean haveEmptyAssigment;

    public SSVisitConfigSearchResponse(StudySiteFilter filter, PaginationData pagination) {
        this.pagination = pagination;
        List<Study_Site__c> ssList = SearchService.search(filter, this.pagination);
        visitPlans = getVisitPlans(filter.pageFeatureIds);
        studySiteItems = convertToSSItems(ssList, filter.pageFeatureIds);
        haveEmptyAssigment = isHaveEmptyAssignment(filter);
    }

    private static List<LabelValueItem> getVisitPlans(String selectedVPIdsStr) {
        Map<Id, Visit_Plan__c> vpMap = new Map<Id, Visit_Plan__c>(
            [SELECT Id, Name FROM Visit_Plan__c]
        );
        List<Id> selectedVPIds = new List<Id>(vpMap.keySet());
        if (!String.isEmpty(selectedVPIdsStr))
            selectedVPIds = selectedVPIdsStr.split(';');
        List<LabelValueItem> visitPlans = new List<LabelValueItem>();
        for (Id vpId : selectedVPIds) {
            Visit_Plan__c vp = vpMap.get(vpId);
            if (vp != null)
                visitPlans.add(new LabelValueItem(vp.Name, vpId));
        }
        return visitPlans;
    }

    private static Boolean isHaveEmptyAssignment(StudySiteFilter filter) {
        List<Study_Site__c> allSSList = [
            SELECT Id, (SELECT Id FROM StudySiteVisitPlans__r)
            FROM Study_Site__c
            WHERE Clinical_Trial_Profile__c = :filter.ctpId
        ];
        for (Study_Site__c ss : allSSList)
            if (ss.StudySiteVisitPlans__r.isEmpty())
                return true;
        return false;
    }

    public static List<StudySiteItem> convertToSSItems(
        List<Study_Site__c> studySites,
        String selectedVPIdsStr
    ) {
        List<LabelValueItem> visitPlans = getVisitPlans(selectedVPIdsStr);
        Map<Id, List<StudySiteVisitPlan__c>> ssVisitPlansBySSIdMap = getVisitPlansBySSIdMap(
            studySites
        );
        List<StudySiteItem> studySiteItems = new List<StudySiteItem>();
        for (Study_Site__c ss : studySites) {
            String countryName = ss.Site__r.BillingCountry;
            String countryCode = ss.Site__r.BillingCountryCode;
            StudySiteItem item = new StudySiteItem(
                new LabelValueItem(countryName, countryCode),
                ss.Name,
                ss
            );
            List<StudySiteVisitPlan__c> ssVPList = ssVisitPlansBySSIdMap.containsKey(ss.Id)
                ? ssVisitPlansBySSIdMap.get(ss.Id)
                : new List<StudySiteVisitPlan__c>();
            item.emptyAssignments = ssVPList.isEmpty();
            if(!ssVPList.isEmpty() && ssVPList.size()==1){
             item.soleVisitPlan = ssVPList[0].Visit_Plan__c;   
            }
            for (LabelValueItem vp : visitPlans) {
                Id ssVPId;
                for (StudySiteVisitPlan__c ssVP : ssVPList) {
                    if (ssVP.Visit_Plan__c == vp.value) {
                        ssVPId = ssVP.Id;
                        break;
                    }
                }
                item.assignments.add(new ValueStateItem(vp.value, ssVPId));
            }
            studySiteItems.add(item);
        }
        return studySiteItems;
    }

    private static Map<Id, List<StudySiteVisitPlan__c>> getVisitPlansBySSIdMap(
        List<Study_Site__c> ssList
    ) {
        List<StudySiteVisitPlan__c> studySiteVisitPlans = [
            SELECT Id, Visit_Plan__c, Study_Site__c
            FROM StudySiteVisitPlan__c
            WHERE Study_Site__c IN :ssList
        ];
        Map<Id, List<StudySiteVisitPlan__c>> vpListBySSIdMap = new Map<Id, List<StudySiteVisitPlan__c>>();
        for (StudySiteVisitPlan__c ssVP : studySiteVisitPlans) {
            if (!vpListBySSIdMap.containsKey(ssVP.Study_Site__c)) {
                vpListBySSIdMap.put(ssVP.Study_Site__c, new List<StudySiteVisitPlan__c>());
            }
            vpListBySSIdMap.get(ssVP.Study_Site__c).add(ssVP);
        }
        return vpListBySSIdMap;
    }
}
