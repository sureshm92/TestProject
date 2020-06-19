/**
 * Created by Yehor Dobrovolskyi
 */
public inherited sharing class VisitReportService {

    public static final String VISIT_RECORD_TYPE_LABS = 'Labs';
    public static final String VISIT_RES_RECORD_TYPE_BIO = 'Biomarker';

    public VisitReportContainerRemote.ReportDataWrapper getReportDataWrapper(Id peId) {
        Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(peId, CommunityService.USER_MODE_PARTICIPANT);
        VisitResultsService visitResultsService = ((VisitResultsService) ClassFactory.newInstance(VisitResultsService.class));
        VisitResultMService visitResultMService = ((VisitResultMService) ClassFactory.newInstance(VisitResultMService.class));

        List<Patient_Visit__c> patientVisits = visitResultsService.getPatientVisitsForReport(pe);
        List<Visit_Result_GroupM__mdt> visitResultGroupMS = visitResultMService.getVisitResultGroups(true, null);
        Map<String, VisitReportContainerRemote.ReportDataTableWrapper> reportDataWrapperMap =
                getDataTableWrappersByGroupName(pe, patientVisits, visitResultGroupMS);

        return getFillReportData(reportDataWrapperMap, visitResultGroupMS, pe);
    }

    @TestVisible
    private Map<String, VisitReportContainerRemote.ReportDataTableWrapper> getDataTableWrappersByGroupName(
            Participant_Enrollment__c pe,
            List<Patient_Visit__c> patientVisits,
            List<Visit_Result_GroupM__mdt> visitResultGroupMS
    ) {
        String language  = IRBParticipantService.getSuitableLanguageForIRBTranslation(pe.Id);
        if(language == null) language = UserInfo.getLanguage();

        VisitResultSharingService visitResultSharingServiceInt = ((VisitResultSharingService) ClassFactory.newInstance(VisitResultSharingService.class));
        Map<String, VisitReportContainerRemote.ReportDataTableWrapper> result = new Map<String, VisitReportContainerRemote.ReportDataTableWrapper>();
        Map<Id, List<VisitResultWrapper>> availableVisitResultTypeMSByGroupIds = visitResultSharingServiceInt.geAvailableVisitResultTypeMSByGroupIds(pe, visitResultGroupMS);
        Map<Id, Map<String, Visit_Result__c>> availableVisitResultsByPatientVisitIds = visitResultSharingServiceInt.getAvailableVisitResultsByPatientVisitIds(pe, patientVisits);
        Set<String> notAccessResultType = visitResultSharingServiceInt.getNotAccessResultType();

        for (Patient_Visit__c patientVisit : patientVisits) {
            if (availableVisitResultsByPatientVisitIds.containsKey(patientVisit.Id)) {
                Map<String, Visit_Result__c> availableVisitResultsByResultType = availableVisitResultsByPatientVisitIds.get(patientVisit.Id);

                for (Visit_Result_GroupM__mdt visitResultGroupM : visitResultGroupMS) {
                    if (availableVisitResultTypeMSByGroupIds.containsKey(visitResultGroupM.Id)) {
                        List<VisitResultWrapper> availableVisitResultSortWrappers = availableVisitResultTypeMSByGroupIds.get(visitResultGroupM.Id);
                        List<VisitReportContainerRemote.VisitDataWrapper> reportRowWrappers = new List<VisitReportContainerRemote.VisitDataWrapper>();
                        List<VisitReportContainerRemote.VisitDataWrapper> reportHeaderWrappers = new List<VisitReportContainerRemote.VisitDataWrapper>();
                        List<VisitReportContainerRemote.LabsNameDescriptionWrapper> labsDescription = new List<VisitReportContainerRemote.LabsNameDescriptionWrapper>();
                        //PEH-2374: Added logic to avoid null pointer exception
                        reportHeaderWrappers.add(new VisitReportContainerRemote.VisitHeaderWrapper('Report_Dates'));
                        if(!PEStatusState.PE_STATUS_GROUP_ALUMNI.contains(pe.Participant_Status__c)){
                            reportRowWrappers.add(patientVisit.Planned_Date__c != null ? 
                                    new VisitReportContainerRemote.VisitDateColumnWrapper(patientVisit.Planned_Date__c) :
                                    new VisitReportContainerRemote.VisitDateColumnWrapper('______'));
                        } else{
                            reportRowWrappers.add(patientVisit.Completed_Date__c != null ? 
                                    new VisitReportContainerRemote.VisitDateColumnWrapper(patientVisit.Completed_Date__c) :
                                    new VisitReportContainerRemote.VisitDateColumnWrapper('______'));
                        }
                        Boolean isResult = false;
                        for (VisitResultWrapper visitResultWrapper : availableVisitResultSortWrappers) {
                            if (!notAccessResultType.contains(visitResultWrapper.visitResultTypeM.DeveloperName)) {
                                if (availableVisitResultsByResultType.containsKey(visitResultWrapper.visitResultTypeM.DeveloperName)) {
                                    this.fillDataFromExistingVisit(
                                            visitResultGroupM,
                                            reportHeaderWrappers,
                                            availableVisitResultsByResultType.get(visitResultWrapper.visitResultTypeM.DeveloperName),
                                            reportRowWrappers
                                    );
                                    isResult = true;
                                } else {
                                    reportHeaderWrappers.add(new VisitReportContainerRemote.VisitHeaderWrapper(visitResultWrapper.visitResultTypeM.DeveloperName));
                                    reportRowWrappers.add(new VisitReportContainerRemote.VisitValueWrapper('______'));

                                }
                                labsDescription.add(new VisitReportContainerRemote.LabsNameDescriptionWrapper(visitResultWrapper.visitResultTypeM, language));
                            }
                        }
                        if (isResult) {
                            if (result.containsKey(visitResultGroupM.DeveloperName)) {
                                result.get(visitResultGroupM.DeveloperName).visitResultsWrapper.add(reportRowWrappers);
                            } else {
                                VisitReportContainerRemote.ReportDataTableWrapper reportDataTableWrapper = this.getReportDataTableWrapper(
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
    private VisitReportContainerRemote.ReportDataWrapper getFillReportData(
            Map<String, VisitReportContainerRemote.ReportDataTableWrapper> reportDataWrapperMap,
            List<Visit_Result_GroupM__mdt> visitResultGroupMS,
            Participant_Enrollment__c pe
    ) {
        VisitReportContainerRemote.ReportDataWrapper result = new VisitReportContainerRemote.ReportDataWrapper();
        List<VisitReportContainerRemote.ReportDataTableWrapper> sortReportDataTableWrappers =
                this.getSortedReportDataTableWrappers(reportDataWrapperMap, visitResultGroupMS);

        String language  = IRBParticipantService.getSuitableLanguageForIRBTranslation(pe.Id);
        if (language == null) {
            language = UserInfo.getLanguage();
            result.notAvailableMessage = ParticipantIRBCheckerRemote.checkLanguagePermissions(pe.Id).message;
        }
        TranslateHelper.translate(pe, language);

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
            result.enrollmentDate = myDate.format();
        }
        //PEH-1986: Show status if Trial is not yet completed
        if(!PEStatusState.PE_STATUS_GROUP_ALUMNI.contains(pe.Participant_Status__c)){
            result.participantStatus = pe.Participant_Status__c;
        }
        result.studySiteName = pe.Study_Site__r.Name;
        return result;
    }

    private VisitReportContainerRemote.ReportDataTableWrapper getReportDataTableWrapper(
            List<VisitReportContainerRemote.VisitDataWrapper> reportHeaderWrappers,
            List<VisitReportContainerRemote.VisitDataWrapper> reportRowWrappers,
            Visit_Result_GroupM__mdt visitResultGroupM,
            List<VisitReportContainerRemote.LabsNameDescriptionWrapper> labsDescription,
            Id peId
    ) {
        String language  = IRBParticipantService.getSuitableLanguageForIRBTranslation(peId);
        if(language == null) language = UserInfo.getLanguage();

        VisitReportContainerRemote.ReportDataTableWrapper reportDataTableWrapper = new VisitReportContainerRemote.ReportDataTableWrapper();
        reportDataTableWrapper.tHead = reportHeaderWrappers;
        reportDataTableWrapper.visitResultsWrapper = new List<List<VisitReportContainerRemote.VisitDataWrapper>>{
                reportRowWrappers
        };
        reportDataTableWrapper.tableName = TranslateHelper.getLabelValue('Report_' + visitResultGroupM.DeveloperName + '_header', language);
        reportDataTableWrapper.tableApiName = visitResultGroupM.DeveloperName;
        reportDataTableWrapper.labsDescription = labsDescription;

        return reportDataTableWrapper;
    }

    private void fillDataFromExistingVisit(
            Visit_Result_GroupM__mdt visitResultGroupM,
            List<VisitReportContainerRemote.VisitDataWrapper> reportHeaderWrappers,
            Visit_Result__c visitResult,
            List<VisitReportContainerRemote.VisitDataWrapper> reportRowWrappers
    ) {
        if (VisitReportService.VISIT_RECORD_TYPE_LABS.equalsIgnoreCase(visitResultGroupM.Visit_Results_Mode__c)) {
            reportHeaderWrappers.add(new VisitReportContainerRemote.VisitHeaderWrapper(visitResult));
        } else {
            reportHeaderWrappers.add(new VisitReportContainerRemote.VisitHeaderWrapper(visitResult.Result_Type__c, visitResult.Measurement__c));
        }
    //PEH-2256: Report should display +Positive/ -Negative/ Unknown
        if(visitResult.RecordType.DeveloperName.equalsIgnoreCase(VisitReportService.VISIT_RES_RECORD_TYPE_BIO)){
            String biomarkerValue = '';
            if(visitResult.Actual_Value__c == -1.0){
                biomarkerValue = '- ' + System.Label.Biomarkers_Negative;
            } else if(visitResult.Actual_Value__c == 1.0){
                biomarkerValue = '+ ' + System.Label.Biomarkers_Positive;
            }else if(visitResult.Actual_Value__c == 0.0){
                biomarkerValue = System.Label.Biomarkers_Unknown;
            }
            reportRowWrappers.add(new VisitReportContainerRemote.VisitValueWrapper(biomarkerValue));
        } else{
            reportRowWrappers.add(new VisitReportContainerRemote.VisitValueWrapper(visitResult.Actual_Value__c, visitResult.Measurement__c));
        }
        
    }

    private List<VisitReportContainerRemote.ReportDataTableWrapper> getSortedReportDataTableWrappers(
            Map<String, VisitReportContainerRemote.ReportDataTableWrapper> reportDataWrapperMap,
            List<Visit_Result_GroupM__mdt> visitResultGroupMS
    ) {
        List<VisitReportContainerRemote.ReportDataTableWrapper> result = new List<VisitReportContainerRemote.ReportDataTableWrapper>();
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
            return (Integer) (visitResultTypeM.Display_Order__c - compareToVisitResult.visitResultTypeM.Display_Order__c);
        }
    }
}