/**
 * Created by Yehor Dobrovolskyi
 */
public inherited sharing class VisitReportContainerRemote {
    static Set<String> differentLabNames = new Set<String>{
            'Body_Mass_Index',
            'BUN',
            'AST',
            'ALT'
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
    public static ReportDataWrapper getReportDataWrappers(Id peId) {
        try {
            VisitReportService visitReportService = ((VisitReportService) ClassFactory.newInstance(VisitReportService.class));
            return visitReportService.getReportDataWrapper(peId);
        } catch (Exception e) {
            return (ReportDataWrapper) AuraHelper.throwException(e);
        }
    }

    public class ReportDataWrapper {
        @AuraEnabled public List<ReportDataTableWrapper> dataTables;
        @AuraEnabled public String studyCodeName;
        @AuraEnabled public String studyTitle;
        @AuraEnabled public String profilePicture;
        @AuraEnabled public String participantFullName;
        @AuraEnabled public String participantLastName;
        @AuraEnabled public String enrollmentDate;
        @AuraEnabled public String studySiteName;
        @AuraEnabled public String notAvailableMessage;
        @AuraEnabled public String participantStatus;//For In-trial Summary Report
    }

    public class ReportDataTableWrapper {
        @AuraEnabled public List<LabsNameDescriptionWrapper> labsDescription;
        @AuraEnabled public List<VisitDataWrapper> tHead;
        @AuraEnabled public List<List<VisitDataWrapper>> visitResultsWrapper;
        @AuraEnabled public String tableName;
        @AuraEnabled public String tableApiName;
    }

    public class LabsNameDescriptionWrapper {
        @AuraEnabled public String nameLabs;
        @AuraEnabled public String descriptionLab;

        public LabsNameDescriptionWrapper(Visit_Result_TypeM__mdt visitResultTypeM, String language) {
            this.nameLabs = differentLabNames.contains(visitResultTypeM.DeveloperName)
                    ? TranslateHelper.getLabelValue(visitResultTypeM.DeveloperName + '_Name_Labs', language)
                    : TranslateHelper.getLabelValue(visitResultTypeM.DeveloperName, language);
            this.descriptionLab = TranslateHelper.getLabelValue(visitResultTypeM.Description_Label_Api_Name__c, language);
        }
    }

    public virtual class VisitDataWrapper{
        @AuraEnabled public String value;
    }

    public class VisitHeaderWrapper extends VisitDataWrapper{
        @AuraEnabled public Double minValue;
        @AuraEnabled public Double maxValue;
        @AuraEnabled public Boolean isShowRange;
        @AuraEnabled public String measurement;

        public VisitHeaderWrapper(Visit_Result__c visitResult) {
            this.value = TranslateHelper.getLabelValue(visitResult.Result_Type__c);
            this.minValue = visitResult.Min_Value__c;
            this.maxValue = visitResult.Max_Value__c;
            this.isShowRange = true;
            this.measurement = visitResult.Measurement__c;
        }
    
        public VisitHeaderWrapper(String value) {
            this.value = TranslateHelper.getLabelValue(value);
            this.isShowRange = false;
        }
        public VisitHeaderWrapper(String value, String measurement) {
            this.value = TranslateHelper.getLabelValue(value);
            this.isShowRange = false;
            this.measurement = measurement;
        }
    }

    public class VisitDateColumnWrapper extends VisitDataWrapper{
        public VisitDateColumnWrapper(Date resultDate) {
            this.value = resultDate.format();
        }
    }

    public class VisitValueWrapper extends VisitDataWrapper {
        @AuraEnabled
        public String measurement;

        public VisitValueWrapper(Decimal value, String measurement) {
            this.value = value.toPlainString();
            this.measurement = measurement;
        }
        public VisitValueWrapper(String value) {
            this.value = value;
        }
    }
}