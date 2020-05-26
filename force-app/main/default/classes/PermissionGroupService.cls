/**
 * Created by Olga Skrynnikova on 5/18/2020.
 */

public with sharing class PermissionGroupService {

    //Permission Groups
    public static final String PERMISSION_GR_SPNL = 'SPNL';
    public static final String PERMISSION_GR_BUSINESS_ADMINISTRATOR = 'Business Administrator';
    public static final String PERMISSION_GR_BUSINESS_LEAD = 'Business Lead';
    public static final String PERMISSION_GR_PRDB = 'PRDBAPI';
    public static final String PERMISSION_GR_PRODUCT_OWNER = 'Product Owner';

    static public List<String> permissionGroupList = new List<String>{
            PERMISSION_GR_SPNL,
            PERMISSION_GR_BUSINESS_ADMINISTRATOR,
            PERMISSION_GR_BUSINESS_LEAD,
            PERMISSION_GR_PRDB,
            PERMISSION_GR_PRODUCT_OWNER
    };

    //Profile
    public static final String PROFILE_SPNL = 'IQVIA SPNL';
    public static final String PROFILE_SPNL2 = 'IQVIA SPNL2';
    public static final String PROFILE_BUSINESS_ADMINISTRATOR = 'Business Administrator';
    public static final String PROFILE_BUSINESS_LEAD = 'BusinessLead';
    public static final String PROFILE_PRDB = 'PRDBAPI';
    public static final String PROFILE_PRODUCT_OWNER = 'Product Owner';

    static public List<String> profilesSPNL = new List<String>{
            PROFILE_SPNL,
            PROFILE_SPNL2
    };

    static public List<String> profileList = new List<String>{
            PROFILE_SPNL,
            PROFILE_SPNL2,
            PROFILE_BUSINESS_ADMINISTRATOR,
            PROFILE_BUSINESS_LEAD,
            PROFILE_PRDB,
            PROFILE_PRODUCT_OWNER
    };

    private Map<String, PermissionSetGroup> permissionGroupIdByName = new Map<String, PermissionSetGroup>();
    public PermissionGroupService() {
        List<PermissionSetGroup> permissionSetGroups = [
                SELECT Id, MasterLabel
                FROM PermissionSetGroup
                WHERE MasterLabel IN: permissionGroupList
        ];
        for(PermissionSetGroup perGr: permissionSetGroups) permissionGroupIdByName.put(perGr.MasterLabel, perGr);
    }

    public Map<Id, PermissionSetGroup> getPermissionGroupIdByUserId(List<User> users) {
        Map<Id, PermissionSetGroup> permissionGrByUserId = new Map<Id, PermissionSetGroup>();
        String profileName;
        PermissionSetGroup permGroup;

        for (User u : users) {

            profileName = u.Profile.Name;
            if (profilesSPNL.contains(profileName)) permGroup = permissionGroupIdByName.get(PERMISSION_GR_SPNL);
            if (profileName == PROFILE_BUSINESS_ADMINISTRATOR) permGroup = permissionGroupIdByName.get(PERMISSION_GR_BUSINESS_ADMINISTRATOR);
            if (profileName == PROFILE_BUSINESS_LEAD) permGroup = permissionGroupIdByName.get(PERMISSION_GR_BUSINESS_LEAD);
            if (profileName == PROFILE_PRDB) permGroup = permissionGroupIdByName.get(PERMISSION_GR_PRDB);
            if (profileName == PROFILE_PRODUCT_OWNER) permGroup = permissionGroupIdByName.get(PERMISSION_GR_PRODUCT_OWNER);

            permissionGrByUserId.put(u.Id, permGroup);
        }

        return permissionGrByUserId;
    }
}