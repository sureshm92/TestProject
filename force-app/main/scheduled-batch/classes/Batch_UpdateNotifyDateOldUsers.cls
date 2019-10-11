/**
 * Created by Yulia Yakushenkova on 10/9/2019.
 */

public with sharing class Batch_UpdateNotifyDateOldUsers extends Batch_ScheduledAbstract {

    public override Type getType() {
        return Batch_UpdateNotifyDateOldUsers.class;
    }

    public void execute(Database.BatchableContext param1, List<Contact> contacts) {
        List<Id> cntIds = new List<Id>();
        for(Contact cnt : contacts) cntIds.add(cnt.Id);
        update ContactService.updateNextNotifyDate(cntIds);
    }

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([SELECT Id FROM Contact]);
    }
}