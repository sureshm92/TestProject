/**
 * Created by Denis Z on 14-Aug-19.
 */

public without sharing class Batch_AssignLanguagePreferences implements Database.Batchable<SObject> {

    private String query;

    public Batch_AssignLanguagePreferences(String query){
        this.query = query;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> records) {
        for(Participant__c participant : (List<Participant__c>)records){
            participant.Preferred_Language__c = LanguagePreferenceService.getLanguageCode(participant.Language_Preference_Code__c);
        }
        update records;
    }

    public void finish(Database.BatchableContext bc) {}

    public static void run(){
        Database.executeBatch(new Batch_AssignLanguagePreferences('SELECT Id, Preferred_Language__c, Language_Preference_Code__c FROM Participant__c WHERE Preferred_Language__c = null'), 200);
    }

}