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

    public final static String SS_TYPE_TRADITIONAL = 'Traditional';
    public final static String SS_TYPE_VIRTUAL = 'Virtual';
    public final static String SS_TYPE_HYBRID = 'Hybrid';

    public final static List<String> SS_TYPE_SHOW_DISTANCE = new List<String>{
        SS_TYPE_TRADITIONAL,
        SS_TYPE_HYBRID
    };

    public final static List<String> SS_TYPE_VT_INTEGRATION = new List<String>{
        SS_TYPE_VIRTUAL,
        SS_TYPE_HYBRID
    };

    public final static String SS_SORT_TYPE_DISTANCE = 'Distance';
    public final static String SS_SORT_TYPE_DISTANCE_VIRT_LAST = 'Distance-virtual-last';

    static {
        for (
            Schema.PicklistEntry ple : Study_Site__c.Override_PI_Referral_Status__c.getDescribe()
                .getPicklistValues()
        ) {
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
        // SS_CHANGE_STATUS_MAP.get(PI_S_INVITATION_SENT).put('decline', PI_S_DECLINED_ACCEPTANCE);
    }

    private static StudySiteService instance;

    public static StudySiteService getInstance() {
        if (instance == null)
            instance = new StudySiteService();
        return instance;
    }

    public static void setMock(StubProvider stubProvider) {
        instance = (StudySiteService) Test.createStub(StudySiteService.class, stubProvider);
    }
    public List<StudySiteDistanceWrapper> getStudySitesWithDistanceForHCPByTrialIdImpl(
        SiteFilter filter,
        PaginationData paginationData,
        Boolean filterEmptyHCPE
    ) {
        return getStudySitesWithDistanceForHCPByTrialIdImpl(
            filter,
            paginationData,
            filterEmptyHCPE,
            null
        );
    }
    public List<StudySiteDistanceWrapper> getStudySitesWithDistanceForHCPByTrialIdImpl(
        SiteFilter filter,
        PaginationData paginationData,
        Boolean filterEmptyHCPE,
        String delegateId
    ) {
        List<Study_Site__c> siteList = getStudySitesByFilter(filter);
        List<StudySiteDistanceWrapper> result = new List<StudySiteService.StudySiteDistanceWrapper>();
        Set<Id> quueriedTrials = new Set<Id>();
        Set<Id> siteIds = new Set<Id>();
        Set<Id> piContactIds =  new Set<Id>();
        // Set<Id> siteWithPatientsIds = new Set<Id>();
        for (Study_Site__c site : siteList) {
            quueriedTrials.add(site.Clinical_Trial_Profile__c);
            siteIds.add(site.Id);
            piContactIds.add(site.Principal_Investigator__c);
        }
        System.debug('queried Trials' + quueriedTrials);
        Map<Id, HCP_Enrollment__c> hcpeMap = new Map<Id, HCP_Enrollment__c>();
        List<HCP_Enrollment__c> enrollments = HCPEnrollmentService.getHCPEnrollmentsForHCPByTrials(
            new List<Id>(quueriedTrials),
            delegateId
        );
        List<Id> piContactIdsList = new List<Id>();
        Map<Id,String> piContactNames = ParticipantWorkflowService.getPIContactSalutationAndNames(piContactIds);
        for (HCP_Enrollment__c hcpe : enrollments) {
            hcpeMap.put(hcpe.Study_Site__c, hcpe);
        }
        //Commenting this because this is nowhere used and this snipet is throwing SOQL 50001 error
        /*
        for (Participant_Enrollment__c pe : [
            SELECT Id, Study_Site__c
            FROM Participant_Enrollment__c
            WHERE
                Study_Site__c IN :siteIds
                AND Participant_Status__c NOT IN (
                    :ParticipantEnrollmentService.PART_STATUS_FAILED_REVIEW,
                    :ParticipantEnrollmentService.PART_STATUS_PENDING_REFERRAL,
                    :ParticipantEnrollmentService.PART_STATUS_EXCLUDED_FROM_REFERRING
                )
        ]) {
            siteWithPatientsIds.add(pe.Study_Site__c);
        }
        */
        for (Study_Site__c site : siteList) {
            if (
                site.Clinical_Trial_Profile__r != null &&
                (!filterEmptyHCPE || hcpeMap.containsKey(site.Id))
            ) {
                StudySiteDistanceWrapper siteWrapper = new StudySiteDistanceWrapper(
                    site,
                    hcpeMap.get(site.Id),
                    filter.sortType,
                    delegateId,
                    piContactNames.isEmpty() ? null : piContactNames.get(site.Principal_Investigator__c)
                );
                result.add(siteWrapper);
            }
        }

        if (paginationData != null) {
            paginationData.setRecordsCount(result.size());
            List<StudySiteDistanceWrapper> pageList = new List<StudySiteDistanceWrapper>();
            for (Integer i = paginationData.offset; i < paginationData.endOffset; i++) {
                pageList.add(result[i]);
            }
            result = pageList;
        }
        result.sort();
        return result;
    }

    public SiteFilterData getSiteFilterDataImpl(Id trialId, String mode) {
        Id userContactId = CommunityService.getUserContact().Id;

        SiteFilterData siteFilterData = new SiteFilterData();
        siteFilterData.mode = mode;
        siteFilterData.trialId = trialId;
        siteFilterData.siteTypes = new List<LabelValueItem>();
        siteFilterData.siteTypes.add(new LabelValueItem(Label.PG_SFS_L_All_Site_Types, null));
        Schema.DescribeFieldResult siteTypesfield = Study_Site__c.Study_Site_Type__c.getDescribe();
        for (PicklistEntry ple : siteTypesfield.getPicklistValues()) {
            siteFilterData.siteTypes.add(new LabelValueItem(ple.label, ple.value));
        }
        siteFilterData.distanceRanges = new List<LabelValueItem>();
        siteFilterData.distanceRanges.add(new LabelValueItem(Label.PG_SFS_L_Any_distance, null));
        siteFilterData.therapeuticAreas = new List<LabelValueItem>();
        siteFilterData.therapeuticAreas.add(
            new LabelValueItem(Label.PG_SFS_L_All_Therapeutic_Areas, null)
        );
        return siteFilterData;
    }

    public static String changeStatus(Id studySiteId, String userMod, String newStatusType) {
        Study_Site__c studySite = [
            SELECT Id, Override_PI_Referral_Status__c
            FROM Study_Site__c
            WHERE Id = :studySiteId
        ];

        if (studySite == null)
            throw new AuraHandledException('Incorrect Study site studySiteId=' + studySiteId);
        String oldStatus = studySite.Override_PI_Referral_Status__c;
        String newStatus = SS_CHANGE_STATUS_MAP.get(oldStatus).get(newStatusType);

        if (newStatus == null) {
            throw new AuraHandledException(
                'Invalid action! Can`t change this status to status = ' + newStatusType
            );
        }
        studySite.Override_PI_Referral_Status__c = newStatus;
        update studySite;
        return newStatus;
    }

    public static void changeStatus(Set<Id> studySiteId, String userMod, String newStatusType) {
        List<Study_Site__c> studySite = [
            SELECT Id, Override_PI_Referral_Status__c
            FROM Study_Site__c
            WHERE Id IN :studySiteId
        ];
        if (!studySite.isEmpty()) {
            for (Integer i = 0; i < studySite.size(); i++) {
                String oldStatus = studySite[i].Override_PI_Referral_Status__c;
                String newStatus = SS_CHANGE_STATUS_MAP.get(oldStatus).get(newStatusType);
                if (newStatus == null) {
                    throw new AuraHandledException(
                        'Invalid action! Can`t change this status to status = ' + newStatusType
                    );
                }
                studySite[i].Override_PI_Referral_Status__c = newStatus;
            }
            update studySite;
        }
    }

    public static List<Study_Site__c> getStudySitesForPIBySponsor(String communityTemplate) {
        return getStudySitesCommon(
            CommunityService.USER_MODE_PI,
            'AND Clinical_Trial_Profile__r.CommunityTemplate__c = \'' +
            communityTemplate +
            '\'',
            false
        );
    }

    public static List<Study_Site__c> getStudySitesForPI() {
        return getStudySitesCommon(CommunityService.USER_MODE_PI, null, false);
    }

    public static List<Study_Site__c> getStudySitesForPI(Boolean excludeDelegates) {
        return getStudySitesCommon(CommunityService.USER_MODE_PI, null, excludeDelegates);
    }

    public static final List<String> SS_COMMON_FIELDS = new List<String>{
        'Id',
        'Approved_Lng__c',
        'Name',
        'Site__c',
        'Override_PI_Referral_Status__c',
        'Is_Virtual_Study_Site__c',
        'Study_Site_Type__c',
        'Study_Site_Phone__c',
        'Study_Site_Email__c',
        'Account_Was_Changed__c',
        'Site__r.Name',
        'Site__r.BillingAddress',
        'Site__r.BillingCountry',
        'Site__r.BillingCountryCode',
        'Site__r.BillingState',
        'Site__r.BillingStateCode',
        'Site__r.BillingPostalCode',
        'Site__r.BillingCity',
        'Site__r.BillingStreet',
        'Site__r.BillingLatitude',
        'Site__r.BillingLongitude',
        'Site__r.BillingGeocodeAccuracy',
        'Site__r.Driving_Directions__c',
        'Site__r.Parking_Instructions__c',
        'Site__r.ParentId',
        'Clinical_Trial_Profile__c',
        'Clinical_Trial_Profile__r.Id',
        'Clinical_Trial_Profile__r.Study_Title__c',
        'Clinical_Trial_Profile__r.Protocol_ID__c',
        'Clinical_Trial_Profile__r.Study_Code_Name__c',
        'Clinical_Trial_Profile__r.Official_Title__c',
        'Clinical_Trial_Profile__r.Study_Sponsor__c',
        'Clinical_Trial_Profile__r.Override_Recruitment_Status__c',
        'Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c',
        'Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c',
        'Clinical_Trial_Profile__r.Link_to_Pre_screening__c',
        'Clinical_Trial_Profile__r.Orientation_Required__c',
        'Clinical_Trial_Profile__r.Patient_Portal_Enabled__c',
        'Clinical_Trial_Profile__r.CommunityTemplate__c',
        'Suppress_Participant_Emails__c',
        'Clinical_Trial_Profile__r.Suppress_Participant_Emails__c',
        'Principal_Investigator__c',    
        'Principal_Investigator__r.Name',
        'Principal_Investigator__r.FirstName',
        'Principal_Investigator__r.LastName',
        'Principal_Investigator__r.Suffix',
        'Principal_Investigator__r.Title',
        'Principal_Investigator__r.MailingStreet',
        'Principal_Investigator__r.MailingCity',
        'Principal_Investigator__r.MailingState',
        'Principal_Investigator__r.MailingPostalCode',
        'Principal_Investigator__r.MailingAddress',
        'Principal_Investigator__r.Phone',
        'Principal_Investigator__r.Email',
        'Principal_Investigator__r.Salutation',
        'Principal_Investigator__r.Account.BillingStreet',
        'Principal_Investigator__r.Account.BillingCity',
        'Principal_Investigator__r.Account.BillingState',
        'Principal_Investigator__r.Account.BillingStateCode',
        'Principal_Investigator__r.Account.BillingPostalCode',
        'Principal_Investigator__r.Account.BillingCountry',
        'Principal_Investigator__r.Account.BillingCountryCode',
        'Principal_Investigator__r.Account.BillingLatitude',
        'Principal_Investigator__r.Account.BillingLongitude',
        'Principal_Investigator__r.Account.BillingGeocodeAccuracy',
        'Principal_Investigator__r.Account.BillingAddress',
        'Principal_Investigator__r.Full_Name__c',
        'Site_Staff__r.Site_Contact__c',
        'Participant_DOB_format__c'
    };

    public static List<Study_Site__c> getStudySitesCommon(String filter) {
        String query = 'SELECT ' + String.join(SS_COMMON_FIELDS, ',') + ' FROM Study_Site__c ';
        if (filter != null)
            query += ' WHERE ' + filter;
        System.debug('EXECUTE QUERY: ' + query);
        List<Study_Site__c> ssList = Database.query(query);
        TranslateHelper.translate(ssList);
        return ssList;
    }

    public static List<Study_Site__c> getStudySitesCommon(String filter, List<String> SS_FIELDS) {
        String query = 'SELECT ' + String.join(SS_FIELDS, ',') + ' FROM Study_Site__c ';
        if (filter != null)
            query += ' WHERE ' + filter;
        System.debug('EXECUTE QUERY: ' + query);
        List<Study_Site__c> ssList = Database.query(query);
        TranslateHelper.translate(ssList);
        return ssList;
    }    
    
    public static List<Study_Site__c> getStudySitesCommon(
        String userMode,
        String filter,
        Boolean excludeDelegates,
        List<String> SS_FIELDS
    ) {
        String userModeFilter = getUserModeFilter(userMode, excludeDelegates);
        if (filter != null)
            userModeFilter += ' ' + filter;
        return getStudySitesCommon(userModeFilter, SS_FIELDS);
    }

    public static List<Study_Site__c> getStudySitesCommon(
        String userMode,
        String filter,
        Boolean excludeDelegates,
        String delegateId
    ) {
        String userModeFilter = getUserModeFilter(userMode, excludeDelegates, delegateId);
        if (filter != null)
            userModeFilter += ' ' + filter;
        return getStudySitesCommon(userModeFilter);
    }    
    
    public static List<Study_Site__c> getStudySitesCommon(
        String userMode,
        String filter,
        Boolean excludeDelegates
    ) {
        String userModeFilter = getUserModeFilter(userMode, excludeDelegates);
        if (filter != null)
            userModeFilter += ' ' + filter;
        return getStudySitesCommon(userModeFilter);
    }

    public static String getUserModeFilter(String userMode, Boolean excludeDelegates) {
        return getUserModeFilter(userMode, excludeDelegates, null);
    }
    public static String getUserModeFilter(
        String userMode,
        Boolean excludeDelegates,
        String delegateId
    ) {
        String filter =
            ' Clinical_Trial_Profile__c != NULL ' + ' AND Override_PI_Referral_Status__c != NULL ';
        if (userMode == CommunityService.USER_MODE_PI) {
            if (
                delegateId == null ||
                delegateId == '' ||
                delegateId == CommunityService.getUserContact().Id
            ) {
                if (excludeDelegates) {
                    filter +=
                        ' AND  Principal_Investigator__c = \'' +
                        CommunityService.getUserContact().Id +
                        '\' ';
                } else {
                    filter +=
                        ' AND ( ' +
                        '       Principal_Investigator__c = \'' +
                        CommunityService.getUserContact().Id +
                        '\' ' +
                        '       OR Id IN (\'' +
                        String.join(DelegateService.getDelegatedStudySiteIds(), '\',\'') +
                        '\')' +
                        '   ) ';
                }
            } else {
                filter +=
                    ' AND ( ' +
                    '       Principal_Investigator__c = \'' +
                    delegateId +
                    '\' ' +
                    '       AND Id IN (\'' +
                    String.join(DelegateService.getDelegatedStudySiteIds(), '\',\'') +
                    '\')' +
                    '   ) ';
            }
        }
        return filter;
    }

    public static Study_Site__c getStudySiteForHCPById(Id ssId) {
        List<Study_Site__c> studySites = getStudySitesCommon(
            CommunityService.USER_MODE_HCP,
            ' AND Id = \'' +
            ssId +
            '\' ',
            false
        );
        if (studySites.size() == 0)
            throw new CommunityServiceException('Data not found');
        return studySites[0];
    }

    public static Study_Site__c getStudySiteForPIById(Id ssId) {
        List<Study_Site__c> studySites = getStudySitesCommon(
            CommunityService.USER_MODE_PI,
            ' AND Id = \'' +
            ssId +
            '\' ',
            false
        );
        if (studySites.size() == 0)
            throw new CommunityServiceException('Data not found');
        return studySites[0];
    }

    public static List<Study_Site__c> getStudySiteForPIByTrialId(Id trialId) {
        return getStudySitesCommon(
            CommunityService.USER_MODE_PI,
            ' AND Clinical_Trial_Profile__c = \'' +
            trialId +
            '\' ' +
            ' AND Override_PI_Referral_Status__c != NULL',
            false
        );
    }

    public static List<Study_Site__c> getStudySiteForPIByTrialId(Id trialId, List<String> SS_COMMON_CUSTOM_FIELDS) {
        return getStudySitesCommon(
            CommunityService.USER_MODE_PI,
            ' AND Clinical_Trial_Profile__c = \'' +
            trialId +
            '\' ' +
            ' AND Override_PI_Referral_Status__c != NULL',
            false,
            SS_COMMON_CUSTOM_FIELDS
        );
    }    
    
    public static List<Study_Site__c> getStudySitesForHCP(List<Id> trialIds) {
        return getStudySitesForHCP(trialIds, null);
    }

    public static List<Study_Site__c> getStudySitesForHCP(List<Id> trialIds, String delegateId) {
        List<HCP_Enrollment__c> hcpEnrollments = HCPEnrollmentService.getHCPEnrollmentsCommon(
            CommunityService.USER_MODE_HCP,
            delegateId,
            ' AND Study_Site__r.Clinical_Trial_Profile__c IN (\'' +
            String.join(trialIds, '\',\'') +
            '\')',
            false
        );
        List<Study_Site__c> resList = new List<Study_Site__c>();
        for (HCP_Enrollment__c he : hcpEnrollments)
            resList.add(he.Study_Site__r);
        return resList;
    }

    public static List<Study_Site__c> getStudySitesForHCPByTrialId(Id trialId) {
        String query =
            'SELECT ' +
            String.join(SS_COMMON_FIELDS, ',') +
            ' FROM Study_Site__c WHERE Clinical_Trial_Profile__c =\'' +
            trialId +
            '\'' +
            '  AND Override_PI_Referral_Status__c != NULL ' +
            '  AND Override_PI_Referral_Status__c IN (\'' +
            String.join(STATUS_GROUP_ACCEPTED, '\',\'') +
            '\')';
        return Database.query(query);
    }
    public static List<Study_Site__c> getStudySitesWithDelegateLevelFiltered(
        String filter,
        Set<String> delegateLevels,
        String parentId
    ) {
        List<Study_Site__c> ssList = new List<Study_Site__c>();
        Map<Id, String> delegateLevelMap = DelegateService.getPIStudySitesAccessLevelMap();
        for (
            Study_Site__c site : getStudySitesCommon(
                CommunityService.USER_MODE_PI,
                filter,
                false,
                parentId
            )
        ) {
            if (
                !delegateLevelMap.containsKey(site.Id) ||
                delegateLevels.contains(delegateLevelMap.get(site.Id))
            ) {
                ssList.add(site);
            }
        }
        return ssList;
    }
    public static List<Study_Site__c> getStudySitesWithDelegateLevelFiltered(
        String filter,
        Set<String> delegateLevels
    ) {
        return getStudySitesWithDelegateLevelFiltered(filter, delegateLevels, null);
    }
    //contains selected filter values
    public class SiteFilter {
        public String mode;
        public Id trialId;
        public List<Id> trialIds;
        public String siteType;
        public String distanceRange;
        public String therapeuticArea;
        public String searchText;
        public List<String> searchFields;
        public String sortType = SortOrder.STUDY_SITE_SORT_TYPES[0].value;
        public String additionalFilter;
        public Boolean onlyAcceptedSites = true;

        public SiteFilter(SiteFilterData filterData) {
            mode = filterData.mode;
            trialId = filterData.trialId;
            trialIds = filterData.trialIds;
        }
    }

    //contains pick list values for SiteFilter
    public class SiteFilterData {
        public String mode;
        public Id trialId;
        public List<Id> trialIds;
        public List<LabelValueItem> siteTypes;
        public List<LabelValueItem> distanceRanges;
        public List<LabelValueItem> therapeuticAreas;
        public List<LabelValueItem> sortVariants = SortOrder.STUDY_SITE_SORT_TYPES;
    }

    public static SiteFilterData getSiteFilterData(Id trialId, String mode) {
        Id userContactId = CommunityService.getUserContact().Id;

        SiteFilterData siteFilterData = new SiteFilterData();
        siteFilterData.mode = mode;
        siteFilterData.trialId = trialId;
        siteFilterData.siteTypes = new List<LabelValueItem>();
        siteFilterData.siteTypes.add(new LabelValueItem(Label.PG_SFS_L_All_Site_Types, null));
        Schema.DescribeFieldResult siteTypesfield = Study_Site__c.Study_Site_Type__c.getDescribe();
        for (PicklistEntry ple : siteTypesfield.getPicklistValues()) {
            siteFilterData.siteTypes.add(new LabelValueItem(ple.label, ple.value));
        }
        siteFilterData.distanceRanges = new List<LabelValueItem>();
        siteFilterData.distanceRanges.add(new LabelValueItem(Label.PG_SFS_L_Any_distance, null));
        siteFilterData.distanceRanges.add(
            new LabelValueItem('5   ' + DistanceHelper.getUnitsOfMeasurementLabel(), '5')
        );
        siteFilterData.distanceRanges.add(
            new LabelValueItem('15  ' + DistanceHelper.getUnitsOfMeasurementLabel(), '15')
        );
        siteFilterData.distanceRanges.add(
            new LabelValueItem('30  ' + DistanceHelper.getUnitsOfMeasurementLabel(), '30')
        );
        siteFilterData.distanceRanges.add(
            new LabelValueItem('60  ' + DistanceHelper.getUnitsOfMeasurementLabel(), '60')
        );
        siteFilterData.distanceRanges.add(
            new LabelValueItem('150 ' + DistanceHelper.getUnitsOfMeasurementLabel(), '150')
        );
        siteFilterData.distanceRanges.add(
            new LabelValueItem('300 ' + DistanceHelper.getUnitsOfMeasurementLabel(), '300')
        );
        siteFilterData.therapeuticAreas = new List<LabelValueItem>();
        siteFilterData.therapeuticAreas.add(
            new LabelValueItem(Label.PG_SFS_L_All_Therapeutic_Areas, null)
        );
        return siteFilterData;
    }
    public class StudySiteDistanceWrapper implements Comparable {
        public Study_Site__c site;
        public Double distance;
        public String formatedDistance;
        public String siteType;
        public String siteTypeLabel;
        public String siteStatusLabel;
        public HCP_Enrollment__c hcpe;
        public Map<String, StudyActions.Action> actions;
        public String sortType;
        public Boolean hasActiveHCPE;
        public Boolean hasPatients;
        public Datetime hcpCreatedDate;
        public String piName;

        public StudySiteDistanceWrapper() {
        }

        public StudySiteDistanceWrapper(
            Study_Site__c site,
            HCP_Enrollment__c hcpe,
            String sortType
        ) {
            this(site, hcpe, sortType, null);
        }

        public StudySiteDistanceWrapper(
            Study_Site__c site,
            HCP_Enrollment__c hcpe,
            String sortType,
            String delegateId
        ) {
            this(site, hcpe, sortType, delegateId, null);
        }
        
        public StudySiteDistanceWrapper(
            Study_Site__c site,
            HCP_Enrollment__c hcpe,
            String sortType,
            String delegateId,
            String piName
        ) {
            this.site = site;
            this.siteType = site.Study_Site_Type__c;
            this.siteTypeLabel = TranslateHelper.getPickListLabel(
                Study_Site__c.Study_Site_Type__c,
                site.Study_Site_Type__c
            );
            if (hcpe != null) {
                this.siteStatusLabel = TranslateHelper.getPickListLabel(
                    HCP_Enrollment__c.Status__c,
                    hcpe.Status__c
                );
            }

            if (SS_TYPE_SHOW_DISTANCE.contains(this.siteType)) {
                this.distance = DistanceHelper.calculateDistanceTo(site.Site__r);
                if (this.distance != null) {
                    this.formatedDistance =
                        DistanceHelper.roundDouble(this.distance) +
                        '&nbsp;' +
                        DistanceHelper.getUnitsOfMeasurementLabel();
                } else {
                    this.formatedDistance = null;
                }
            }

            if (sortType != null && sortType != '') {
                this.sortType = sortType;
            } else {
                this.sortType = SS_SORT_TYPE_DISTANCE;
            }

            this.hcpe = hcpe;
            if (hcpe != null) {
                this.actions = new StudyActionsHCP(hcpe, delegateId).actions;
                this.hcpCreatedDate = hcpe.CreatedDate;
            } else {
                this.actions = new StudyActionsHCP(
                        this.site.Clinical_Trial_Profile__r,
                        this.site,
                        null,
                        delegateId
                    )
                    .actions;
            }
            this.hasActiveHCPE =
                hcpe != null &&
                hcpe.Status__c != HCPEnrollmentService.HCP_S_INVITATION_SENT;
            this.piName = piName;
        }
        public Integer compareTo(Object compareTo) {
            StudySiteDistanceWrapper compareToWrapper = (StudySiteDistanceWrapper) compareTo;
            if (sortType == SS_SORT_TYPE_DISTANCE) {
                if (
                    !SS_TYPE_SHOW_DISTANCE.contains(this.siteType) &&
                    !SS_TYPE_SHOW_DISTANCE.contains(compareToWrapper.siteType)
                ) {
                    return 0;
                } else if (!SS_TYPE_SHOW_DISTANCE.contains(this.siteType)) {
                    return -1;
                } else if (!SS_TYPE_SHOW_DISTANCE.contains(compareToWrapper.siteType)) {
                    return 1;
                } else if (this.distance == null) {
                    return 1;
                } else if (compareToWrapper.distance == null) {
                    return -1;
                } else {
                    return (Integer) (this.distance - compareToWrapper.distance);
                }
            } else if (sortType == SS_SORT_TYPE_DISTANCE_VIRT_LAST) {
                if (
                    !SS_TYPE_SHOW_DISTANCE.contains(this.siteType) &&
                    !SS_TYPE_SHOW_DISTANCE.contains(compareToWrapper.siteType)
                ) {
                    return 0;
                } else if (!SS_TYPE_SHOW_DISTANCE.contains(this.siteType)) {
                    return 1;
                } else if (!SS_TYPE_SHOW_DISTANCE.contains(compareToWrapper.siteType)) {
                    return -1;
                } else if (this.distance == null) {
                    return 1;
                } else if (compareToWrapper.distance == null) {
                    return -1;
                } else {
                    return (Integer) (this.distance - compareToWrapper.distance);
                }
            } else {
                return 0;
            }
        }
    }
    public static List<StudySiteDistanceWrapper> getStudySitesWithDistanceForHCPByTrialId(
        SiteFilter filter,
        PaginationData paginationData,
        Boolean filterEmptyHCPE
    ) {
        return getStudySitesWithDistanceForHCPByTrialId(
            filter,
            paginationData,
            filterEmptyHCPE,
            null
        );
    }
    public static List<StudySiteDistanceWrapper> getStudySitesWithDistanceForHCPByTrialId(
        SiteFilter filter,
        PaginationData paginationData,
        Boolean filterEmptyHCPE,
        String delegateId
    ) {
        List<Study_Site__c> siteList = getStudySitesByFilter(filter, delegateId);
        List<StudySiteDistanceWrapper> result = new List<StudySiteService.StudySiteDistanceWrapper>();
        Set<Id> quueriedTrials = new Set<Id>();
        Set<Id> siteIds = new Set<Id>();
        Set<Id> piContactIds =  new Set<Id>();        
        for (Study_Site__c site : siteList) {
            quueriedTrials.add(site.Clinical_Trial_Profile__c);
            siteIds.add(site.Id);
            piContactIds.add(site.Principal_Investigator__c);
        }
        System.debug('queried Trials' + quueriedTrials);
        Map<Id, HCP_Enrollment__c> hcpeMap = new Map<Id, HCP_Enrollment__c>();
        List<HCP_Enrollment__c> enrollments = HCPEnrollmentService.getHCPEnrollmentsForHCPByTrials(
            new List<Id>(quueriedTrials),
            delegateId
        );
        for (HCP_Enrollment__c hcpe : enrollments) {
            hcpeMap.put(hcpe.Study_Site__c, hcpe);
        }
        List<Id> piContactIdsList = new List<Id>();
        Map<Id,String> piContactNames = ParticipantWorkflowService.getPIContactSalutationAndNames(piContactIds);
        for (Study_Site__c site : siteList) {
            if (
                site.Clinical_Trial_Profile__r != null &&
                (!filterEmptyHCPE || hcpeMap.containsKey(site.Id))
            ) {
                StudySiteDistanceWrapper siteWrapper = new StudySiteDistanceWrapper(
                    site,
                    hcpeMap.get(site.Id),
                    filter.sortType,
                    delegateId,
                    piContactNames.isEmpty() ? null : piContactNames.get(site.Principal_Investigator__c)
                );
                result.add(siteWrapper);
            }
        }
        if (filter.distanceRange != null && filter.distanceRange != '') {
            List<StudySiteDistanceWrapper> pageList = new List<StudySiteDistanceWrapper>();
            for (StudySiteDistanceWrapper siteWrapper : result) {
                Double maxDistance = Double.valueOf(filter.distanceRange);
                if (
                    siteWrapper.siteType == 'Virtual' ||
                    (siteWrapper.distance != null &&
                    siteWrapper.distance <= maxDistance)
                ) {
                    pageList.add(siteWrapper);
                }
            }
            result = pageList;
        }

        if (paginationData != null) {
            paginationData.setRecordsCount(result.size());
            List<StudySiteDistanceWrapper> pageList = new List<StudySiteDistanceWrapper>();
            for (Integer i = paginationData.offset; i < paginationData.endOffset; i++) {
                pageList.add(result[i]);
            }
            result = pageList;
        }
        result.sort();
        return result;
    }

    public static List<Study_Site__c> getStudySitesByFilter(SiteFilter filter) {
        return getStudySitesByFilter(filter, null);
    }

    public static List<Study_Site__c> getStudySitesByFilter(SiteFilter filter, String delegateId) {
        Contact userContact = CommunityService.getUserContact();
        String userCountry;
        if (userContact.MailingCountry != null && userContact.MailingCountry != '') {
            userCountry = userContact.MailingCountry;
        } else {
            userCountry = 'United States';
        }
        String filterString = '';
        if (filter.trialId != null && (filter.trialIds == null || filter.trialIds.isEmpty())) {
            filterString = 'Clinical_Trial_Profile__c =\'' + filter.trialId + '\' ';
        } else if (filter.trialIds != null && !filter.trialIds.isEmpty()) {
            filterString =
                'Clinical_Trial_Profile__c IN (\'' +
                String.join(filter.trialIds, '\',\'') +
                '\') ';
        } else {
            List<Id> studyIds = TrialService.getAvailableTrialIds(
                CommunityService.USER_MODE_HCP,
                delegateId
            );
            System.debug('studyIds SSN' + studyIds);
            filterString =
                'Clinical_Trial_Profile__c IN (\'' +
                String.join(studyIds, '\',\'') +
                '\') ';
        }
        if (filter.onlyAcceptedSites) {
            filterString +=
                ' AND Override_PI_Referral_Status__c != NULL ' +
                '  AND Override_PI_Referral_Status__c IN (\'' +
                String.join(STATUS_GROUP_ACCEPTED, '\',\'') +
                '\')';
        }

        if (filter.siteType != null && filter.siteType != '') {
            filterString += ' AND Study_Site_Type__c = \'' + filter.siteType + '\' ';
        }
        /*filterString += 'AND Principal_Investigator__r.Account.BillingCountry = \'' + userCountry+'\' ';*/
        filterString += 'AND Site__r.BillingCountry = \'' + userCountry + '\' ';
        filterString +=
            'AND Clinical_Trial_Profile__r.CommunityTemplate__c != \'' +
            CommunityTemplateService.TEMPLATE_JANSSEN +
            '\' ';

        System.debug('filterString SSDW ' + filterString);
        return getStudySitesCommon(filterString);
    }

    public static Map<Id, List<StudySiteVisitPlan__c>> getStudySiteVisitPlansMap(List<Id> ssIds) {
        List<StudySiteVisitPlan__c> studySiteVisitPlans = [
            SELECT Id, Visit_Plan__r.Name, Study_Site__c
            FROM StudySiteVisitPlan__c
            WHERE Study_Site__c IN :ssIds
        ];

        Map<Id, List<StudySiteVisitPlan__c>> ssVisitPlansBySSId = new Map<Id, List<StudySiteVisitPlan__c>>();
        for (StudySiteVisitPlan__c ssVP : studySiteVisitPlans) {
            if (!ssVisitPlansBySSId.containsKey(ssVP.Study_Site__c)) {
                ssVisitPlansBySSId.put(ssVP.Study_Site__c, new List<StudySiteVisitPlan__c>());
            }
            ssVisitPlansBySSId.get(ssVP.Study_Site__c).add(ssVP);
        }

        return ssVisitPlansBySSId;
    }

    public static List<LabelValueItem> getVisitPlansLVList(Id ssId) {
        Map<Id, List<StudySiteVisitPlan__c>> ssVisitPlanMap = getStudySiteVisitPlansMap(
            new List<Id>{ ssId }
        );
        List<StudySiteVisitPlan__c> ssVisitPlans = ssVisitPlanMap.get(ssId);
        List<LabelValueItem> resList = new List<LabelValueItem>();
        if (ssVisitPlans != null) {
            for (StudySiteVisitPlan__c ssVisitPlan : ssVisitPlans) {
                resList.add(
                    new LabelValueItem(ssVisitPlan.Visit_Plan__r.Name, ssVisitPlan.Visit_Plan__c)
                );
            }
        }
        return resList;
    }

    public static List<Study_Site__c> filterStudySitesWithPE(
        List<Study_Site__c> studySites,
        String activePE,
        String mode,
        String delegateId,
        String additionalFilters
    ) {
        Set<Id> ssIds = new Set<Id>();
        //for (Participant_Enrollment__c pe : ParticipantEnrollmentService.getParticipantEnrollmentsActiveFilter(activePE, mode, delegateId, additionalFilters)){
        for (
            Participant_Enrollment__c pe : ParticipantEnrollmentService.getParticipantEnrollmentsActiveFilterOptimized(
                activePE,
                mode,
                delegateId,
                additionalFilters,
                ParticipantEnrollmentService.ACTIVE_PE_FIELDS_FOR_CTP_SS
            )
        ) {
            ssIds.add(pe.Study_Site__c);
        }
        return (List<Study_Site__c>) SObjectHelper.filterSObjectsByIds(studySites, ssIds);
    }
}