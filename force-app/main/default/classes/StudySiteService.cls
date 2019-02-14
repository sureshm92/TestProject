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
            'Clinical_Trial_Profile__r.Orientation_Required__c '
    };

    public static List<Study_Site__c> getStudySitesCommon(String userMode, String filter, Boolean excludeDelegates){
        String query = 'SELECT ' + String.join(SS_COMMON_FIELDS, ',') +
                ' FROM Study_Site__c ' +
                ' WHERE ' + getUserModeFilter(userMode, excludeDelegates);
        if(filter != null) query += ' ' + filter;
        System.debug('EXECUTE QUERY: ' + query);
        List<Study_Site__c> ssList = Database.query(query);
        TranslateHelper.translate(ssList);
        return ssList;
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
}