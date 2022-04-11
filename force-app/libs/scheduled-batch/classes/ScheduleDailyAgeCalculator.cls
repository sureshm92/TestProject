public  class ScheduleDailyAgeCalculator implements Schedulable{
    public void execute(SchedulableContext ctx){
      Batch_UpdateAgeOfParticipantsBDayToday batch = new Batch_UpdateAgeOfParticipantsBDayToday();
      Database.executebatch(batch, 200);
    }
}