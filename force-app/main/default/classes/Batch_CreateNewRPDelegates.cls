/**
* Created by Nikita Abrazhevitch on 14-Aug-19.
*/
public without sharing class Batch_CreateNewRPDelegates implements Database.Batchable<sObject>, Database.Stateful {
    private String query = 'SELECT Id, HCP_Enrollment__r.HCP_Contact__c, Contact__c, Delegate_Level__c FROM Referring_HCP_Staff__c';
    private Set<String> insertedRecords = new Set<String>();
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
    public void execute (Database.BatchableContext bc, List<sObject> records){
        List<RP_Delegate_Relationship__c> newRPDelegatesList = new List<RP_Delegate_Relationship__c>();
        for(Referring_HCP_Staff__c newDelegate : (List<Referring_HCP_Staff__c>) records){
            if(!insertedRecords.contains(newDelegate.HCP_Enrollment__r.HCP_Contact__c + '' + newDelegate.Contact__c)){
                newRPDelegatesList.add(new RP_Delegate_Relationship__c( Delegate__c = newDelegate.Contact__c,
                        Delegate_Access_Level__c = newDelegate.Delegate_Level__c,
                        Referring_Provider__c = newDelegate.HCP_Enrollment__r.HCP_Contact__c));
                insertedRecords.add(newDelegate.HCP_Enrollment__r.HCP_Contact__c + '' + newDelegate.Contact__c);
            }
        }
        delete records;
        insert newRPDelegatesList;
    }
    public void finish (Database.BatchableContext bc){}
    public static void run(){
        Database.executeBatch(new Batch_CreateNewRPDelegates());
    }
}