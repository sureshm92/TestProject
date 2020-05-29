/**
 * Created by Olga Skrynnikova on 5/28/2020.
 */

public with sharing class Batch_SetVisitedCommunitiesOnContact implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT Id,
                        Contact.Visited_Communities__c,
                        LastLoginDate,
                        IsActive
                FROM User
                WHERE IsActive = TRUE
                AND Contact.Visited_Communities__c = NULL
                AND LastLoginDate != NULL
                AND Contact.userCommunityMode__c = :CommunityModeService.USER_MODE_PARTICIPANT
        ]);
    }

    public void execute(Database.BatchableContext param1, List<User> users) {
        List<String> allPermissions = new List<String>(CommunityTemplateService.getAllPermissionSets());

        List<PermissionSetAssignment> userPerSetAssignments = [
                SELECT Id, AssigneeId, Assignee.ContactId, PermissionSet.Name
                FROM PermissionSetAssignment
                WHERE AssigneeId IN :users AND PermissionSet.Name IN:allPermissions
        ];

        Map<Id, List<String>> permissionSetByUserMap = new Map<Id, List<String>>();
        for (PermissionSetAssignment perm : userPerSetAssignments) {
            if (!permissionSetByUserMap.containsKey(perm.AssigneeId)) permissionSetByUserMap.put(perm.AssigneeId, new List<String>());
            permissionSetByUserMap.get(perm.AssigneeId).add(perm.PermissionSet.Name);
        }

        List<Contact> updateContacts = new List<Contact>();
        for (User u : users) {
            if (permissionSetByUserMap.containsKey(u.Id)) {
                String visitedCommunities = '';
                for (String perm : permissionSetByUserMap.get(u.Id)) {
                    visitedCommunities += CommunityTemplateService.getTemplateByPermissionSetName(perm).templateName + ';';
                }
                u.Contact.Visited_Communities__c = visitedCommunities.removeEnd(';');
                updateContacts.add(u.Contact);
            }
        }

        update updateContacts;
    }

    public void finish(Database.BatchableContext param1) {
    }

    public static void run() {
        Database.executeBatch(new Batch_SetVisitedCommunitiesOnContact());
    }
}