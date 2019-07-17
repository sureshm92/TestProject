public inherited sharing class VisitResultsService {

    public static final String DASHBOARD_TYPE_HOME_PAGE = 'Home Page';

    private VisitResultMService metadataService;

    public VisitResultsService() {
        this.metadataService = (VisitResultMService) ClassFactory.newInstance(VisitResultMService.class);
    }

    public List<String> getVisitResultsGroupNames(String visitResultsMode) {
        return this.metadataService.getVisitResultGroupNames(visitResultsMode);
    }

    public List<VisitResultWrapper> getVisitResultWrappersForDashboard() {

        List<Visit_Result_TypeM_Dashboard_Config__mdt> configs = metadataService.getVisitResultTypeDashboardConfigs();
        List<Visit_Result__c> visitResults = VisitResultSharingService.processResults();
        if (visitResults.isEmpty() || configs.isEmpty()) {
            return new List<VisitResultWrapper>();
        }

        Map<String, Double> visitResultValuesByNames = new Map<String, Double>();
        List<VisitResultWrapper> wrappers = new List<VisitResultWrapper>();
        Boolean listIsNotEmpty = false;

        for (Visit_Result__c singleVisitResult : visitResults) {
            visitResultValuesByNames.put(singleVisitResult.Result_Type__c, singleVisitResult.Actual_Value__c);
        }

        for (Visit_Result_TypeM_Dashboard_Config__mdt singleConfig : configs) {
            if (visitResultValuesByNames.get(singleConfig.Visit_Result_Type__r.DeveloperName) != null) {
                listIsNotEmpty = true;
            }
            wrappers.add(new VisitResultWrapper(singleConfig.Dashboard_Name__c, visitResultValuesByNames.get(singleConfig.Visit_Result_Type__r.DeveloperName)));
        }
        return listIsNotEmpty ? wrappers : new List<VisitResultWrapper>();
    }

    public VisitResultsContainer getVisitResultsContainer(String visitResultsGroupName) {

        List<Visit_Result_TypeM__mdt> visitResultTypes = this.metadataService.getVisitResultTypes(visitResultsGroupName);
        List<Visit_Result__c> visitResults = VisitResultSharingService.processResults();
        return visitResults.isEmpty()
                ? null
                : new VisitResultsContainer(visitResults[0].Patient_Visit__r, this.getVisitResultWrappers(visitResults, visitResultTypes), visitResultsGroupName);
    }

    private List<VisitResultWrapper> getVisitResultWrappers(List<Visit_Result__c> visitResults, List<Visit_Result_TypeM__mdt> visitResultTypes) {

        Map<String, Visit_Result__c> visitResultsByTypeDeveloperNames = this.getVisitResultsByTypeDeveloperNames(visitResults);
        List<VisitResultWrapper> wrappers = new List<VisitResultWrapper>();
        for (Visit_Result_TypeM__mdt singleVRT : visitResultTypes) {
            wrappers.add(new VisitResultWrapper(visitResultsByTypeDeveloperNames.get(singleVRT.DeveloperName), singleVRT.Label));
        }
        return wrappers;
    }

    private Map<String, Visit_Result__c> getVisitResultsByTypeDeveloperNames(List<Visit_Result__c> visitResults) {
        Map<String, Visit_Result__c> result = new Map<String, Visit_Result__c>();
        for (Visit_Result__c singleResult : visitResults) {
            result.put(singleResult.Result_Type__c, singleResult);
        }
        return result;
    }

    public class VisitResultsContainer {

        @AuraEnabled
        public List<VisitResultsService.VisitResultWrapper> wrappers;
        @AuraEnabled
        public String visitDate;
        @AuraEnabled
        public String groupName;

        public VisitResultsContainer(Patient_Visit__c visit, List<VisitResultWrapper> wrappers, String groupName) {
            this.wrappers = wrappers;
            this.visitDate = visit.Completed_Date__c == null ? Label.StudyVisit_Information_Not_Available : DateService.format(visit.Completed_Date__c, 'DD-MMM-YYYY');
            this.groupName = groupName;
        }
    }

    public class VisitResultWrapper {

        @AuraEnabled
        public Double value;
        @AuraEnabled
        public Double minValue;
        @AuraEnabled
        public Double maxValue;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String measurement;

        public VisitResultWrapper(Visit_Result__c visitResult, String name) {
            this.name = name;
            if (visitResult != null) {
                this.value = visitResult.Actual_Value__c;
                this.minValue = visitResult.Min_Value__c;
                this.maxValue = visitResult.Max_Value__c;
                this.measurement = visitResult.Measurement__c;
            }
        }

        public VisitResultWrapper(String name) {
            this.name = name;
        }

        public VisitResultWrapper(String name, Double value) {
            this.name = name;
            this.value = value;
        }
    }
}