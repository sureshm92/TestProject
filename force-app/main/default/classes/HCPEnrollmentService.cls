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
    public final static String HCP_S_ACTIVATION_PENDING_O = 'Orientation Pending';
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
            StudyActions.ACT_HCP_ACTIVATE => HCP_S_ACTIVATED,
            StudyActions.ACT_HCP_ON_HOLD => HCP_S_ON_HOLD_APPROVAL,
            StudyActions.ACT_HCP_DECLINE => HCP_S_DECLINED_APPROVAL,
            StudyActions.ACT_HCP_ACTIVATE_FOR_ALL => HCP_S_ACTIVATED
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
            StudyActions.ACT_HCP_DECLINE => HCP_S_DECLINE_ACTIVATION,
            StudyActions.ACT_HCP_ACTIVATE_FOR_ALL => HCP_S_ACTIVATED
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

    private static HCPEnrollmentService instance;

    public static HCPEnrollmentService getInstance() {
        if (instance == null)
            instance = new HCPEnrollmentService();
        return instance;
    }

    public static void setMock(StubProvider stubProvider) {
        instance = (HCPEnrollmentService) Test.createStub(HCPEnrollmentService.class, stubProvider);
    }

    public static String changeStatus(Id HCPEnrollmentId, String userMode, String newStatusType) {
        return changeStatus(HCPEnrollmentId, userMode, newStatusType, '');
    }

    public static String changeStatus(Id hcpeId, String userMode, String actionId, String value) {
        HCP_Enrollment__c hcpe = getHCPEnrollmentById(hcpeId, userMode);
        if (actionId != StudyActions.ACT_HCP_ACTIVATE_FOR_ALL) {
            String newStatus = HCP_CHANGE_STATUS_MAP.get(hcpe.Status__c).get(actionId);
            if (newStatus == null)
                throw new CommunityServiceException('Invalid action');
            if (hcpe.Status__c == HCP_S_ACTIVATION_PENDING_O && newStatus == HCP_S_ACTIVATED) {
                hcpe.Completed_Orientation__c = true;
                hcpe.Orientation_Date__c = Date.valueOf(value);
                hcpe.Status__c = newStatus;
            } else if (
                hcpe.Study_Site__r.Clinical_Trial_Profile__r.Orientation_Required__c &&
                newStatus == HCP_S_ACTIVATED &&
                !hcpe.Completed_Orientation__c
            ) {
                hcpe.Status__c = HCP_S_ACTIVATION_PENDING_O;
            } else {
                hcpe.Status__c = newStatus;
            }
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
        } else {
            String filter =
                ' Principal_Investigator__c = \'' +
                hcpe.Study_Site__r.Principal_Investigator__c +
                '\' ';
            List<Study_Site__c> ssList = StudySiteService.getStudySitesCommon(filter);
            Map<String, Study_Site__c> ssMap = new Map<String, Study_Site__c>();
            Set<Id> trailIds = new Set<Id>();
            for (Study_Site__c ss : ssList) {
                if (
                    StudySiteService.STATUS_GROUP_ACCEPTED.contains(
                        ss.Override_PI_Referral_Status__c
                    ) &&
                    ss.Clinical_Trial_Profile__r.CommunityTemplate__c !=
                    CommunityTemplateService.TEMPLATE_JANSSEN
                ) {
                    trailIds.add(ss.Clinical_Trial_Profile__c);
                    ssMap.put(ss.Id, ss);
                }
            }
            List<HCP_Enrollment__c> upsertList = new List<HCP_Enrollment__c>();
            List<String> ssIdsList = new List<String>(ssMap.keySet());
            List<HCP_Enrollment__c> hcpEnrollmentList = getHCPEnrollmentsCommon(
                CommunityService.USER_MODE_PI,
                'AND HCP_Contact__c = \'' +
                hcpe.HCP_Contact__c +
                '\' AND Study_Site__c IN (\'' +
                String.join(ssIdsList, '\',\'') +
                '\') ',
                false
            );
            for (HCP_Enrollment__c enrollment : hcpEnrollmentList) {
                if (enrollment.Status__c != HCP_S_ACTIVATED) {
                    enrollment.Status__c = ssMap.get(enrollment.Study_Site__c)
                            .Clinical_Trial_Profile__r.Orientation_Required__c
                        ? HCP_S_ACTIVATION_PENDING_O
                        : HCP_S_ACTIVATED;
                    upsertList.add(enrollment);
                }
                ssMap.remove(enrollment.Study_Site__c);
            }
            for (String ssId : ssMap.keySet()) {
                upsertList.add(
                    new HCP_Enrollment__c(
                        HCP_Contact__c = hcpe.HCP_Contact__c,
                        HCP_Account__c = hcpe.HCP_Contact__r.AccountId,
                        Status__c = ssMap.get(ssId)
                                .Clinical_Trial_Profile__r.Orientation_Required__c
                            ? HCP_S_ACTIVATION_PENDING_O
                            : HCP_S_ACTIVATED,
                        Study_Site__c = ssId
                    )
                );
            }
            if (!upsertList.isEmpty() && !ssMap.values().isEmpty()) {
                insert new PI_RP_Relationship__c(
                    PI_Contact__c = ssMap.values()[0].Principal_Investigator__c,
                    RP_Contact__c = hcpe.HCP_Contact__c
                );
            }
            upsert upsertList;
            /*ReferHealthcareProviderRemote.sendNotificationForRPInvite(hcpe.Id, hcpe.HCP_Contact__c);*/
            /*insert new Notification__c(
                    Notification_Type__c = NotificationCatalog.MESSAGE_TO_HCP_APPROVED_TYPE,
                    Recipient__c = hcpe.HCP_Contact__c,
                    WhatId__c = hcpe.Id);*/
            return HCP_S_ACTIVATED;
        }
    }

    public static final List<String> HCPE_COMMON_FIELDS = new List<String>{
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
        'HCP_Contact__r.Account.BillingStreet',
        'HCP_Contact__r.Account.BillingState',
        'HCP_Contact__r.Account.BillingPostalCode',
        'HCP_Contact__r.Account.BillingCity',
        'HCP_Contact__r.Account.Phone',
        'HCP_Contact__r.Salutation',
        'HCP_Contact__r.Is_First_logon__c',
        'HCP_Name__c',
        'HCP_Enrollment__c.Study__c',
        'Study_Site__r.Id',
        'Study_Site__r.Name',
        'Study_Site__r.Site__c',
        'Study_Name__c',
        'Study_Site__r.Principal_Investigator__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Id',
        'Study_Site__r.Clinical_Trial_Profile__r.Study_Title__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Official_Title__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Orientation_Required__c',
        'Study_Site__r.Clinical_Trial_Profile__c',
        'Study_Site__r.Override_PI_Referral_Status__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Override_Recruitment_Status__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Override_Status_Updated_By__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Link_to_Pre_screening__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Study_Sponsor__c',
        'Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c',
        'Study_Site__r.Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c',
        'Study_Site__r.Site__r.Name',
        'Study_Site__r.Principal_Investigator__r.Name',
        'Study_Site__r.Principal_Investigator__r.Title',
        'Study_Site__r.Principal_Investigator__r.Email',
        'Study_Site__r.Principal_Investigator__r.Phone',
        'Study_Site__r.Principal_Investigator__r.MailingAddress',
        'Study_Site__r.Is_Virtual_Study_Site__c',
        'Study_Site__r.Study_Site_Type__c',
        'Study_Site__r.Participant_DOB_format__c',
        'Override_PI_Status__c',
        'Orientation_Date__c',
        'Completed_Orientation__c'
    };

    public static List<HCP_Enrollment__c> getHCPEnrollmentsCommonCustomFields(
        String userMode,
        List<String> customFields,
        String filter,
        Boolean excludeDelegates
    ) {
        return getHCPEnrollmentsCommonCustomFields(
            userMode,
            null,
            customFields,
            filter,
            excludeDelegates
        );
    }

    public static List<HCP_Enrollment__c> getHCPEnrollmentsCommonCustomFields(
        String userMode,
        String delegateId,
        List<String> customFields,
        String filter,
        Boolean excludeDelegates
    ) {
        String query =
            'SELECT ' +
            String.join(customFields, ',') +
            ' FROM HCP_Enrollment__c ' +
            ' WHERE ' +
            getUserModeFilter(userMode, delegateId, excludeDelegates);
        if (filter != null)
            query += ' ' + filter;
        System.debug('EXECUTE QUERY: ' + query);

        List<HCP_Enrollment__c> hcpeList = Database.query(query);

        System.debug('Query:' + query + ' result hcpeList = ' + hcpeList);
        TranslateHelper.translate(hcpeList);
        return hcpeList;
    }

    public static List<HCP_Enrollment__c> getHCPEnrollmentsCommon(
        String userMode,
        String filter,
        Boolean excludeDelegates
    ) {
        return getHCPEnrollmentsCommon(userMode, null, filter, excludeDelegates);
    }

    public static List<HCP_Enrollment__c> getHCPEnrollmentsCommon(
        String userMode,
        String delegateId,
        String filter,
        Boolean excludeDelegates
    ) {
        return getHCPEnrollmentsCommonCustomFields(
            userMode,
            delegateId,
            HCPE_COMMON_FIELDS,
            filter,
            excludeDelegates
        );
    }
    public static HCP_Enrollment__c getHcpEnroll(Id hcpeId) {
        String query =
            'SELECT ' +
            String.join(HCPE_COMMON_FIELDS, ',') +
            ' FROM HCP_Enrollment__c ' +
            ' WHERE Id = \'' +
            hcpeId +
            '\'';
        HCP_Enrollment__c hcpe = Database.query(query);
        TranslateHelper.translate(hcpe);
        return hcpe;
    }

    //    public static List<HCP_Enrollment__c> getHCPEnrollmentsWithDelegateLevelFiltered(String filter, Set<String> delegateLevels){
    //        List<HCP_Enrollment__c> hcpeList = new List<HCP_Enrollment__c>();
    //        Map<Id, String> delegateLevelMap = DelegateService.getHCPEnrollmentAccessLevelMap();
    //        for(HCP_Enrollment__c hcpe : getHCPEnrollmentsCommonCustomFields(CommunityService.USER_MODE_HCP, HCPE_COMMON_FIELDS, filter, false)){
    //            if(!delegateLevelMap.containsKey(hcpe.Id) || delegateLevels.contains(delegateLevelMap.get(hcpe.Id))){
    //                hcpeList.add(hcpe);
    //            }
    //        }
    //        return hcpeList;
    //    }

    public static HCP_Enrollment__c getHCPEnrollmentForHCPById(Id hcpeId) {
        return getHCPEnrollmentForHCPById(hcpeId, null);
    }

    public static HCP_Enrollment__c getHCPEnrollmentForHCPById(Id hcpeId, String delegateId) {
        return getHCPEnrollmentById(hcpeId, CommunityService.USER_MODE_HCP, delegateId);
    }

    public HCP_Enrollment__c getHCPEnrollmentByIdImpl(Id hcpeId, String userMode) {
        return getHCPEnrollmentByIdImpl(hcpeId, userMode, null);
    }

    public HCP_Enrollment__c getHCPEnrollmentByIdImpl(
        Id hcpeId,
        String userMode,
        String delegateId
    ) {
        List<HCP_Enrollment__c> hcpeList = getHCPEnrollmentsCommon(
            userMode,
            delegateId,
            ' AND Id =\'' +
            hcpeId +
            '\'',
            false
        );
        if (hcpeList.size() == 0)
            throw new CommunityServiceException('Data not found');
        return hcpeList[0];
    }

    public HCP_Enrollment__c getHCPEnrollmentByIdImpl(
        Id hcpeId,
        String userMode,
        String delegateId,
        List<String> HCP_FIELDS
    ) {
        List<HCP_Enrollment__c> hcpeList = getHCPEnrollmentsCommon(
            userMode,
            delegateId,
            ' AND Id =\'' +
            hcpeId +
            '\'',
            false,
            HCP_FIELDS
        );
        if (hcpeList.size() == 0)
            throw new CommunityServiceException('Data not found');
        return hcpeList[0];
    }  

    public static List<HCP_Enrollment__c> getHCPEnrollmentsCommon(
        String userMode,
        String delegateId,
        String filter,
        Boolean excludeDelegates,
        List<String> HCP_FIELDS
    ) {
        return getHCPEnrollmentsCommonCustomFields(
            userMode,
            delegateId,
            HCP_FIELDS,
            filter,
            excludeDelegates
        );
    }    
    
    public static HCP_Enrollment__c getHCPEnrollmentById(Id hcpeId, String userMode) {
        return HCPEnrollmentService.getInstance().getHCPEnrollmentByIdImpl(hcpeId, userMode);
    }

    public static HCP_Enrollment__c getHCPEnrollmentById(
        Id hcpeId,
        String userMode,
        String delegateId
    ) {
        return HCPEnrollmentService.getInstance()
            .getHCPEnrollmentByIdImpl(hcpeId, userMode, delegateId);
    }

    public static List<HCP_Enrollment__c> getHCPEnrollmentsForPI() {
        return getHCPEnrollmentsCommon(CommunityService.USER_MODE_PI, null, false);
    }
    //TODO:Refactoring
    //Use in classes or remove
    //    public static List<HCP_Enrollment__c> getEnrollmentsForPIByTrialIds(Set<Id> trialIds){
    //        return getEnrollmentsForPIByTrialIds(trialIds, null, false);

    //    }
    //
    //    public static List<HCP_Enrollment__c> getEnrollmentsForPIByTrialIds(Set<Id> trialIds, List<String> statusesList, Boolean excludeStatuses){
    //        return getEnrollmentsForPIByTrialIds(trialIds, statusesList, excludeStatuses, null);
    //    }
    //
    //    public static List<HCP_Enrollment__c> getEnrollmentsForPIByTrialIds(Set<Id> trialIds, List<String> statusesList, Boolean excludeStatuses, String sortString) {
    //        String filter = ' AND Study_Site__r.Clinical_Trial_Profile__c IN (\'' + String.join( new List<Id>(trialIds), '\',\'') + '\') ';
    //        if(statusesList != null && excludeStatuses) filter += ' AND Status__c NOT IN (\'' + String.join(statusesList, '\',\'') + '\')';
    //        if(statusesList != null && !excludeStatuses) filter += ' AND Status__c IN (\'' + String.join(statusesList, '\',\'') + '\')';
    //        if(sortString != null) filter += ' ORDER BY ' + sortString;
    //        return getHCPEnrollmentsCommon(
    //                CommunityService.USER_MODE_PI,
    //                filter,
    //                false
    //        );
    //    }

    public static List<HCP_Enrollment__c> getEnrollmentsForPIByStudySiteId(Id studySiteId) {
        return getEnrollmentsForPIByStudySiteId(studySiteId, null, false);
    }

    public static List<HCP_Enrollment__c> getEnrollmentsForPIByStudySiteId(
        Id studySiteId,
        List<String> statusesList,
        Boolean excludeStatuses
    ) {
        return getEnrollmentsForPIByStudySiteId(studySiteId, statusesList, excludeStatuses, null);
    }

    public static List<HCP_Enrollment__c> getEnrollmentsForPIByStudySiteId(
        Id studySiteId,
        List<String> statusesList,
        Boolean excludeStatuses,
        String sortString
    ) {
        String filter = ' AND Study_Site__c =\'' + studySiteId + '\' ';
        if (statusesList != null && excludeStatuses)
            filter += ' AND Status__c NOT IN (\'' + String.join(statusesList, '\',\'') + '\')';
        if (statusesList != null && !excludeStatuses)
            filter += ' AND Status__c IN (\'' + String.join(statusesList, '\',\'') + '\')';
        if (sortString != null)
            filter += ' ORDER BY ' + sortString;
        return getHCPEnrollmentsCommon(CommunityService.USER_MODE_PI, filter, false);
    }
    //TODO:Refactoring
    //Use in classes or remove
    //    public static List<HCP_Enrollment__c> getEnrollmentsForHCPOnStudySite(String trialId){
    //        return getEnrollmentsForHCPOnStudySite(trialId, null);
    //    }
    //
    //    public static List<HCP_Enrollment__c> getEnrollmentsForHCPOnStudySite(String trialId, String delegateId){
    //        String filter  = ' AND Status__c NOT IN (\'' + String.join(HCP_E_S_INVISIBLE_ON_STUDY_SITE_P, '\',\'') + '\') ';
    //        if(!String.isEmpty(trialId)) filter += ' AND Study_Site__r.Clinical_Trial_Profile__c = \'' + trialId + '\' ';
    //        return getHCPEnrollmentsCommon(CommunityService.USER_MODE_HCP, delegateId, filter, false);
    //    }

    public static List<Account> getReferringClinics(List<Id> trialIds) {
        List<HCP_Enrollment__c> enrollments = getHCPEnrollmentsCommon(
            CommunityService.USER_MODE_PI,
            ' AND Study_Site__r.Clinical_Trial_Profile__c IN (\'' +
            String.join(trialIds, '\',\'') +
            '\') ',
            false
        );
        List<Account> clinics = new List<Account>();
        Set<Id> includedIds = new Set<Id>();
        for (HCP_Enrollment__c enrollment : enrollments) {
            if (!includedIds.contains(enrollment.HCP_Contact__r.AccountId)) {
                clinics.add(enrollment.HCP_Contact__r.Account);
                includedIds.add(enrollment.HCP_Contact__r.AccountId);
            }
        }
        return clinics;
    }

    //TODO:Refactoring
    //Use in classes or remove

    //    public static List<HCP_Enrollment__c> getHCPEnrollmentsForPI(List<String> statuses, Integer recordsLimit){
    //        return getHCPEnrollmentsCommon(
    //                CommunityService.USER_MODE_PI,
    //                ' AND Status__c IN (\'' + String.join(statuses, '\',\'') + '\') LIMIT ' + recordsLimit,
    //                false
    //        );
    //    }

    public static List<HCP_Enrollment__c> getHCPEnrollmentsByPI(Id piId) {
        String query =
            'SELECT ' +
            String.join(HCPE_COMMON_FIELDS, ',') +
            ' FROM HCP_Enrollment__c ' +
            ' WHERE Study_Site__r.Principal_Investigator__c = \'' +
            piId +
            '\'';
        List<HCP_Enrollment__c> hcpeList = Database.query(query);
        TranslateHelper.translate(hcpeList);
        return hcpeList;
    }

    public static List<HCP_Enrollment__c> getHCPEnrollmentsByPIVSStudy(Id piId, Id ctpId) {
        List<HCP_Enrollment__c> hcpeList = new List<HCP_Enrollment__c>();
        String query =
            'SELECT ' +
            String.join(HCPE_COMMON_FIELDS, ',') +
            ' FROM HCP_Enrollment__c ' +
            ' WHERE Study_Site__r.Principal_Investigator__c = \'' +
            piId +
            '\' AND Clinical_Trial_Profile__c = \'' +
            ctpId +
            '\'';
        hcpeList = Database.query(query);
        if (!hcpeList.isEmpty()) {
            TranslateHelper.translate(hcpeList);
        }
        return hcpeList;
    }
    //TODO:Refactoring
    //Use in classes or remove
    //    public static List<HCP_Enrollment__c> getHCPEnrollmentsForHCP() {
    //        return getHCPEnrollmentsForHCP(null,false);
    //    }

    //    public static List<HCP_Enrollment__c> getHCPEnrollmentsForHCP(Boolean excludeDelegates) {
    //        return getHCPEnrollmentsForHCP(null, excludeDelegates);
    //    }

    //    public static List<HCP_Enrollment__c> getHCPEnrollmentsForHCP(String delegateId) {
    //        return getHCPEnrollmentsForHCP(delegateId, false);
    //    }

    //    public static List<HCP_Enrollment__c> getHCPEnrollmentsForHCP(String delegateId, Boolean excludeDelegates) {
    //        return getHCPEnrollmentsCommon(CommunityService.USER_MODE_HCP, delegateId, null, excludeDelegates);
    //    }

    //    public static List<HCP_Enrollment__c> getHCPEnrollmentsForHCPByTrial(Id trialId) {
    //        return getHCPEnrollmentsForHCPByTrial(trialId, null);
    //    }

    public static List<HCP_Enrollment__c> getHCPEnrollmentsForHCPByTrial(
        Id trialId,
        String delegateId
    ) {
        return getHCPEnrollmentsCommon(
            CommunityService.USER_MODE_HCP,
            delegateId,
            ' AND Study_Site__r.Clinical_Trial_Profile__c = \'' +
            trialId +
            '\' ',
            false
        );
    }

    //TODO:Refactoring
    //Use in classes or remove
    //    public static List<HCP_Enrollment__c> getHCPEnrollmentsForHCPByTrials(List<Id> trialIds) {
    //        return getHCPEnrollmentsForHCPByTrials( trialIds, null);
    //    }

    public static List<HCP_Enrollment__c> getHCPEnrollmentsForHCPByTrials(
        List<Id> trialIds,
        String delegateId
    ) {
        return getHCPEnrollmentsCommon(
            CommunityService.USER_MODE_HCP,
            delegateId,
            ' AND Study_Site__r.Clinical_Trial_Profile__c IN (\'' +
            String.join(trialIds, '\',\'') +
            '\' )',
            false
        );
    }

    public static HCP_Enrollment__c getHCPEnrollmentForHCPByTrial(Id trialId) {
        return getHCPEnrollmentForHCPByTrial(trialId, null);
    }

    public static HCP_Enrollment__c getHCPEnrollmentForHCPByTrial(Id trialId, String delegateId) {
        List<HCP_Enrollment__c> enrollments = getHCPEnrollmentsForHCPByTrial(trialId, delegateId);
        if (enrollments.size() > 0)
            return enrollments[0];
        return null;
    }

    //TODO:Refactoring
    //Use in classes or remove
    //    public static Integer getHCPEnrollmentsCountForPI(List<String> statuses){
    //        String filter = ' AND Status__c IN (\'' + String.join(statuses, '\',\'') + '\') ';
    //        return getHCPECountCommon(CommunityService.USER_MODE_PI, filter, false);
    //    }

    //    public static Integer getAttendedRequiredCount(String userMode, Boolean attended, String filterAdd){
    //        return getAttendedRequiredCount(userMode, null, attended, filterAdd);
    //    }

    public static Integer getAttendedRequiredCount(
        String userMode,
        String delegateId,
        Boolean attended,
        String filterAdd
    ) {
        String filter = ' AND Orientation_Date__c ' + (attended ? ' != ' : ' = ') + ' null ';
        filter += ' AND Study_Site__r.Clinical_Trial_Profile__r.Orientation_Required__c = true ';
        filter += filterAdd;
        return getHCPECountCommon(userMode, delegateId, filter, false);
    }

    //TODO:Refactoring
    //Use in classes or remove
    //    public static Integer getHCPECountCommon(String userMode, String filter, Boolean excludeDelegates){
    //        return getHCPECountCommon(userMode, null, filter, excludeDelegates);
    //    }

    public static Integer getHCPECountCommon(
        String userMode,
        String delegateId,
        String filter,
        Boolean excludeDelegates
    ) {
        String query =
            'SELECT COUNT() ' +
            'FROM HCP_Enrollment__c ' +
            'WHERE ' +
            getUserModeFilter(userMode, delegateId, excludeDelegates);
        if (filter != null)
            query += filter;
        System.debug('QUERY: ' + query);
        return Database.countQuery(query);
    }

    //TODO:Refactoring
    //Use in classes or remove
    //    public static String getUserModeFilter(String userMode, Boolean excludeDelegates){
    //        return getUserModeFilter(userMode, null, excludeDelegates);
    //    }

    public static String getUserModeFilter(
        String userMode,
        String delegateId,
        Boolean excludeDelegates
    ) {
        String filter;
        if (userMode == CommunityService.USER_MODE_PI) {
            if (excludeDelegates) {
                filter =
                    ' Study_Site__r.Principal_Investigator__c = \'' +
                    CommunityService.getUserContact().Id +
                    '\' ';
            } else {
                filter =
                    '(' +
                    '   Study_Site__r.Principal_Investigator__c = \'' +
                    CommunityService.getUserContact().Id +
                    '\' ' +
                    '   OR Study_Site__c IN (\'' +
                    String.join(DelegateService.getDelegatedStudySiteIds(), '\',\'') +
                    '\')' +
                    ') ';
            }
        } else {
            if (delegateId == null || delegateId == '') {
                filter = ' HCP_Contact__c = \'' + CommunityService.getUserContact().Id + '\' ';
            } else {
                filter = ' HCP_Contact__c = \'' + delegateId + '\' ';
            }
        }
        filter +=
            ' AND Status__c != NULL ' +
            ' AND Override_PI_Status__c != NULL ' +
            ' AND Study_Site__r.Clinical_Trial_Profile__c != NULL ';
        System.debug('HCPE filter' + filter);
        return filter;
    }

    //TODO:Refactoring
    //Use in classes or remove
    //    public static List<HCP_Enrollment__c> getHCPEnrollmentByContactId(){
    //        String contactId = CommunityService.getUserContact().Id;
    //        List<HCP_Enrollment__c> enrollemntsToReturn = [SELECT Id,
    //                                                              HCP_Contact__c
    //                                                        FROM HCP_Enrollment__c WHERE HCP_Contact__c =: contactId];
    //        return enrollemntsToReturn;
    //    }
}
