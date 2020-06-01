/**
 * Created by Yulia Yakushenkova on 10/15/2019.
 */

public with sharing class GetPermissions {

    private static final String DISABLED_MODE = 'Disabled';
    private static final String EDIT_MODE = 'Edit';
    private static final String VIEW_MODE = 'View';

    //Default version
//    public static String getViewMode(String feature) {
//        String ppFeature = 'PP_' + feature + '%';
//        List<PermissionSetAssignment> permissionSetAssignment = [
//                SELECT Id, PermissionSet.Name
//                FROM PermissionSetAssignment
//                WHERE AssigneeId = :UserInfo.getUserId()
//                AND PermissionSet.Name LIKE :ppFeature
//        ];
//
//        String viewMode = DISABLED_MODE;
//        if(permissionSetAssignment.isEmpty()) return viewMode;
//
//        for(PermissionSetAssignment assignment : permissionSetAssignment) {
//            if(assignment.PermissionSet.Name.endsWith(EDIT_MODE)) {
//                viewMode = EDIT_MODE;
//                break;
//            }
//            if(assignment.PermissionSet.Name.endsWith(VIEW_MODE)) viewMode = VIEW_MODE;
//        }
//        return viewMode;
//    }

    //New version with PermissionGroup
    public static String getViewMode(String feature) {
        String ppFeature = 'PP_' + feature + '%';
        List<PermissionSetAssignment> permissionSetAssignment = [
                SELECT Id, PermissionSet.Name, PermissionSetGroupId, PermissionSetGroup.MasterLabel
                FROM PermissionSetAssignment
                WHERE (PermissionSet.Name LIKE :ppFeature OR PermissionSetGroupId != NULL)
                AND AssigneeId = :UserInfo.getUserId()
        ];

        String viewMode = DISABLED_MODE;
        if (permissionSetAssignment.isEmpty()) return viewMode;

        Set<String> namePermissionSet = new Set<String>();
        List<Id> groupIds = new List<Id>();
        for (PermissionSetAssignment per : permissionSetAssignment) {
            if (per.PermissionSetGroupId != null) {
                groupIds.add(per.PermissionSetGroupId);
            } else {
                namePermissionSet.add(per.PermissionSet.Name);
            }
        }

        List<PermissionSetGroupComponent> permissionSetInGroups = new List<PermissionSetGroupComponent>();
        if (!groupIds.isEmpty()) {
            permissionSetInGroups = [
                    SELECT PermissionSet.Name
                    FROM PermissionSetGroupComponent
                    WHERE PermissionSetGroupId IN:groupIds
                    AND PermissionSet.Name LIKE 'PP_%'
            ];
            for (PermissionSetGroupComponent cmp : permissionSetInGroups) {
                namePermissionSet.add(cmp.PermissionSet.Name);
            }
        }

        for (String ps : namePermissionSet) {
            if (ps.endsWith(EDIT_MODE) && ps.startsWith(ppFeature)) {
                viewMode = EDIT_MODE;
                break;
            }
            if (ps.endsWith(VIEW_MODE)) viewMode = VIEW_MODE;
        }
        return viewMode;
    }

}