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
        Participant_Enrollment__c objCurrParEnroll=ParticipantContext.getCurrentPE();
        String strCountryCode='';
        if(objCurrParEnroll.Study_Site__c!=null && objCurrParEnroll.Study_Site__r.Site__c!=null){
            strCountryCode=objCurrParEnroll.Study_Site__r.Site__r.BillingCountryCode;
        }
        
        Id currentCTP = objCurrParEnroll.Clinical_Trial_Profile__c;
        Clinical_Trial_Profile__c ctpObject = [SELECT Id,Participant_Visit_Result_Group__c FROM Clinical_Trial_Profile__c WHERE Id = :currentCTP];
        String currentCTPVisitResultGroup = ctpObject.Participant_Visit_Result_Group__c;
        List<String> ctpAvailableNames = new List<String>();
        List<Visit_Result_Type_Sharing__c> ctpAvailable = [
                SELECT Id,Include_Countries__c,Sharing_Countries__c,
                        Type__c
                FROM Visit_Result_Type_Sharing__c
                WHERE Clinical_Trial_Profile__c = :currentCTP

        ];
        for (Visit_Result_Type_Sharing__c visitResultTypeSharing : ctpAvailable) {
            if(!visitResultTypeSharing.Include_Countries__c){
                if(String.isBlank(strCountryCode) || String.isBlank(visitResultTypeSharing.Sharing_Countries__c) || visitResultTypeSharing.Sharing_Countries__c.equals('All') || (!visitResultTypeSharing.Sharing_Countries__c.contains(strCountryCode))){
                    ctpAvailableNames.add(visitResultTypeSharing.Type__c);
                }    
            }
            else{
                if(String.isBlank(strCountryCode) || String.isBlank(visitResultTypeSharing.Sharing_Countries__c) || (!String.isBlank(strCountryCode) && visitResultTypeSharing.Sharing_Countries__c.contains(strCountryCode))){
                    ctpAvailableNames.add(visitResultTypeSharing.Type__c);
                }
            }
        }
        List<Visit_Result_GroupM__mdt> visistResultGroupMetaDataTypeList = [
                SELECT Id, Label, (SELECT Id, DeveloperName, Label, Visit_Result_Code__c FROM Visit_Result_Types__r)
                FROM Visit_Result_GroupM__mdt
                WHERE Label = :currentCTPVisitResultGroup
        ];
        List<String> attributePerSectionList = new List<String>();
        for (Visit_Result_GroupM__mdt objMetadata : visistResultGroupMetaDataTypeList) {
            for (Visit_Result_TypeM__mdt objVSR : objMetadata.Visit_Result_Types__r) {
                attributePerSectionList.add(objVSR.DeveloperName);
            }
        }
        List<String> filteredVisitResults = new List<String>();
        for (String ctpAttributeAvailable : ctpAvailableNames) {
            if (attributePerSectionList.contains(ctpAttributeAvailable)) {
                filteredVisitResults.add(ctpAttributeAvailable);
            }
        }
        List<Visit_Result__c> visitResults = VisitResultSharingService.processResults();
        if (visitResults.isEmpty() || filteredVisitResults.isEmpty()) {
            return new List<VisitResultWrapper>();
        }
        Map<String, Visit_Result__c> visitResultValuesByNames = new Map<String, Visit_Result__c>();
        List<VisitResultWrapper> wrappers = new List<VisitResultWrapper>();
        Boolean listIsNotEmpty = false;
        for (Visit_Result__c singleVisitResult : visitResults) {
            visitResultValuesByNames.put(singleVisitResult.Result_Type__c, singleVisitResult);
        }
        for (String selectedVisitGroup : filteredVisitResults) {
            Visit_Result__c visitResult = visitResultValuesByNames.get(selectedVisitGroup);
            if (visitResult != null && visitResult.Actual_Value__c != null) {
                listIsNotEmpty = true;
            }
            wrappers.add(new VisitResultWrapper(visitResult, TranslateHelper.getLabelValue(selectedVisitGroup), this.visitResultsMeasurementNamesMap));
        }
        List<VisitResultWrapper> resultWrappers = new List<VisitResultWrapper>();
        List<VisitResultWrapper> emptyWrappers = new List<VisitResultWrapper>();
        for (Integer index = 0; index < wrappers.size(); index++) {
            if (wrappers.get(index).value != null) {
                resultWrappers.add(wrappers.get(index));
            } else {
                emptyWrappers.add(wrappers.get(index));
            }
        }
        if (resultWrappers.isEmpty()) {
            return new List<VisitResultWrapper>();
        }
        resultWrappers.addAll(emptyWrappers);
        if (resultWrappers.size() > 5) {
            for (Integer index = resultWrappers.size() - 1; index >= 5; index--) {
                resultWrappers.remove(index);
            }
        }
        return listIsNotEmpty ? resultWrappers : new List<VisitResultWrapper>();
    }

    public List<Patient_Visit__c> getPatientVisitsForReport(Participant_Enrollment__c pe) {
        String visitsQuery = 'SELECT ' +
                'Name, ' +
                'Completed_Date__c, ' +
                'Planned_Date__c, ' +
                'Participant_Enrollment__r.Participant__r.Full_Name__c, ' +
                'Participant_Enrollment__r.Participant__r.Last_Name__c, ' +
                '(SELECT Name, Actual_Value__c, Min_Value__c, Max_Value__c, Measurement__c, Result_Type__c, Patient_Visit__r.Visit_Number__c, RecordType.DeveloperName FROM Visit_Results__r) ' +
                'FROM Patient_Visit__c ' +
                'WHERE Participant_Enrollment__c = \'' + pe.Id + '\'' +
                ' AND Status__c = \'Completed\'' +
                ' ORDER BY Completed_Date__c NULLS LAST';
        return ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class)).query(visitsQuery, true);
    }

    public VisitResultsContainer getVisitResultsContainer(String visitResultsGroupName, Map<String, List<String>> visitResultSharings) {
        List<Visit_Result_TypeM__mdt> visitResultTypes = this.metadataService.getVisitResultTypes(visitResultsGroupName);
        List<String> availableVisitResults = visitResultSharings.get(visitResultsGroupName);
        List<Visit_Result_TypeM__mdt> filteredVisitResultTypesIfAvailable = new List<Visit_Result_TypeM__mdt>();
        for (Visit_Result_TypeM__mdt visitResultTypeM : visitResultTypes) {
            if (availableVisitResults.contains(visitResultTypeM.DeveloperName)) filteredVisitResultTypesIfAvailable.add(visitResultTypeM);
        }
        List<Visit_Result__c> visitResults = VisitResultSharingService.processResults();

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
        @AuraEnabled
        public String recordtype;

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
                this.recordtype = visitResult.RecordType.DeveloperName;
                if(visitResult.Measurement__c!=null){
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
}