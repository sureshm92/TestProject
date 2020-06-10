/* Created By
 * Akanksha */

public class MediaOutreachServices {
    
    public static final String STUDIES_FILTER_DATA_FIELD = 'studies';
    
    public static final Map<String, Map<String, String>> FILTER_FIELD_MAP = new Map<String, Map<String, String>>{
        STUDIES_FILTER_DATA_FIELD => new Map<String, String>{
            'Study_Name__c' => 'Study_Name__r.Clinical_Trial_Profile__r.Study_Code_Name__c'
                }
    };
        
        public class moFilter{
            public List<Id> trialIds;
            public Id study;
            public String searchText;
            public String mode;
            public moFilter(moFilterData filterData) {
                mode = filterData.mode;
                trialIds = filterData.trialIds;
            }
        }
    
    public class moFilterData {
        public String mode;
        public List<Id> trialIds;
        public List<LabelValueItem> studies;
    }
    
    public static moFilterData getMOFilterData(Id trialId, String mode, Boolean restrictTrial, String delegateId) {
        Id userContactId = CommunityService.getUserContact().Id;
        Clinical_Trial_Profile__c trial;
        moFilterData moFilterData = new moFilterData();
        moFilterData.mode = mode;
        Map<Id, Clinical_Trial_Profile__c> trialsMap = new Map<Id, Clinical_Trial_Profile__c>(TrialService.getAvailableTrials(mode, delegateId));
        moFilterData.studies = new List<LabelValueItem>();
        moFilterData.studies.add(new LabelValueItem(Label.PG_MRRL_L_All_studies, null));
        moFilterData.trialIds = new List<Id>();
        
        for (String id : trialsMap.keySet()) {
            moFilterData.trialIds.add(id);
            trial = trialsMap.get(id);
            moFilterData.studies.add(new LabelValueItem(trial.Study_Code_Name__c, trial.Id));
        }
        return moFilterData;
    }
    
    public static List<Media_Outreach__c> getMediaOutreach(moFilter filter, PaginationData paginationData) {
        return getMediaOutreach(filter, paginationData, null);
    }
    
    public static List<Media_Outreach__c> getMediaOutreach(moFilter filter, PaginationData paginationData, String delegateId) {
        List<Media_Outreach__c> mList = getMediaOutreach(filter, delegateId);
        return getMediaOutreachPagination(mList, paginationData);
    }
    
    public static List<Media_Outreach__c> getMediaOutreachPagination(List<Media_Outreach__c> mList, PaginationData paginationData) {
        //Pagination:
        if (paginationData != null) {
            paginationData.setRecordsCount(mList.size());
            List<Media_Outreach__c> pageList = new List<Media_Outreach__c>();
            for (Integer i = paginationData.offset; i < paginationData.endOffset; i++) {
                pageList.add(mList[i]);
            }
            return pageList;
        }
        return mList;
    }
    
    //Media Outreach fields
    public static final List<String> MO_COMMON_FIELDS = new List<String>{
        'Id',
            'Name',
            'Preferred_contact_method__c',
            'Status__c',
            'Media_Type__c',
            'Study_Name__r.Site__r.Name',
            'Study_Name__r.Name',
            'Study_Name__r.Clinical_Trial_Profile__r.Study_Code_Name__c',
            'Study_Name__r.Clinical_Trial_Profile__c',
            'Study_Name__r.Principal_Investigator__c',
            'Requested_End_Date__c',
            'Requested_Start_Date__c'
            
            };
                
                //filter criteria - existing filter on study
                public static List<Media_Outreach__c> getMediaOutreach(moFilter filter, String delegateId){
                    //get all the media outreach assigned to a PI
                    String filterStr = ' AND Study_Name__r.Clinical_Trial_Profile__c IN (\'' + String.join(filter.trialIds, '\',\'') + '\') ';
                    if (filter.searchText != null) filter.searchText = filter.searchText.trim();
                    
                    //If a filter is selected
                    if (String.isEmpty(filter.searchText)) {
                        if (!String.isEmpty(filter.study)) filterStr += ' AND Study_Name__c = \'' + filter.study + '\' ';
                    }
                    
                    //sort
                    filterStr += ' ORDER BY Name DESC';
                    
                    //get media outreach List:
                    List<Media_Outreach__c> mList = getMOutreachCommon(filterStr, delegateId);
                    return mList;
                }
    
    public static List<Media_Outreach__c> getMOutreachCommon(String filter, String delegateId) {
        List<Media_Outreach__c> mList = getMOutreachCommonCustomFields(MO_COMMON_FIELDS, filter, delegateId);
        return mList;
    }
    
    public static List<Media_Outreach__c> getMOutreachCommonCustomFields(List<String> customFields, String filter, String delegateId) {
        return getMOutreachCommonCustomFieldsImpl(customFields, filter, delegateId);
    }
    
    public static List<Media_Outreach__c> getMOutreachCommonCustomFieldsImpl(List<String> customFields, String filter) {
        return getMOutreachCommonCustomFieldsImpl(customFields, filter, null);
    }
    
    
    //dynamic query formation. Adding the filters and fields to be fetched from Media Outreach object
    public static List<Media_Outreach__c> getMOutreachCommonCustomFieldsImpl(List<String> customFields, String filter, String delegateId) {
        String defaultFilter = ' Study_Name__c != NULL AND Status__c !=NULL';// AND ' + getUserModeFilter(userMode, delegateId);
        defaultFilter += ' AND ' + getUserModeFilter(delegateId);
        if (filter != null) defaultFilter += ' ' + filter;
        
        List<Media_Outreach__c> mList = DatabaseService.query(
            customFields,
            Media_Outreach__c.getSObjectType(),
            defaultFilter
        );
        return mList;
    }
    
    //default filter on the Principal Investigator
    private static String getUserModeFilter(String delegateId) {
        String delegatesFilter = '';
        List<Id> delegatedSSIds = DelegateService.getDelegatedStudySiteIds();
        if (delegatedSSIds.size() > 0) delegatesFilter = ' OR Study_Name__c IN (\'' + String.join(delegatedSSIds, '\',\'') + '\')' ;
        return '( ' +
            '   Study_Name__r.Principal_Investigator__c = \'' + CommunityService.getUserContact().Id + '\' ' +
            delegatesFilter +
            ') ';
    }
    
}