/**
 * Created by Olga Skrynnikova on 5/18/2020.
 */

public with sharing class Batch_SetPermissionGroupByProfile implements Database.Batchable<SObject> {

    List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT Id,
                        Profile.Name,
                        IsActive
                FROM User
                WHERE IsActive = TRUE
                AND Profile.Name IN:PermissionGroupService.profileList
        ]);
    }

    public void execute(Database.BatchableContext param1, List<User> activeUsersWithSelectedProfiles) {
        PermissionGroupService service = new PermissionGroupService();
        Map<Id, PermissionSetGroup> permissionGrByUserId = service.getPermissionGroupIdByUserId(activeUsersWithSelectedProfiles);

        PermissionSetAssignment permissionAssignment;
        for (User user : activeUsersWithSelectedProfiles) {
            if (permissionGrByUserId.containsKey(user.Id)){
                permissionAssignment = new PermissionSetAssignment(
                        AssigneeId = user.Id,
                        PermissionSetGroupId = permissionGrByUserId.get(user.Id).Id
                );
                permissionSetAssignments.add(permissionAssignment);
            }
        }

        insert permissionSetAssignments;
    }

    public void finish(Database.BatchableContext param1) {
    }

    public static void run() {
        Database.executeBatch(new Batch_SetPermissionGroupByProfile());
    }

}