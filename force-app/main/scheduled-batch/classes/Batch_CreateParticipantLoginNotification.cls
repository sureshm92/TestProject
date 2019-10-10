/**
 * Created by Julia Kazakevich on 18-Sep-19.
 */

public without sharing class Batch_CreateParticipantLoginNotification extends Batch_ScheduledAbstract {
    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT Id, Next_Notify_Date__c, Participant_Opt_In_Status_Emails__c
                FROM Contact
        ]);
    }

    public void execute(Database.BatchableContext param1, List<Contact> contacts) {
        List<Id> contactIds = new List<Id>();
        List<Contact> listOfContactEmails = new List<Contact>();

        for (Contact con : contacts) {
            if (con.Next_Notify_Date__c == Date.today() & con.Participant_Opt_In_Status_Emails__c == false) {
                contactIds.add(con.Id);
                listOfContactEmails.add(con);
            }
        }
        System.debug('contactIds' + JSON.serialize(contacts));
        if (contactIds != null) {
            Map<Id, List<Id>> availablePE = PatientDelegateService.getAvailablePEIdsListByContactIdMap(contactIds);
            List<Participant_Enrollment__c> peList = [
                    SELECT Participant_Contact__c, Clinical_Trial_Profile__r.Logged_Out_Days_Notification__c
                    FROM Participant_Enrollment__c
                    WHERE Participant_Contact__c IN :availablePE.keySet()
            ];
            List<Contact> contactsForUpdate = new List<Contact>();
            for (Id contId : availablePE.keySet()) {
                List<Decimal> minDays = new List<Decimal>();
                Decimal dayForNotify;
                for (Participant_Enrollment__c pe : peList) {
                    if (contId == pe.Participant_Contact__c) {
                        minDays.add(pe.Clinical_Trial_Profile__r.Logged_Out_Days_Notification__c);
                    }
                }
                minDays.sort();
                contactsForUpdate.add(new Contact(Id = contId, Next_Notify_Date__c = Date.today().addDays((Integer) minDays[0])));
            }
            update contactsForUpdate;
        }

        if (!listOfContactEmails.isEmpty()) {
            SendEmailToParticipant.sendParticipantLoginNotification(listOfContactEmails, false);
        }
    }

    public override Type getType() {
        return Batch_CreateParticipantLoginNotification.class;
    }


}