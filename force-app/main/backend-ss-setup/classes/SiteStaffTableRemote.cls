/**
 * Created by Andrii Kryvolap.
 */

public with sharing class SiteStaffTableRemote {
    public static final String FEATURE_SITE_STAFF_INVITATION = 'Site_Staff_Invitation';
    public final static String PI_ACCESS_LEVEL_LABEL = 'Principal Investigator';
    public static final String IQVIAREFERRALHUB = 'Default';
    public static final String GSKPANONCOLOGY = 'GSK';
    public static final String JANSSEN = 'Janssen';
    public static final String IQVIAPatientPortalNew = 'PatientPortal';
    public static final Set<String> INVITATION_ACTIVE_STATUSES = new Set<String>{
        StudySiteService.PI_S_INVITATION_SENT,
        StudySiteService.PI_S_ACCEPTED,
        StudySiteService.PI_S_ACCEPTED_A
    };

    public class InitData {
        @AuraEnabled
        public String viewMode;
        @AuraEnabled
        public Boolean inInvitationActiveStatus;
        @AuraEnabled
        public List<SiteStaffWrapper> siteStaffMembers;
    }
    public class SiteStaffWrapper {
        @AuraEnabled
        public Contact staffContact;
        @AuraEnabled
        public String accessLevel;
        @AuraEnabled
        public Boolean hasUser = false;
        @AuraEnabled
        public Boolean hasPendingActions = false;
        @AuraEnabled
        public Boolean isInvited = false;
    }

    @AuraEnabled
    public static InitData getInitData(String ssId) {
        String viewMode = GetPermissions.getViewMode(FEATURE_SITE_STAFF_INVITATION);
        return createInitData(ssId, viewMode);
    }

    @TestVisible
    private static InitData createInitData(String ssId, String viewMode) {
        InitData data = new InitData();
        data.viewMode = viewMode;
        if (viewMode == 'Disabled') {
            return data;
        }
        Study_Site__c ss = [
            SELECT
                id,
                Principal_Investigator__c,
                Principal_Investigator__r.Id,
                Principal_Investigator__r.Name,
                Principal_Investigator__r.Email,
                Override_PI_Referral_Status__c,
                Clinical_Trial_Profile__r.CommunityTemplate__c
            FROM Study_Site__c
            WHERE Id = :ssId
        ];
        Set<Id> staffContactIds = new Set<Id>();
        Map<Id, SiteStaffWrapper> siteStaffWrapperMap = new Map<Id, SiteStaffWrapper>();
        data.inInvitationActiveStatus = INVITATION_ACTIVE_STATUSES.contains(
            ss.Override_PI_Referral_Status__c
        );
        data.siteStaffMembers = new List<SiteStaffWrapper>();
        SiteStaffWrapper piWrapper = new SiteStaffWrapper();
        piWrapper.staffContact = ss.Principal_Investigator__r;
        piWrapper.accessLevel = PI_ACCESS_LEVEL_LABEL;
        staffContactIds.add(ss.Principal_Investigator__c);
        siteStaffWrapperMap.put(ss.Principal_Investigator__c, piWrapper);
        data.siteStaffMembers.add(piWrapper);
        for (Site_Staff__c staffMember : [
            SELECT
                Id,
                Delegate_Level__c,
                is_Invited__c,
                Study_Site__c,
                Site_Contact__r.Id,
                Site_Contact__r.Name,
                Site_Contact__r.Email
            FROM Site_Staff__c
            WHERE Study_Site__c = :ssId
            ORDER BY Delegate_Level__c ASC
        ]) {
            if (staffContactIds.contains(staffMember.Site_Contact__c)) {
                if (staffMember.is_Invited__c) {
                    siteStaffWrapperMap.get(staffMember.Site_Contact__c).isInvited = true;
                }
                continue;
            }

            SiteStaffWrapper staffMemberWrapper = new SiteStaffWrapper();
            if (staffMember.is_Invited__c) {
                staffMemberWrapper.isInvited = true;
            }
            staffMemberWrapper.staffContact = staffMember.Site_Contact__r;
            staffMemberWrapper.accessLevel = staffMember.Delegate_Level__c;
            staffContactIds.add(staffMember.Site_Contact__c);
            siteStaffWrapperMap.put(staffMember.Site_Contact__c, staffMemberWrapper);
            data.siteStaffMembers.add(staffMemberWrapper);
        }
        List<Action_AssignContactPermissions> pendingPermissionSetActions = new List<Action_AssignContactPermissions>();
        for (Action__c pendingAction : [
            SELECT Body__c
            FROM Action__c
            WHERE
                Type__c = 'Action_AssignContactPermissions'
                AND Status__c = :ActionExecutor.ACTION_STATUS_PENDING
        ]) {
            Action_AssignContactPermissions actionAssignContactPermissions = (Action_AssignContactPermissions) JSON.deserialize(
                pendingAction.Body__c,
                Action_AssignContactPermissions.class
            );
            for (Id staffMemberId : siteStaffWrapperMap.keySet()) {
                Set<String> permissions = actionAssignContactPermissions.getAssignedPermissions(
                    staffMemberId
                );
                if (permissions != null && (ss.Clinical_Trial_Profile__r.CommunityTemplate__c == GSKPANONCOLOGY || ss.Clinical_Trial_Profile__r.CommunityTemplate__c == IQVIAPatientPortalNew)&& permissions.contains(CommunityTemplateService.getTemplate(IQVIAREFERRALHUB).permissionSet)) {
                    siteStaffWrapperMap.get(staffMemberId).hasPendingActions = true;
                }else if (permissions != null && ss.Clinical_Trial_Profile__r.CommunityTemplate__c == IQVIAREFERRALHUB && permissions.contains(CommunityTemplateService.getTemplate(ss.Clinical_Trial_Profile__r.CommunityTemplate__c).permissionSet)) {
                       siteStaffWrapperMap.get(staffMemberId).hasPendingActions = true;
                }else if (permissions != null && ss.Clinical_Trial_Profile__r.CommunityTemplate__c == JANSSEN && permissions.contains(CommunityTemplateService.getTemplate(ss.Clinical_Trial_Profile__r.CommunityTemplate__c).permissionSet)) {
                        siteStaffWrapperMap.get(staffMemberId).hasPendingActions = true;
                }
            }
        }

        for (User u : CommunityService.getCommunityUsersByContactIds(staffContactIds)) {
            for (PermissionSetAssignment psa : u.PermissionSetAssignments) {
                if ((ss.Clinical_Trial_Profile__r.CommunityTemplate__c == GSKPANONCOLOGY || ss.Clinical_Trial_Profile__r.CommunityTemplate__c == IQVIAPatientPortalNew)&& psa.PermissionSet.Name == CommunityTemplateService.getTemplate(IQVIAREFERRALHUB).permissionSet) {
                    siteStaffWrapperMap.get(u.ContactId).hasUser = true;
                }else if (ss.Clinical_Trial_Profile__r.CommunityTemplate__c == IQVIAREFERRALHUB && psa.PermissionSet.Name == CommunityTemplateService.getTemplate(ss.Clinical_Trial_Profile__r.CommunityTemplate__c).permissionSet) {
                        siteStaffWrapperMap.get(u.ContactId).hasUser = true;
                }else if (ss.Clinical_Trial_Profile__r.CommunityTemplate__c == JANSSEN && psa.PermissionSet.Name == CommunityTemplateService.getTemplate(ss.Clinical_Trial_Profile__r.CommunityTemplate__c).permissionSet) {
                        siteStaffWrapperMap.get(u.ContactId).hasUser = true;
                }
            }
        }
        return data;
    }

    @AuraEnabled
    public static void inviteStaffMember(String contactId, String ssId) {
        try {
            String filter = DatabaseService.fieldEqual('Study_Site__c', ssId);
            filter += 'and' + DatabaseService.fieldEqual('Site_Contact__c', contactId);

            List<Site_Staff__c> staffMembers = (List<Site_Staff__c>) DatabaseService.query(
                new List<String>{
                    'Id',
                    'Delegate_Level__c',
                    'is_Invited__c',
                    'Study_Site__c',
                    'Site_Contact__r.Id',
                    'Site_Contact__r.Name',
                    'Site_Contact__r.Email'
                },
                Site_Staff__c.getSObjectType(),
                filter
            );
            Study_Site__c ss = [
                SELECT id, Clinical_Trial_Profile__r.CommunityTemplate__c
                FROM Study_Site__c
                WHERE Id = :ssId
            ];
            Contact staffcontact = new Contact();
            staffcontact.Id = contactId;
            staffcontact.UserCommunityIsDelegate__c = true;
            DMLService.updateRecord(staffcontact);
            Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
            if (
                CommunityService.getCommunityUsersByContactIds(new Set<Id>{ contactId }).isEmpty()
            ) {
                ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                    .createPortalUsers(new Set<Id>{ contactId });
            } 

            if(ss.Clinical_Trial_Profile__r.CommunityTemplate__c == GSKPANONCOLOGY || ss.Clinical_Trial_Profile__r.CommunityTemplate__c == IQVIAPatientPortalNew){
                actionAssignContactPermissions.addPermission(contactId,CommunityTemplateService.getTemplate(IQVIAREFERRALHUB).permissionSet);
            }else{
                actionAssignContactPermissions.addPermission(contactId,CommunityTemplateService.getTemplate(ss.Clinical_Trial_Profile__r.CommunityTemplate__c).permissionSet);
                
            }
            
            if (!actionAssignContactPermissions.isEmpty()) {
                ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
            }
            staffMembers[0].is_Invited__c = true;
            DMLService.updateRecord(staffMembers[0]);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
}
