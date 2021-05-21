/**
 * Created by Leonid Bartenev
 */

public without sharing class DelegateService {
    public static String OWNER_LEVEL = 'All';
    public static String DELEGATE_LEVEL_1 = 'Level 1';
    public static String DELEGATE_LEVEL_2 = 'Level 2';
    public static String DELEGATE_LEVEL_3 = 'Level 3';

    public static final List<String> DELEGATE_LEVEL_1_AND_LOW = new List<String>{
        DELEGATE_LEVEL_1,
        DELEGATE_LEVEL_2,
        DELEGATE_LEVEL_3
    };
    public static final List<String> DELEGATE_LEVEL_2_AND_LOW = new List<String>{
        DELEGATE_LEVEL_2,
        DELEGATE_LEVEL_3
    };
    public static final String ACCESS_LEVEL_ALL = 'All';

    private Map<Id, String> piStudySitesAccessLevelMap;
    private Map<Id, String> piStudiesAccessLevel;
    private Map<Id, Id> studyPIContactsMap;
    private Map<Id, Map<Id, Site_Staff__c>> piTeamStaffTrialMap;

    private List<RP_Delegate_Relationship__c> hcpDelegatesList;
    private Map<Id, String> hcpDelegateLevelMap;

    private Set<Id> piDelegateParents;

    private static DelegateService instance;

    public DelegateService() {
        Set<Id> siteIds = new Set<Id>();
        System.debug('>>>>iddasdad332>>'+CommunityService.getUserContact().Id);
        if(String.isNotBlank(CommunityService.getUserContact().Id)) {
            system.debug('>>comign inside>>');
            for (Site_Staff__c del : [
                SELECT Id, Study_Site__c
                FROM Site_Staff__c
                WHERE Site_Contact__c = :CommunityService.getUserContact().Id
            ]) {
                siteIds.add(del.Study_Site__c);
            }
        }
        system.debug('>>siteIds>>'+siteIds);
        piDelegateParents = new Set<Id>();
        List<Site_Staff__c> piStaffs = [
            SELECT
                Id,
                Study_Site__c,
                Study_Site__r.Principal_Investigator__c,
                Study_Site__r.Clinical_Trial_Profile__c,
                Delegate_Level__c,
                Clinical_Trial_Profile__c,
                Site_Contact__c,
                is_Invited__c
            FROM Site_Staff__c
            WHERE
                (Site_Contact__c = :CommunityService.getUserContact().Id
                OR Study_Site__r.Principal_Investigator__c = :CommunityService.getUserContact().Id
                OR Study_Site__c IN :siteIds)
                AND is_Invited__c = TRUE
        ];
        piStudySitesAccessLevelMap = new Map<Id, String>();
        piStudiesAccessLevel = new Map<Id, String>();
        studyPIContactsMap = new Map<Id, Id>();
        piTeamStaffTrialMap = new Map<Id, Map<Id, Site_Staff__c>>();
        for (Site_Staff__c siteStaff : piStaffs) {
            if (siteStaff.Site_Contact__c == CommunityService.getUserContact().Id) {
                piDelegateParents.add(siteStaff.Study_Site__r.Principal_Investigator__c);
                piStudySitesAccessLevelMap.put(
                    siteStaff.Study_Site__c,
                    siteStaff.Delegate_Level__c
                );
                piStudiesAccessLevel.put(siteStaff.Study_Site__c, siteStaff.Delegate_Level__c);
                studyPIContactsMap.put(
                    siteStaff.Study_Site__r.Clinical_Trial_Profile__c,
                    siteStaff.Study_Site__r.Principal_Investigator__c
                );
            }
            if (
                siteStaff.Study_Site__r.Principal_Investigator__c ==
                CommunityService.getUserContact().Id || siteIds.contains(siteStaff.Study_Site__c)
            ) {
                if (!piTeamStaffTrialMap.containsKey(siteStaff.Site_Contact__c)) {
                    piTeamStaffTrialMap.put(
                        siteStaff.Site_Contact__c,
                        new Map<Id, Site_Staff__c>()
                    );
                }
                piTeamStaffTrialMap.get(siteStaff.Site_Contact__c)
                    .put(siteStaff.Study_Site__c, siteStaff);
            }
        }
        if(String.isNotBlank(CommunityService.getUserContact().Id)){
            hcpDelegatesList = [
                SELECT
                Id,
                Referring_Provider__r.Full_Name__c,
                Referring_Provider__c,
                Delegate__c,
                Delegate_Access_Level__c,
                Referring_Provider__r.Salutation,
                Referring_Provider__r.Title,
                Referring_Provider__r.Suffix
                FROM RP_Delegate_Relationship__c
                WHERE Delegate__c = :CommunityService.getUserContact().Id
            ];
        }
        hcpDelegateLevelMap = new Map<Id, String>();
        for (RP_Delegate_Relationship__c delegate : hcpDelegatesList) {
            hcpDelegateLevelMap.put(
                delegate.Referring_Provider__c,
                delegate.Delegate_Access_Level__c
            );
        }
        hcpDelegateLevelMap.put(CommunityService.getInstance().getCurrentContactId(), OWNER_LEVEL);
    }

    public static DelegateService getInstance() {
        if (instance == null)
            instance = new DelegateService();
        return instance;
    }

    public static void setMock(StubProvider stubProvider) {
        instance = (DelegateService) Test.createStub(DelegateService.class, stubProvider);
    }

    public Map<Id, String> getPIStudySitesAccessLevelMapImpl() {
        return piStudySitesAccessLevelMap;
    }

    public List<Id> getDelegatedStudySiteIdsImpl() {
        return new List<Id>(piStudySitesAccessLevelMap.keySet());
    }

    public Map<Id, Id> getStudyPIContactsMapImpl() {
        return studyPIContactsMap;
    }

    public Map<Id, Map<Id, Site_Staff__c>> getPITeamStaffTrialMapImpl() {
        return piTeamStaffTrialMap;
    }

    public Map<Id, String> getStudiesAccessLevelMapImpl(String userMode) {
        if (userMode == CommunityService.USER_MODE_PI) {
            return piStudiesAccessLevel;
        } else {
            return null;
        }
    }

    public String getStudyAccessLevelImpl(Id studyId, String userMode) {
        return getStudyAccessLevelImpl(studyId, userMode, null);
    }

    public String getStudyAccessLevelImpl(Id studySiteId, String userMode, String delegateId) {
        if (userMode == CommunityService.USER_MODE_HCP) {
            if (delegateId != null && delegateId != '') {
                return getHCPDelegateLevelMapImpl().get(delegateId);
            }
        } else if (userMode == CommunityService.USER_MODE_PI) {
            String accessLevel = getStudiesAccessLevelMapImpl(userMode).get(studySiteId);
            if (accessLevel != null)
                return accessLevel;
        }

        return ACCESS_LEVEL_ALL;
    }

    public List<RP_Delegate_Relationship__c> getHCPDelegatesImpl() {
        return hcpDelegatesList;
    }
    public Map<Id, String> getHCPDelegateLevelMapImpl() {
        return hcpDelegateLevelMap;
    }
    public Set<Id> getPIDelegateParentsImpl() {
        return piDelegateParents;
    }

    public void CheckAndDeactivateUsersForHCPImpl(
        List<RP_Delegate_Relationship__c> delegateRecords
    ) {
        Set<Id> delegateIds = new Set<Id>();
        for (RP_Delegate_Relationship__c delegateRecord : delegateRecords) {
            delegateIds.add(delegateRecord.Delegate__c);
        }
        CheckAndDeactivateUsersForContactIds(delegateIds);
    }

    public void CheckAndDeactivateUsersForPIImpl(List<Site_Staff__c> delegateRecords) {
        Set<Id> delegateIds = new Set<Id>();
        for (Site_Staff__c delegateRecord : delegateRecords) {
            delegateIds.add(delegateRecord.Site_Contact__c);
        }
        CheckAndDeactivateUsersForContactIds(delegateIds);
    }

    public void CheckAndDeactivateUsersForContactIds(Set<Id> delegateIds) {
        Set<Id> delegateIdsWithDelRecords = new Set<Id>();
        for (RP_Delegate_Relationship__c rpDel : [
            SELECT Id, Delegate__c
            FROM RP_Delegate_Relationship__c
            WHERE Delegate__c IN :delegateIds
        ]) {
            delegateIdsWithDelRecords.add(rpDel.Delegate__c);
        }
        for (Site_Staff__c piDel : [
            SELECT Id, Site_Contact__c
            FROM Site_Staff__c
            WHERE Site_Contact__c IN :delegateIds
        ]) {
            delegateIdsWithDelRecords.add(piDel.Site_Contact__c);
        }
        delegateIds.removeAll(delegateIdsWithDelRecords);
        if (!delegateIds.isEmpty()) {
            List<User> delegateUsersToDeactivate = [
                SELECT Id, IsActive
                FROM User
                WHERE ContactId IN :delegateIds AND Contact.userCommunytyType__c = NULL
            ];
            if (!delegateUsersToDeactivate.isEmpty()) {
                Set<Id> userIds = new Set<Id>();
                for (User u : delegateUsersToDeactivate) {
                    userIds.add(u.Id);
                }
                deactivateDelegateUsers(userIds);
            }
        }
    }
    @future
    public static void deactivateDelegateUsers(Set<Id> userIds) {
        List<User> users = [SELECT Id, IsActive FROM User WHERE Id IN :userIds];
        for (User u : users) {
            u.IsActive = false;
        }
        update users;
    }

    @future
    public static void activateDelegateUsers(Set<Id> userIds) {
        List<User> users = [SELECT Id, IsActive FROM User WHERE Id IN :userIds];
        for (User u : users) {
            u.IsActive = true;
        }
        update users;
    }

    @TestVisible
    public static void addConversationSharesForPITeam(List<Site_Staff__c> staffs) {
        List<Site_Staff__c> newStaff = [
            SELECT Id, Site_Contact__c, Study_Site__c, Study_Site__r.Principal_Investigator__c
            FROM Site_Staff__c
            WHERE Id IN :staffs
        ];

        Set<Id> staffContactIds = new Set<Id>();
        Map<Id, List<Site_Staff__c>> staffByPIds = new Map<Id, List<Site_Staff__c>>();
        for (Site_Staff__c staff : newStaff) {
            staffContactIds.add(staff.Site_Contact__c);
            Id piCon = staff.Study_Site__r.Principal_Investigator__c;
            if (!staffByPIds.containsKey(piCon))
                staffByPIds.put(piCon, new List<Site_Staff__c>());
            staffByPIds.get(piCon).add(staff);
        }

        List<User> staffUsers = [
            SELECT Id, ContactId
            FROM User
            WHERE ContactId IN :staffContactIds AND IsActive = TRUE
        ];
        Map<Id, Id> staffUserByContact = new Map<Id, Id>();
        for (User staffUser : staffUsers)
            staffUserByContact.put(staffUser.ContactId, staffUser.Id);

        List<User> piUsers = [
            SELECT Id, ContactId
            FROM User
            WHERE ContactId IN :staffByPIds.keySet()
        ];
        Map<Id, Id> piContactByUser = new Map<Id, Id>();
        for (User piUser : piUsers)
            piContactByUser.put(piUser.Id, piUser.ContactId);

        List<Conversation__Share> conversationShare = [
            SELECT Id, ParentId, Parent.Participant_Enrollment__r.Study_Site__c, UserOrGroupId
            FROM Conversation__Share
            WHERE UserOrGroupId IN :piUsers
        ];

        List<Conversation__Share> newShares = new List<Conversation__Share>();
        for (Conversation__Share cs : conversationShare) {
            Id piContact = piContactByUser.get(cs.UserOrGroupId);
            List<Site_Staff__c> piStaffs = staffByPIds.get(piContact);
            for (Site_Staff__c staff : piStaffs) {
                if (
                    staff.Study_Site__c == cs.Parent.Participant_Enrollment__r.Study_Site__c &&
                    staffUserByContact.containsKey(staff.Site_Contact__c)
                ) {
                    newShares.add(
                        new Conversation__Share(
                            AccessLevel = 'Edit',
                            ParentId = cs.ParentId,
                            UserOrGroupId = staffUserByContact.get(staff.Site_Contact__c)
                        )
                    );
                }
            }
        }

        if (!newShares.isEmpty())
            insert newShares;
    }

    @TestVisible
    public static void removeConversationSharesForPITeam(List<Site_Staff__c> staffs) {
        List<Id> staffContactIds = new List<Id>();
        List<Id> ssIds = new List<Id>();
        for (Site_Staff__c staff : staffs) {
            staffContactIds.add(staff.Site_Contact__c);
            ssIds.add(staff.Study_Site__c);
        }

        Map<Id, Conversation__c> conversationMap = new Map<Id, Conversation__c>(
            [SELECT Id FROM Conversation__c WHERE Participant_Enrollment__r.Study_Site__c IN :ssIds]
        );

        List<User> staffUsers = [SELECT Id FROM User WHERE ContactId IN :staffContactIds];
        List<Conversation__Share> conversationShares = [
            SELECT Id
            FROM Conversation__Share
            WHERE ParentId IN :conversationMap.keySet() AND UserOrGroupId IN :staffUsers
        ];
        if (!conversationShares.isEmpty())
            delete conversationShares;
    }

    public static void updateDelegatePermissionSetsPI(Contact delegateContact) {
        Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
        String permissionSetName;
        for (Study_Site__c studySite : [
            SELECT Id, Clinical_Trial_Profile__r.CommunityTemplate__c
            FROM Study_Site__c
            WHERE Principal_Investigator__c = :delegateContact.Id
        ]) {
            permissionSetName = CommunityTemplateService.getTemplate(
                    studySite.Clinical_Trial_Profile__r.CommunityTemplate__c
                )
                .permissionSet;
            actionAssignContactPermissions.addPermission(
                delegateContact.Id,
                permissionSetName == CommunityTemplateService.PERMISSION_COMMUNITY_GSK_NAME
                    ? CommunityTemplateService.PERMISSION_COMMUNITY_DEFAULT_NAME
                    : permissionSetName
            );
        }
        for (Site_Staff__c siteStaff : [
            SELECT Id, Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c
            FROM Site_Staff__c
            WHERE Site_Contact__c = :delegateContact.Id AND is_Invited__c = TRUE
        ]) {
            permissionSetName = CommunityTemplateService.getTemplate(
                    siteStaff.Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c
                )
                .permissionSet;
            actionAssignContactPermissions.addPermission(
                delegateContact.Id,
                permissionSetName == CommunityTemplateService.PERMISSION_COMMUNITY_GSK_NAME
                    ? CommunityTemplateService.PERMISSION_COMMUNITY_DEFAULT_NAME
                    : permissionSetName
            );
        }
        if (!actionAssignContactPermissions.isEmpty()) {
            ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
        }
    }

    // Static facade: --------------------------------------------------------------------------------------------------

    public static Map<Id, String> getPIStudySitesAccessLevelMap() {
        return getInstance().getPIStudySitesAccessLevelMapImpl();
    }

    public static List<Id> getDelegatedStudySiteIds() {
        return getInstance().getDelegatedStudySiteIdsImpl();
    }

    public static Map<Id, Id> getStudyPIContactsMap() {
        return getInstance().getStudyPIContactsMapImpl();
    }

    public static Map<Id, Map<Id, Site_Staff__c>> getPITeamStaffTrialMap() {
        return getInstance().getPITeamStaffTrialMapImpl();
    }

    public static Map<Id, String> getStudiesAccessLevelMap(String userMode) {
        return getInstance().getStudiesAccessLevelMapImpl(userMode);
    }

    public static String getStudyAccessLevel(Id studyId, String userMode) {
        return getStudyAccessLevel(studyId, userMode, null);
    }

    public static String getStudyAccessLevel(Id studySiteId, String userMode, String delegateId) {
        return getInstance().getStudyAccessLevelImpl(studySiteId, userMode, delegateId);
    }

    public static List<RP_Delegate_Relationship__c> getHCPDelegates() {
        return getInstance().getHCPDelegatesImpl();
    }

    public static Map<Id, String> getHCPDelegateLevelMap() {
        return getInstance().getHCPDelegateLevelMapImpl();
    }
    public static Set<Id> getPIDelegateParents() {
        return getInstance().getPIDelegateParentsImpl();
    }

    public static void CheckAndDeactivateUsersForHCP(
        List<RP_Delegate_Relationship__c> delegateRecords
    ) {
        getInstance().CheckAndDeactivateUsersForHCPImpl(delegateRecords);
    }

    public static void CheckAndDeactivateUsersForPI(List<Site_Staff__c> delegateRecords) {
        getInstance().CheckAndDeactivateUsersForPIImpl(delegateRecords);
    }
}