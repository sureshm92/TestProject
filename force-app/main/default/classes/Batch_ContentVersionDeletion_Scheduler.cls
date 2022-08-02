global class Batch_ContentVersionDeletion_Scheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        Batch_ContentVersionDeletion batchObj = new Batch_ContentVersionDeletion();
        Database.executeBatch(batchObj,200);
     }
}