public class ExcelController {
    
    private String userMode;
    private String study;
    private String referringClinic;
    private String dateRange;
    private String delegateId;
    
    private List<String> peFields;
    private List<FieldSetMember> peFSMList;
    private List<String> hcpeFields;
    private List<FieldSetMember> hcpeFSMList;
    
    private static final List<String> USER_MODES_FOR_REPORTS = new List<String>{
            CommunityService.USER_MODE_PI,
            CommunityService.USER_MODE_HCP
    };
    private static final List<String> COMMUNITY_TEMPLATES_NON_JANSSEN = new List<String>{
            CommunityTemplateService.TEMPLATE_DEFAULT,
            CommunityTemplateService.TEMPLATE_GSK
    };

    private static final String EXPORTED_SOBJECT_PE = 'PE';
    private static final String EXPORTED_SOBJECT_HCPE = 'HCPPE';

    public ExcelController() {
        //userMode = CommunityService.USER_MODE_HCP;
        //CommunityService.setDummyUserContact('0030n00000d8PgE');
        if(ApexPages.currentPage() != null){
            userMode = ApexPages.currentPage().getParameters().get('userMode');
            study = ApexPages.currentPage().getParameters().get('study');
            referringClinic = ApexPages.currentPage().getParameters().get('referringClinic');
            dateRange = ApexPages.currentPage().getParameters().get('dateRange');
            delegateId = ApexPages.currentPage().getParameters().get('delegateId');
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
        if(userMode == CommunityService.USER_MODE_PI){
            filters.add(DatabaseService.fieldInValues('Participant_Status__c', PEStatusState.PE_STATUS_GROUP_PI_VISIBLE));
        }
        if (!String.isBlank(study)) {
            filters.add(' Study_Site__r.Clinical_Trial_Profile__c = \'' + study + '\' ');
        }
        else {
            filters.add(getCommunityFilter(EXPORTED_SOBJECT_PE));
        }
        if (!String.isBlank(referringClinic)) filters.add(' HCP__r.HCP_Contact__r.AccountId = \'' + referringClinic + '\' ');
        if (!String.isEmpty(dateRange)) filters.add(' CreatedDate ' + EncodingUtil.urlDecode(dateRange, 'UTF-8'));
        if (!filters.isEmpty()) filter = 'AND ' + String.join(filters, ' AND ');
        
        System.debug('FILTER: ' + filter);
        return ParticipantEnrollmentService.getPEnrolmentsCommonCustomFields(userMode, peFields, filter, delegateId);
    }
    public List<FieldWrapper> getPEFieldsList() {
        List<FieldWrapper> result = new List<FieldWrapper>();
        Map<String, String> fieldLabelsMap = new Map<String, String>();
        for(Excel_Export_Field_Label__mdt fieldLabelSetting : [SELECT
                Field_Name__c, Label_Name__c
                FROM Excel_Export_Field_Label__mdt
                WHERE SObject_Name__c='Participant_Enrollment__c']){
            TranslateHelper.prepareLabelFields(fieldLabelSetting, new Set<String>{'Label_Name__c'});
            fieldLabelsMap.put(fieldLabelSetting.Field_Name__c, fieldLabelSetting.Label_Name__c);
        }
        for(FieldSetMember fsm : peFSMList){
            String path = fsm.getFieldPath();
            FieldWrapper fw = new FieldWrapper();
            fw.fieldPath = path;
            if(fieldLabelsMap.containsKey(path)){
                fw.label = fieldLabelsMap.get(path);
            }
            else{
                fw.label = fsm.getLabel();
            }
            result.add(fw);

        }

        return result;
    }

    public List<HCP_Enrollment__c> getHCPEList(){
        if(!USER_MODES_FOR_REPORTS.contains(userMode)) return new List<HCP_Enrollment__c>();
        
        String filter;
        List<String> filters = new List<String>();
        filters.add('Study_Site__r.Clinical_Trial_Profile__r.Orientation_Required__c = true');
        if (!String.isEmpty(study)) {
            filters.add(' Study_Site__r.Clinical_Trial_Profile__c = \'' + study + '\' ');
        }
        else {
            filters.add(getCommunityFilter(EXPORTED_SOBJECT_HCPE));
        }
        if (!String.isEmpty(referringClinic)) filters.add(' HCP_Contact__r.AccountId = \'' + referringClinic + '\' ');
        if (!String.isEmpty(dateRange)) filters.add(' CreatedDate ' + EncodingUtil.urlDecode(dateRange, 'UTF-8'));
        if (!filters.isEmpty()) filter = 'AND ' + String.join(filters, ' AND ');
        
        System.debug('FILTER: ' + filter);
        return HCPEnrollmentService.getHCPEnrollmentsCommonCustomFields(userMode, delegateId, hcpeFields, filter, false);
    }

    public String getCommunityFilter(String exportedSObject){
        if (UserContext.getCurrentCommunityTemplate().templateName == CommunityTemplateService.TEMPLATE_JANSSEN) {
            return ' Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c NOT IN (\'' + String.join(COMMUNITY_TEMPLATES_NON_JANSSEN, '\',\'') + '\') ';
        }
        else{
            return ' Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c IN (\'' + String.join(COMMUNITY_TEMPLATES_NON_JANSSEN, '\',\'') + '\') ';
        }
    }

    public class FieldWrapper{
        public String label;
        public String fieldPath;
        public String getLabel(){
            return label;
        }
        public String getFieldPath(){
            return fieldPath;
        }
    }
    
}