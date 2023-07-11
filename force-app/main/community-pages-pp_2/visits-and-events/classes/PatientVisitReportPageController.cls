public without sharing class PatientVisitReportPageController {
    public String peId { get; set; }
    public ModifiedVisitReportContainerRemote.ReportDataWrapper reportDataObj { get; set; }
    public String imgUrl { get; set; }
    public Boolean isRTL { get; set; }
    public String studyTitle { get; set; }
    public String str { get; set; }
    public String studyCodeName { get; set; }
    public String participantFullName { get; set; }
    public String enrollmentDate { get; set; }
    public String studySiteName { get; set; }
    public String participantStatus { get; set; }
    public String pdfStudyHeaderName { get; set; }
    public ReportDataWrapper reportWrapperFinalObj { get; set; }
    public String fontFamily { get; set; }
    public String footerText { get; set; }
    public String patientVisitName { get; set; }
    public Id patientVisitId { get; set; }
    public String patVisitCompleted { get; set; }
    public String pdfFooterptFullName { get; set; }
    public String pdfFooterstudySiteName { get; set; }
    public String pdfHeaderVisitName { get; set; }
    public String pdfFooterptStatus { get; set; }
    public String headerName { get; set; }
    public String dateLabel { get; set; }
    public class ReportDataWrapper {
        public List<ReportDataTableWrapper> dataTables { get; set; }
        public String studyCodeName { get; set; }
        public String communityTemplate { get; set; }
        public String studyTitle { get; set; }
        public String profilePicture { get; set; }
        public String participantFullName { get; set; }
        public String participantLastName { get; set; }
        public String enrollmentDate { get; set; }
        public String studySiteName { get; set; }
        public String notAvailableMessage { get; set; }
        public String participantStatus { get; set; }
    }
    public class ReportDataTableWrapper {
        public List<LabsNameDescriptionWrapper> labsDescription { get; set; }
        public List<VisitHeaderWrapper> tHead { get; set; }
        public List<List<VisitDataWrapper>> visitResultsWrapper { get; set; }
        public String tableName { get; set; }
        public String tableApiName { get; set; }
    }

    public class LabsNameDescriptionWrapper {
        public String nameLabs { get; set; }
        public String descriptionLab { get; set; }
    }
    public virtual class VisitDataWrapper {
        public String value { get; set; }
        public String measurement { get; set; }
    }

    public class VisitHeaderWrapper extends VisitDataWrapper {
        public Double minValue { get; set; }
        public Double maxValue { get; set; }
        public Boolean isShowRange { get; set; }
        public String measurement { get; set; }
    }

    public PatientVisitReportPageController() {
        peId = System.currentPagereference().getParameters().get('peId');
        isRTL = Boolean.valueOf(System.currentPagereference().getParameters().get('isRTL'));

        if (System.currentPagereference().getParameters().containsKey('patientVisitNam')) {
            patientVisitName = System.currentPagereference().getParameters().get('patientVisitNam');
        }
        if (System.currentPagereference().getParameters().containsKey('patientVisitId')) {
            patientVisitId = System.currentPagereference().getParameters().get('patientVisitId');
        }

        if (String.IsNotBlank(peId)) {
            reportDataObj = ModifiedVisitReportContainerRemote.getReportDataWrappers_Modified(
                peId,
                patientVisitId
            );
            str = JSON.serialize(reportDataObj);
            reportWrapperFinalObj = (ReportDataWrapper) System.JSON.deserialize(
                str,
                ReportDataWrapper.class
            );

            imgUrl = reportDataObj.communityTemplate + '.png';
            studyTitle = reportDataObj.studyTitle;
            studyCodeName = reportDataObj.studyCodeName;
            participantFullName = reportDataObj.participantFullName;
            enrollmentDate = reportDataObj.enrollmentDate;
            participantStatus = reportDataObj.participantStatus;
            studySiteName = reportDataObj.studySiteName;
            pdfStudyHeaderName = studyCodeName.length() > 70
                ? studyCodeName.substring(0, 70) + '...'
                : studyCodeName;
            pdfFooterptFullName = participantFullName.length() > 35
                ? participantFullName.substring(0, 35) + '...'
                : participantFullName;
            pdfFooterstudySiteName = studySiteName.length() > 40
                ? studySiteName.substring(0, 40) + '...'
                : studySiteName;
            if (patientVisitName != null) {
                pdfHeaderVisitName = patientVisitName.length() > 20
                    ? patientVisitName.substring(0, 20) + '...'
                    : patientVisitName;
            } else {
                pdfHeaderVisitName = System.Label.Cumulative_Study_Data_Report;
            }
            if (participantStatus != null) {
                pdfFooterptStatus = participantStatus.length() > 32
                    ? participantStatus.substring(0, 32) + '...'
                    : participantStatus;
            }
            if (patientVisitName != null) {
                headerName = System.Label.Study_Data_Report;
            } else {
                headerName = System.Label.Cumulative_Study_Data_Report;
            }

            if (participantStatus == 'Randomization Success') {
                dateLabel = System.Label.Report_Randomization_Date;
            } else {
                dateLabel = System.Label.Report_Enrollment_Date;
            }
            String file_Name='';
            if(String.isNotBlank(patientVisitName)){ 
                file_Name=System.Label.MyResultsData+'_'+studyCodeName+'_'+patientVisitName;
            }else{
                file_Name=System.Label.MyCumulativeResultsData+'_'+studyCodeName;
            }
            file_Name = file_Name.replace(' ','');
            Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename='+file_Name+'.pdf');
            fontFamily = 'Arial Unicode MS';
            Set<String> latinIso = new Set<String>{
                'it',
                'es',
                'pt',
                'fr',
                'de',
                'nl',
                'en',
                'da',
                'sv',
                'no',
                'is'
            };
            for (String st : latinIso) {
                if (UserInfo.getLanguage().contains(st)) {
                    fontFamily = 'sans-serif';
                    break;
                }
            }
            List<ReportDataTableWrapper> dataTablesContainer = reportWrapperFinalObj.dataTables;
            if (dataTablesContainer != null) {
                for (ReportDataTableWrapper dattable : dataTablesContainer) {
                    if (dattable != null) {
                        List<List<VisitDataWrapper>> visitResultsWrapper = dattable.visitResultsWrapper;
                        for (List<VisitDataWrapper> wrapper : visitResultsWrapper) {
                            for (VisitDataWrapper visData : wrapper) {
                                String completedDate = visData.value;
                                if (String.isNotEmpty(completedDate))
                                    patVisitCompleted = completedDate;
                                break;
                            }
                        }
                    }
                }
            }

            if (isRTL) {
                List<ReportDataTableWrapper> datatablesList = reportWrapperFinalObj.dataTables;

                Integer j = 0;
                for (ReportDataTableWrapper dattable : datatablesList) {
                    List<VisitHeaderWrapper> tHeadList = dattable.tHead;
                    List<VisitHeaderWrapper> tHeadRevList = new List<VisitHeaderWrapper>();
                    for (Integer i = tHeadList.size() - 1; i >= 0; i--) {
                        tHeadRevList.add(tHeadList[i]);
                    }
                    datatablesList[j].tHead = tHeadRevList;

                    List<List<VisitDataWrapper>> visitResultsWrapper = dattable.visitResultsWrapper;
                    Integer k = 0;
                    for (List<VisitDataWrapper> rowItem : visitResultsWrapper) {
                        List<VisitDataWrapper> rowReverItem = new List<VisitDataWrapper>();
                        for (Integer i = rowItem.size() - 1; i >= 0; i--) {
                            rowReverItem.add(rowItem[i]);
                        }
                        dattable.visitResultsWrapper[k] = rowReverItem;
                        k++;
                    }

                    j++;
                }
            }

            if (UserInfo.getLanguage() == 'ja') {
                List<ReportDataTableWrapper> datatablesLists = reportWrapperFinalObj.dataTables;
                footerText = addBreakLines(Label.Visit_Results_Report_Footer_2, 95);
                Integer i = 0;
                for (ReportDataTableWrapper dattable : datatablesLists) {
                    List<LabsNameDescriptionWrapper> labDescription = dattable.labsDescription;
                    Integer j = 0;
                    for (LabsNameDescriptionWrapper labTabItem : labDescription) {
                        String resultString = addBreakLines(labTabItem.descriptionLab, 65);
                        reportWrapperFinalObj.dataTables[i]
                            .labsDescription[j]
                            .descriptionLab = resultString;
                        j++;
                    }

                    i++;
                }
            } else {
                footerText = Label.Visit_Results_Report_Footer_2;
            }
        }
    }

    public static String addBreakLines(String actualString, Integer limitLength) {
        String resultString = '';
        Integer startIndex = 0;
        Integer endIndex = limitLength;
        while (true) {
            Integer length = actualString.length();
            if (length > (limitLength + 1)) {
                String s = actualString.subString(startIndex, endIndex);
                resultString = resultString + s + '\n';
                startIndex = endIndex;
                endIndex = endIndex + limitLength;
                if (endIndex > actualString.length()) {
                    endIndex = actualString.length();
                    resultString = resultString + actualString.subString(startIndex, endIndex);
                    break;
                }
                continue;
            } else {
                return actualString;
            }
        }
        return resultString;
    }
}