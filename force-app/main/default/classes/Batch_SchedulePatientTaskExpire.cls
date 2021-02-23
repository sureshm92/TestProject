global class Batch_SchedulePatientTaskExpire implements Schedulable {
    global void execute(SchedulableContext sc) {
        Batch_PatientTaskExpire objPtr = new Batch_PatientTaskExpire(); 
        database.executebatch(objPtr);
    }
}