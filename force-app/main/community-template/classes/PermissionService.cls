/**
 * Created by Igor Malyuta on 19.02.2020.
 */

public without sharing class PermissionService {

    public class PermissionServiceException extends Exception {
    }

    public static final String PERMISSION_COMMUNITY_DEFAULT_NAME = 'Community_Default';
    public static final String PERMISSION_COMMUNITY_GSK_NAME = 'Community_GSK_Pan_Oncology';

    private static final List<String> CUSTOM_PERMISSIONS = new List<String>{
            PERMISSION_COMMUNITY_DEFAULT_NAME,
            PERMISSION_COMMUNITY_GSK_NAME

    };

    private static Map<String, Id> permissionSetByName;
    private static PermissionService instance;

    private PermissionService() {
        List <PermissionSet> communityPermissionSets = [
                SELECT Id, Name
                FROM PermissionSet
        ];
        if (communityPermissionSets.isEmpty()) throw new PermissionServiceException('No permissions found!');

        permissionSetByName = new Map<String, Id>();

        for (PermissionSet perm : communityPermissionSets) permissionSetByName.put(perm.Name, perm.Id);
    }

    public static PermissionService getInstance() {
        if (instance == null) {
            instance = new PermissionService();
        }
        return instance;
    }

    public Id getPermissionSetIdByName(String permissionSetName) {
        if(permissionSetByName == null || !permissionSetByName.containsKey(permissionSetName)) {
            throw new PermissionServiceException('Wrong permissionSet name!');
        }
        return permissionSetByName.get(permissionSetName);
    }

    public static Map<Id, List<Id>> getAssignmentPermissionByUser(List<Id> userIds) {
        List<PermissionSetAssignment> permissionSetAssignmentsForUsers = [
                SELECT
                        AssigneeId,
                        PermissionSetId,
                        PermissionSet.Name
                FROM PermissionSetAssignment
                WHERE AssigneeId IN:userIds
        ];
        Map<Id, List<Id>> permissionsByUser = new Map<Id, List<Id>>();
        for (PermissionSetAssignment assignment : permissionSetAssignmentsForUsers) {
            if(!permissionsByUser.containsKey(assignment.AssigneeId)) {
                permissionsByUser.put(assignment.AssigneeId, new List<Id>());
            }

            if(CUSTOM_PERMISSIONS.contains(assignment.PermissionSet.Name)) {
                permissionsByUser.get(assignment.AssigneeId).add(assignment.PermissionSetId);
            }
        }

        return permissionsByUser;
    }

    @Future
    public static void setPermissionForUsers(String userPermissionsMap) {
        Map<Id, Id> permissionByUser = (Map<Id, Id>) JSON.deserialize(userPermissionsMap, Map<Id, Id>.class);
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        for(Id userId : permissionByUser.keySet()) {
            assignments.add(new PermissionSetAssignment(
                    AssigneeId = userId,
                    PermissionSetId = permissionByUser.get(userId)
            ));
        }

        insert assignments;
    }

    @Future
    public static void setPermissions(Id userAssigneeId, List<Id> permissionIds) {
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        for(Id permId : permissionIds) {
            assignments.add(new PermissionSetAssignment(
                    AssigneeId = userAssigneeId,
                    PermissionSetId = permId
            ));
        }
        insert assignments;
    }
}