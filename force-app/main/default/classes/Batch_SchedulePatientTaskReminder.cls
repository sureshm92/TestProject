global class Batch_SchedulePatientTaskReminder implements Schedulable {
    global void execute(SchedulableContext sc) {
        Batch_PatientTaskReminder objPtr = new Batch_PatientTaskReminder(); 
        database.executebatch(objPtr);
    }
}