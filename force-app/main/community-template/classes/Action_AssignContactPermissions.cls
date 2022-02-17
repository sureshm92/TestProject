/**
 * Created by Leonid Bartenev
 */

public without sharing class Action_AssignContactPermissions implements Action {
    @TestVisible
    private Map<Id, Set<String>> contactPermissionsMap = new Map<Id, Set<String>>();
    @TestVisible
    private Map<Id, Set<String>> contactPermissionsToRemoveMap = new Map<Id, Set<String>>();

    public void addPermission(Id contactId, String permissionSet) {
        Set<String> permissions = contactPermissionsMap.get(contactId);
        if (permissions == null)
            permissions = new Set<String>();
        permissions.add(permissionSet);
        contactPermissionsMap.put(contactId, permissions);
    }

    public void addPermissions(Id contactId, Set<String> permissionSets) {
        for (String permission : permissionSets)
            addPermission(contactId, permission);
    }

    public Set<String> getAssignedPermissions(Id contactId) {
        return contactPermissionsMap.get(contactId);
    }

    public void deletePermission(Id contactId, String permissionSet) {
        Set<String> permissions = contactPermissionsToRemoveMap.get(contactId);
        if (permissions == null)
            permissions = new Set<String>();
        permissions.add(permissionSet);
        contactPermissionsToRemoveMap.put(contactId, permissions);
    }

    public void deletePermissions(Id contactId, Set<String> permissionSets) {
        for (String permission : permissionSets)
            deletePermission(contactId, permission);
    }

    public Boolean isEmpty() {
        return contactPermissionsMap.isEmpty() && contactPermissionsToRemoveMap.isEmpty();
    }

    public void execute() {
        cleanReassignedPermissions();
        deletePermissions();
        insertPermissions();
    }

    public Type getType() {
        return Action_AssignContactPermissions.class;
    }

    public Boolean isDMLWithSetupObjects() {
        return true;
    }

    public void postDML(Action__c dbAction, Execution_History__c executionHistory) {
    }
    @TestVisible
    private void cleanReassignedPermissions() {
        //remove permission from remove map if this permission exist in assign map
        Map<Id, Set<String>> resMap = new Map<Id, Set<String>>();
        for (Id contactId : contactPermissionsToRemoveMap.keySet()) {
            Set<String> permissionsForRemove = new Set<String>();
            Set<String> contactAssignedPerms = contactPermissionsMap.get(contactId);
            if (contactAssignedPerms == null)
                contactAssignedPerms = new Set<String>();
            for (String contactRemovePerm : contactPermissionsToRemoveMap.get(contactId)) {
                if (!contactAssignedPerms.contains(contactRemovePerm)) {
                    permissionsForRemove.add(contactRemovePerm);
                }
            }
            resMap.put(contactId, permissionsForRemove);
        }
        contactPermissionsToRemoveMap = resMap;
    }
    @TestVisible
    private void insertPermissions() {
        // all permission sets:
        Map<String, Id> permissionIdByNameMap = new Map<String, Id>();
        List<PermissionSet> permissionSets = [SELECT Id, Name FROM PermissionSet];
        for (PermissionSet ps : permissionSets)
            permissionIdByNameMap.put(ps.Name, ps.Id);
        List<User> users = [
            SELECT Id, ContactId, (SELECT Id, PermissionSet.Name FROM PermissionSetAssignments)
            FROM User
            WHERE ContactId IN :contactPermissionsMap.keySet() AND IsActive = TRUE
        ];
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        for (User user : users) {
            Set<String> currentPermissions = new Set<String>();
            for (PermissionSetAssignment psa : user.PermissionSetAssignments)
                currentPermissions.add(psa.PermissionSet.Name);
            Set<String> newPermissions = contactPermissionsMap.get(user.ContactId);
            for (String newPermission : newPermissions) {
                String permissionId = permissionIdByNameMap.get(newPermission);
                if (!currentPermissions.contains(newPermission) && permissionId != null) {
                    psaList.add(
                        new PermissionSetAssignment(
                            AssigneeId = user.Id,
                            PermissionSetId = permissionId
                        )
                    );
                }
            }
        }
        if (psaList.size() > 0)
            insert psaList;
    }
    @TestVisible
    private void deletePermissions() {
        List<User> users = [
            SELECT Id, ContactId, (SELECT Id, PermissionSet.Name FROM PermissionSetAssignments)
            FROM User
            WHERE ContactId IN :contactPermissionsToRemoveMap.keySet() AND IsActive = TRUE
        ];
        List<PermissionSetAssignment> psaRemoveList = new List<PermissionSetAssignment>();
        for (User user : users) {
            Set<String> permissionsToRemove = contactPermissionsToRemoveMap.get(user.ContactId);
            if (permissionsToRemove != null) {
                for (PermissionSetAssignment psa : user.PermissionSetAssignments) {
                    if (permissionsToRemove.contains(psa.PermissionSet.Name))
                        psaRemoveList.add(psa);
                }
            }
        }
        if (psaRemoveList.size() > 0)
            delete psaRemoveList;
    }
}
