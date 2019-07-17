/**
 * Created by Yehor Dobrovolskyi
 */
public inherited sharing class VisitReportContainerRemote {

    @AuraEnabled
    public static String getReportDataWrappers() {
        List<VisitReportContainerRemote.ReportDataWrapper> reportDataWrappers = new List<VisitReportContainerRemote.ReportDataWrapper>();
        try {
            VisitReportService visitReportService = ((VisitReportService) ClassFactory.newInstance(VisitReportService.class));
            reportDataWrappers = visitReportService.getReportDataWrapper();
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return JSON.serialize(reportDataWrappers);
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
        public List<LabsNameDescriptionWrapper> labsDescription;
        @AuraEnabled
        public List<VisitDataWrapper> tHead;
        @AuraEnabled
        public List<List<VisitDataWrapper>> visitResultsWrapper;
        @AuraEnabled
        public String tableName;
    }

    public class LabsNameDescriptionWrapper {
        @AuraEnabled
        public String nameLabs;
        @AuraEnabled
        public String descriptionLab;

        public LabsNameDescriptionWrapper(Visit_Result_TypeM__mdt visitResultTypeM) {
            this.nameLabs = TranslateHelper.getLabelValue(visitResultTypeM.DeveloperName);
            this.descriptionLab = TranslateHelper.getLabelValue(visitResultTypeM.Description_Label_Api_Name__c);
        }
    }

    public class VisitDataWrapper {
        @AuraEnabled
        public String value;
        @AuraEnabled
        public Double minValue;
        @AuraEnabled
        public Double maxValue;
        @AuraEnabled
        public Boolean isShowRange;
        @AuraEnabled
        public String measurement;

        public VisitDataWrapper(Visit_Result__c visitResult) {
            this.value = TranslateHelper.getLabelValue(visitResult.Result_Type__c);
            this.minValue = visitResult.Min_Value__c;
            this.maxValue = visitResult.Max_Value__c;
            this.measurement = visitResult.Measurement__c;
            this.isShowRange = true;
        }

        public VisitDataWrapper(String value, String measurement) {
            this.value = TranslateHelper.getLabelValue(value);
            this.measurement = measurement;
        }

        public VisitDataWrapper(String value) {
            this.value = TranslateHelper.getLabelValue(value);
            this.isShowRange = false;
        }
    }
}