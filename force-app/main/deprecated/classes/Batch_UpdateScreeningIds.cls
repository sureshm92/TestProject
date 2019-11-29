/**
 * Created by Denis Z
 */

public class Batch_UpdateScreeningIds implements Database.Batchable<SObject>{

    private String query;

    public Batch_UpdateScreeningIds(String query){
        this.query = query;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> records) {
        //PSEService.updateExternalKey((List<Participant_Enrollment__c>) records, null);
    }

    public void finish(Database.BatchableContext bc) {}

    public static void run(){
        Database.executeBatch(new Batch_UpdateScreeningIds('SELECT Id, Screening_ID__c FROM Participant_Enrollment__c'), 50);
    }


}