/**
 * Created by Yulia Yakushenkova on 10/15/2019.
 */

public with sharing class GetPermissions {

    private static final String DISABLED_MODE = 'Disabled';
    private static final String EDIT_MODE = 'Edit';
    private static final String VIEW_MODE = 'View';

    public static String getViewMode(String feature) {
        String ppFeature = 'PP_' + feature + '%';
        List<PermissionSetAssignment> permissionSetAssignment = [
                SELECT Id, PermissionSet.Name
                FROM PermissionSetAssignment
                WHERE AssigneeId = :UserInfo.getUserId()
                AND PermissionSet.Name LIKE :ppFeature
        ];

        String viewMode = DISABLED_MODE;
        if(permissionSetAssignment.isEmpty()) return viewMode;

        for(PermissionSetAssignment assignment : permissionSetAssignment) {
            if(assignment.PermissionSet.Name.endsWith(EDIT_MODE)) {
                viewMode = EDIT_MODE;
                break;
            }
            if(assignment.PermissionSet.Name.endsWith(VIEW_MODE)) viewMode = VIEW_MODE;
        }

        return viewMode;
    }

}