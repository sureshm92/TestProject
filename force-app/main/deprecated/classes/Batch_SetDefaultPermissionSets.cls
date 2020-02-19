/**
 * Created by Igor Iosifov on 2020-02-17.
 */

public with sharing class Batch_SetDefaultPermissionSets implements Database.Batchable<SObject>, Database.Stateful {
    List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
    Id defaultPermissionSet;

    public Database.QueryLocator start(Database.BatchableContext param1) {
        defaultPermissionSet = [
                SELECT Id
                FROM PermissionSet
                WHERE Name = :CommunityTemplateService.PERMISSION_COMMUNITY_DEFAULT_NAME
                LIMIT 1
        ].Id;

        return Database.getQueryLocator([
                SELECT Id
                FROM User
                WHERE IsActive = TRUE
                AND Profile.Name = :CommunityService.COMMUNITY_USER_PROFILE_NAME
        ]);
    }

    public void execute(Database.BatchableContext param1, List<User> activeUsersWithDefaultCommunity) {

        for (User user : activeUsersWithDefaultCommunity) {
            permissionSetAssignments.add (new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = defaultPermissionSet));
        }
    }

    public void finish(Database.BatchableContext param1) {
        Database.insert(permissionSetAssignments, false);
    }

    public static void run() {
        Database.executeBatch(new Batch_SetDefaultPermissionSets());
    }
}

