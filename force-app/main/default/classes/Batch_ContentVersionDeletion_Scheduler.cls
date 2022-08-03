/**
 * Test class for scheduling batch class of deleting PI bulk import error files which are more than 6 months old.
*/

global class Batch_ContentVersionDeletion_Scheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        Batch_ContentVersionDeletion batchObj = new Batch_ContentVersionDeletion();
        Database.executeBatch(batchObj,200);
     }
}