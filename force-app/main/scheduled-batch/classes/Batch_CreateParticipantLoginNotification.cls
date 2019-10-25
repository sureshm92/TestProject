/**
 * Created by Julia Kazakevich on 18-Sep-19.
 */

public without sharing class Batch_CreateParticipantLoginNotification extends Batch_ScheduledAbstract {
    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT Id, Next_Notify_Date__c, Participant_Opt_In_Status_Emails__c
                FROM Contact
                WHERE Next_Notify_Date__c <= TODAY AND Participant_Opt_In_Status_Emails__c = true
        ]);
    }

    public void execute(Database.BatchableContext param1, List<Contact> contacts) {

        List<Id> cntIds = new List<Id>();
        for (Contact cnt : contacts) cntIds.add(cnt.Id);
        Map<Id, Integer> conIdsAndNearestNotifyDate = ParticipantService.getNearestLogOutNotification(cntIds);

        List<Contact> listOfContactEmails = new List<Contact>();
        for (Id conId : conIdsAndNearestNotifyDate.keySet()) {
            listOfContactEmails.add(new Contact(Id = conId, Next_Notify_Date__c = Date.today() + conIdsAndNearestNotifyDate.get(conId)));
        }

        update listOfContactEmails;

        if (!listOfContactEmails.isEmpty()) {
            SendEmailToParticipant.sendParticipantLoginNotification(listOfContactEmails, false);
        }
    }

    public override Type getType() {
        return Batch_CreateParticipantLoginNotification.class;
    }


}