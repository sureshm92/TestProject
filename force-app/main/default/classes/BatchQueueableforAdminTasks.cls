public class BatchQueueableforAdminTasks implements Queueable {
     private Map<Id, List<Id>> contactsWithWhatIds;
     private TaskService.TaskConfig adminTask;
     private Map<id,String> IdTypeOfContactMap;
	public BatchQueueableforAdminTasks( Map<Id, List<Id>> contactsWithWhatIds,
        TaskService.TaskConfig adminTask,
        Map<id,String> IdTypeOfContactMap){
        this.contactsWithWhatIds = contactsWithWhatIds;
        this.adminTask = adminTask;    
        this.IdTypeOfContactMap = IdTypeOfContactMap;
    }
    public void execute(QueueableContext context){
        try{
            Batch_CreateAdminTasks.launch(contactsWithWhatIds, adminTask, IdTypeOfContactMap);
        }
        catch(Exception e) {
            System.debug(e);
        }
    }
}