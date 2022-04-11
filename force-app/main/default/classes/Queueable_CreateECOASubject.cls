public class Queueable_CreateECOASubject implements Queueable {
    Set<Id> recordids;
    public Queueable_CreateECOASubject(Set<Id> recordIds) {
        this.recordIds = recordIds;
    }
    public void execute(QueueableContext context) {
        // Do something here
        if (!this.recordids.isEmpty()) {
            ParticipantEnrollmentTriggerHandler.perTriggerEcoaEventAsync(recordIds);
        }
    }
}
