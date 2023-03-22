public without sharing class PP_VisitResultsService {
    public static final String BIOMARKER_VISIT_RESULT_GROUP = 'Biomarkers';
    public static final String VITAL_VISIT_RESULT_GROUP = 'Vitals';
    public static final String LABS_VISIT_RESULT_GROUP = 'Labs';
    public static final String METABOLICPANEL = 'MetabolicPanel';
    public static final String HEMATOLOGY = 'Hematology';
    public static final String FASTING_LIPID_PROFILE = 'FastingLipidProfile';
    public static Boolean isMetabolicPanel = false;
    public static Boolean isHematology = false;
    public static Boolean isFastingLipidProfile = false;

    @AuraEnabled
    public static PP_VisitResultsContainer ppVisitResultsWrapper1() {
        PP_VisitResultsContainer finalRes = new PP_VisitResultsContainer();
        Map<String, List<VisitResultsService.VisitResultWrapper>> wrapper = new Map<String, List<VisitResultsService.VisitResultWrapper>>();
        String visitResultsMode;
        Map<String, List<String>> visitResultSharings;
        Map<String, List<String>> visitResultSharingsForLabs = new Map<String, List<String>>();
        Map<String, List<String>> visitResultSharingsDummy = new Map<String, List<String>>();
        //  List<String> li=new List<String>();
        //li.add('ICOS_Peritumoral');
        //li.add('Height');
        //li.add('Systolic_Blood_Pr');
        //li.add('Respiratory_Rate');
        //visitResultSharingsDummy.put('Biomarkers',li);
        Map<String, Map<String, List<String>>> visResultsSharing = new Map<String, Map<String, List<String>>>();
        Map<String, List<String>> visitTrial = new Map<String, List<String>>();
        List<String> MBP = new List<String>();
        MBP.add('BUN');
        MBP.add('ALT');
        MBP.add('Albumin');
        MBP.add('Calcium');
        List<String> HEA = new List<String>{ 'WBC_Count', 'RBC_Count', 'Platelet_Count' };
        List<String> FLP = new List<String>{ 'Total_Cholesterol', 'Triglycerides' };
        visitTrial.put(METABOLICPANEL, MBP);
        visitTrial.put(HEMATOLOGY, HEA);
        visitTrial.put(FASTING_LIPID_PROFILE, FLP);
        visResultsSharing.put('Labs', visitTrial);

        //    visResultsSharing.put('Biomarkers',visitResultSharingsDummy);

        Map<String, Map<String, List<String>>> resMap = new Map<String, Map<String, List<String>>>();
        String participantMailingCC = 'US';
        String ctpId = 'a0E6s000002vqc2EAA';
        String patientVisitId = 'a136s000000j1KoAAI';
        try {
            for (String categories : visResultsSharing.keySet()) {
                if (categories == LABS_VISIT_RESULT_GROUP)
                    visitResultSharingsForLabs = visResultsSharing.get(categories);
                else
                    visitResultSharings = visResultsSharing.get(categories);
                visitResultsMode = categories;
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
                    List<VisitResultsService.VisitResultWrapper> mPResWrapper = formResultWrapper(
                        filteredVisResMDTypesMB,
                        METABOLICPANEL,
                        null,
                        resultTypeWithVisRes
                    );
                    wrapper.put(
                        TranslateHelper.getLabelValue('Visit_Result_Group_' + METABOLICPANEL),
                        mPResWrapper
                    );
                }
                if (
                    filteredVisResMDTypesHea.size() > 0 &&
                    visitResultSharingsForLabs.containsKey(HEMATOLOGY)
                ) {
                    List<VisitResultsService.VisitResultWrapper> mPResWrapper = formResultWrapper(
                        filteredVisResMDTypesHea,
                        HEMATOLOGY,
                        null,
                        resultTypeWithVisRes
                    );
                    wrapper.put(
                        TranslateHelper.getLabelValue('Visit_Result_Group_' + HEMATOLOGY),
                        mPResWrapper
                    );
                }
                if (
                    filteredVisResMDTypesFLP.size() > 0 &&
                    visitResultSharingsForLabs.containsKey(FASTING_LIPID_PROFILE)
                ) {
                    List<VisitResultsService.VisitResultWrapper> mPResWrapper = formResultWrapper(
                        filteredVisResMDTypesFLP,
                        FASTING_LIPID_PROFILE,
                        null,
                        resultTypeWithVisRes
                    );
                    wrapper.put(
                        TranslateHelper.getLabelValue(
                            'Visit_Result_Group_' + FASTING_LIPID_PROFILE
                        ),
                        mPResWrapper
                    );
                }
                finalRes.resWrappers = wrapper;
            } else {
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
                List<VisitResultsService.VisitResultWrapper> resWrapper = formResultWrapper(
                    filteredVisResMDTypes,
                    visitResultsMode,
                    visitResultTypeWithCusToolMap,
                    resultTypeWithVisRes
                );
                wrapper.put(
                    TranslateHelper.getLabelValue('Visit_Result_Group_' + visitResultsMode),
                    resWrapper
                );
                finalRes.resWrappers = wrapper;
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }

        return finalRes;
    }

    @AuraEnabled
    public static PP_VisitResultsContainer ppVisitResultsWrapper(
        String ctpId,
        String patientVisitId,
        String participantMailingCC,
        Map<String, Map<String, List<String>>> allVisResultCategories
    ) {
        PP_VisitResultsContainer finalRes = new PP_VisitResultsContainer();
        Map<String, List<VisitResultsService.VisitResultWrapper>> wrapper = new Map<String, List<VisitResultsService.VisitResultWrapper>>();
        String visitResultsMode;
        Map<String, List<String>> visitResultSharings = new Map<String, List<String>>();
        Map<String, List<String>> visitResultSharingsForLabs = new Map<String, List<String>>();

        try {
            for (String category : allVisResultCategories.keySet()) {
                if (category == LABS_VISIT_RESULT_GROUP)
                    visitResultSharingsForLabs = allVisResultCategories.get(category);
                else
                    visitResultSharings = allVisResultCategories.get(category);
                visitResultsMode = category;
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
                    List<VisitResultsService.VisitResultWrapper> mPResWrapper = formResultWrapper(
                        filteredVisResMDTypesMB,
                        METABOLICPANEL,
                        null,
                        resultTypeWithVisRes
                    );
                    wrapper.put(
                        TranslateHelper.getLabelValue('Visit_Result_Group_' + METABOLICPANEL),
                        mPResWrapper
                    );
                }
                if (
                    filteredVisResMDTypesHea.size() > 0 &&
                    visitResultSharingsForLabs.containsKey(HEMATOLOGY)
                ) {
                    List<VisitResultsService.VisitResultWrapper> mPResWrapper = formResultWrapper(
                        filteredVisResMDTypesHea,
                        HEMATOLOGY,
                        null,
                        resultTypeWithVisRes
                    );
                    wrapper.put(
                        TranslateHelper.getLabelValue('Visit_Result_Group_' + HEMATOLOGY),
                        mPResWrapper
                    );
                }
                if (
                    filteredVisResMDTypesFLP.size() > 0 &&
                    visitResultSharingsForLabs.containsKey(FASTING_LIPID_PROFILE)
                ) {
                    List<VisitResultsService.VisitResultWrapper> mPResWrapper = formResultWrapper(
                        filteredVisResMDTypesFLP,
                        FASTING_LIPID_PROFILE,
                        null,
                        resultTypeWithVisRes
                    );
                    wrapper.put(
                        TranslateHelper.getLabelValue(
                            'Visit_Result_Group_' + FASTING_LIPID_PROFILE
                        ),
                        mPResWrapper
                    );
                }
                finalRes.resWrappers = wrapper;
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
                List<VisitResultsService.VisitResultWrapper> resWrapper = formResultWrapper(
                    filteredVisResMDTypes,
                    visitResultsMode,
                    visitResultTypeWithCusToolMap,
                    resultTypeWithVisRes
                );
                wrapper.put(
                    TranslateHelper.getLabelValue('Visit_Result_Group_' + visitResultsMode),
                    resWrapper
                );
                finalRes.resWrappers = wrapper;
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }

        return finalRes;
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

    public static List<VisitResultsService.VisitResultWrapper> formResultWrapper(
        List<Visit_Result_TypeM__mdt> filteredVisResMDTypes,
        String visitResultsMode,
        Map<String, String> visitResultTypeWithCusToolMap,
        Map<String, Visit_Result__c> resultTypeWithVisRes
    ) {
        List<VisitResultsService.VisitResultWrapper> finalWrapper = new List<VisitResultsService.VisitResultWrapper>();
        VisitResultMService metadataService = new VisitResultMService();
        Map<String, String> visitResultsMeasurementNamesMap = metadataService.getVisitResultsMeasurementNamesMap();

        List<VisitResultsService.VisitResultWrapper> wrappersWithVisRes = new List<VisitResultsService.VisitResultWrapper>();
        List<VisitResultsService.VisitResultWrapper> wrappersWithOutVisRes = new List<VisitResultsService.VisitResultWrapper>();

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
                        new VisitResultsService.VisitResultWrapper(
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
                        new VisitResultsService.VisitResultWrapper(
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
        }
        if (wrappersWithOutVisRes.size() > 0) {
            finalWrapper.addAll(wrappersWithOutVisRes);
        }
        return finalWrapper;
    }

    public class PP_VisitResultsContainer {
        @AuraEnabled
        public Map<String, List<VisitResultsService.VisitResultWrapper>> resWrappers;
        PP_VisitResultsContainer() {
        }
    }
}
