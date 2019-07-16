/**
 * Created by Yehor Dobrovolskyi
 */
public inherited sharing class VisitReportContainerRemote {

    @AuraEnabled
    public static String getReportDataWrappers() {
        List<ReportDataWrapper> reportDataWrappers = new List<VisitReportContainerRemote.ReportDataWrapper>();
        ReportDataWrapper reportDataWrapper = new ReportDataWrapper();
        Map<String, VisitReportContainerRemote.ReportDataTableWrapper> reportDataWrapperMap = new Map<String, VisitReportContainerRemote.ReportDataTableWrapper>();
        VisitResultsService service = ((VisitResultsService) ClassFactory.newInstance(VisitResultsService.class));
        VisitResultMService visitResultMService = ((VisitResultMService) ClassFactory.newInstance(VisitResultMService.class));
        List<Visit_Result_GroupM__mdt> visitResultGroupMS = visitResultMService.getVisitResultGroups(true, null);
        List<Patient_Visit__c> patientVisits = service.getPatientVisitsForReport();
        if (patientVisits.isEmpty()) {
            return null;
        }
        ParticipantService.ParticipantState pState = ((ParticipantService) ClassFactory.newInstance(ParticipantService.class)).getState();

        for (Patient_Visit__c patientVisit : patientVisits) {
            if (!patientVisit.Visit_Results__r.isEmpty()) {
                Map<String, Visit_Result__c> visitResultsByResultType = getVisitResultMapByResultType(patientVisit.Visit_Results__r);
                for (Visit_Result_GroupM__mdt visitResultGroupM : visitResultGroupMS) {
                    Boolean isResult = false;
                    List<ReportRowWrapper> reportRowWrappers = new List<VisitReportContainerRemote.ReportRowWrapper>();
                    List<ReportHeaderWrapper> reportHeaderWrappers = new List<VisitReportContainerRemote.ReportHeaderWrapper>();
                    String visitDate = DateService.format(patientVisit.Completed_Date__c, 'MMM, D YYYY');
                    reportHeaderWrappers.add(new ReportHeaderWrapper('Report_Dates'));
                    reportRowWrappers.add(new ReportRowWrapper(visitDate));
                    for (Visit_Result_TypeM__mdt visitResultTypeM : visitResultGroupM.Visit_Result_Types__r) {
//                        reportHeaderWrappers.add(new ReportHeaderWrapper(visitResultTypeM.DeveloperName));
                        if (visitResultsByResultType.containsKey(visitResultTypeM.DeveloperName)) {
                            Visit_Result__c visitResult = visitResultsByResultType.get(visitResultTypeM.DeveloperName);
                            if ('Labs'.equalsIgnoreCase(visitResultGroupM.Visit_Results_Mode__c)) {
                                reportHeaderWrappers.add(new ReportHeaderWrapper(visitResult));
                            } else {
                                reportHeaderWrappers.add(new ReportHeaderWrapper(visitResultTypeM.DeveloperName));
                            }
                            Decimal rounded = visitResult.Actual_Value__c.setScale(2, RoundingMode.HALF_UP);
                            String value = String.valueOf(rounded);
                            reportRowWrappers.add(new ReportRowWrapper(value, visitResult.Measurement__c));
                            isResult = true;
                        } else {
                            reportRowWrappers.add(new ReportRowWrapper('______'));
                            reportHeaderWrappers.add(new ReportHeaderWrapper(visitResultTypeM.DeveloperName));

                        }
                    }
                    if (isResult) {
                        if (reportDataWrapperMap.get(visitResultGroupM.DeveloperName) != null) {
                            reportDataWrapperMap.get(visitResultGroupM.DeveloperName).visitResultsWrapper.add(reportRowWrappers);
                        } else {
                            ReportDataTableWrapper reportDataTableWrapper = new ReportDataTableWrapper();
                            reportDataTableWrapper.tHead = reportHeaderWrappers;
                            reportDataTableWrapper.visitResultsWrapper = new List<List<VisitReportContainerRemote.ReportRowWrapper>>{
                                    reportRowWrappers
                            };
                            reportDataTableWrapper.tableName = 'Report_' + visitResultGroupM.DeveloperName + '_header';
                            reportDataTableWrapper.textResult = 'Report_' + visitResultGroupM.DeveloperName + '_text';
                            reportDataWrapperMap.put(visitResultGroupM.DeveloperName, reportDataTableWrapper);
                        }
                    }
                    isResult = false;
                }
            }
        }
        if (reportDataWrapperMap.isEmpty()) {
            return null;
        }
        List<ReportDataTableWrapper> sortReportDataTableWrappers = new List<VisitReportContainerRemote.ReportDataTableWrapper>();
        for (Visit_Result_GroupM__mdt visitResultGroupM : visitResultGroupMS) {
            ReportDataTableWrapper rep = reportDataWrapperMap.get(visitResultGroupM.DeveloperName);
            if (rep != null) {
                sortReportDataTableWrappers.add(rep);
            }
        }
        reportDataWrapper.dataTables = sortReportDataTableWrappers;
//        reportDataWrapper.dataTables = reportDataWrapperMap.values();
        reportDataWrapper.studyCodeName = pState.ctp.Study_Code_Name__c;
        reportDataWrapper.studyTitle = pState.ctp.Study_Title__c;
        reportDataWrapper.profilePicture = pState.ctp.Profile_Picture__c;
        reportDataWrapper.participantFullName = pState.participant.Full_Name__c;
        reportDataWrapper.participantLastName = pState.participant.Last_Name__c;
        Datetime dT = System.now();
        Date myDate = Date.newInstance(dT.year(), dT.month(), dT.day());
        reportDataWrapper.enrollmentDate = DateService.format(myDate, 'DD-MMM-YYYY');
        reportDataWrapper.studySiteName = pState.pse.Study_Site__r.Name;
        System.debug('PDF ===> : ' + reportDataWrapper);
        reportDataWrappers.add(reportDataWrapper);
        return JSON.serialize(reportDataWrappers);
    }

    private static Map<String, Visit_Result__c> getVisitResultMapByResultType(List<Visit_Result__c> visitResults) {
        Map<String, Visit_Result__c> result = new Map<String, Visit_Result__c>();
        for (Visit_Result__c visitResult : visitResults) {
            result.put(visitResult.Result_Type__c, visitResult);
        }
        return result;
    }

    public class ReportDataWrapper {
        @AuraEnabled
        public List<ReportDataTableWrapper> dataTables;
        @AuraEnabled
        public String studyCodeName;
        @AuraEnabled
        public String studyTitle;
        @AuraEnabled
        public String profilePicture;
        @AuraEnabled
        public String participantFullName;
        @AuraEnabled
        public String participantLastName;
        @AuraEnabled
        public String enrollmentDate;
        @AuraEnabled
        public String studySiteName;
    }

    public class ReportDataTableWrapper {
        @AuraEnabled
        public List<ReportHeaderWrapper> tHead;
        @AuraEnabled
        public List<List<ReportRowWrapper>> visitResultsWrapper;
        @AuraEnabled
        public String tableName;
        @AuraEnabled
        public String textResult;

    }

    public class ReportHeaderWrapper {
        @AuraEnabled
        public String colName;
        @AuraEnabled
        public Double minValue;
        @AuraEnabled
        public Double maxValue;
        @AuraEnabled
        public Boolean isShowRange;

        public ReportHeaderWrapper(Visit_Result__c visitResult) {
            this.colName = visitResult.Result_Type__c;
            this.minValue = visitResult.Min_Value__c;
            this.maxValue = visitResult.Max_Value__c;
            this.isShowRange = true;
        }

        public ReportHeaderWrapper(String headerName) {
            this.colName = headerName;
            this.isShowRange = false;
        }

    }

    public class ReportRowWrapper {
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String measurement;

        public ReportRowWrapper(String value, String measurement) {
            this.value = value;
            this.measurement = measurement;
        }

        public ReportRowWrapper(String value) {
            this.value = value;
        }
    }
}