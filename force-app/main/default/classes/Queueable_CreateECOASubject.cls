public class Queueable_CreateECOASubject implements Queueable, Database.AllowsCallouts {
    Set<Id> recordids;
    public Queueable_CreateECOASubject(Set<Id> recordIds) {
        this.recordIds = recordIds;
    }
    public void execute(QueueableContext context) {
        // Do something here
        List<Id> recordIdslst = new List<Id>();
        Set<Id> recrdtoPrcessset = new Set<Id>();
        recordIdslst.addAll(recordIds); // Added to List since Set is an unordered Collection
        integer counter = 0;
        if (!recordIdslst.isEmpty()) {
            while (counter < 200 && counter < recordIdslst.size()) {
                // Proccessing each 200 records
                recrdtoPrcessset.add(recordIdslst[counter++]); // Added to Set to process 200 records
            }
        }
        if (!recrdtoPrcessset.isEmpty()) {
            ParticipantEnrollmentTriggerHandler.perTriggerEcoaEventAsync(recordIds);
        }
        recordIds.removeAll(recrdtoPrcessset); // Removed processed 200 records from the main set
        recordIdslst.clear();
        recrdtoPrcessset.clear();
        if (!this.recordIds.isEmpty()) {
            System.enqueueJob(new Queueable_CreateECOASubject(recordIds));
        }
    }
}
