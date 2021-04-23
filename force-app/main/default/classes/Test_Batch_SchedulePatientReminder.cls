@isTest
public class Test_Batch_SchedulePatientReminder {
    
    @isTest 
    static void executeTest(){
        
        SchedulableContext sc = null;
        Batch_SchedulePatientTaskReminder tsc = new Batch_SchedulePatientTaskReminder();
        tsc.execute(sc);
         
    }  
    
}