/**
 * Created by Leonid Bartenev
 */

public without sharing class Action_AssignContactPermissions implements Action{
    
    private Map<Id, Set<String>> contactPermissionsMap = new Map<Id, Set<String>>();
    private Map<Id, Set<String>> contactPermissionsToRemoveMap = new Map<Id, Set<String>>();
    
    public void addPermission(Id contactId, String permissionSet){
        Set<String> permissions = contactPermissionsMap.get(contactId);
        if(permissions == null) permissions = new Set<String>();
        permissions.add(permissionSet);
        contactPermissionsMap.put(contactId, permissions);
    }
    
    public void addPermissions(Id contactId, Set<String> permissionSets){
        for(String permission : permissionSets) addPermission(contactId, permission);
    }
    
    public void deletePermission(Id contactId, String permissionSet){
        Set<String> permissions = contactPermissionsToRemoveMap.get(contactId);
        if(permissions == null) permissions = new Set<String>();
        permissions.add(permissionSet);
        contactPermissionsToRemoveMap.put(contactId, permissions);
    }
    
    public void deletePermissions(Id contactId, Set<String> permissionSets){
        for(String permission : permissionSets) deletePermission(contactId, permission);
    }
    
    public Boolean isEmpty(){
        return contactPermissionsMap.isEmpty() && contactPermissionsToRemoveMap.isEmpty();
    }
    
    
    public void execute() {
        System.enqueueJob(new Queueable_AssignContactPermissions(contactPermissionsMap, contactPermissionsToRemoveMap));
    }
    
    public Type getType() {
        return Action_AssignContactPermissions.class;
    }

}