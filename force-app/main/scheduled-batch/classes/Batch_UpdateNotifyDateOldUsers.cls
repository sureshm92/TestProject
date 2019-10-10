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
        Map<Id, List<Id>> availablePE = PatientDelegateService.getAvailablePEIdsListByContactIdMap(cntIds);
        List<Participant_Enrollment__c> peList = [
                SELECT Participant_Contact__c, Clinical_Trial_Profile__r.Logged_Out_Days_Notification__c
                FROM Participant_Enrollment__c
                WHERE Participant_Contact__c IN :availablePE.keySet()
        ];

        List<Contact> cnt = new List<Contact>();
        for(Id cntId : availablePE.keySet()){
            List<Decimal> minDays = new List<Decimal>();
            for(Participant_Enrollment__c pe : peList){
                if(cntId == pe.Participant_Contact__c) {
                    minDays.add(pe.Clinical_Trial_Profile__r.Logged_Out_Days_Notification__c);
                }
            }
            minDays.sort();
            cnt.add(new Contact(Id = cntId, Next_Notify_Date__c = Date.today().addDays((Integer) minDays[0])));
            System.debug('>>>>>> ' + Date.today().addDays((Integer) minDays[0]) + ' in ' + cntId);
        }
        update cnt;
    }

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([SELECT Id FROM Contact]);
    }
}