/**
 * Created by Andrii Kryvolap.
 */

public with sharing class SiteStaffTableRemote {

    public final static String PI_ACCESS_LEVEL_LABEL = 'Principal Investigator';

    public class InitData {
        @AuraEnabled public Boolean inInvitationSentState;
        @AuraEnabled public List<SiteStaffWrapper> siteStaffMembers;
    }
    public class SiteStaffWrapper{
        @AuraEnabled public Contact staffContact;
        @AuraEnabled public String accessLevel;
        @AuraEnabled public Boolean hasUser = false;
        @AuraEnabled public Boolean hasPendingActions = false;
    }


    @AuraEnabled
    public static InitData getInitData(String ssId){
        InitData data = new InitData();
        Study_Site__c ss = [SELECT id, Principal_Investigator__c, Principal_Investigator__r.Id, Principal_Investigator__r.Name, Principal_Investigator__r.Email, Override_PI_Referral_Status__c, Clinical_Trial_Profile__r.CommunityTemplate__c FROM Study_Site__c WHERE Id = :ssId];
        Set<Id> staffContactIds = new Set<Id>();
        Map<Id, SiteStaffWrapper> siteStaffWrapperMap = new Map<Id, SiteStaffWrapper>();
        data.inInvitationSentState = ss.Override_PI_Referral_Status__c == StudySiteService.PI_S_INVITATION_SENT;
        data.siteStaffMembers = new List<SiteStaffWrapper>();
        SiteStaffWrapper piWrapper = new SiteStaffWrapper();
        piWrapper.staffContact = ss.Principal_Investigator__r;
        piWrapper.accessLevel = PI_ACCESS_LEVEL_LABEL;
        staffContactIds.add(ss.Principal_Investigator__c);
        siteStaffWrapperMap.put(ss.Principal_Investigator__c, piWrapper);
        data.siteStaffMembers.add(piWrapper);
        for (Site_Staff__c staffMember: [SELECT Id, Delegate_Level__c, Study_Site__c, Site_Contact__r.Id, Site_Contact__r.Name, Site_Contact__r.Email FROM Site_Staff__c WHERE Study_Site__c = :ssId  ORDER BY Delegate_Level__c ASC ]){
            SiteStaffWrapper staffMemberWrapper = new SiteStaffWrapper();
            staffMemberWrapper.staffContact = staffMember.Site_Contact__r;
            staffMemberWrapper.accessLevel = staffMember.Delegate_Level__c;
            staffContactIds.add(staffMember.Site_Contact__c);
            siteStaffWrapperMap.put(staffMember.Site_Contact__c, staffMemberWrapper);
            data.siteStaffMembers.add(staffMemberWrapper);
        }
        List<Action_AssignContactPermissions> pendingPermissionSetActions = new List<Action_AssignContactPermissions>();
        for (Action__c pendingAction : [SELECT Body__c FROM Action__c WHERE Type__c = 'Action_AssignContactPermissions' AND Status__c = :ActionExecutor.ACTION_STATUS_PENDING]){
            Action_AssignContactPermissions actionAssignContactPermissions = (Action_AssignContactPermissions) JSON.deserialize(pendingAction.Body__c, Action_AssignContactPermissions.class);
            for (Id staffMemberId : siteStaffWrapperMap.keySet()){
                Set<String> permissions = actionAssignContactPermissions.getAssignedPermissions(staffMemberId);
                if (permissions != null && permissions.contains(CommunityTemplateService.getTemplate(ss.Clinical_Trial_Profile__r.CommunityTemplate__c).permissionSet)) {
                    siteStaffWrapperMap.get(staffMemberId).hasPendingActions = true;
                }
            }
        }

        for (User u : CommunityService.getCommunityUsersByContactIds(staffContactIds)){
            for (PermissionSetAssignment psa : u.PermissionSetAssignments){
                if (psa.PermissionSet.Name == CommunityTemplateService.getTemplate(ss.Clinical_Trial_Profile__r.CommunityTemplate__c).permissionSet) {
                    siteStaffWrapperMap.get(u.ContactId).hasUser = true;
                }
            }
        }
        return data;
    }

    @AuraEnabled
    public static void inviteStaffMember(String contactId, String ssId){
        try{
            Study_Site__c ss = [SELECT id, Clinical_Trial_Profile__r.CommunityTemplate__c FROM Study_Site__c WHERE Id = :ssId];
            Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
            actionAssignContactPermissions.addPermission(contactId, CommunityTemplateService.getTemplate(ss.Clinical_Trial_Profile__r.CommunityTemplate__c).permissionSet);
            if (CommunityService.getCommunityUsersByContactIds(new Set<Id>{contactId}).isEmpty()) {
                ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createPortalUsers(new Set<Id>{contactId});
            }
            if (!actionAssignContactPermissions.isEmpty()) {
                ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
            }

        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

}