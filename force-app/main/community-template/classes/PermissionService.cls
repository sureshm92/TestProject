/**
 * Created by Igor Malyuta on 19.02.2020.
 */

public without sharing class PermissionService {

    public class PermissionServiceException extends Exception {
    }

    public static final String PERMISSION_COMMUNITY_DEFAULT = 'Community_Default';
    public static final String PERMISSION_COMMUNITY_GSK = 'Community_GSK_Pan_Oncology';

    private static final List<String> CUSTOM_PERMISSIONS = new List<String>{
            PERMISSION_COMMUNITY_DEFAULT,
            PERMISSION_COMMUNITY_GSK

    };

    private static Map<String, Id> permissionSetByName;
    private static PermissionService instance;

    private PermissionService() {
        List <PermissionSet> communityPermissionSets = [
                SELECT Id, Name
                FROM PermissionSet
                WHERE Name IN: CUSTOM_PERMISSIONS
        ];
        if (communityPermissionSets.isEmpty()) throw new PermissionServiceException('No permissions found!');

        permissionSetByName = new Map<String, Id>();

        for (PermissionSet perm : communityPermissionSets) permissionSetByName.put(perm.Name, perm.Id);
    }

    public static PermissionService getInstance() {
        if (instance == null) instance = new PermissionService();
        return instance;
    }

    public Id getPermissionSetIdByName(String permissionSetName) {
        if (permissionSetByName == null || !permissionSetByName.containsKey(permissionSetName)) {
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
            if (!permissionsByUser.containsKey(assignment.AssigneeId)) {
                permissionsByUser.put(assignment.AssigneeId, new List<Id>());
            }

            if (CUSTOM_PERMISSIONS.contains(assignment.PermissionSet.Name)) {
                permissionsByUser.get(assignment.AssigneeId).add(assignment.PermissionSetId);
            }
        }

        return permissionsByUser;
    }

    public static void setPermissionForUsers(String userPermissionsMap) {
        if (System.isBatch() || System.isFuture()) {
            setPermissionForProvidedUsers(userPermissionsMap);
        } else {
            setPermissionForProvidedUsersFuture(userPermissionsMap);
        }
    }

    @Future
    private static void setPermissionForProvidedUsersFuture(String userPermissionsMap) {
        setPermissionForProvidedUsers(userPermissionsMap);
    }

    private static void setPermissionForProvidedUsers(String userPermissionsMap) {
        Map<Id, Id> permissionByUser = (Map<Id, Id>) JSON.deserialize(userPermissionsMap, Map<Id, Id>.class);
        Map<Id, List<Id>> assigmentByUser = getAssignmentPermissionByUser(new List<Id>(permissionByUser.keySet()));

        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        for (Id userId : permissionByUser.keySet()) {
            Id newPermissionSetId = permissionByUser.get(userId);

            Boolean haveAlready = false;
            if (assigmentByUser.containsKey(userId)) {
                for (Id permId : assigmentByUser.get(userId)) {
                    if (String.valueOf(permId) == String.valueOf(newPermissionSetId)) {
                        haveAlready = true;
                        break;
                    }
                }
            }
            if (haveAlready) continue;

            assignments.add(new PermissionSetAssignment(
                    AssigneeId = userId,
                    PermissionSetId = newPermissionSetId
            ));
        }
        if (!assignments.isEmpty()) insert assignments;
    }

    @Future
    public static void setPermissions(Id userAssigneeId, List<Id> permissionIds) {
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        for (Id permId : permissionIds) {
            assignments.add(new PermissionSetAssignment(
                    AssigneeId = userAssigneeId,
                    PermissionSetId = permId
            ));
        }
        insert assignments;
    }
}