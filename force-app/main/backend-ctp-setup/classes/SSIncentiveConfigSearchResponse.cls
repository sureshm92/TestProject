/**
 * Created by Alexey Moseev on 5/7/20.
 */

public without sharing class SSIncentiveConfigSearchResponse {

    @AuraEnabled public PaginationData pagination;
    @AuraEnabled public List<StudySiteItem> studySiteItems;
    @AuraEnabled public List<LabelValueItem> incentivePlans;
    @AuraEnabled public Boolean haveEmptyAssigment;

    public SSIncentiveConfigSearchResponse(StudySiteFilter filter, PaginationData pagination){
        this.pagination = pagination;
        List<Study_Site__c> ssList = SearchService.search(filter, this.pagination);
        incentivePlans = getIncentivePlans(filter);
        studySiteItems = convertToSSItems(ssList, filter, true);
        haveEmptyAssigment = isHaveEmptyAssignment(filter);
    }

    private static List<LabelValueItem> getIncentivePlans(StudySiteFilter filter) {
        Map<Id, Incentive_Plan__c> ipMap = new Map<Id, Incentive_Plan__c>([
                SELECT Id, Name, Plan_Name__c
                FROM Incentive_Plan__c
                WHERE Clinical_Trial_Profile__c = :filter.ctpId]);
        List<Id> selectedIPIds = new List<Id>(ipMap.keySet());
        if (!String.isEmpty(filter.pageFeatureIds)) selectedIPIds = filter.pageFeatureIds.split(';');
        List<LabelValueItem> incentivePlans = new List<LabelValueItem>();
        for (Id ipId : selectedIPIds) {
            Incentive_Plan__c ip = ipMap.get(ipId);
            if (ip != null) incentivePlans.add(new LabelValueItem(ip.Plan_Name__c, ipId));
        }
        return incentivePlans;
    }

    private static Boolean isHaveEmptyAssignment(StudySiteFilter filter){
        List<Study_Site__c> allSSList = [SELECT Id, (SELECT Id FROM Study_Incentive_Plans__r) FROM Study_Site__c WHERE Clinical_Trial_Profile__c = :filter.ctpId];
        for (Study_Site__c ss : allSSList) if (ss.StudySiteVisitPlans__r.isEmpty()) return true;
        return false;
    }

    public static List<StudySiteItem> convertToSSItems(List<Study_Site__c> studySites, StudySiteFilter filter, Boolean fromInit) {
        List<LabelValueItem> incentivePlans = getIncentivePlans(filter);
        Map<Id, List<Study_Incentive_Plan__c>> ssIncentivePlansBySSIdMap = getIncentivePlansBySSIdMap(studySites);
        List<StudySiteItem> studySiteItems = new List<StudySiteItem>();
        for (Study_Site__c ss : studySites) {
            String countryName = ss.Site__r.BillingCountry;
            String countryCode = ss.Site__r.BillingCountryCode;
            StudySiteItem item = new StudySiteItem(new LabelValueItem(countryName, countryCode), ss.Name, ss);
            List<Study_Incentive_Plan__c> ssIPList = ssIncentivePlansBySSIdMap.containsKey(ss.Id) ? ssIncentivePlansBySSIdMap.get(ss.Id) : new List<Study_Incentive_Plan__c>();
            item.emptyAssignments = ssIPList.isEmpty();
            Boolean hasCheckedIncentives = false;
            for (LabelValueItem ip : incentivePlans) {
                Id ssIPId;
                for (Study_Incentive_Plan__c ssIP : ssIPList){
                    if (ssIP.Incentive_Plan__c == ip.value){
                        ssIPId = ssIP.Id;
                        break;
                    }
                }
                hasCheckedIncentives = hasCheckedIncentives || ssIPId != null;
                item.assignments.add(new ValueStateItem(ip.value, ssIPId));
            }
            if (!fromInit || String.isBlank(filter.pageFeatureIds) ||
                    !String.isBlank(filter.pageFeatureIds) && hasCheckedIncentives) {
                studySiteItems.add(item);
            }
        }
        return studySiteItems;
    }

    private static Map<Id, List<Study_Incentive_Plan__c>> getIncentivePlansBySSIdMap(List<Study_Site__c> ssList) {
        List<Study_Incentive_Plan__c> studySiteIncentivePlans = [
                SELECT Id, Incentive_Plan__c, Study_Site__c
                FROM Study_Incentive_Plan__c
                WHERE Study_Site__c IN: ssList
        ];
        Map<Id, List<Study_Incentive_Plan__c>> ipListBySSIdMap = new Map<Id, List<Study_Incentive_Plan__c>>();
        for (Study_Incentive_Plan__c ssIP : studySiteIncentivePlans) {
            if (!ipListBySSIdMap.containsKey(ssIP.Study_Site__c)) {
                ipListBySSIdMap.put(ssIP.Study_Site__c, new List<Study_Incentive_Plan__c>());
            }
            ipListBySSIdMap.get(ssIP.Study_Site__c).add(ssIP);
        }
        return ipListBySSIdMap;
    }

}