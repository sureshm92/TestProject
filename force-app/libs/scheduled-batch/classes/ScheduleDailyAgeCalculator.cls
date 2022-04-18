/*
 * This class is scheduled from setup to run once everyday
 */
public  class ScheduleDailyAgeCalculator implements Schedulable{
    public void execute(SchedulableContext ctx){
      //call to batch running to update age of participants
      Batch_UpdateAgeOfParticipantsBDayToday batch = new Batch_UpdateAgeOfParticipantsBDayToday();
      Database.executebatch(batch, 200);
    }
}