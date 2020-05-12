/**
 * Created by Dmitry Ivakhnenko on 28-Apr-20.
 */

public without sharing class Batch_UpdateVisitResultsOptIn implements Database.Batchable<SObject> {

    public Database.QueryLocator start (Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Visit_Results_Opt_In__c, Visit_Results_OptIn__c FROM Contact]);
    }

    public void execute(Database.BatchableContext bc, List<Contact> contacts) {
        for (Contact contact : contacts) {
            contact.Visit_Results_OptIn__c = contact.Visit_Results_Opt_In__c ? 'Vitals;Labs;Biomarkers' : null;
        }

        update contacts;
    }

    public void finish(Database.BatchableContext bc) {}

    public static void run() {
        run(false);
    }

    public static void run(Boolean overwriteData) {
        if (overwriteData || !isDataExistsAlready()) {
            Database.executeBatch(new Batch_UpdateVisitResultsOptIn(), 200);
        } else {
            throw new DataExistsException('\nData exists already in the \'Visit_Results_OptIn__c\' field.\n' +
                    'To overwrite this data execute \'Batch_UpdateVisitResultsOptIn.run(true);\'');
        }
    }

    private static Boolean isDataExistsAlready() {
        Integer rowsWithData = [SELECT COUNT() FROM Contact WHERE Visit_Results_OptIn__c != NULL];
        return rowsWithData != 0;
    }

    public class DataExistsException extends Exception {}
}