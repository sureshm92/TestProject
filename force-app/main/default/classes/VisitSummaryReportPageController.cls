public without sharing class  VisitSummaryReportPageController {
    public String peId {get;set;}
    public VisitReportContainerRemote.ReportDataWrapper reportDataObj {get;set;}
    public String imgUrl {get;set;}
    public Boolean isRTL {get;set;}
    public String studyTitle {get;set;}
    public String str {get;set;}
    public String studyCodeName{get;set;}
    public String communityTemplate{get;set;}
    public String participantFullName{get;set;}
    public String participantLastName{get;set;}
    public String enrollmentDate{get;set;}
    public String studySiteName{get;set;}
    public String notAvailableMessage{get;set;}
    public String participantStatus{get;set;}
    public String pdfStudyHeaderName {get;set;}
    public ReportDataWrapper reportWrapperFinalObj { get;set;}
    public String fontFamily { get;set;}
    
    
    public List<ReportDataTableWrapper> reportDataTableWrapperList {get;set;}
    List<VisitReportContainerRemote.ReportDataTableWrapper> rsList {get;set;}
    public List<List<VisitDataWrapper>> visitResultsWrapperList {get;set;} 
    
    
    
    public class ReportDataWrapper {
        public List<ReportDataTableWrapper> dataTables  {get;set;} 
        public String studyCodeName  {get;set;} 
        public String communityTemplate  {get;set;} 
        public String studyTitle  {get;set;}  
        public String profilePicture  {get;set;} 
        public String participantFullName  {get;set;} 
        public String participantLastName  {get;set;} 
        public String enrollmentDate  {get;set;} 
        public String studySiteName  {get;set;} 
        public String notAvailableMessage  {get;set;} 
        public String participantStatus  {get;set;} 
    }
    public class ReportDataTableWrapper {  
        
        public List<LabsNameDescriptionWrapper> labsDescription{get;set;}
        public List<VisitHeaderWrapper> tHead{get;set;}
        public List<List<VisitDataWrapper>> visitResultsWrapper{get;set;}
        public String tableName{get;set;}
        public String tableApiName{get;set;}
    }
    
    public class LabsNameDescriptionWrapper {
        public String nameLabs {get;set;}
        public String descriptionLab {get;set;}
        
    }
    public virtual class VisitDataWrapper {
        public String value {get;set;}
    }
    
    public class VisitHeaderWrapper extends VisitDataWrapper {
        public Double minValue {get;set;}
        public Double maxValue {get;set;}
        public Boolean isShowRange {get;set;}
        public String measurement {get;set;}
    }
    
    public VisitSummaryReportPageController() {
        peId= System.currentPagereference().getParameters().get('peId');
        isRTL =  Boolean.valueOf(System.currentPagereference().getParameters().get('isRTL'));
        if(String.IsNotBlank(peId))
        {
            reportDataObj = VisitReportContainerRemote.getReportDataWrappers(peId);
            str = JSON.serialize(reportDataObj);
            reportWrapperFinalObj=  (ReportDataWrapper) System.JSON.deserialize(str, ReportDataWrapper.class);
            
            imgUrl=reportDataObj.communityTemplate + '.png';
            studyTitle = reportDataObj.studyTitle;
            studyCodeName = reportDataObj.studyCodeName;
            pdfStudyHeaderName = reportDataObj.studyCodeName;
            participantFullName = reportDataObj.participantFullName;
            enrollmentDate = reportDataObj.enrollmentDate;
            participantStatus = reportDataObj.participantStatus;
            studySiteName = reportDataObj.studySiteName;
            if(studyCodeName.length()>58){
                pdfStudyHeaderName= pdfStudyHeaderName.substring(0,58)+'...';
            }
            fontFamily =  'Arial Unicode MS';
            Set<String> latinIso = new Set<String>{'it','es','pt','fr','de','nl','en','da','sv','no','is'};
                for (String st : latinIso) {
                    if(UserInfo.getLanguage().contains(st))
                    { 
                        fontFamily ='sans-serif' ;
                        break;
                    }
                }
            
            List<ReportDataTableWrapper> datatablesList = reportWrapperFinalObj.dataTables;
            List<ReportDataTableWrapper> datatablesRevList = reportWrapperFinalObj.dataTables;
            if(isRTL){
                Integer j=0;
                for(ReportDataTableWrapper dattable :datatablesList )
                {
                    
                    List<VisitHeaderWrapper> tHeadList = dattable.tHead;
                    List<VisitHeaderWrapper> tHeadRevList = new List<VisitHeaderWrapper>();
                    for(Integer i = tHeadList.size() - 1; i >= 0; i--){
                        tHeadRevList.add(tHeadList[i]);
                    }
                    datatablesList[j].tHead = tHeadRevList;
                    
                    List<List<VisitDataWrapper>> visitResultsWrapper = dattable.visitResultsWrapper;
                    Integer k =0;
                    for(List<VisitDataWrapper> rowItem : visitResultsWrapper)
                    {
                        List<VisitDataWrapper> rowReverItem = new List<VisitDataWrapper>();           
                        for(Integer i = rowItem.size() - 1; i >= 0; i--){
                            rowReverItem.add(rowItem[i]);
                        }
                        dattable.visitResultsWrapper[k] = rowReverItem; 
                        k++;
                    }
                    
                    j++; 
                    
                    
                }
            }
            
        }
        
    }
}