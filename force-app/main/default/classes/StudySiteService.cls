/**
 * Created by D.Yasinskyi on 28.03.2018
 */
public without sharing class StudySiteService {
    public final static List<String> PI_STATUS_VALUES = new List<String>();
    public final static String PI_S_INVITATION_SENT = 'Invitation Sent';
    public final static String PI_S_ACCEPTED = 'Accepted';
    public final static String PI_S_ACCEPTED_A = 'Accepted (Admin)';
    public final static String PI_S_NON_RESPONCIVE_A = 'Non-Responsive (Admin)';
    public final static String PI_S_ON_HOLD = 'On Hold';
    public final static String PI_S_ON_HOLD_A = 'On Hold (Admin)';
    public final static String PI_S_DEACTIVATED_A = 'Deactivated (Admin)';
    public final static String PI_S_DECLINED_ACCEPTANCE = 'Declined (Acceptance)';
    //oldStatus/<actionType, newStatus>
    public final static Map<String, Map<String, String>> SS_CHANGE_STATUS_MAP = new Map<String, Map<String, String>>();
    
    public final static List<String> STATUS_GROUP_ACCEPTED = new List<String>{
            PI_S_ACCEPTED,
            PI_S_ACCEPTED_A
    };

    public final static List<String> STATUS_GROUP_ON_HOLD = new List<String>{
            PI_S_ON_HOLD,
            PI_S_ON_HOLD_A
    };

    static {
        for (Schema.PicklistEntry ple : Study_Site__c.Override_PI_Referral_Status__c.getDescribe().getPicklistValues()) {
            PI_STATUS_VALUES.add(ple.getValue());
        }
        SS_CHANGE_STATUS_MAP.put(PI_S_INVITATION_SENT, new Map<String, String>());
        SS_CHANGE_STATUS_MAP.get(PI_S_INVITATION_SENT).put('decline', PI_S_DECLINED_ACCEPTANCE);

        SS_CHANGE_STATUS_MAP.put(PI_S_ACCEPTED, new Map<String, String>());
        SS_CHANGE_STATUS_MAP.put(PI_S_ACCEPTED_A, new Map<String, String>());
        SS_CHANGE_STATUS_MAP.put(PI_S_NON_RESPONCIVE_A, new Map<String, String>());
        SS_CHANGE_STATUS_MAP.put(PI_S_ON_HOLD, new Map<String, String>());
        SS_CHANGE_STATUS_MAP.put(PI_S_ON_HOLD_A, new Map<String, String>());
        SS_CHANGE_STATUS_MAP.put(PI_S_DEACTIVATED_A, new Map<String, String>());
        SS_CHANGE_STATUS_MAP.put(PI_S_DECLINED_ACCEPTANCE, new Map<String, String>());

    }

    public static String changeStatus(Id studySiteId, String userMod, String newStatusType) {
        Study_Site__c studySite = [
                SELECT Id, Override_PI_Referral_Status__c
                FROM Study_Site__c
                WHERE Id = :studySiteId
        ];

        if (studySite == null) throw new AuraHandledException('Incorrect Study site studySiteId=' + studySiteId);
        String oldStatus = studySite.Override_PI_Referral_Status__c;
        String newStatus = SS_CHANGE_STATUS_MAP.get(oldStatus).get(newStatusType);

        if (newStatus == null) {
            throw new AuraHandledException('Invalid action! Can`t change this status to status = ' + newStatusType);
        }
        studySite.Override_PI_Referral_Status__c = newStatus;
        update studySite;
        return newStatus;
    }

    public static List<Study_Site__c> getStudySitesForPI() {
        return getStudySitesCommon(CommunityService.USER_MODE_PI, null, false);
    }

    private static final List<String> SS_COMMON_FIELDS = new List<String>{
            'Id',
            'Name',
            'Site__c',
            'Override_PI_Referral_Status__c',
            'Is_Virtual_Study_Site__c',
            'Site__r.BillingAddress',
            'Site__r.BillingCountry',
            'Site__r.BillingState',
            'Site__r.BillingStateCode',
            'Site__r.BillingPostalCode',
            'Site__r.BillingCity',
            'Site__r.BillingStreet',
            'Clinical_Trial_Profile__c',
            'Clinical_Trial_Profile__r.Id',
            'Clinical_Trial_Profile__r.Study_Title__c',
            'Clinical_Trial_Profile__r.Study_Code_Name__c',
            'Clinical_Trial_Profile__r.Official_Title__c',
            'Clinical_Trial_Profile__r.Study_Sponsor__c',
            'Clinical_Trial_Profile__r.Override_Recruitment_Status__c',
            'Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c',
            'Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c',
            'Clinical_Trial_Profile__r.Link_to_Pre_screening__c',
            'Clinical_Trial_Profile__r.Orientation_Required__c ',
            'Principal_Investigator__r.Name'
    };


    public static List<Study_Site__c> getStudySitesCommon(String filter){
        String query = 'SELECT ' + String.join(SS_COMMON_FIELDS, ',') +
                ' FROM Study_Site__c ';
        if(filter != null) query += ' WHERE ' + filter;
        System.debug('EXECUTE QUERY: ' + query);
        List<Study_Site__c> ssList = Database.query(query);
        TranslateHelper.translate(ssList);
        return ssList;
    }

    public static List<Study_Site__c> getStudySitesCommon(String userMode, String filter, Boolean excludeDelegates){
        String userModeFilter = getUserModeFilter(userMode, excludeDelegates);
        if(filter != null) userModeFilter += ' ' + filter;
        return getStudySitesCommon(userModeFilter);
    }

    public static String getUserModeFilter(String userMode, Boolean excludeDelegates){
        String filter = ' Clinical_Trial_Profile__c != NULL ' +
                        ' AND Override_PI_Referral_Status__c != NULL ';
        if(userMode == CommunityService.USER_MODE_PI){
            if(excludeDelegates){
                filter +=       ' AND  Principal_Investigator__c = \'' + CommunityService.getUserContact().Id + '\' ';
            }
            else{
                filter +=       ' AND ( ' +
                        '       Principal_Investigator__c = \'' + CommunityService.getUserContact().Id + '\' ' +
                        '       OR Id IN (\'' + String.join(DelegateService.getDelegatedStudySiteIds(), '\',\'') + '\')'+
                        '   ) ';
            }

        }
        return filter;
    }

    public static Study_Site__c getStudySiteForHCPById(Id ssId){
        List<Study_Site__c> studySites = getStudySitesCommon(
                CommunityService.USER_MODE_HCP,
                ' AND Id = \'' + ssId + '\' ',
                false
        );
        if(studySites.size() == 0) throw new CommunityServiceException('Data not found');
        return studySites[0];
    }

    public static List<Study_Site__c> getStudySiteForPIByTrialId(Id trialId) {
        return getStudySitesCommon(
                CommunityService.USER_MODE_PI,
                ' AND Clinical_Trial_Profile__c = \'' + trialId + '\' ' +
                        ' AND Override_PI_Referral_Status__c != NULL',
                false
        );
    }

    public static List<Study_Site__c> getStudySitesForHCP(List<Id> trialIds) {
        List<HCP_Enrollment__c> hcpEnrollments = HCPEnrollmentService.getHCPEnrollmentsCommon(
                CommunityService.USER_MODE_HCP,
                ' AND Study_Site__r.Clinical_Trial_Profile__c IN (\'' + String.join(trialIds, '\',\'') + '\')',
                false
        );
        List<Study_Site__c> resList = new List<Study_Site__c>();
        for (HCP_Enrollment__c he : hcpEnrollments) resList.add(he.Study_Site__r);
        return resList;
    }

    public static List<Study_Site__c> getStudySitesForHCPByTrialId(Id trialId){
        String query = 'SELECT ' + String.join(SS_COMMON_FIELDS, ',') +
                ' FROM Study_Site__c WHERE Clinical_Trial_Profile__c =\'' + trialId + '\'' +
                '  AND Override_PI_Referral_Status__c != NULL ' +
                '  AND Override_PI_Referral_Status__c IN (\'' + String.join(STATUS_GROUP_ACCEPTED, '\',\'') + '\')';
        return Database.query(query);
    }
    public static List<Study_Site__c> getStudySitesWithDelegateLevelFiltered(String filter, Set<String> delegateLevels){

        List<Study_Site__c> ssList = new List<Study_Site__c>();
        Map<Id, String> delegateLevelMap = DelegateService.getPIStudySitesAccessLevelMap();

        for(Study_Site__c site : getStudySitesCommon(CommunityService.USER_MODE_PI, filter, false)){
            if(!delegateLevelMap.containsKey(site.Id) || delegateLevels.contains(delegateLevelMap.get(site.Id))){
                ssList.add(site);
            }
        }
        return ssList;
    }
    //contains selected filter values
    public class SiteFilter{
        public String mode;
        public Id trialId;
//        public List<Id> trialIds;
        public String siteType;
        public String distanceRange;
        public String therapeuticArea;
        public String searchText;
        public List<String> searchFields;
        public String sortType = SortOrder.STUDY_SITE_SORT_TYPES[0].value;
        public String additionalFilter;

        public SiteFilter(SiteFilterData filterData){
            mode = filterData.mode;
            trialId = filterData.trialId;
//            trialIds = filterData.trialIds;
        }
    }

    //contains pick list values for SiteFilter
    public class SiteFilterData{
        public String mode;
        public Id trialId;
//        public List<Id> trialIds;
        public List<LabelValueItem> siteTypes;
        public List<LabelValueItem> distanceRanges;
        public List<LabelValueItem> therapeuticAreas;
        public List<LabelValueItem> sortVariants = SortOrder.STUDY_SITE_SORT_TYPES;

    }

    public static SiteFilterData getSiteFilterData(Id trialId, String mode){
        Id userContactId = CommunityService.getUserContact().Id;

        SiteFilterData siteFilterData = new SiteFilterData();
        siteFilterData.mode = mode;
        siteFilterData.trialId = trialId;
        siteFilterData.siteTypes = new List<LabelValueItem>();
        siteFilterData.siteTypes.add(new LabelValueItem(Label.PG_SFS_L_All_Site_Types, null));
        siteFilterData.siteTypes.add(new LabelValueItem(Label.PG_SFS_L_Virtual, 'Virtual'));
        siteFilterData.siteTypes.add(new LabelValueItem(Label.PG_SFS_L_Traditional, 'Traditional'));
        siteFilterData.siteTypes.add(new LabelValueItem(Label.PG_SFS_L_Hybrid, 'Hybrid'));
        siteFilterData.distanceRanges = new List<LabelValueItem>();
        siteFilterData.distanceRanges.add(new LabelValueItem(Label.PG_SFS_L_Any_distance, null));
        siteFilterData.therapeuticAreas = new List<LabelValueItem>();
        siteFilterData.therapeuticAreas.add(new LabelValueItem(Label.PG_SFS_L_All_Therapeutic_Areas, null));
        return siteFilterData;
    }
    public class StudySiteDistanceWrapper{
        public Study_Site__c site;
        public Decimal distance;
        public String siteType;

        public StudySiteDistanceWrapper(Study_Site__c site){
            this.site = site;
            this.distance = 0;
            if(!site.Is_Virtual_Study_Site__c){
                this.siteType = 'Traditional';
            }
            else if(site.Site__r.BillingAddress == null){
                this.siteType = 'Virtual';
            }
            else{
                this.siteType = 'Hybrid';
            }
        }

    }

    public static List<StudySiteDistanceWrapper> getStudySitesWithDistanceForHCPByTrialId( SiteFilter filter, PaginationData paginationData){
        String filterString = 'Clinical_Trial_Profile__c =\'' + filter.trialId + '\'' +
                '  AND Override_PI_Referral_Status__c != NULL ' +
                '  AND Override_PI_Referral_Status__c IN (\'' + String.join(STATUS_GROUP_ACCEPTED, '\',\'') + '\')';
        List<Study_Site__c> siteList = getStudySitesCommon(filterString);
        List<StudySiteDistanceWrapper> result = new List<StudySiteService.StudySiteDistanceWrapper>();
        for(Study_Site__c site : siteList){
            result.add(new StudySiteDistanceWrapper(site));
        }

        if(paginationData != null){
            paginationData.setRecordsCount(result.size());
            List<StudySiteDistanceWrapper> pageList = new List<StudySiteDistanceWrapper>();
            for(Integer i = paginationData.offset; i < paginationData.endOffset; i++){
                pageList.add(result[i]);
            }
            return pageList;
        }
        return result;
    }
}