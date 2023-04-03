public inherited sharing class VisitResultsService {
    public static final String DASHBOARD_TYPE_HOME_PAGE = 'Home Page';
    public static final String ALL_COUNTRIES = 'All';
    public static final String BIOMARKER_VISIT_RESULT_GROUP = 'Biomarkers';
    private VisitResultMService metadataService;
    private Map<String, String> visitResultsMeasurementNamesMap;
    public static Map<Id, Set<String>> patientVisitbyVisitGroupMap = new Map<Id, Set<String>>();

    public VisitResultsService() {
        this.metadataService = (VisitResultMService) ClassFactory.newInstance(
            VisitResultMService.class
        );
        this.visitResultsMeasurementNamesMap = metadataService.getVisitResultsMeasurementNamesMap();
    }

    public List<String> getVisitResultsGroupNames(String visitResultsMode) {
        return this.metadataService.getVisitResultGroupNames(visitResultsMode);
    }

    public List<VisitResultWrapper> getVisitResultWrappersForDashboard() {
        Participant_Enrollment__c objCurrParEnroll = ParticipantContext.getCurrentPE();
        String strCountryCode = '';
        Map<String, String> visitResultTypeGroupMap = new Map<String, String>();
        Map<String, String> visitResultTypeSharingDesMap = new Map<String, String>();
        if (objCurrParEnroll.Participant__c != null) {
            strCountryCode = objCurrParEnroll.Participant__r.Mailing_Country_Code__c;
        }

        Id currentCTP = objCurrParEnroll.Clinical_Trial_Profile__c;
        Clinical_Trial_Profile__c ctpObject = [
            SELECT
                Id,
                Participant_Visit_Result_Group__c,
                Shareback_Settings_On_Country_Level__c,
                Shareback_Settings_Countries__c
            FROM Clinical_Trial_Profile__c
            WHERE Id = :currentCTP
        ];
        String currentCTPVisitResultGroup = ctpObject.Participant_Visit_Result_Group__c;
        String strShareBackCountries = '';
        if (!String.isBlank(ctpObject.Shareback_Settings_Countries__c)) {
            strShareBackCountries = ctpObject.Shareback_Settings_Countries__c;
        }
        List<String> ctpAvailableNames = new List<String>();
        List<Visit_Result_Type_Sharing__c> ctpAvailable = [
            SELECT Id, Include_Countries__c, Sharing_Countries__c, Type__c, Custom_Tooltip__c
            FROM Visit_Result_Type_Sharing__c
            WHERE Clinical_Trial_Profile__c = :currentCTP
        ];
        if (ctpAvailable != null && ctpAvailable.size() > 0) {
            TranslateHelper.translate(
                ctpAvailable,
                IRBParticipantService.getSuitableLanguageForIRBTranslation(objCurrParEnroll.Id)
            );
        }
        for (Visit_Result_Type_Sharing__c visitResultTypeSharing : ctpAvailable) {
            if (!visitResultTypeSharing.Include_Countries__c) {
                if (
                    String.isBlank(strCountryCode) ||
                    String.isBlank(visitResultTypeSharing.Sharing_Countries__c) ||
                    visitResultTypeSharing.Sharing_Countries__c.equals(ALL_COUNTRIES) ||
                    (!visitResultTypeSharing.Sharing_Countries__c.contains(strCountryCode) &&
                    ((!String.isBlank(strShareBackCountries) &&
                    strShareBackCountries.contains(strCountryCode)) ||
                    String.isBlank(strShareBackCountries)))
                ) {
                    ctpAvailableNames.add(visitResultTypeSharing.Type__c);
                    if (!String.isBlank(visitResultTypeSharing.Custom_Tooltip__c)) {
                        visitResultTypeSharingDesMap.put(
                            visitResultTypeSharing.Type__c,
                            visitResultTypeSharing.Custom_Tooltip__c
                        );
                    }
                }
            } else {
                if (
                    String.isBlank(strCountryCode) ||
                    String.isBlank(visitResultTypeSharing.Sharing_Countries__c) ||
                    (!String.isBlank(strCountryCode) &&
                    visitResultTypeSharing.Sharing_Countries__c.contains(strCountryCode))
                ) {
                    ctpAvailableNames.add(visitResultTypeSharing.Type__c);
                    if (!String.isBlank(visitResultTypeSharing.Custom_Tooltip__c)) {
                        visitResultTypeSharingDesMap.put(
                            visitResultTypeSharing.Type__c,
                            visitResultTypeSharing.Custom_Tooltip__c
                        );
                    }
                }
            }
        }
        List<Visit_Result_GroupM__mdt> visistResultGroupMetaDataTypeList = [
            SELECT
                Id,
                Label,
                (
                    SELECT
                        Id,
                        DeveloperName,
                        Label,
                        Visit_Result_Code__c,
                        Description_Label_Api_Name__c
                    FROM Visit_Result_Types__r
                )
            FROM Visit_Result_GroupM__mdt
            WHERE Label = :currentCTPVisitResultGroup
        ];
        List<String> attributePerSectionList = new List<String>();
        Map<String, String> visitResultTypeDescriptionMap = new Map<String, String>();
        for (Visit_Result_GroupM__mdt objMetadata : visistResultGroupMetaDataTypeList) {
            for (Visit_Result_TypeM__mdt objVSR : objMetadata.Visit_Result_Types__r) {
                visitResultTypeGroupMap.put(objVSR.DeveloperName, objMetadata.Label);
                attributePerSectionList.add(objVSR.DeveloperName);
                visitResultTypeDescriptionMap.put(
                    objVSR.DeveloperName,
                    objVSR.Description_Label_Api_Name__c
                );
            }
        }
        List<String> filteredVisitResults = new List<String>();
        for (String ctpAttributeAvailable : ctpAvailableNames) {
            if (attributePerSectionList.contains(ctpAttributeAvailable)) {
                filteredVisitResults.add(ctpAttributeAvailable);
            }
        }
        List<Visit_Result__c> visitResults = VisitResultSharingService.processResults(
            currentCTPVisitResultGroup
        );
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
            if (
                visitResultTypeGroupMap.containskey(selectedVisitGroup) &&
                (visitResultTypeGroupMap.get(selectedVisitGroup) != BIOMARKER_VISIT_RESULT_GROUP ||
                (visitResultTypeGroupMap.get(selectedVisitGroup) == BIOMARKER_VISIT_RESULT_GROUP &&
                visitResult != null))
            ) {
                VisitResultWrapper objVisitResultWrapper = new VisitResultWrapper(
                    visitResult,
                    TranslateHelper.getLabelValue(selectedVisitGroup),
                    this.visitResultsMeasurementNamesMap
                );
                if (visitResultTypeSharingDesMap.containsKey(selectedVisitGroup)) {
                    objVisitResultWrapper.description = visitResultTypeSharingDesMap.get(
                        selectedVisitGroup
                    );
                } else {
                    objVisitResultWrapper.description = TranslateHelper.getLabelValue(
                        visitResultTypeDescriptionMap.get(selectedVisitGroup)
                    );
                }
                if (!String.isBlank(selectedVisitGroup) && selectedVisitGroup.contains('ICOS')) {
                    objVisitResultWrapper.isConversion = false;
                } else {
                    objVisitResultWrapper.isConversion = true;
                }
                wrappers.add(objVisitResultWrapper);
            }
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
        //For in-trial report
        List<Patient_Visit__c> filteredPatientVisits = new List<Patient_Visit__c>();
        Boolean isAlumniParticipant = PEStatusState.PE_STATUS_GROUP_ALUMNI.contains(
            pe.Participant_Status__c
        );
        String dataOrder = isAlumniParticipant
            ? ' ORDER BY Completed_Date__c NULLS LAST'
            : ' ORDER BY Visit_Number__c, Completed_Date__c';
        String visitsQuery =
            'SELECT ' +
            'Id, ' +
            'Name, ' +
            'Completed_Date__c, ' +
            'Planned_Date__c, ' +
            'Participant_Enrollment__r.Participant__r.Full_Name__c, ' +
            'Participant_Enrollment__r.Participant__r.Last_Name__c, ' +
            '(SELECT Name, Actual_Value__c, Min_Value__c, Max_Value__c, Measurement__c, Result_Type__c, Patient_Visit__r.Visit_Number__c, RecordType.DeveloperName FROM Visit_Results__r) ' +
            'FROM Patient_Visit__c ' +
            'WHERE Participant_Enrollment__c = \'' +
            pe.Id +
            '\'' +
            ' AND Status__c = \'Completed\'' +
            dataOrder;
        List<Patient_Visit__c> queryResult = ((DatabaseProxy) ClassFactory.newInstance(
                DatabaseProxy.class
            ))
            .query(visitsQuery, true);
        if (!isAlumniParticipant) {
            Integer timeSharing =
                queryResult.size() -
                (pe.Clinical_Trial_Profile__r.Shareback_Availability_Timing__c.intValue());
            Map<String, Patient_Visit__c> visitResultGroupwithPatientVisitMap = new Map<String, Patient_Visit__c>();
            for (Integer i = queryResult.size() - 1; i >= 0; i--) {
                if (
                    (i + 1) <= timeSharing &&
                    queryResult.get(i).Visit_Results__r != null &&
                    !queryResult.get(i).Visit_Results__r.isEmpty() &&
                    visitResultGroupwithPatientVisitMap.keySet().size() < 3
                ) {
                    Set<String> visitResultGroupSet = visitResultAvailabilityByGroupForReport(
                        queryResult.get(i).Visit_Results__r
                    );
                    if (visitResultGroupSet != null && visitResultGroupSet.size() > 0) {
                        if (
                            visitResultGroupSet.contains(
                                VisitResultSharingService.VITAL_RECORDTYPE
                            ) &&
                            !visitResultGroupwithPatientVisitMap
                                .containsKey(VisitResultSharingService.VITAL_RECORDTYPE)
                        ) {
                            visitResultGroupwithPatientVisitMap.put(
                                VisitResultSharingService.VITAL_RECORDTYPE,
                                queryResult.get(i)
                            );
                            if (patientVisitbyVisitGroupMap.containsKey(queryResult.get(i).Id)) {
                                patientVisitbyVisitGroupMap.get(queryResult.get(i).Id)
                                    .add(VisitResultSharingService.VITAL_RECORDTYPE);
                            } else {
                                patientVisitbyVisitGroupMap.put(
                                    queryResult.get(i).Id,
                                    new Set<String>{ VisitResultSharingService.VITAL_RECORDTYPE }
                                );
                            }
                        }
                        if (
                            visitResultGroupSet.contains(
                                VisitResultSharingService.LAB_RECORDTYPE
                            ) &&
                            !visitResultGroupwithPatientVisitMap
                                .containsKey(VisitResultSharingService.LAB_RECORDTYPE)
                        ) {
                            visitResultGroupwithPatientVisitMap.put(
                                VisitResultSharingService.LAB_RECORDTYPE,
                                queryResult.get(i)
                            );
                            if (patientVisitbyVisitGroupMap.containsKey(queryResult.get(i).Id)) {
                                patientVisitbyVisitGroupMap.get(queryResult.get(i).Id)
                                    .add(VisitResultSharingService.LAB_RECORDTYPE);
                            } else {
                                patientVisitbyVisitGroupMap.put(
                                    queryResult.get(i).Id,
                                    new Set<String>{ VisitResultSharingService.LAB_RECORDTYPE }
                                );
                            }
                        }
                        if (
                            visitResultGroupSet.contains(
                                VisitResultSharingService.BIOMARKER_RECORDTYPE
                            ) &&
                            !visitResultGroupwithPatientVisitMap
                                .containsKey(VisitResultSharingService.BIOMARKER_RECORDTYPE)
                        ) {
                            visitResultGroupwithPatientVisitMap.put(
                                VisitResultSharingService.BIOMARKER_RECORDTYPE,
                                queryResult.get(i)
                            );
                            if (patientVisitbyVisitGroupMap.containsKey(queryResult.get(i).Id)) {
                                patientVisitbyVisitGroupMap.get(queryResult.get(i).Id)
                                    .add(VisitResultSharingService.BIOMARKER_RECORDTYPE);
                            } else {
                                patientVisitbyVisitGroupMap.put(
                                    queryResult.get(i).Id,
                                    new Set<String>{
                                        VisitResultSharingService.BIOMARKER_RECORDTYPE
                                    }
                                );
                            }
                        }
                    }
                }
            }
            Set<Patient_Visit__c> patientVisitSet = new Set<Patient_Visit__c>();
            List<Patient_Visit__c> patientVisitList = new List<Patient_Visit__c>();
            patientVisitSet.addAll(visitResultGroupwithPatientVisitMap.values());
            patientVisitList.addAll(patientVisitSet);
            return patientVisitList;
        }
        return queryResult;
    }

    public VisitResultsContainer getVisitResultsContainer(
        String visitResultsGroupName,
        Map<String, List<String>> visitResultSharings,
        Id ctpId,
        String mailingCC
    ) {
        List<Visit_Result_TypeM__mdt> visitResultTypes = this.metadataService.getVisitResultTypes(
            visitResultsGroupName
        );
        List<String> availableVisitResults = visitResultSharings.get(visitResultsGroupName);
        List<Visit_Result_TypeM__mdt> filteredVisitResultTypesIfAvailable = new List<Visit_Result_TypeM__mdt>();
        for (Visit_Result_TypeM__mdt visitResultTypeM : visitResultTypes) {
            if (availableVisitResults.contains(visitResultTypeM.DeveloperName))
                filteredVisitResultTypesIfAvailable.add(visitResultTypeM);
        }

        List<VisitResultSharingService.VisitResultWithAvailableSign> resultsWithAvailableSing = VisitResultSharingService.getVisitResultsWithAvailableCountry(
            VisitResultsRemote.getPatientVisits(),
            ctpId,
            mailingCC,
            visitResultsGroupName
        );

        if (!resultsWithAvailableSing.isEmpty()) {
            Patient_Visit__c patientVisit;
            for (
                VisitResultSharingService.VisitResultWithAvailableSign resultWithAvailableSign : resultsWithAvailableSing
            ) {
                if (resultWithAvailableSign.visitResult != null) {
                    patientVisit = resultWithAvailableSign.visitResult.Patient_Visit__r;
                    break;
                }
            }
            return new VisitResultsContainer(
                patientVisit,
                getVisitResultWrappers(
                    resultsWithAvailableSing,
                    filteredVisitResultTypesIfAvailable,
                    visitResultsGroupName,
                    ctpId
                ),
                TranslateHelper.getLabelValue('Visit_Result_Group_' + visitResultsGroupName)
            );
        }
        return null;
    }

    @testVisible
    private static Set<String> visitResultAvailabilityByGroupForReport(
        List<Visit_Result__c> visitResults
    ) {
        Boolean isVitalResult = false;
        Boolean isLabResult = false;
        Boolean isBiomarkerResult = false;
        Set<String> visitResultGroupSet = new Set<String>();

        for (Visit_Result__c objVisitResult : visitResults) {
            if (
                objVisitResult.recordType.DeveloperName ==
                VisitResultSharingService.VITAL_RECORDTYPE
            ) {
                isVitalResult = true;
            }
            if (
                objVisitResult.recordType.DeveloperName == VisitResultSharingService.LAB_RECORDTYPE
            ) {
                isLabResult = true;
            }
            if (
                objVisitResult.recordType.DeveloperName ==
                VisitResultSharingService.BIOMARKER_RECORDTYPE
            ) {
                isBiomarkerResult = true;
            }
        }
        if (isVitalResult) {
            visitResultGroupSet.add(VisitResultSharingService.VITAL_RECORDTYPE);
        }
        if (isLabResult) {
            visitResultGroupSet.add(VisitResultSharingService.LAB_RECORDTYPE);
        }
        if (isBiomarkerResult) {
            visitResultGroupSet.add(VisitResultSharingService.BIOMARKER_RECORDTYPE);
        }

        return visitResultGroupSet;
    }
    public static List<Visit_Result__c> getVisitResults(
        Id ctpId,
        String mailingCC,
        String visitResultGroup
    ) {
        List<VisitResultSharingService.VisitResultWithAvailableSign> resultsWithAvailableSing = VisitResultSharingService.getVisitResultsWithAvailableCountry(
            VisitResultsRemote.getPatientVisits(),
            ctpId,
            mailingCC,
            visitResultGroup
        );

        List<Visit_Result__c> visitResults = new List<Visit_Result__c>();
        for (
            VisitResultSharingService.VisitResultWithAvailableSign visitResultWithAvailableSign : resultsWithAvailableSing
        ) {
            if (visitResultWithAvailableSign.visitResult != null)
                visitResults.add(visitResultWithAvailableSign.visitResult);
        }

        return visitResults;
    }

    private List<VisitResultWrapper> getVisitResultWrappers(
        List<VisitResultSharingService.VisitResultWithAvailableSign> resultsWithAvailableSign,
        List<Visit_Result_TypeM__mdt> visitResultTypes,
        String visitResultGroupName,
        Id ctpId
    ) {
        Map<String, VisitResultSharingService.VisitResultWithAvailableSign> visitResultsByType = getVisitResultsByTypeDeveloperNames(
            resultsWithAvailableSign
        );
        String language;
        if (resultsWithAvailableSign != null && resultsWithAvailableSign.size() > 0) {
            for (
                VisitResultSharingService.VisitResultWithAvailableSign objVisitResultSign : resultsWithAvailableSign
            ) {
                if (objVisitResultSign.visitResult != null) {
                    language = IRBParticipantService.getSuitableLanguageForIRBTranslation(
                        objVisitResultSign.visitResult.Patient_Visit__r.Participant_Enrollment__c
                    );
                }
            }
        }
        List<Visit_Result_Type_Sharing__c> visitResulTypeSharingList = [
            SELECT Id, Custom_Tooltip__c, Type__c
            FROM Visit_Result_Type_Sharing__c
            WHERE Clinical_Trial_Profile__c = :ctpId
        ];
        if (visitResulTypeSharingList != null && visitResulTypeSharingList.size() > 0) {
            TranslateHelper.translate(visitResulTypeSharingList, language);
        }
        Map<String, String> visitResultTypeWithDesMap = new Map<String, String>();
        for (Visit_Result_Type_Sharing__c objVisitResultType : visitResulTypeSharingList) {
            if (!String.isBlank(objVisitResultType.Custom_Tooltip__c)) {
                visitResultTypeWithDesMap.put(
                    objVisitResultType.Type__c,
                    objVisitResultType.Custom_Tooltip__c
                );
            }
        }
        List<VisitResultWrapper> wrappers = new List<VisitResultWrapper>();
        for (Visit_Result_TypeM__mdt singleVRT : visitResultTypes) {
            String description = '';
            if (visitResultTypeWithDesMap.containsKey(singleVRT.DeveloperName)) {
                description = visitResultTypeWithDesMap.get(singleVRT.DeveloperName);
            }
            VisitResultSharingService.VisitResultWithAvailableSign resultWithAvailableSign = visitResultsByType.get(
                singleVRT.DeveloperName
            );
            if (resultWithAvailableSign == null || !resultWithAvailableSign.isCountryEnabled)
                continue;

            if (
                (visitResultGroupName == BIOMARKER_VISIT_RESULT_GROUP &&
                resultWithAvailableSign.visitResult != null) ||
                (visitResultGroupName != BIOMARKER_VISIT_RESULT_GROUP)
            ) {
                wrappers.add(
                    new VisitResultWrapper(
                        resultWithAvailableSign.visitResult,
                        TranslateHelper.getLabelValue(singleVRT.DeveloperName),
                        description == ''
                            ? TranslateHelper.getLabelValue(singleVRT.Description_Label_Api_Name__c)
                            : description,
                        this.visitResultsMeasurementNamesMap
                    )
                );
            }
        }
        return wrappers;
    }

    private Map<String, VisitResultSharingService.VisitResultWithAvailableSign> getVisitResultsByTypeDeveloperNames(
        List<VisitResultSharingService.VisitResultWithAvailableSign> resultWithAvailableCountries
    ) {
        Map<String, VisitResultSharingService.VisitResultWithAvailableSign> result = new Map<String, VisitResultSharingService.VisitResultWithAvailableSign>();
        for (
            VisitResultSharingService.VisitResultWithAvailableSign singleResult : resultWithAvailableCountries
        ) {
            String resultType = singleResult.visitResult != null
                ? singleResult.visitResult.Result_Type__c
                : singleResult.resultType;
            result.put(resultType, singleResult);
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
        @AuraEnabled
        public String visitName;
        @AuraEnabled
        public Date dateVisited;

        public VisitResultsContainer(
            Patient_Visit__c visit,
            List<VisitResultWrapper> wrappers,
            String groupName
        ) {
            this.wrappers = wrappers;
            if (visit != null && visit.Completed_Date__c != null) {
                if (String.isBlank(visit.Portal_Name__c)) {
                    this.visitName = System.Label.StudyVisit_Unscheduled_Visit;
                } else {
                    this.visitName = visit.Portal_Name__c;
                }
                Datetime dt = Datetime.newInstance(
                    visit.Completed_Date__c.year(),
                    visit.Completed_Date__c.month(),
                    visit.Completed_Date__c.day(),
                    0,
                    0,
                    0
                );
                this.visitDate = dt.format('dd-MMM-yyyy');
                this.dateVisited = visit.Completed_Date__c;
            } else {
                this.visitDate = Label.StudyVisit_Information_Not_Available;
            }
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
        public String visitName;
        @AuraEnabled
        public String measurement;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public String recordtype;
        @AuraEnabled
        public String visitDate;
        @AuraEnabled
        public Date dateVisited;
        @AuraEnabled
        public boolean isConversion;

        public VisitResultWrapper(Visit_Result__c visitResult, String name, String description) {
            this(visitResult, name, description, null);
        }

        public VisitResultWrapper(
            Visit_Result__c visitResult,
            String name,
            String description,
            Map<String, String> measurementNamesMap
        ) {
            this.name = name;
            this.description = description;
            if (visitResult != null) {
                this.value = visitResult.Actual_Value__c;
                this.minValue = visitResult.Min_Value__c;
                this.maxValue = visitResult.Max_Value__c;
                if (visitResult.Measurement__c != null) {
                    String measurementLowerCase = visitResult.Measurement__c.toLowerCase();
                    if (
                        measurementNamesMap != null &&
                        measurementNamesMap.containsKey(measurementLowerCase)
                    ) {
                        this.measurement = measurementNamesMap.get(measurementLowerCase)
                            .replace('/', ' / ');
                    } else {
                        this.measurement = visitResult.Measurement__c.replace('/', ' / ');
                    }
                }
            }
        }

        public VisitResultWrapper(Visit_Result__c visitResult, String name) {
            this(visitResult, name, new Map<String, String>());
        }

        public VisitResultWrapper(
            Visit_Result__c visitResult,
            String name,
            Map<String, String> measurementNamesMap
        ) {
            this.name = name;
            if (visitResult != null) {
                this.value = visitResult.Actual_Value__c;
                this.recordtype = visitResult.RecordType.DeveloperName;
                if (visitResult.Measurement__c != null) {
                    String measurementLowerCase = visitResult.Measurement__c.toLowerCase();
                    if (
                        measurementNamesMap != null &&
                        measurementNamesMap.containsKey(measurementLowerCase)
                    ) {
                        this.measurement = measurementNamesMap.get(measurementLowerCase)
                            .replace('/', ' / ');
                    } else {
                        this.measurement = visitResult.Measurement__c.replace('/', ' / ');
                    }
                }
                if (visitResult != null && visitResult.Patient_Visit__r.Completed_Date__c != null) {
                    if (String.isBlank(visitResult.Patient_Visit__r.Portal_Name__c)) {
                        this.visitName = System.Label.StudyVisit_Unscheduled_Visit;
                    } else {
                        this.visitName = visitResult.Patient_Visit__r.Portal_Name__c;
                    }
                    Datetime dt = Datetime.newInstance(
                        visitResult.Patient_Visit__r.Completed_Date__c.year(),
                        visitResult.Patient_Visit__r.Completed_Date__c.month(),
                        visitResult.Patient_Visit__r.Completed_Date__c.day(),
                        0,
                        0,
                        0
                    );
                    this.visitDate = dt.format('dd-MMM-yyyy');
                    this.dateVisited = visitResult.Patient_Visit__r.Completed_Date__c;
                } else {
                    this.visitDate = Label.StudyVisit_Information_Not_Available;
                }
            }
        }
    }
}
