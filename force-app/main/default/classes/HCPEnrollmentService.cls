/**
 * Created by D.Yasinskyi on 01.03.2018
 */
public without sharing class HCPEnrollmentService {

    public final static String HCP_S_INVITATION_SENT = 'Invitation Sent';
    public final static String HCP_S_ON_HOLD_ACCEPTANCE = 'On Hold (Acceptance)';
    public final static String HCP_S_DECLINED_ACCEPTANCE = 'Declined (Acceptance)';
    public final static String HCP_S_NON_RESPONCIVE_A = 'Non-Responsive (Admin)';
    public final static String HCP_S_APPROVAL_PENDING = 'Approval Pending';
    public final static String HCP_S_ACTIVATION_PENDING = 'Activation Pending';
    public final static String HCP_S_ACTIVATION_PENDING_O = 'Activation Pending Orientation';
    public final static String HCP_S_DECLINED_APPROVAL = 'Declined (Approval)';
    public final static String HCP_S_ON_HOLD_APPROVAL = 'On Hold (Approval)';
    public final static String HCP_S_DECLINE_ACTIVATION = 'Declined (Activation)';
    public final static String HCP_S_ON_HOLD_ACTIVATION = 'On Hold (Activation)';
    public final static String HCP_S_ACTIVATED = 'Activated';
    public final static String HCP_S_ACTIVATED_A = 'Activated (Admin)';
    public final static String HCP_S_ON_HOLD_A = 'On Hold (Admin)';
    public final static String HCP_S_DECLINED_A = 'Declined (Admin)';
    public final static String HCP_S_DEACTIVATED_A = 'Deactivated (Admin)';

    public static final List<String> STATUS_GROUP_PENDING = new List<String>{
            HCP_S_APPROVAL_PENDING,
            HCP_S_ACTIVATION_PENDING,
            HCP_S_ACTIVATION_PENDING_O
    };
    public static final List<String> STATUS_GROUP_ON_HOLD = new List<String>{
            HCP_S_ON_HOLD_ACCEPTANCE,
            HCP_S_ON_HOLD_APPROVAL,
            HCP_S_ON_HOLD_ACTIVATION,
            HCP_S_ON_HOLD_A
    };
    public static final List<String> STATUS_GROUP_DECLINED = new List<String>{
            HCP_S_DECLINED_ACCEPTANCE,
            HCP_S_DECLINED_APPROVAL,
            HCP_S_DECLINED_A,
            HCP_S_DECLINE_ACTIVATION
    };
    public static final List<String> STATUS_GROUP_ACTIVATED = new List<String>{
            HCP_S_ACTIVATED,
            HCP_S_ACTIVATED_A
    };
    public static final List<String> STATUS_GROUP_DEACTIVATED = new List<String>{
            HCP_S_DEACTIVATED_A
    };

    //HCP_Enrollment__c.Status__c invisible for [PI] on my Study Site page
    public final static List<String> HCP_E_S_INVISIBLE_ON_STUDY_SITE_P = new List<String>{
            HCP_S_INVITATION_SENT,
            HCP_S_ON_HOLD_ACCEPTANCE,
            HCP_S_DECLINED_ACCEPTANCE,
            HCP_S_NON_RESPONCIVE_A
    };

    public final static Map<String, Map<String, String>> HCP_CHANGE_STATUS_MAP = new Map<String, Map<String, String>>{
            //for HCP:
            HCP_S_INVITATION_SENT => new Map<String, String>{
                    StudyActions.ACT_HCP_DECLINE => HCP_S_DECLINED_ACCEPTANCE,
                    StudyActions.ACT_HCP_ON_HOLD => HCP_S_ON_HOLD_ACCEPTANCE
            },
            //Approval Flow [PI] - Orientation Required
            HCP_S_APPROVAL_PENDING => new Map<String, String>{
                    StudyActions.ACT_HCP_APPROVE => HCP_S_ACTIVATION_PENDING_O,
                    StudyActions.ACT_HCP_ON_HOLD => HCP_S_ON_HOLD_APPROVAL,
                    StudyActions.ACT_HCP_DECLINE => HCP_S_DECLINED_APPROVAL
            },
            HCP_S_DECLINED_APPROVAL => new Map<String, String>{
                    StudyActions.ACT_HCP_APPROVE => HCP_S_ACTIVATION_PENDING_O,
                    StudyActions.ACT_HCP_ON_HOLD => HCP_S_ON_HOLD_APPROVAL
            },
            HCP_S_ON_HOLD_APPROVAL => new Map<String, String>{
                    StudyActions.ACT_HCP_APPROVE => HCP_S_ACTIVATION_PENDING_O,
                    StudyActions.ACT_HCP_DECLINE => HCP_S_DECLINED_APPROVAL
            },
            HCP_S_ACTIVATION_PENDING_O => new Map<String, String>{
                    StudyActions.ACT_HCP_ORIENTATION_ATTENDED_AND_ACTIVATE => HCP_S_ACTIVATED,
                    StudyActions.ACT_HCP_ON_HOLD => HCP_S_ON_HOLD_APPROVAL,
                    StudyActions.ACT_HCP_DECLINE => HCP_S_DECLINED_APPROVAL
            },
            //Approval Flow [PI] - Orientation NOT Required
            HCP_S_ACTIVATION_PENDING => new Map<String, String>{
                    StudyActions.ACT_HCP_ACTIVATE => HCP_S_ACTIVATED,
                    StudyActions.ACT_HCP_ON_HOLD => HCP_S_ON_HOLD_ACTIVATION,
                    StudyActions.ACT_HCP_DECLINE => HCP_S_DECLINE_ACTIVATION
            },
            HCP_S_ACTIVATED_A => new Map<String, String>{
                    StudyActions.ACT_HCP_ON_HOLD => HCP_S_ON_HOLD_ACTIVATION,
                    StudyActions.ACT_HCP_DECLINE => HCP_S_DECLINE_ACTIVATION
            },
            HCP_S_ACTIVATED => new Map<String, String>{
                    StudyActions.ACT_HCP_ON_HOLD => HCP_S_ON_HOLD_ACTIVATION,
                    StudyActions.ACT_HCP_DECLINE => HCP_S_DECLINE_ACTIVATION
            },
            HCP_S_ON_HOLD_ACTIVATION => new Map<String, String>{
                    StudyActions.ACT_HCP_ACTIVATE => HCP_S_ACTIVATED,
                    StudyActions.ACT_HCP_DECLINE => HCP_S_DECLINE_ACTIVATION
            },
            HCP_S_DECLINE_ACTIVATION => new Map<String, String>{
                    StudyActions.ACT_HCP_ACTIVATE => HCP_S_ACTIVATED,
                    StudyActions.ACT_HCP_ON_HOLD => HCP_S_ON_HOLD_ACTIVATION
            },
            //Admin statuses:
            HCP_S_ON_HOLD_A => new Map<String, String>{
                    StudyActions.ACT_HCP_DECLINE => HCP_S_DECLINED_A,
                    StudyActions.ACT_HCP_DEACTIVATE => HCP_S_DEACTIVATED_A
            },
            HCP_S_DEACTIVATED_A => new Map<String, String>{
                    StudyActions.ACT_HCP_ON_HOLD => HCP_S_ON_HOLD_A,
                    StudyActions.ACT_HCP_DECLINE => HCP_S_DECLINED_A
            },
            HCP_S_DECLINED_A => new Map<String, String>{
                    StudyActions.ACT_HCP_ON_HOLD => HCP_S_ON_HOLD_A,
                    StudyActions.ACT_HCP_DEACTIVATE => HCP_S_DEACTIVATED_A
            }
    };

    public static String changeStatus(Id HCPEnrollmentId, String userMode, String newStatusType){
        return  changeStatus(HCPEnrollmentId, userMode, newStatusType, '');
    }

    public static String changeStatus(Id hcpeId, String userMode, String actionId, String value) {
        HCP_Enrollment__c hcpe = getHCPEnrollmentById(hcpeId, userMode);
        String newStatus = HCP_CHANGE_STATUS_MAP.get(hcpe.Status__c).get(actionId);
        if(newStatus == null) throw new CommunityServiceException('Invalid action');
        if(hcpe.Status__c == HCP_S_ACTIVATION_PENDING_O && newStatus == HCP_S_ACTIVATED){
            hcpe.Completed_Orientation__c = true;
            hcpe.Orientation_Date__c = Date.valueOf(value);
        }
        hcpe.Status__c = newStatus;
        if (String.isNotEmpty(value)) {
            if (actionId == StudyActions.ACT_HCP_ON_HOLD) {
                hcpe.On_Hold_Reason__c = value;
            } else if (actionId == StudyActions.ACT_HCP_DECLINE) {
                hcpe.Declining_Reason__c = value;
            } else if (actionId == StudyActions.ACT_HCP_DEACTIVATE) {
                hcpe.Deactivation_Reason__c = value;
            }
        }
        update hcpe;
        return newStatus;
    }

    private static final List<String> HCPE_COMMON_FIELDS = new List<String>{
            'Id',
            'Name',
            'Status__c',
            'Trial_Requires_Orientation__c',
            'CreatedDate',
            'LastModifiedDate',
            'HCP_Contact__c',
            'HCP_Contact__r.FirstName',
            'HCP_Contact__r.LastName',
            'HCP_Contact__r.Name',
            'HCP_Contact__r.AccountId',
            'HCP_Contact__r.Account.Name',
            'HCP_Name__c',
            'Study_Site__r.Id',
            'Study_Site__r.Name',
            'Study_Site__r.Site__c',
            'Study_Name__c',
            'Study_Site__r.Principal_Investigator__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Id',
            'Study_Site__r.Clinical_Trial_Profile__r.Study_Title__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Official_Title__c',
            'Study_Site__r.Clinical_Trial_Profile__c',
            'Study_Site__r.Override_PI_Referral_Status__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Override_Recruitment_Status__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Override_Status_Updated_By__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Link_to_Pre_screening__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c',
            'Override_PI_Status__c',
            'Orientation_Date__c'
    };
    
    public static List<HCP_Enrollment__c> getHCPEnrollmentsCommonCustomFields(String userMode, List<String> customFields, String filter, Boolean excludeDelegates){
        String query = 'SELECT ' + String.join(customFields, ',') +
                ' FROM HCP_Enrollment__c ' +
                ' WHERE ' + getUserModeFilter(userMode, excludeDelegates);
        if(filter != null) query += ' ' + filter;
        System.debug('EXECUTE QUERY: ' + query);
        List<HCP_Enrollment__c> hcpeList = Database.query(query);
        TranslateHelper.translate(hcpeList);
        return hcpeList;

    }

    public static List<HCP_Enrollment__c> getHCPEnrollmentsCommon(String userMode, String filter, Boolean excludeDelegates){
        return getHCPEnrollmentsCommonCustomFields(userMode, HCPE_COMMON_FIELDS, filter, excludeDelegates);
    }

    public static HCP_Enrollment__c getHCPEnrollmentForHCPById(Id hcpeId){
        return getHCPEnrollmentById(hcpeId, CommunityService.USER_MODE_HCP);
    }

    public static HCP_Enrollment__c getHCPEnrollmentById(Id hcpeId, String userMode){
        List<HCP_Enrollment__c> hcpeList = getHCPEnrollmentsCommon(
                userMode,
                ' AND Id =\'' + hcpeId + '\'',
                false
        );
        if(hcpeList.size() == 0) throw new CommunityServiceException('Data not found');
        return hcpeList[0];
    }

    public static List<HCP_Enrollment__c> getHCPEnrollmentsForPI(){
        return getHCPEnrollmentsCommon(CommunityService.USER_MODE_PI, null, false);
    }

    public static List<HCP_Enrollment__c> getEnrollmentsForPIByTrialIds(Set<Id> trialIds){
        return getEnrollmentsForPIByTrialIds(trialIds, null);
    }

    public static List<HCP_Enrollment__c> getEnrollmentsForPIByTrialIds(Set<Id> trialIds, List<String> excludeStatuses) {
        String filter = ' AND Study_Site__r.Clinical_Trial_Profile__c IN (\'' + String.join( new List<Id>(trialIds), '\',\'') + '\') ';
        if(excludeStatuses != null) filter += ' AND Status__c NOT IN (\'' + String.join(excludeStatuses, '\',\'') + '\')';
        return getHCPEnrollmentsCommon(
                CommunityService.USER_MODE_PI,
                filter,
                false
        );
    }

    public static List<HCP_Enrollment__c> getEnrollmentsForPIByStudySiteId(Id studySiteId) {
        return getHCPEnrollmentsCommon(
                CommunityService.USER_MODE_PI,
                ' AND Study_Site__c =\'' + studySiteId + '\' ',
                false
        );
    }

    public static List<HCP_Enrollment__c> getEnrollmentsForHCPOnStudySite(String trialId){
        String filter  = ' AND Status__c NOT IN (\'' + String.join(HCP_E_S_INVISIBLE_ON_STUDY_SITE_P, '\',\'') + '\') ';
        if(!String.isEmpty(trialId)) filter += ' AND Study_Site__r.Clinical_Trial_Profile__c = \'' + trialId + '\' ';
        return getHCPEnrollmentsCommon(CommunityService.USER_MODE_HCP, filter, false);
    }
    
    public static List<Account> getReferringClinics(List<Id> trialIds){
        List<HCP_Enrollment__c> enrollments = getHCPEnrollmentsCommon(
                CommunityService.USER_MODE_PI,
                ' AND Study_Site__r.Clinical_Trial_Profile__c IN (\'' + String.join(trialIds, '\',\'') + '\') ',
                false
        );
        List<Account> clinics = new List<Account>();
        Set<Id> includedIds = new Set<Id>();
        for(HCP_Enrollment__c enrollment : enrollments) {
            if(!includedIds.contains(enrollment.HCP_Contact__r.AccountId)) {
                clinics.add(enrollment.HCP_Contact__r.Account);
                includedIds.add(enrollment.HCP_Contact__r.AccountId);
            }
        }
        return clinics;
    }
    
    public static List<HCP_Enrollment__c> getHCPEnrollmentsForPI(List<String> statuses, Integer recordsLimit){
        return getHCPEnrollmentsCommon(
                CommunityService.USER_MODE_PI,
                ' AND Status__c IN (\'' + String.join(statuses, '\',\'') + '\') LIMIT ' + recordsLimit,
                false
        );
    }

    public static List<HCP_Enrollment__c> getHCPEnrollmentsForHCP() {
        return getHCPEnrollmentsCommon(CommunityService.USER_MODE_HCP, null, false);
    }

    public static List<HCP_Enrollment__c> getHCPEnrollmentsForHCPByTrial(Id trialId) {
        return getHCPEnrollmentsCommon(
                CommunityService.USER_MODE_HCP,
                ' AND Study_Site__r.Clinical_Trial_Profile__c = \'' + trialId + '\' ',
                false
        );
    }

    public static HCP_Enrollment__c getHCPEnrollmentForHCPByTrial(Id trialId) {
        List<HCP_Enrollment__c> enrollments = getHCPEnrollmentsForHCPByTrial(trialId);
        if(enrollments.size() > 0) return enrollments[0];
        return null;
    }
    
    public static Integer getHCPEnrollmentsCountForPI(List<String> statuses){
        String filter = ' AND Status__c IN (\'' + String.join(statuses, '\',\'') + '\') ';
        return getHCPECountCommon(CommunityService.USER_MODE_PI, filter, false);
    }
    
    public static Integer getAttendedRequiredCount(String userMode, Boolean attended, String filterAdd){
        String filter = ' AND Orientation_Date__c ' + (attended ? ' != ' : ' = ') + ' null ';
        filter += ' AND Study_Site__r.Clinical_Trial_Profile__r.Orientation_Required__c = true ';
        filter += filterAdd;
        return getHCPECountCommon(userMode, filter, false);
    }
    
    public static Integer getHCPECountCommon(String userMode, String filter, Boolean excludeDelegates){
        String query =
                'SELECT COUNT() ' +
                        'FROM HCP_Enrollment__c ' +
                        'WHERE ' + getUserModeFilter(userMode, excludeDelegates);
        if(filter != null) query += filter;
        System.debug('QUERY: ' + query);
        return Database.countQuery(query);
    }

    public static String getUserModeFilter(String userMode, Boolean excludeDelegates){
        String filter;
        if(userMode == CommunityService.USER_MODE_PI){
            if(excludeDelegates){
                filter =    ' Study_Site__r.Principal_Investigator__c = \'' + CommunityService.getUserContact().Id + '\' ';
            }
            else{
                filter =    '(' +
                            '   Study_Site__r.Principal_Investigator__c = \'' + CommunityService.getUserContact().Id + '\' ' +
                            '   OR Study_Site__c IN (\'' + String.join(DelegateService.getDelegatedStudySiteIds(), '\',\'') + '\')' +
                            ') ';
            }

        }else {
            if(excludeDelegates){
                filter =    ' HCP_Contact__c = \'' + CommunityService.getUserContact().Id + '\' ';
            }
            else{
                filter =    '(' +
                            '   HCP_Contact__c = \'' + CommunityService.getUserContact().Id + '\' ' +
                            '   OR Id IN (\'' + String.join(DelegateService.getDelegatedHCPEnrollmentIds(), '\',\'') + '\')' +
                            ') ';
            }
        }
        filter +=
                ' AND Status__c != NULL ' +
                ' AND Override_PI_Status__c != NULL ' +
                ' AND Study_Site__r.Clinical_Trial_Profile__c != NULL ';
        return filter;
    }
}