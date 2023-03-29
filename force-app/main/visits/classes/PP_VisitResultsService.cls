public without sharing class PP_VisitResultsService {
    public static final String BIOMARKER_VISIT_RESULT_GROUP = 'Biomarkers';
    public static final String VITAL_VISIT_RESULT_GROUP = 'Vitals';
    public static final String LABS_VISIT_RESULT_GROUP = 'Labs';
    public static final String METABOLICPANEL = 'MetabolicPanel';
    public static final String HEMATOLOGY = 'Hematology';
    public static final String FASTING_LIPID_PROFILE = 'FastingLipidProfile';

    /**RK START*/
    @AuraEnabled
    public static PPInitDataWrapper getInitDataPP(Integer ctpSharingTiming, String patientVisitId) {
        PPInitDataWrapper wrapper = (PPInitDataWrapper) ClassFactory.newInstance(
            PPInitDataWrapper.class
        );

        if (checkDataSharebackTiming(ctpSharingTiming, patientVisitId)) {
            /**CTP level configuration in Map*/
            Map<String, Map<String, List<String>>> visitResultSharings = VisitResultSharingService.visitResultSharingByGroupAndModeAndCountry();
            if (visitResultSharings != null) {
                wrapper.visitResultWithSubTypesCTP = visitResultSharings;
            }

            Set<String> visitResultSubTypeSet = new Set<String>();
            wrapper.visitResultsShares = new Map<String, List<String>>();
            Participant_Enrollment__c currentPE = ParticipantContext.getCurrentPE();
            for (String visitResultTypeCTP : visitResultSharings.keySet()) {
                Map<String, List<String>> visitResultTypeWithSubTypeCTP = visitResultSharings.get(
                    visitResultTypeCTP
                );
                if (visitResultTypeCTP == 'Vitals') {
                    wrapper.toggleStateForVitals = toggleStateForPP(visitResultTypeCTP, currentPE);
                } else if (visitResultTypeCTP == 'Labs') {
                    wrapper.toggleStateForLabs = toggleStateForPP(visitResultTypeCTP, currentPE);
                } else if (visitResultTypeCTP == 'Biomarkers') {
                    wrapper.toggleStateForBiomarkers = toggleStateForPP(
                        visitResultTypeCTP,
                        currentPE
                    );
                }
                for (String visitResultTypeInner : visitResultTypeWithSubTypeCTP.keySet()) {
                    List<String> subTypeSet = visitResultTypeWithSubTypeCTP.get(
                        visitResultTypeInner
                    );
                    visitResultSubTypeSet.addAll(subTypeSet);
                    if (wrapper.visitResultsShares.containsKey(visitResultTypeCTP)) {
                        List<String> subTypeList = wrapper.visitResultsShares.get(
                            visitResultTypeCTP
                        );
                        subTypeList.addAll(subTypeSet);
                    } else {
                        wrapper.visitResultsShares.put(visitResultTypeCTP, subTypeSet);
                    }
                }
            }

            List<Visit_Result__c> visResults = [
                SELECT
                    Id,
                    Actual_Value__c,
                    Max_Value__c,
                    Measurement__c,
                    Min_Value__c,
                    Patient_Visit__r.Completed_Date__c,
                    Patient_Visit__r.Portal_Name__c,
                    Patient_Visit__r.Participant_Enrollment__c,
                    Result_Type__c,
                    RecordType.DeveloperName
                FROM Visit_Result__c
                WHERE
                    Patient_Visit__c = :patientVisitId
                    AND Result_Type__c IN :visitResultSubTypeSet
            ];

            wrapper.visitResultsGroupNamesCTP = new List<String>(visitResultSharings.keySet());
            if (visResults != null && !visResults.isEmpty()) {
                wrapper.isVisitResultsAvailable = false;
                for (Visit_Result__c vr : visResults) {
                    List<String> subTypesList = wrapper.visitResultsShares.get(
                        vr.RecordType.DeveloperName + 's'
                    );
                    if (subTypesList != null && subTypesList.contains(vr.Result_Type__c)) {
                        wrapper.isVisitResultsAvailable = true;
                        break;
                    }
                }
            } else {
                wrapper.isVisitResultsAvailable = false;
            }
            wrapper.isDelegate = ParticipantContext.isCurrentDelegate();
            return wrapper;
        } else {
            wrapper.isVisitResultsAvailable = false;
            return wrapper;
        }
    }

    public static Boolean checkDataSharebackTiming(
        Integer ctpSharingTiming,
        String patientVisitId
    ) {
        List<Patient_Visit__c> patientVisitList = getPatientVisitsForPP();
        /**checking CTP level Data Shareback Timing Configuration*/
        if (
            patientVisitList == null ||
            (patientVisitList != null &&
            patientVisitList.size() <= ctpSharingTiming)
        ) {
            return false;
        } else {
            for (Integer i = 0; i < patientVisitList.size(); i++) {
                if (patientVisitList[i].Id == patientVisitId) {
                    Integer patientVisitPosition = i + 1;
                    if (patientVisitPosition > ctpSharingTiming) {
                        return true;
                    } else {
                        return false;
                    }
                }
            }
            return false;
        }
    }

    /**Returns toggle state for specific visit result type configured at PE level*/
    @AuraEnabled
    public static Boolean toggleStateForPP(
        String visitResultsMode,
        Participant_Enrollment__c currentPE
    ) {
        String currentVisitResults = currentPE == null ||
            currentPE.Visit_Results_Opt_In__c == null
            ? ''
            : currentPE.Visit_Results_Opt_In__c;
        return currentVisitResults.contains(visitResultsMode);
    }

    @AuraEnabled
    public static void switchToggleRemoteForPP(String visitResultsMode, Boolean isToggleOn) {
        Participant_Enrollment__c currentPE = ParticipantContext.getCurrentPE();
        String currentVisitResults = currentPE.Visit_Results_Opt_In__c == null
            ? ''
            : currentPE.Visit_Results_Opt_In__c;
        String updatedVisitResults = '';
        if (isToggleOn) {
            if (!currentVisitResults.contains(visitResultsMode)) {
                updatedVisitResults = currentVisitResults + ';' + visitResultsMode;
            }
        } else {
            List<String> visitResults = currentVisitResults.split(';');
            for (String str : visitResults) {
                if (!str.equals(visitResultsMode))
                    updatedVisitResults += str + ';';
            }
        }
        currentPE.Visit_Results_Opt_In__c = updatedVisitResults;
        update currentPE;
    }

    public static List<Patient_Visit__c> getPatientVisitsForPP() {
        if (!isOnStudy())
            return new List<Patient_Visit__c>();

        return [
            SELECT Id, Completed_Date__c, Visit_Number__c
            FROM Patient_Visit__c
            WHERE
                Participant_Enrollment__c = :ParticipantContext.getCurrentPEId()
                AND Status__c = 'Completed'
            ORDER BY Visit_Number__c, Completed_Date__c
        ];
    }

    public static Boolean isOnStudy() {
        ParticipantService.ParticipantState participantState = ParticipantService.getParticipantState();
        if (
            PEStatusState.PE_STATUS_GROUP_PARTICIPATION_IN_PROGRESS.contains(
                participantState.pe.Participant_Status__c
            ) ||
            PEStatusState.PE_STATUS_GROUP_COMPLETE.contains(
                participantState.pe.Participant_Status__c
            )
        ) {
            return true;
        }
        return false;
    }

    public class PPInitDataWrapper {
        @AuraEnabled
        public Boolean isDelegate;
        @AuraEnabled
        public Boolean isVisitResultsAvailable;
        @AuraEnabled
        public Map<String, List<String>> visitResultsShares;
        @AuraEnabled
        public Boolean toggleStateForVitals;
        @AuraEnabled
        public Boolean toggleStateForLabs;
        @AuraEnabled
        public Boolean toggleStateForBiomarkers;
        @AuraEnabled
        public Map<String, Map<String, List<String>>> visitResultWithSubTypesCTP;

        @AuraEnabled
        public List<String> visitResultsGroupNamesCTP;

        public PPInitDataWrapper() {
            this.isVisitResultsAvailable = false;
        }
    }

    /**RK END*/

    /*Jayashree J*/
    /* Returns the visit results for the visit tesult mode selected*/
    @AuraEnabled
    public static List<PP_VisitResultsContainer> ppVisitResultsWrapper(
        String ctpId,
        String patientVisitId,
        String participantMailingCC,
        Map<String, Map<String, List<String>>> allVisResultCategories,
        String visitResultsMode
    ) {
        List<PP_VisitResultsContainer> finalResults = new List<PP_VisitResultsContainer>();

        Map<String, List<String>> visitResultSharings = new Map<String, List<String>>();
        Map<String, List<String>> visitResultSharingsForLabs = new Map<String, List<String>>();

        try {
            for (String category : allVisResultCategories.keySet()) {
                if (category == visitResultsMode) {
                    if (visitResultsMode == LABS_VISIT_RESULT_GROUP)
                        visitResultSharingsForLabs = allVisResultCategories.get(category);
                    else
                        visitResultSharings = allVisResultCategories.get(category);
                }
            }
            // Fetch visit results for patient visit ID
            List<Visit_Result__c> visResults = [
                SELECT
                    Id,
                    Actual_Value__c,
                    Max_Value__c,
                    Measurement__c,
                    Min_Value__c,
                    Patient_Visit__r.Completed_Date__c,
                    Patient_Visit__r.Portal_Name__c,
                    Patient_Visit__r.Participant_Enrollment__c,
                    Result_Type__c,
                    RecordType.DeveloperName
                FROM Visit_Result__c
                WHERE Patient_Visit__c = :patientVisitId
            ];

            //Form visit result wrapper for Labs
            if (visitResultSharingsForLabs.size() > 0) {
                Map<String, Visit_Result__c> existingVisResultsMap = new Map<String, Visit_Result__c>();

                for (Visit_Result__c result : visResults)
                    existingVisResultsMap.put(result.Result_Type__c, result);

                VisitResultMService metadataService = new VisitResultMService();

                List<Visit_Result_TypeM__mdt> visitResultMDTypesMetbPan;
                List<Visit_Result_TypeM__mdt> visitResultMDTypesHea;
                List<Visit_Result_TypeM__mdt> visitResultMDTypesFLP;

                Map<String, String> visitResultsMeasurementNamesMap = metadataService.getVisitResultsMeasurementNamesMap();
                List<String> enabledVisitResultsOnCtp = new List<String>();
                for (String subType : visitResultSharingsForLabs.keySet()) {
                    if (subType == METABOLICPANEL) {
                        visitResultMDTypesMetbPan = metadataService.getVisitResultTypes(subType);
                        enabledVisitResultsOnCtp.addAll(visitResultSharingsForLabs.get(subType));
                    }
                    if (subType == HEMATOLOGY) {
                        visitResultMDTypesHea = metadataService.getVisitResultTypes(subType);
                        enabledVisitResultsOnCtp.addAll(visitResultSharingsForLabs.get(subType));
                    }
                    if (subType == FASTING_LIPID_PROFILE) {
                        visitResultMDTypesFLP = metadataService.getVisitResultTypes(subType);
                        enabledVisitResultsOnCtp.addAll(visitResultSharingsForLabs.get(subType));
                    }
                }

                List<Visit_Result_TypeM__mdt> filteredVisResMDTypesMB = new List<Visit_Result_TypeM__mdt>();
                List<Visit_Result_TypeM__mdt> filteredVisResMDTypesHea = new List<Visit_Result_TypeM__mdt>();
                List<Visit_Result_TypeM__mdt> filteredVisResMDTypesFLP = new List<Visit_Result_TypeM__mdt>();

                //Filter metadata records for vis results enabled on CTP
                for (Visit_Result_TypeM__mdt visitResultTypeM : visitResultMDTypesMetbPan) {
                    if (enabledVisitResultsOnCtp.contains(visitResultTypeM.DeveloperName))
                        filteredVisResMDTypesMB.add(visitResultTypeM);
                }
                for (Visit_Result_TypeM__mdt visitResultTypeM : visitResultMDTypesHea) {
                    if (enabledVisitResultsOnCtp.contains(visitResultTypeM.DeveloperName))
                        filteredVisResMDTypesHea.add(visitResultTypeM);
                }
                for (Visit_Result_TypeM__mdt visitResultTypeM : visitResultMDTypesFLP) {
                    if (enabledVisitResultsOnCtp.contains(visitResultTypeM.DeveloperName))
                        filteredVisResMDTypesFLP.add(visitResultTypeM);
                }

                String mailingCountryCode = String.isNotEmpty(participantMailingCC)
                    ? participantMailingCC
                    : '';
                List<Visit_Result_Type_Sharing__c> visitResultTypeSharing = [
                    SELECT
                        Id,
                        Include_Countries__c,
                        Sharing_Countries__c,
                        Type__c,
                        Custom_Tooltip__c
                    FROM Visit_Result_Type_Sharing__c
                    WHERE
                        Clinical_Trial_Profile__c = :ctpId
                        AND Type__c IN :enabledVisitResultsOnCtp
                ];
                Map<String, Visit_Result_Type_Sharing__c> visitResultTypeSharingByType = new Map<String, Visit_Result_Type_Sharing__c>();

                for (Visit_Result_Type_Sharing__c resultType : visitResultTypeSharing)
                    visitResultTypeSharingByType.put(resultType.Type__c, resultType);

                //Map of result type and available visit results
                Map<String, Visit_Result__c> resultTypeWithVisRes = new Map<String, Visit_Result__c>();

                for (String resultType : visitResultTypeSharingByType.keySet()) {
                    Visit_Result__c res = existingVisResultsMap.get(resultType);
                    if (res != null)
                        resultTypeWithVisRes.put(resultType, res);
                    else
                        resultTypeWithVisRes.put(resultType, null);
                }

                //Fetch language of participant for translation
                String language = getLanguage(resultTypeWithVisRes);

                if (
                    filteredVisResMDTypesMB.size() > 0 &&
                    visitResultSharingsForLabs.containsKey(METABOLICPANEL)
                ) {
                    PP_VisitResultsContainer visitResultsContainer = formResultWrapper(
                        filteredVisResMDTypesMB,
                        METABOLICPANEL,
                        null,
                        resultTypeWithVisRes
                    );
                    finalResults.add(visitResultsContainer);
                }
                if (
                    filteredVisResMDTypesHea.size() > 0 &&
                    visitResultSharingsForLabs.containsKey(HEMATOLOGY)
                ) {
                    PP_VisitResultsContainer visitResultsContainer = formResultWrapper(
                        filteredVisResMDTypesHea,
                        HEMATOLOGY,
                        null,
                        resultTypeWithVisRes
                    );
                    finalResults.add(visitResultsContainer);
                }
                if (
                    filteredVisResMDTypesFLP.size() > 0 &&
                    visitResultSharingsForLabs.containsKey(FASTING_LIPID_PROFILE)
                ) {
                    PP_VisitResultsContainer visitResultsContainer = formResultWrapper(
                        filteredVisResMDTypesFLP,
                        FASTING_LIPID_PROFILE,
                        null,
                        resultTypeWithVisRes
                    );
                    finalResults.add(visitResultsContainer);
                }
            } else {
                //Form visit result wrapper for Vitals/Biomarkers
                //Form Map of Type and Visit results
                Map<String, Visit_Result__c> existingVisResultsMap = new Map<String, Visit_Result__c>();

                for (Visit_Result__c result : visResults)
                    existingVisResultsMap.put(result.Result_Type__c, result);

                //Fetch metadata records for Visit Result mode- lab:biomarker:vitals
                VisitResultMService metadataService = new VisitResultMService();

                List<Visit_Result_TypeM__mdt> visitResultMDTypes = metadataService.getVisitResultTypes(
                    visitResultsMode
                );

                Map<String, String> visitResultsMeasurementNamesMap = metadataService.getVisitResultsMeasurementNamesMap();

                List<String> enabledVisitResultsOnCtp = visitResultSharings.get(visitResultsMode);

                List<Visit_Result_TypeM__mdt> filteredVisResMDTypes = new List<Visit_Result_TypeM__mdt>();

                //Filter metadata records for vis results enabled on CTP
                for (Visit_Result_TypeM__mdt visitResultTypeM : visitResultMDTypes) {
                    if (
                        enabledVisitResultsOnCtp != null &&
                        enabledVisitResultsOnCtp.contains(visitResultTypeM.DeveloperName)
                    )
                        filteredVisResMDTypes.add(visitResultTypeM);
                }

                String mailingCountryCode = String.isNotEmpty(participantMailingCC)
                    ? participantMailingCC
                    : '';

                List<Visit_Result_Type_Sharing__c> visitResultTypeSharing = [
                    SELECT
                        Id,
                        Include_Countries__c,
                        Sharing_Countries__c,
                        Type__c,
                        Custom_Tooltip__c
                    FROM Visit_Result_Type_Sharing__c
                    WHERE
                        Clinical_Trial_Profile__c = :ctpId
                        AND Type__c IN :enabledVisitResultsOnCtp
                ];

                Map<String, Visit_Result_Type_Sharing__c> visitResultTypeSharingByType = new Map<String, Visit_Result_Type_Sharing__c>();

                Map<String, String> visitResultTypeWithCusToolMap = new Map<String, String>();

                for (Visit_Result_Type_Sharing__c resultType : visitResultTypeSharing) {
                    visitResultTypeSharingByType.put(resultType.Type__c, resultType);
                    if (!String.isBlank(resultType.Custom_Tooltip__c)) {
                        visitResultTypeWithCusToolMap.put(
                            resultType.Type__c,
                            resultType.Custom_Tooltip__c
                        );
                    }
                }

                //Map of result type and available visit results
                Map<String, Visit_Result__c> resultTypeWithVisRes = new Map<String, Visit_Result__c>();

                for (String resultType : visitResultTypeSharingByType.keySet()) {
                    Visit_Result__c res = existingVisResultsMap.get(resultType);
                    if (res != null)
                        resultTypeWithVisRes.put(resultType, res);
                    else
                        resultTypeWithVisRes.put(resultType, null);
                }

                //Fetch language of participant for translation
                String language = getLanguage(resultTypeWithVisRes);

                if (visitResultTypeSharing != null && visitResultTypeSharing.size() > 0) {
                    TranslateHelper.translate(visitResultTypeSharing, language);
                }
                PP_VisitResultsContainer visitResultsContainer = formResultWrapper(
                    filteredVisResMDTypes,
                    visitResultsMode,
                    visitResultTypeWithCusToolMap,
                    resultTypeWithVisRes
                );
                finalResults.add(visitResultsContainer);
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }

        return finalResults;
    }

    public static String getLanguage(Map<String, Visit_Result__c> resultTypeWithVisRes) {
        String lang;
        if (resultTypeWithVisRes != null && resultTypeWithVisRes.size() > 0) {
            for (String visResType : resultTypeWithVisRes.keySet()) {
                Visit_Result__c res = resultTypeWithVisRes.get(visResType);
                if (res != null) {
                    lang = IRBParticipantService.getSuitableLanguageForIRBTranslation(
                        res.Patient_Visit__r.Participant_Enrollment__c
                    );
                }
            }
        }
        return lang;
    }

    public static PP_VisitResultsContainer formResultWrapper(
        List<Visit_Result_TypeM__mdt> filteredVisResMDTypes,
        String visitResultsMode,
        Map<String, String> visitResultTypeWithCusToolMap,
        Map<String, Visit_Result__c> resultTypeWithVisRes
    ) {
        Boolean isResultAvailable = false;

        List<PP_VisitResultWrapper> finalWrapper = new List<PP_VisitResultWrapper>();

        VisitResultMService metadataService = new VisitResultMService();
        Map<String, String> visitResultsMeasurementNamesMap = metadataService.getVisitResultsMeasurementNamesMap();

        List<PP_VisitResultWrapper> wrappersWithVisRes = new List<PP_VisitResultWrapper>();
        List<PP_VisitResultWrapper> wrappersWithOutVisRes = new List<PP_VisitResultWrapper>();

        //Form result wrapper
        for (Visit_Result_TypeM__mdt singleVRT : filteredVisResMDTypes) {
            String description = '';
            if (
                visitResultTypeWithCusToolMap != null &&
                visitResultTypeWithCusToolMap.containsKey(singleVRT.DeveloperName)
            ) {
                description = visitResultTypeWithCusToolMap.get(singleVRT.DeveloperName);
            }

            Visit_Result__c visitResult = resultTypeWithVisRes.get(singleVRT.DeveloperName);
            if (visitResult != null) {
                if (
                    (visitResultsMode == BIOMARKER_VISIT_RESULT_GROUP && visitResult != null) ||
                    (visitResultsMode != BIOMARKER_VISIT_RESULT_GROUP)
                ) {
                    wrappersWithVisRes.add(
                        new PP_VisitResultWrapper(
                            visitResult,
                            TranslateHelper.getLabelValue(singleVRT.DeveloperName),
                            description == ''
                                ? TranslateHelper.getLabelValue(
                                      singleVRT.Description_Label_Api_Name__c
                                  )
                                : description,
                            visitResultsMeasurementNamesMap
                        )
                    );
                }
            } else {
                if (visitResultsMode != BIOMARKER_VISIT_RESULT_GROUP) {
                    wrappersWithOutVisRes.add(
                        new PP_VisitResultWrapper(
                            visitResult,
                            TranslateHelper.getLabelValue(singleVRT.DeveloperName),
                            description == ''
                                ? TranslateHelper.getLabelValue(
                                      singleVRT.Description_Label_Api_Name__c
                                  )
                                : description,
                            visitResultsMeasurementNamesMap
                        )
                    );
                }
            }
        }
        if (wrappersWithVisRes.size() > 0) {
            finalWrapper.addAll(wrappersWithVisRes);
            isResultAvailable = true;
        }
        if (wrappersWithOutVisRes.size() > 0) {
            finalWrapper.addAll(wrappersWithOutVisRes);
        }
        return new PP_VisitResultsContainer(
            finalWrapper,
            isResultAvailable,
            TranslateHelper.getLabelValue('Visit_Result_Group_' + visitResultsMode)
        );
    }

    public class PP_VisitResultsContainer {
        @AuraEnabled
        public List<PP_VisitResultWrapper> resWrappers;
        @AuraEnabled
        public Boolean isResultsAvailable;
        @AuraEnabled
        public String resultsModeName;
        PP_VisitResultsContainer() {
        }
        PP_VisitResultsContainer(
            List<PP_VisitResultWrapper> resWrappers,
            Boolean isResultsAvailable,
            String resultsModeName
        ) {
            this.resWrappers = resWrappers;
            this.isResultsAvailable = isResultsAvailable;
            this.resultsModeName = resultsModeName;
        }
    }

    public class PP_VisitResultWrapper {
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

        public PP_VisitResultWrapper(
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
                        this.measurement = measurementNamesMap.get(measurementLowerCase);
                    } else {
                        this.measurement = visitResult.Measurement__c;
                    }
                }
            }
        }
    }
}
