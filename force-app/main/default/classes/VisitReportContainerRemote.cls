/**
 * Created by Yehor Dobrovolskyi
 */
public inherited sharing class VisitReportContainerRemote {
    public static final List<Object> FORMAT_PARAMETERS = new List<Object>{
            '',
            ')',
            '(BMI)',
            'Blood urea nitrogen (',
            'Alanine aminotransferase (',
            'Aspartate aminotransferase ('
    };
    public static final List<Object> FORMAT_EMPTY_PARAMETERS = new List<Object>{
            '',
            '',
            '',
            '',
            '',
            ''
    };
    public static final String IQVIA_LOGO = 'IQVIA';
    private static String base64PNG = 'data:image/png;base64,';

    @AuraEnabled
    public static String getLogoFromStatic() {
        try {
            Blob imageLogo = [
                    SELECT Body
                    FROM StaticResource
                    WHERE Name = :IQVIA_LOGO
            ].Body;
            return base64PNG + EncodingUtil.base64Encode(imageLogo);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return base64PNG;
    }

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
        @AuraEnabled
        public String tableApiName;
    }

    public class LabsNameDescriptionWrapper {
        @AuraEnabled
        public String nameLabs;
        @AuraEnabled
        public String descriptionLab;

        public LabsNameDescriptionWrapper(Visit_Result_TypeM__mdt visitResultTypeM) {

            this.nameLabs = String.format(TranslateHelper.getLabelValue(visitResultTypeM.DeveloperName), FORMAT_PARAMETERS);
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
            this.value = String.format(TranslateHelper.getLabelValue(visitResult.Result_Type__c), FORMAT_EMPTY_PARAMETERS);
            if (visitResult.Min_Value__c != null) {
                this.minValue = visitResult.Min_Value__c.setScale(4, RoundingMode.HALF_UP).stripTrailingZeros();
                this.isShowRange = true;
            }
            if (visitResult.Max_Value__c != null) {
                this.maxValue = visitResult.Max_Value__c.setScale(4, RoundingMode.HALF_UP).stripTrailingZeros();
                this.isShowRange = true;
            }
            this.measurement = visitResult.Measurement__c;
        }

        public VisitDataWrapper(String value, String measurement) {
            this.value = TranslateHelper.getLabelValue(value);
            this.measurement = measurement;
        }

        public VisitDataWrapper(String value) {
            this.value = String.format(TranslateHelper.getLabelValue(value), FORMAT_EMPTY_PARAMETERS);
            this.isShowRange = false;
        }
    }
}