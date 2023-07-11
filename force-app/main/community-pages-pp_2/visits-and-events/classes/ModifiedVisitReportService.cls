public without sharing class ModifiedVisitReportService {
    public static final String VISIT_RECORD_TYPE_LABS = 'Labs';
    public static final String VISIT_RES_RECORD_TYPE_BIO = 'Biomarker';
    public static final String VISIT_RES_BIOMARKER_TYPE = 'Biomarkers';
    public static String userLanguage;

    public ModifiedVisitReportContainerRemote.ReportDataWrapper getReportDataWrapper(
        Id peId,
        Id patientVisitId
    ) {
        Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(
            peId,
            CommunityService.USER_MODE_PARTICIPANT
        );
        VisitResultsService visitResultsService = ((VisitResultsService) ClassFactory.newInstance(
            VisitResultsService.class
        ));
        VisitResultMService visitResultMService = ((VisitResultMService) ClassFactory.newInstance(
            VisitResultMService.class
        ));
        setLanguage(peId);
        ModifiedVisitResultsService modifiedVisitResultService = ((ModifiedVisitResultsService) ClassFactory.newInstance(
            ModifiedVisitResultsService.class
        ));

        List<Patient_Visit__c> patientVisits = modifiedVisitResultService.getPatientVisitsForReports(
            patientVisitId,
            pe
        );

        List<Visit_Result_GroupM__mdt> visitResultGroupMS = visitResultMService.getVisitResultGroups(
            true,
            null
        );
        Map<String, ModifiedVisitReportContainerRemote.ReportDataTableWrapper> reportDataWrapperMap = getDataTableWrappersByGroupName(
            pe,
            patientVisits,
            visitResultGroupMS
        );

        return getFillReportData(reportDataWrapperMap, visitResultGroupMS, pe);
    }

    public void setLanguage(String peId) {
        ModifiedVisitReportService.userLanguage = IRBParticipantService.getSuitableLanguageForIRBTranslation(
            peId
        );
        if (ModifiedVisitReportService.userLanguage == null)
            ModifiedVisitReportService.userLanguage = UserInfo.getLanguage();
    }

    @TestVisible
    private Map<String, ModifiedVisitReportContainerRemote.ReportDataTableWrapper> getDataTableWrappersByGroupName(
        Participant_Enrollment__c pe,
        List<Patient_Visit__c> patientVisits,
        List<Visit_Result_GroupM__mdt> visitResultGroupMS
    ) {
        VisitResultSharingService visitResultSharingServiceInt = ((VisitResultSharingService) ClassFactory.newInstance(
            VisitResultSharingService.class
        ));
        Map<String, ModifiedVisitReportContainerRemote.ReportDataTableWrapper> result = new Map<String, ModifiedVisitReportContainerRemote.ReportDataTableWrapper>();
        //Fetches available Visit result sharing types on CTP for PE
        Map<Id, List<VisitReportService.VisitResultWrapper>> availableVisitResultTypeMSByGroupIds = visitResultSharingServiceInt.geAvailableVisitResultTypeMSByGroupIds(
            pe,
            visitResultGroupMS
        );
        //Map of patient visit If,reslt type and results
        Map<Id, Map<String, Visit_Result__c>> availableVisitResultsByPatientVisitIds = visitResultSharingServiceInt.getAvailableVisitResultsByPatientVisitIds(
            pe,
            patientVisits
        );

        Set<String> notAccessResultType = visitResultSharingServiceInt.getNotAccessResultType();
        Map<String, Visit_Result__c> accessVisitResultMap = new Map<String, Visit_Result__c>();
        Map<String, String> visitResultTypeSharingWithDesMap = new Map<String, String>();
        Set<String> biomarkerLabDes = new Set<String>();
        if (pe.Clinical_Trial_Profile__c != null) {
            Map<String, Visit_Result_Type_Sharing__c> visitResultTypeSharingByType = visitResultSharingServiceInt.getVisitResultTypeSharingMap(
                pe.Clinical_Trial_Profile__c
            );

            if (
                visitResultTypeSharingByType != null &&
                visitResultTypeSharingByType.values().size() > 0
            ) {
                //Do language translation
                TranslateHelper.translate(
                    visitResultTypeSharingByType.values(),
                    ModifiedVisitReportService.userLanguage
                );
            }

            //fetch custom tooltip
            for (
                Visit_Result_Type_Sharing__c objVisitResultType : visitResultTypeSharingByType.values()
            ) {
                if (!String.isBlank(objVisitResultType.Custom_Tooltip__c)) {
                    visitResultTypeSharingWithDesMap.put(
                        objVisitResultType.Type__c,
                        objVisitResultType.Custom_Tooltip__c
                    );
                }
            }
        }
        //Collects visit result types and result record
        for (Patient_Visit__c objVisit : patientVisits) {
            if (availableVisitResultsByPatientVisitIds.containsKey(objVisit.Id)) {
                Map<String, Visit_Result__c> availableVisitResultsByResultType = availableVisitResultsByPatientVisitIds.get(
                    objVisit.Id
                );
                for (Visit_Result__c objVisitResult : objVisit.Visit_Results__r) {
                    if (
                        availableVisitResultsByResultType.containsKey(objVisitResult.result_Type__c)
                    ) {
                        accessVisitResultMap.put(objVisitResult.Result_Type__c, objVisitResult);
                    }
                }
            }
        }

        for (Patient_Visit__c patientVisit : patientVisits) {
            if (availableVisitResultsByPatientVisitIds.containsKey(patientVisit.Id)) {
                Map<String, Visit_Result__c> availableVisitResultsByResultType = availableVisitResultsByPatientVisitIds.get(
                    patientVisit.Id
                );

                for (Visit_Result_GroupM__mdt visitResultGroupM : visitResultGroupMS) {
                    if (availableVisitResultTypeMSByGroupIds.containsKey(visitResultGroupM.Id)) {
                        List<VisitReportService.VisitResultWrapper> availableVisitResultSortWrappers = availableVisitResultTypeMSByGroupIds.get(
                            visitResultGroupM.Id
                        );
                        List<ModifiedVisitReportContainerRemote.VisitValueWrapper> reportRowWrappers = new List<ModifiedVisitReportContainerRemote.VisitValueWrapper>();
                        List<ModifiedVisitReportContainerRemote.VisitDataWrapper> reportHeaderWrappers = new List<ModifiedVisitReportContainerRemote.VisitDataWrapper>();
                        List<ModifiedVisitReportContainerRemote.LabsNameDescriptionWrapper> labsDescription = new List<ModifiedVisitReportContainerRemote.LabsNameDescriptionWrapper>();
                        //PEH-2374: Added logic to avoid null pointer exception
                        reportHeaderWrappers.add(
                            new ModifiedVisitReportContainerRemote.VisitHeaderWrapper(
                                'Report_Date_PP'
                            )
                        );
                        //Adds completed dates
                        reportRowWrappers.add(
                            patientVisit.Completed_Date__c != null
                                ? new ModifiedVisitReportContainerRemote.VisitValueWrapper(
                                      patientVisit.Completed_Date__c
                                  )
                                : new ModifiedVisitReportContainerRemote.VisitValueWrapper('______')
                        );
                        Boolean isResult = false;
                        for (
                            VisitReportService.VisitResultWrapper visitResultWrapper : availableVisitResultSortWrappers
                        ) {
                            if (
                                !notAccessResultType.contains(
                                    visitResultWrapper.visitResultTypeM.DeveloperName
                                )
                            ) {
                                if (
                                    availableVisitResultsByResultType.containsKey(
                                        visitResultWrapper.visitResultTypeM.DeveloperName
                                    )
                                ) {
                                    this.fillDataFromExistingVisit(
                                        visitResultGroupM,
                                        reportHeaderWrappers,
                                        availableVisitResultsByResultType.get(
                                            visitResultWrapper.visitResultTypeM.DeveloperName
                                        ),
                                        reportRowWrappers
                                    );
                                    isResult = true;
                                } else {
                                    if (
                                        visitResultWrapper.visitResultTypeM.Visit_Result_Type__c !=
                                        VISIT_RES_BIOMARKER_TYPE ||
                                        (accessVisitResultMap.containsKey(
                                            visitResultWrapper.visitResultTypeM.DeveloperName
                                        ))
                                    ) {
                                        if (
                                            accessVisitResultMap.containsKey(
                                                visitResultWrapper.visitResultTypeM.DeveloperName
                                            )
                                        ) {
                                            Visit_Result__c objVisitRes = accessVisitResultMap.get(
                                                visitResultWrapper.visitResultTypeM.DeveloperName
                                            );
                                            if (
                                                VisitReportService.VISIT_RECORD_TYPE_LABS.equalsIgnoreCase(
                                                    visitResultGroupM.Visit_Results_Mode__c
                                                )
                                            ) {
                                                reportHeaderWrappers.add(
                                                    new ModifiedVisitReportContainerRemote.VisitHeaderWrapper(
                                                        objVisitRes
                                                    )
                                                );
                                            } else {
                                                reportHeaderWrappers.add(
                                                    new ModifiedVisitReportContainerRemote.VisitHeaderWrapper(
                                                        objVisitRes.Result_Type__c
                                                    )
                                                );
                                            }
                                        } else {
                                            reportHeaderWrappers.add(
                                                new ModifiedVisitReportContainerRemote.VisitHeaderWrapper(
                                                    visitResultWrapper.visitResultTypeM.DeveloperName
                                                )
                                            );
                                        }
                                        if (
                                            visitResultWrapper.visitResultTypeM.Visit_Result_Type__c !=
                                            VISIT_RES_BIOMARKER_TYPE
                                        ) {
                                            reportRowWrappers.add(
                                                new ModifiedVisitReportContainerRemote.VisitValueWrapper(
                                                    '______'
                                                )
                                            );
                                        } else {
                                            reportRowWrappers.add(
                                                new ModifiedVisitReportContainerRemote.VisitValueWrapper(
                                                    ''
                                                )
                                            );
                                        }
                                    }
                                }
                                if (
                                    (availableVisitResultsByResultType.containsKey(
                                        visitResultWrapper.visitResultTypeM.DeveloperName
                                    ) &&
                                    visitResultWrapper.visitResultTypeM.Visit_Result_Type__c ==
                                    VISIT_RES_BIOMARKER_TYPE) ||
                                    (visitResultWrapper.visitResultTypeM.Visit_Result_Type__c !=
                                    VISIT_RES_BIOMARKER_TYPE)
                                ) {
                                    if (
                                        !biomarkerLabDes.contains(
                                            visitResultWrapper.visitResultTypeM.DeveloperName
                                        ) ||
                                        visitResultWrapper.visitResultTypeM.Visit_Result_Type__c !=
                                        VISIT_RES_BIOMARKER_TYPE
                                    ) {
                                        labsDescription.add(
                                            new ModifiedVisitReportContainerRemote.LabsNameDescriptionWrapper(
                                                visitResultWrapper.visitResultTypeM,
                                                ModifiedVisitReportService.userLanguage,
                                                visitResultTypeSharingWithDesMap.containsKey(
                                                        visitResultWrapper.visitResultTypeM.DeveloperName
                                                    )
                                                    ? visitResultTypeSharingWithDesMap.get(
                                                          visitResultWrapper.visitResultTypeM.DeveloperName
                                                      )
                                                    : ''
                                            )
                                        );
                                    }
                                    if (
                                        visitResultWrapper.visitResultTypeM.Visit_Result_Type__c ==
                                        VISIT_RES_BIOMARKER_TYPE
                                    ) {
                                        biomarkerLabDes.add(
                                            visitResultWrapper.visitResultTypeM.DeveloperName
                                        );
                                    }
                                }
                            }
                        }
                        if (isResult) {
                            if (result.containsKey(visitResultGroupM.DeveloperName)) {
                                result.get(visitResultGroupM.DeveloperName)
                                    .visitResultsWrapper.add(reportRowWrappers);
                                if (visitResultGroupM.DeveloperName == VISIT_RES_BIOMARKER_TYPE) {
                                    result.get(visitResultGroupM.DeveloperName)
                                        .labsDescription.addAll(labsDescription);
                                }
                            } else {
                                ModifiedVisitReportContainerRemote.ReportDataTableWrapper reportDataTableWrapper = this.getReportDataTableWrapper(
                                    reportHeaderWrappers,
                                    reportRowWrappers,
                                    visitResultGroupM,
                                    labsDescription,
                                    pe.Id
                                );
                                result.put(visitResultGroupM.DeveloperName, reportDataTableWrapper);
                            }
                        }
                    }
                }
            }
        }
        return result;
    }

    @TestVisible
    private ModifiedVisitReportContainerRemote.ReportDataWrapper getFillReportData(
        Map<String, ModifiedVisitReportContainerRemote.ReportDataTableWrapper> reportDataWrapperMap,
        List<Visit_Result_GroupM__mdt> visitResultGroupMS,
        Participant_Enrollment__c pe
    ) {
        ModifiedVisitReportContainerRemote.ReportDataWrapper result = new ModifiedVisitReportContainerRemote.ReportDataWrapper();
        List<ModifiedVisitReportContainerRemote.ReportDataTableWrapper> sortReportDataTableWrappers = this.getSortedReportDataTableWrappers(
            reportDataWrapperMap,
            visitResultGroupMS
        );

        result.notAvailableMessage = ParticipantIRBCheckerRemote.checkLanguagePermissions(pe.Id)
            .message;

        TranslateHelper.translate(pe, ModifiedVisitReportService.userLanguage);

        result.dataTables = sortReportDataTableWrappers;
        result.studyCodeName = pe.Clinical_Trial_Profile__r.Study_Code_Name__c;
        result.communityTemplate = pe.Clinical_Trial_Profile__r.CommunityTemplate__c;
        result.studyTitle = pe.Clinical_Trial_Profile__r.Study_Title__c;
        result.profilePicture = pe.Clinical_Trial_Profile__r.Profile_Picture__c;
        result.participantFullName = pe.Participant__r.Full_Name__c;
        result.participantLastName = pe.Participant__r.Last_Name__c;
        result.studySiteName = pe.Study_Site__r.Name;

        if (pe.Enrolled_DateTime__c != null) {
            Datetime dT = pe.Enrolled_DateTime__c;
            Date myDate = Date.newInstance(dT.year(), dT.month(), dT.day());
            // result.enrollmentDate = myDate.format();
            result.enrollmentDate = UserService.formatDatebyLocale(
                dT,
                UserContext.getUser().LocaleSidKey
            );
        }
        //PEH-1986: Show status if Trial is not yet completed
        if (!PEStatusState.PE_STATUS_GROUP_ALUMNI.contains(pe.Participant_Status__c)) {
            result.participantStatus = pe.Participant_Status__c;
        }
        result.studySiteName = pe.Study_Site__r.Name;
        return result;
    }

    private ModifiedVisitReportContainerRemote.ReportDataTableWrapper getReportDataTableWrapper(
        List<ModifiedVisitReportContainerRemote.VisitDataWrapper> reportHeaderWrappers,
        List<ModifiedVisitReportContainerRemote.VisitValueWrapper> reportRowWrappers,
        Visit_Result_GroupM__mdt visitResultGroupM,
        List<ModifiedVisitReportContainerRemote.LabsNameDescriptionWrapper> labsDescription,
        Id peId
    ) {
        ModifiedVisitReportContainerRemote.ReportDataTableWrapper reportDataTableWrapper = new ModifiedVisitReportContainerRemote.ReportDataTableWrapper();
        reportDataTableWrapper.tHead = reportHeaderWrappers;
        reportDataTableWrapper.visitResultsWrapper = new List<List<ModifiedVisitReportContainerRemote.VisitValueWrapper>>{
            reportRowWrappers
        };
        reportDataTableWrapper.tableName = TranslateHelper.getLabelValue(
            'Report_' +
            visitResultGroupM.DeveloperName +
            '_header_PP',
            ModifiedVisitReportService.userLanguage
        );
        reportDataTableWrapper.tableApiName = visitResultGroupM.DeveloperName;
        reportDataTableWrapper.labsDescription = labsDescription;

        return reportDataTableWrapper;
    }

    private void fillDataFromExistingVisit(
        Visit_Result_GroupM__mdt visitResultGroupM,
        List<ModifiedVisitReportContainerRemote.VisitDataWrapper> reportHeaderWrappers,
        Visit_Result__c visitResult,
        List<ModifiedVisitReportContainerRemote.VisitValueWrapper> reportRowWrappers
    ) {
        if (
            VisitReportService.VISIT_RECORD_TYPE_LABS.equalsIgnoreCase(
                visitResultGroupM.Visit_Results_Mode__c
            )
        ) {
            reportHeaderWrappers.add(
                new ModifiedVisitReportContainerRemote.VisitHeaderWrapper(visitResult)
            );
        } else {
            reportHeaderWrappers.add(
                new ModifiedVisitReportContainerRemote.VisitHeaderWrapper(
                    visitResult.Result_Type__c
                )
            );
        }
        //PEH-2256: Report should display +Positive/ -Negative/ Unknown
        if (
            visitResult.RecordType.DeveloperName.equalsIgnoreCase(
                VisitReportService.VISIT_RES_RECORD_TYPE_BIO
            )
        ) {
            String biomarkerValue = String.valueof(visitResult.Actual_Value__c);
            if (
                !String.isBlank(visitResult.Result_Type__c) &&
                !visitResult.Result_Type__c.contains('ICOS')
            ) {
                if (visitResult.Actual_Value__c == -1.0) {
                    biomarkerValue = System.Label.Biomarkers_Negative;
                } else if (visitResult.Actual_Value__c == 1.0) {
                    biomarkerValue = System.Label.Biomarkers_Positive;
                } else if (visitResult.Actual_Value__c == 0.0) {
                    biomarkerValue = System.Label.Biomarkers_Unknown;
                }
            }
            reportRowWrappers.add(
                new ModifiedVisitReportContainerRemote.VisitValueWrapper(biomarkerValue)
            );
        } else {
            reportRowWrappers.add(
                new ModifiedVisitReportContainerRemote.VisitValueWrapper(
                    visitResult.Actual_Value__c,
                    visitResult.Measurement__c
                )
            );
        }
    }

    private List<ModifiedVisitReportContainerRemote.ReportDataTableWrapper> getSortedReportDataTableWrappers(
        Map<String, ModifiedVisitReportContainerRemote.ReportDataTableWrapper> reportDataWrapperMap,
        List<Visit_Result_GroupM__mdt> visitResultGroupMS
    ) {
        List<ModifiedVisitReportContainerRemote.ReportDataTableWrapper> result = new List<ModifiedVisitReportContainerRemote.ReportDataTableWrapper>();
        for (Visit_Result_GroupM__mdt visitResultGroupM : visitResultGroupMS) {
            if (reportDataWrapperMap.containsKey(visitResultGroupM.DeveloperName)) {
                result.add(reportDataWrapperMap.get(visitResultGroupM.DeveloperName));
            }
        }
        return result;
    }
    public class VisitResultWrapper implements Comparable {
        public Visit_Result_TypeM__mdt visitResultTypeM;

        public VisitResultWrapper(Visit_Result_TypeM__mdt visitResultTypeM) {
            this.visitResultTypeM = visitResultTypeM;
        }

        public Integer compareTo(Object compareTo) {
            VisitResultWrapper compareToVisitResult = (VisitResultWrapper) compareTo;
            return (Integer) (visitResultTypeM.Display_Order__c -
            compareToVisitResult.visitResultTypeM.Display_Order__c);
        }
    }
}
