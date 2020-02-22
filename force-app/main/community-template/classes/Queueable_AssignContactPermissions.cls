/**
 * Created by Leonid Bartenev
 */

public without sharing class Queueable_AssignContactPermissions implements Queueable{
    private Map<Id, Set<String>> contactPermissionsMap = new Map<Id, Set<String>>();
    private Map<Id, Set<String>> contactPermissionsToRemoveMap = new Map<Id, Set<String>>();
    
    public Queueable_AssignContactPermissions(Map<Id, Set<String>> participantPermissionsMap, Map<Id, Set<String>> contactPermissionsToRemoveMap){
        this.contactPermissionsMap = participantPermissionsMap;
        this.contactPermissionsToRemoveMap = contactPermissionsToRemoveMap;
    }
    
    public void execute(QueueableContext qc) {
        deletePermissions();
        insertPermissions();
    }
    
    private void insertPermissions(){
        // all permission sets:
        Map<String, Id> permissionIdByNameMap = new Map<String, Id>();
        List<PermissionSet> permissionSets = [SELECT Id, Name FROM PermissionSet];
        for(PermissionSet ps : permissionSets) permissionIdByNameMap.put(ps.Name, ps.Id);
        List<User> users = [
                SELECT Id, ContactId, (SELECT Id, PermissionSet.Name FROM PermissionSetAssignments)
                FROM User WHERE ContactId IN: contactPermissionsMap.keySet()
        ];
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        for(User user : users){
            Set<String> currentPermissions = new Set<String>();
            for(PermissionSetAssignment psa : user.PermissionSetAssignments) currentPermissions.add(psa.PermissionSet.Name);
            Set<String> newPermissions = contactPermissionsMap.get(user.ContactId);
            for(String newPermission : newPermissions){
                String permissionId = permissionIdByNameMap.get(newPermission);
                if(!currentPermissions.contains(newPermission) && permissionId != null){
                    psaList.add(new PermissionSetAssignment(
                            AssigneeId = user.Id,
                            PermissionSetId = permissionId
                    ));
                }
            }
        }
        insert psaList;
    }
    
    private void deletePermissions(){
        List<User> users = [
                SELECT Id, ContactId, (SELECT Id, PermissionSet.Name FROM PermissionSetAssignments)
                FROM User WHERE ContactId IN: contactPermissionsToRemoveMap.keySet()
        ];
        List<PermissionSetAssignment> psaRemoveList = new List<PermissionSetAssignment>();
        for(User user : users){
            Set<String> permissionsToRemove = contactPermissionsToRemoveMap.get(user.ContactId);
            if (permissionsToRemove != null) {
                for (PermissionSetAssignment psa : user.PermissionSetAssignments) {
                    if (permissionsToRemove.contains(psa.PermissionSet.Name)) psaRemoveList.add(psa);
                }
            }
        }
        if(psaRemoveList.size() > 0) delete psaRemoveList;
    }

}