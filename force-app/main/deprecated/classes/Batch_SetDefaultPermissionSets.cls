/**
 * Created by Igor Iosifov on 2020-02-17.
 */

public with sharing class Batch_SetDefaultPermissionSets implements Database.Batchable<SObject> {


    public Iterable<SObject> start(Database.BatchableContext param1) {
        List<User> activeUsersWithDefaultCommunity = [
                SELECT Id
                FROM User
                WHERE IsActive = TRUE
                AND Profile.Name = 'IQVIA Customer Community Plus Login User'
        ];
        return activeUsersWithDefaultCommunity;
    }

    public void execute(Database.BatchableContext param1, List<User> activeUsersWithDefaultCommunity) {
        PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'Community_Default' LIMIT 1];
        List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
        for (User user : activeUsersWithDefaultCommunity) {
            permissionSetAssignments.add (new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = permissionSet.Id));
        }
        insert permissionSetAssignments;
    }

    public void finish(Database.BatchableContext param1) {
    }

    public static void runAll() {
        Database.executeBatch(new Batch_SetDefaultPermissionSets());
    }

}