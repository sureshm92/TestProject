public class BatchQueueableforAdminTasks implements Queueable {
    private Map<Id, List<Id>> contactsWithWhatIds;
    private TaskService.TaskConfig adminTask;
    private Map<id,String> IdTypeOfContactMap;
    private Map<id,List<Id>> parPdeListofPeMap;
    private Boolean isPlatformLevel;
   
   public BatchQueueableforAdminTasks( Map<Id, List<Id>> contactsWithWhatIds,
       TaskService.TaskConfig adminTask,
       Map<id,String> IdTypeOfContactMap,
       Map<id,List<Id>> parPdeListofPeMap,
       Boolean isPlatformLevel) 
   {
       this.contactsWithWhatIds = contactsWithWhatIds;
       this.adminTask = adminTask;    
       this.IdTypeOfContactMap = IdTypeOfContactMap;
       this.parPdeListofPeMap = parPdeListofPeMap;    
       this.isPlatformLevel = isPlatformLevel;
   }
   public void execute(QueueableContext context){
       try{
           Batch_CreateAdminTasks.launch(contactsWithWhatIds, adminTask, IdTypeOfContactMap,parPdeListofPeMap,isPlatformLevel);
       }
       catch(Exception e) {
           System.debug(e);
       }
   }
}