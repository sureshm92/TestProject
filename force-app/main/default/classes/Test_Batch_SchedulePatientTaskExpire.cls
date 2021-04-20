@isTest
public class Test_Batch_SchedulePatientTaskExpire {
@isTest 
    static void executeTest(){
        
        SchedulableContext sc = null;
        Batch_SchedulePatientTaskExpire tsc = new Batch_SchedulePatientTaskExpire();
        tsc.execute(sc);
         
    }  
}