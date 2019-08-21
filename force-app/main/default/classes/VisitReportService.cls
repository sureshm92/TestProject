/**
 * Created by Yehor Dobrovolskyi
 */
public inherited sharing class VisitReportService {

    public static final String VISIT_RECORD_TYPE_LABS = 'Labs';

    public List<VisitReportContainerRemote.ReportDataWrapper> getReportDataWrapper() {
        List<VisitReportContainerRemote.ReportDataWrapper> result = new List<VisitReportContainerRemote.ReportDataWrapper>();
        VisitResultsService visitResultsService = ((VisitResultsService) ClassFactory.newInstance(VisitResultsService.class));
        VisitResultMService visitResultMService = ((VisitResultMService) ClassFactory.newInstance(VisitResultMService.class));
        if (this.isNotAccessReport()) {
            return result;
        }
        List<Patient_Visit__c> patientVisits = visitResultsService.getPatientVisitsForReport();
        if (patientVisits.isEmpty()) {
            return result;
        }
        List<Visit_Result_GroupM__mdt> visitResultGroupMS = visitResultMService.getVisitResultGroups(true, null);
        Map<String, VisitReportContainerRemote.ReportDataTableWrapper> reportDataWrapperMap = this.getDataTableWrappersByGroupName(patientVisits, visitResultGroupMS);
        if (reportDataWrapperMap.isEmpty()) {
            return result;
        }
        VisitReportContainerRemote.ReportDataWrapper reportDataWrapper = this.getFillReportData(reportDataWrapperMap, visitResultGroupMS);
        result.add(reportDataWrapper);
        return result;
    }

    private Map<String, VisitReportContainerRemote.ReportDataTableWrapper> getDataTableWrappersByGroupName(
            List<Patient_Visit__c> patientVisits,
            List<Visit_Result_GroupM__mdt> visitResultGroupMS
    ) {
        VisitResultSharingService visitResultSharingServiceInt = ((VisitResultSharingService) ClassFactory.newInstance(VisitResultSharingService.class));
        Map<String, VisitReportContainerRemote.ReportDataTableWrapper> result = new Map<String, VisitReportContainerRemote.ReportDataTableWrapper>();
        Map<Id, List<VisitResultWrapper>> availableVisitResultTypeMSByGroupIds = visitResultSharingServiceInt.geAvailableVisitResultTypeMSByGroupIds(visitResultGroupMS);
        Map<Id, Map<String, Visit_Result__c>> availableVisitResultsByPatientVisitIds = visitResultSharingServiceInt.getAvailableVisitResultsByPatientVisitIds(patientVisits);
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
                        reportHeaderWrappers.add(new VisitReportContainerRemote.VisitHeaderWrapper('Report_Dates'));
                        reportRowWrappers.add(new VisitReportContainerRemote.VisitDateColumnWrapper(patientVisit.Completed_Date__c));
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
                                labsDescription.add(new VisitReportContainerRemote.LabsNameDescriptionWrapper(visitResultWrapper.visitResultTypeM));
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
                                        labsDescription
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

    private VisitReportContainerRemote.ReportDataWrapper getFillReportData(
            Map<String, VisitReportContainerRemote.ReportDataTableWrapper> reportDataWrapperMap
            , List<Visit_Result_GroupM__mdt> visitResultGroupMS
    ) {
        ParticipantService.ParticipantState pState = ((ParticipantService) ClassFactory.newInstance(ParticipantService.class)).getState();
        VisitReportContainerRemote.ReportDataWrapper result = new VisitReportContainerRemote.ReportDataWrapper();
        List<VisitReportContainerRemote.ReportDataTableWrapper> sortReportDataTableWrappers = this.getSortedReportDataTableWrappers(reportDataWrapperMap, visitResultGroupMS);
        result.dataTables = sortReportDataTableWrappers;
        result.studyCodeName = pState.ctp.Study_Code_Name__c;
        result.studyTitle = pState.ctp.Study_Title__c;
        result.profilePicture = pState.ctp.Profile_Picture__c;
        result.participantFullName = pState.participant.Full_Name__c;
        result.participantLastName = pState.participant.Last_Name__c;
        Datetime dT = pState.pe.CreatedDate;
        Date myDate = Date.newInstance(dT.year(), dT.month(), dT.day());
        result.enrollmentDate = DateService.format(myDate, 'DD-MMM-YYYY');
        result.studySiteName = pState.pe.Study_Site__r.Name;
        return result;
    }

    private VisitReportContainerRemote.ReportDataTableWrapper getReportDataTableWrapper(
            List<VisitReportContainerRemote.VisitDataWrapper> reportHeaderWrappers,
            List<VisitReportContainerRemote.VisitDataWrapper> reportRowWrappers,
            Visit_Result_GroupM__mdt visitResultGroupM,
            List<VisitReportContainerRemote.LabsNameDescriptionWrapper> labsDescription
    ) {
        VisitReportContainerRemote.ReportDataTableWrapper reportDataTableWrapper = new VisitReportContainerRemote.ReportDataTableWrapper();
        reportDataTableWrapper.tHead = reportHeaderWrappers;
        reportDataTableWrapper.visitResultsWrapper = new List<List<VisitReportContainerRemote.VisitDataWrapper>>{
                reportRowWrappers
        };
        reportDataTableWrapper.tableName = TranslateHelper.getLabelValue('Report_' + visitResultGroupM.DeveloperName + '_header');
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
            reportHeaderWrappers.add(new VisitReportContainerRemote.VisitHeaderWrapper(visitResult.Result_Type__c));
        }
        reportRowWrappers.add(new VisitReportContainerRemote.VisitValueWrapper(visitResult.Actual_Value__c, visitResult.Measurement__c));
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

    private Boolean isNotAccessReport() {
        ParticipantService.ParticipantState pState = ((ParticipantService) ClassFactory.newInstance(ParticipantService.class)).getState();
        return !ParticipantService.ParticipantStates.ALUMNI.equals(pState.value)
                || pState.isDelegate
                || !pState.pe.Participant_Contact__r.Visit_Results_Opt_In__c
                || !VisitResultSharingService.isVisitResultAvailable();
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