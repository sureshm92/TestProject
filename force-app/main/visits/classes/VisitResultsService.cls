public inherited sharing class VisitResultsService {

    public static final String DASHBOARD_TYPE_HOME_PAGE = 'Home Page';

    private VisitResultMService metadataService;
    private Map<String, String> visitResultsMeasurementNamesMap;

    public VisitResultsService() {
        this.metadataService = (VisitResultMService) ClassFactory.newInstance(VisitResultMService.class);
        this.visitResultsMeasurementNamesMap = metadataService.getVisitResultsMeasurementNamesMap();
    }

    public List<String> getVisitResultsGroupNames(String visitResultsMode) {
        return this.metadataService.getVisitResultGroupNames(visitResultsMode);
    }

    public List<VisitResultWrapper> getVisitResultWrappersForDashboard() {

        List<Visit_Result_TypeM_Dashboard_Config__mdt> configs = metadataService.getVisitResultTypeDashboardConfigs();
        List<String> configNames = new List<String>();
        for (Visit_Result_TypeM_Dashboard_Config__mdt visitResultTypeMDashboardConfig : configs) {
            configNames.add(visitResultTypeMDashboardConfig.Visit_Result_Type__r.DeveloperName);
        }

        List<String> ctpAvailableNames = new List<String>();
        List<Visit_Result_Type_Sharing__c> ctpAvailable = [SELECT Id,Type__c FROM Visit_Result_Type_Sharing__c];
        for (Visit_Result_Type_Sharing__c visitResultTypeSharing : ctpAvailable) {
            ctpAvailableNames.add(visitResultTypeSharing.Type__c);
        }

        List<String> filteredVisitResults = new List<String>();
        for (String configName : configNames) {
            if (ctpAvailableNames.contains(configName)) filteredVisitResults.add(configName);
        }

        List<Visit_Result_TypeM_Dashboard_Config__mdt> filteredConfigs = new List<Visit_Result_TypeM_Dashboard_Config__mdt>();
        for (Visit_Result_TypeM_Dashboard_Config__mdt visitResultTypeMDashboardConfig : configs) {
            if (filteredVisitResults.contains(visitResultTypeMDashboardConfig.Visit_Result_Type__r.DeveloperName)) filteredConfigs.add(visitResultTypeMDashboardConfig);
        }


        List<Visit_Result__c> visitResults = VisitResultSharingService.processResults('Vitals',filteredVisitResults);
        if (visitResults.isEmpty() || filteredConfigs.isEmpty()) {
            return new List<VisitResultWrapper>();
        }

        Map<String, Visit_Result__c> visitResultValuesByNames = new Map<String, Visit_Result__c>();
        List<VisitResultWrapper> wrappers = new List<VisitResultWrapper>();
        Boolean listIsNotEmpty = false;

        for (Visit_Result__c singleVisitResult : visitResults) {
            visitResultValuesByNames.put(singleVisitResult.Result_Type__c, singleVisitResult);
        }

        //String languageToTranslate = IRBParticipantService.getSuitableLanguageForIRBTranslation(ParticipantService.getParticipantState().pe.Id);
        for (Visit_Result_TypeM_Dashboard_Config__mdt singleConfig : filteredConfigs) {
            Visit_Result__c visitResult = visitResultValuesByNames.get(singleConfig.Visit_Result_Type__r.DeveloperName);
            if (visitResult != null && visitResult.Actual_Value__c != null) {
                listIsNotEmpty = true;
            }
            wrappers.add(new VisitResultWrapper(visitResult, TranslateHelper.getLabelValue(singleConfig.Dashboard_Name__c), this.visitResultsMeasurementNamesMap));
        }
        return listIsNotEmpty ? wrappers : new List<VisitResultWrapper>();
    }

    public List<Patient_Visit__c> getPatientVisitsForReport(Participant_Enrollment__c pe) {
        String visitsQuery = 'SELECT ' +
                'Name, ' +
                'Completed_Date__c, ' +
                'Participant_Enrollment__r.Participant__r.Full_Name__c, ' +
                'Participant_Enrollment__r.Participant__r.Last_Name__c, ' +
                '(SELECT Name, Actual_Value__c, Min_Value__c, Max_Value__c, Measurement__c, Result_Type__c, Patient_Visit__r.Visit_Number__c FROM Visit_Results__r) ' +
                'FROM Patient_Visit__c ' +
                'WHERE Participant_Enrollment__c = \'' + pe.Id + '\'' +
                ' AND Status__c = \'Completed\'' +
                ' ORDER BY Completed_Date__c NULLS LAST';
        return ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class)).query(visitsQuery, true);
    }

    public VisitResultsContainer getVisitResultsContainer(String visitResultsGroupName,  Map<String,List<String>> visitResultSharings) {
        List<Visit_Result_TypeM__mdt> visitResultTypes = this.metadataService.getVisitResultTypes(visitResultsGroupName);
        List<String> availableVisitResults = visitResultSharings.get(visitResultsGroupName);
        List<Visit_Result_TypeM__mdt> filteredVisitResultTypesIfAvailable = new List<Visit_Result_TypeM__mdt>();
        for (Visit_Result_TypeM__mdt visitResultTypeM : visitResultTypes) {
            if (availableVisitResults.contains(visitResultTypeM.DeveloperName)) filteredVisitResultTypesIfAvailable.add(visitResultTypeM);
        }
        String visitResultMode = this.metadataService.getVisitResultModeByGroupName(visitResultsGroupName);
        List<Visit_Result__c> visitResults = VisitResultSharingService.processResults(visitResultMode, visitResultSharings.get(visitResultsGroupName));

        //String languageToTranslate = IRBParticipantService.getSuitableLanguageForIRBTranslation(ParticipantService.getParticipantState().pe.Id);
        return visitResults.isEmpty()
                ? null
                : new VisitResultsContainer(
                        visitResults[0].Patient_Visit__r,
                        this.getVisitResultWrappers(visitResults, filteredVisitResultTypesIfAvailable),
                        TranslateHelper.getLabelValue(visitResultsGroupName)
                );
    }


    private List<VisitResultWrapper> getVisitResultWrappers(List<Visit_Result__c> visitResults, List<Visit_Result_TypeM__mdt> visitResultTypes) {

        Map<String, Visit_Result__c> visitResultsByTypeDeveloperNames = this.getVisitResultsByTypeDeveloperNames(visitResults);
        List<VisitResultWrapper> wrappers = new List<VisitResultWrapper>();
        for (Visit_Result_TypeM__mdt singleVRT : visitResultTypes) {
            wrappers.add(new VisitResultWrapper(
                    visitResultsByTypeDeveloperNames.get(singleVRT.DeveloperName),
                    TranslateHelper.getLabelValue(singleVRT.DeveloperName),
                    TranslateHelper.getLabelValue(singleVRT.Description_Label_Api_Name__c),
                    this.visitResultsMeasurementNamesMap
            ));
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
            if (visit.Completed_Date__c != null) {
                Datetime dt = Datetime.newInstance(visit.Completed_Date__c.year(), visit.Completed_Date__c.month(), visit.Completed_Date__c.day(), 0, 0, 0);
                this.visitDate = dt.format('dd-MMM-yyyy');
            } else this.visitDate = Label.StudyVisit_Information_Not_Available;
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
        @AuraEnabled
        public String description;

        public VisitResultWrapper(Visit_Result__c visitResult, String name, String description) {
            this(visitResult, name, description, null);
        }

        public VisitResultWrapper(Visit_Result__c visitResult, String name, String description, Map<String, String> measurementNamesMap) {

            this.name = name;
            this.description = description;
            if (visitResult != null) {
                this.value = visitResult.Actual_Value__c;
                this.minValue = visitResult.Min_Value__c;
                this.maxValue = visitResult.Max_Value__c;
                if (visitResult.Measurement__c != null) {
                    String measurementLowerCase = visitResult.Measurement__c.toLowerCase();
                    if (measurementNamesMap != null && measurementNamesMap.containsKey(measurementLowerCase)) {
                        this.measurement = measurementNamesMap.get(measurementLowerCase).replace('/', ' / ');
                    } else {
                        this.measurement = visitResult.Measurement__c.replace('/', ' / ');
                    }
                }
            }
        }

        public VisitResultWrapper(Visit_Result__c visitResult, String name) {
            this(visitResult, name, new Map<String, String>());
        }

        public VisitResultWrapper(Visit_Result__c visitResult, String name, Map<String, String> measurementNamesMap) {
            this.name = name;
            if (visitResult != null) {
                this.value = visitResult.Actual_Value__c;
                String measurementLowerCase = visitResult.Measurement__c.toLowerCase();
                if (measurementNamesMap != null && measurementNamesMap.containsKey(measurementLowerCase)) {
                    this.measurement = measurementNamesMap.get(measurementLowerCase).replace('/', ' / ');
                } else {
                    this.measurement = visitResult.Measurement__c.replace('/', ' / ');
                }
            }
        }
    }
}