global without sharing class Batch_RHPEUpdateParticipant_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Batch_RHPEUpdateParticipantStatus b = new Batch_RHPEUpdateParticipantStatus();
        database.executebatch(b);
    }
}
