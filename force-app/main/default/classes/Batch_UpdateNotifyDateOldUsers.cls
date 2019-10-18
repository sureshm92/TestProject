/**
 * Created by Yulia Yakushenkova on 10/9/2019.
 */

public with sharing class Batch_UpdateNotifyDateOldUsers implements Database.Batchable<SObject>{

    public void execute(Database.BatchableContext param1, List<Contact> contacts) {
        List<Id> cntIds = new List<Id>();
        for(Contact cnt : contacts) cntIds.add(cnt.Id);
        update ContactService.updateNextNotifyDate(cntIds);
    }

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([SELECT Id FROM Contact WHERE Next_Notify_Date__c = NULL]);
    }

    public void finish(Database.BatchableContext param1) {

    }

    public static void run(){
        Database.executeBatch(new Batch_UpdateNotifyDateOldUsers());
    }
}