/**
 * Created by Yulia Yakushenkova on 10/9/2019.
 */

public with sharing class Batch_UpdateNotifyDateOldUsers implements Database.Batchable<SObject>{

    public void execute(Database.BatchableContext param1, List<Contact> contacts) {
        List<Id> cntIds = new List<Id>();
        for(Contact cnt : contacts) cntIds.add(cnt.Id);
        List<User> users = [SELECT ContactId, LastLoginDate FROM User WHERE ContactId IN :cntIds AND LastLoginDate != NULL];
        Map<Id, Datetime> lastLoginDateByContactIds = new Map<Id, Datetime>();
        for(User us : users) lastLoginDateByContactIds.put(us.ContactId, us.LastLoginDate);

        cntIds.clear();
        for(Id key : lastLoginDateByContactIds.keySet()) cntIds.add(key);
        if(!lastLoginDateByContactIds.isEmpty()) update ContactService.updateNextNotifyDate(cntIds, lastLoginDateByContactIds);
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