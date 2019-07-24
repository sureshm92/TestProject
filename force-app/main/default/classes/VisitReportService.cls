/**
 * Created by Yehor Dobrovolskyi
 */
public inherited sharing class VisitReportService {

    public static final String VISIT_RECORD_TYPE_LABS = 'Labs';

    public List<VisitReportContainerRemote.ReportDataWrapper> getReportDataWrapper() {
        List<VisitReportContainerRemote.ReportDataWrapper> result = new List<VisitReportContainerRemote.ReportDataWrapper>();
        VisitResultsService visitResultsService = ((VisitResultsService) ClassFactory.newInstance(VisitResultsService.class));
        VisitResultMService visitResultMService = ((VisitResultMService) ClassFactory.newInstance(VisitResultMService.class));
        ParticipantService.ParticipantState pState = ((ParticipantService) ClassFactory.newInstance(ParticipantService.class)).getState();
        if (!ParticipantService.ParticipantStates.ALUMNI.equals(pState.value) || pState.isDelegate || !VisitResultSharingService.isVisitResultAvailable()) {
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
        VisitReportContainerRemote.ReportDataWrapper reportDataWrapper = this.getFillReportData(reportDataWrapperMap, visitResultGroupMS, pState);
        result.add(reportDataWrapper);
        return result;
    }

    private Map<String, VisitReportContainerRemote.ReportDataTableWrapper> getDataTableWrappersByGroupName(List<Patient_Visit__c> patientVisits, List<Visit_Result_GroupM__mdt> visitResultGroupMS) {
        Map<String, VisitReportContainerRemote.ReportDataTableWrapper> result = new Map<String, VisitReportContainerRemote.ReportDataTableWrapper>();
        for (Patient_Visit__c patientVisit : patientVisits) {
            if (!patientVisit.Visit_Results__r.isEmpty()) {
                List<Visit_Result__c> visitResultsAvailable = VisitResultSharingService.getAvailableVisitResults(patientVisit.Visit_Results__r);
                if (visitResultsAvailable.isEmpty()) continue;
                Map<String, Visit_Result__c> visitResultsByResultType = this.getVisitResultMapByResultType(visitResultsAvailable);
                for (Visit_Result_GroupM__mdt visitResultGroupM : visitResultGroupMS) {
                    Boolean isResult = false;
                    List<VisitReportContainerRemote.VisitDataWrapper> reportRowWrappers = new List<VisitReportContainerRemote.VisitDataWrapper>();
                    List<VisitReportContainerRemote.VisitDataWrapper> reportHeaderWrappers = new List<VisitReportContainerRemote.VisitDataWrapper>();
                    String visitDate = DateService.format(patientVisit.Completed_Date__c, 'MMM, D YYYY');
                    reportHeaderWrappers.add(new VisitReportContainerRemote.VisitDataWrapper('Report_Dates'));
                    reportRowWrappers.add(new VisitReportContainerRemote.VisitDataWrapper(visitDate));
                    List<VisitReportContainerRemote.LabsNameDescriptionWrapper> labsDescription = new List<VisitReportContainerRemote.LabsNameDescriptionWrapper>();
                    List<VisitResultWrapper> visitResultWrappers = new List<VisitResultWrapper>();
                    for (Visit_Result_TypeM__mdt visitResultTypeM : visitResultGroupM.Visit_Result_Types__r) {
                        visitResultWrappers.add(new VisitResultWrapper(visitResultTypeM));
                    }
                    visitResultWrappers.sort();
                    for (VisitResultWrapper visitResultWrapper : visitResultWrappers) {
                        if (visitResultsByResultType.containsKey(visitResultWrapper.visitResultTypeM.DeveloperName)) {
                            Visit_Result__c visitResult = visitResultsByResultType.get(visitResultWrapper.visitResultTypeM.DeveloperName);
                            if (VisitReportService.VISIT_RECORD_TYPE_LABS.equalsIgnoreCase(visitResultGroupM.Visit_Results_Mode__c)) {
                                reportHeaderWrappers.add(new VisitReportContainerRemote.VisitDataWrapper(visitResult));
                            } else {
                                reportHeaderWrappers.add(new VisitReportContainerRemote.VisitDataWrapper(visitResultWrapper.visitResultTypeM.DeveloperName));
                            }
                            Decimal rounded = visitResult.Actual_Value__c.setScale(2, RoundingMode.HALF_UP);
                            String value = String.valueOf(rounded);
                            reportRowWrappers.add(new VisitReportContainerRemote.VisitDataWrapper(value, visitResult.Measurement__c));
                            isResult = true;
                        } else {
                            reportRowWrappers.add(new VisitReportContainerRemote.VisitDataWrapper('______'));
                            reportHeaderWrappers.add(new VisitReportContainerRemote.VisitDataWrapper(visitResultWrapper.visitResultTypeM.DeveloperName));

                        }
                        labsDescription.add(new VisitReportContainerRemote.LabsNameDescriptionWrapper(visitResultWrapper.visitResultTypeM));
                    }
                    if (isResult) {
                        if (result.get(visitResultGroupM.DeveloperName) != null) {
                            result.get(visitResultGroupM.DeveloperName).visitResultsWrapper.add(reportRowWrappers);
                        } else {
                            VisitReportContainerRemote.ReportDataTableWrapper reportDataTableWrapper = new VisitReportContainerRemote.ReportDataTableWrapper();
                            reportDataTableWrapper.tHead = reportHeaderWrappers;
                            reportDataTableWrapper.visitResultsWrapper = new List<List<VisitReportContainerRemote.VisitDataWrapper>>{
                                    reportRowWrappers
                            };
                            reportDataTableWrapper.tableName = TranslateHelper.getLabelValue('Report_' + visitResultGroupM.DeveloperName + '_header');
                            reportDataTableWrapper.tableApiName = visitResultGroupM.DeveloperName;
                            reportDataTableWrapper.labsDescription = labsDescription;
                            result.put(visitResultGroupM.DeveloperName, reportDataTableWrapper);
                        }
                    }
                    isResult = false;
                }
            }
        }
        return result;
    }

    private Map<String, Visit_Result__c> getVisitResultMapByResultType(List<Visit_Result__c> visitResults) {
        Map<String, Visit_Result__c> result = new Map<String, Visit_Result__c>();
        for (Visit_Result__c visitResult : visitResults) {
            result.put(visitResult.Result_Type__c, visitResult);
        }
        return result;
    }

    private List<VisitReportContainerRemote.ReportDataTableWrapper> getSortedReportDataTableWrappers(Map<String, VisitReportContainerRemote.ReportDataTableWrapper> reportDataWrapperMap, List<Visit_Result_GroupM__mdt> visitResultGroupMS) {
        List<VisitReportContainerRemote.ReportDataTableWrapper> result = new List<VisitReportContainerRemote.ReportDataTableWrapper>();
        for (Visit_Result_GroupM__mdt visitResultGroupM : visitResultGroupMS) {
            VisitReportContainerRemote.ReportDataTableWrapper rep = reportDataWrapperMap.get(visitResultGroupM.DeveloperName);
            if (rep != null) {
                result.add(rep);
            }
        }
        return result;
    }

    private VisitReportContainerRemote.ReportDataWrapper getFillReportData(Map<String, VisitReportContainerRemote.ReportDataTableWrapper> reportDataWrapperMap, List<Visit_Result_GroupM__mdt> visitResultGroupMS, ParticipantService.ParticipantState pState) {
        VisitReportContainerRemote.ReportDataWrapper result = new VisitReportContainerRemote.ReportDataWrapper();
        List<VisitReportContainerRemote.ReportDataTableWrapper> sortReportDataTableWrappers = this.getSortedReportDataTableWrappers(reportDataWrapperMap, visitResultGroupMS);
        result.dataTables = sortReportDataTableWrappers;
        result.studyCodeName = pState.ctp.Study_Code_Name__c;
        result.studyTitle = pState.ctp.Study_Title__c;
        result.profilePicture = pState.ctp.Profile_Picture__c;
        result.participantFullName = pState.participant.Full_Name__c;
        result.participantLastName = pState.participant.Last_Name__c;
        Datetime dT = pState.pse.CreatedDate;
        Date myDate = Date.newInstance(dT.year(), dT.month(), dT.day());
        result.enrollmentDate = DateService.format(myDate, 'DD-MMM-YYYY');
        result.studySiteName = pState.pse.Study_Site__r.Name;
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