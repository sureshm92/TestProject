public class ModifiedVisitReportContainerRemote {
    static Set<String> differentLabNames = new Set<String>{
        'Body_Mass_Index',
        'BUN',
        'AST',
        'ALT'
    };

    @AuraEnabled
    public static ReportDataWrapper getReportDataWrappers_Modified(Id peId, Id patientVisitId) {
        try {
            ModifiedVisitReportService visitReportService = ((ModifiedVisitReportService) ClassFactory.newInstance(
                ModifiedVisitReportService.class
            ));
            return visitReportService.getReportDataWrapper(peId, patientVisitId);
        } catch (Exception e) {
            return (ReportDataWrapper) AuraHelper.throwException(e);
        }
    }

    public class ReportDataWrapper {
        @AuraEnabled
        public List<ReportDataTableWrapper> dataTables;
        @AuraEnabled
        public String studyCodeName;
        @AuraEnabled
        public String communityTemplate;
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
        @AuraEnabled
        public String notAvailableMessage;
        @AuraEnabled
        public String participantStatus; //For In-trial Summary Report
    }

    public class ReportDataTableWrapper {
        @AuraEnabled
        public List<LabsNameDescriptionWrapper> labsDescription;
        @AuraEnabled
        public List<VisitDataWrapper> tHead;
        @AuraEnabled
        public List<List<VisitValueWrapper>> visitResultsWrapper;
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

        public LabsNameDescriptionWrapper(
            Visit_Result_TypeM__mdt visitResultTypeM,
            String language,
            String customTooltipDes
        ) {
            this.nameLabs = differentLabNames.contains(visitResultTypeM.DeveloperName)
                ? TranslateHelper.getLabelValue(
                      visitResultTypeM.DeveloperName + '_Name_Labs',
                      language
                  )
                : TranslateHelper.getLabelValue(visitResultTypeM.DeveloperName, language);
            this.descriptionLab = String.isBlank(customTooltipDes)
                ? TranslateHelper.getLabelValue(
                      visitResultTypeM.Description_Label_Api_Name__c,
                      language
                  )
                : customTooltipDes;
        }
    }

    public virtual class VisitDataWrapper {
        @AuraEnabled
        public String value;
    }

    public class VisitHeaderWrapper extends VisitDataWrapper {
        public VisitHeaderWrapper(Visit_Result__c visitResult) {
            this.value = TranslateHelper.getLabelValue(visitResult.Result_Type__c);
        }
        public VisitHeaderWrapper(String value) {
            this.value = TranslateHelper.getLabelValue(value);
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
        public VisitValueWrapper(Date resultDate) {
            DateTime dt = DateTime.newInstance(
                resultDate.year(),
                resultDate.month(),
                resultDate.day()
            );
            this.value = UserService.formatDatebyLocale(dt, UserContext.getUser().LocaleSidKey);
        }
    }

    @AuraEnabled
    public static String getBase64fromVisitSummaryReportPage_Modified(
        String peId,
        String isRTL,
        String patientVisitNam,
        Id patientVisId
    ) {
        PageReference page = Page.PatientVisitReportPage;
        page.getParameters().put('peId', peId);
        page.getParameters().put('isRTL', isRTL);
        page.getParameters().put('patientVisitNam', patientVisitNam);
        page.getParameters().put('patientVisitId', patientVisId);
        String encoded;
        if (!Test.isRunningTest()) {
            Blob content = page.getContent();
            encoded = EncodingUtil.base64Encode(content);
        }
        return encoded;
    }
}
