public class ExcelController {
    
    private String userMode;
    private String study;
    private String referringClinic;
    private String dateRange;
    
    private List<String> peFields;
    private List<FieldSetMember> peFSMList;
    private List<String> hcpeFields;
    private List<FieldSetMember> hcpeFSMList;
    
    private static final List<String> USER_MODES_FOR_REPORTS = new List<String>{
            CommunityService.USER_MODE_PI,
            CommunityService.USER_MODE_HCP
    };
    
    public ExcelController() {
        //userMode = CommunityService.USER_MODE_HCP;
        //CommunityService.setDummyUserContact('0030n00000d8PgE');
        if(ApexPages.currentPage() != null){
            userMode = ApexPages.currentPage().getParameters().get('userMode');
            study = ApexPages.currentPage().getParameters().get('study');
            referringClinic = ApexPages.currentPage().getParameters().get('referringClinic');
            dateRange = ApexPages.currentPage().getParameters().get('dateRange');
        }
        peFields = new List<String>();
        peFSMList = SObjectType.Participant_Enrollment__c.FieldSets.ExportExcel.getFields();
        for (Schema.FieldSetMember fsm : peFSMList) {
            peFields.add(fsm.getFieldPath());
        }
        hcpeFields = new List<String>();
        hcpeFSMList = SObjectType.HCP_Enrollment__c.FieldSets.ExportExcel.getFields();
        for (Schema.FieldSetMember flds : hcpeFSMList) {
            hcpeFields.add(flds.getFieldPath());
        }

    }

    public List<Participant_Enrollment__c> getPEList() {
        if(!USER_MODES_FOR_REPORTS.contains(userMode)) return new List<Participant_Enrollment__c>();
        
        String filter;
        List<String> filters = new List<String>();
        if (!String.isBlank(study)) filters.add(' Study_Site__r.Clinical_Trial_Profile__c = \'' + study + '\' ');
        if (!String.isBlank(referringClinic)) filters.add(' HCP__r.HCP_Contact__r.AccountId = \'' + referringClinic + '\' ');
        if (!String.isEmpty(dateRange)) filters.add(' CreatedDate ' + EncodingUtil.urlDecode(dateRange, 'UTF-8'));
        if (!filters.isEmpty()) filter = 'AND ' + String.join(filters, ' AND ');
        
        System.debug('FILTER: ' + filter);
        return ParticipantEnrollmentService.getPEnrolmentsCommonCustomFields(userMode, peFields, filter);
    }

    public List<HCP_Enrollment__c> getHCPEList(){
        if(!USER_MODES_FOR_REPORTS.contains(userMode)) return new List<HCP_Enrollment__c>();
        
        String filter;
        List<String> filters = new List<String>();
        filters.add('Study_Site__r.Clinical_Trial_Profile__r.Orientation_Required__c = true');
        if (!String.isEmpty(study)) filters.add(' Study_Site__r.Clinical_Trial_Profile__c = \'' + study + '\' ');
        if (!String.isEmpty(referringClinic)) filters.add(' HCP_Contact__r.AccountId = \'' + referringClinic + '\' ');
        if (!String.isEmpty(dateRange)) filters.add(' CreatedDate ' + EncodingUtil.urlDecode(dateRange, 'UTF-8'));
        if (!filters.isEmpty()) filter = 'AND ' + String.join(filters, ' AND ');
        
        System.debug('FILTER: ' + filter);
        return HCPEnrollmentService.getHCPEnrollmentsCommonCustomFields(userMode, hcpeFields, filter, false);
    }
    
}