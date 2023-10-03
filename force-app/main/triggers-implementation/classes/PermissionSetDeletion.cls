public class PermissionSetDeletion implements Queueable {
    
    Public Set<Id> assigneeIds;
    public Boolean  create;
    
    public PermissionSetDeletion(Set<Id> contactIds,Boolean iscreate){
        this.assigneeIds = contactIds;
        this.create = iscreate;
    
    }
    
  public void execute(QueueableContext context) {
 
  List<PermissionSetAssignment> userPerSetAssignments = [
                SELECT
                    Id,
                    AssigneeId,
                    Assignee.ContactId,
                    PermissionSet.Name,
                    Assignee.TimeZoneSidKey
                FROM PermissionSetAssignment
                WHERE Assignee.contactId IN :assigneeIds AND PermissionSet.Name = 'Community_PP'
            ];   
             if(!userPerSetAssignments.isEmpty()){
                  delete userPerSetAssignments;
              }
      if(create){
          PermissionSet ps =[select Id from permissionSet where name = 'Community_PP'];
          List<user> users = [select Id,name from user where contactId IN: assigneeIds];
          List<PermissionSetAssignment> permissionstoinsert = new List<PermissionSetAssignment>();
          for(user u : users){
              permissionstoinsert.add(new PermissionSetAssignment(AssigneeId = u.id,PermissionSetId=ps.id));
          }
          if(!permissionstoinsert.isEmpty())
              insert permissionstoinsert;
      }
      
 
 }

}