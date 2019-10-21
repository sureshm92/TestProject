/**
 * Created by Julia Kazakevich on 18-Sep-19.
 */

public without sharing class Batch_CreateParticipantLoginNotification extends Batch_ScheduledAbstract {
    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT Id, Next_Notify_Date__c, Participant_Opt_In_Status_Emails__c
                FROM Contact
                WHERE Next_Notify_Date__c != null
        ]);
    }

    public void execute(Database.BatchableContext param1, List<Contact> contacts) {
        List<Contact> listOfContactEmails = new List<Contact>();
        for (Contact con : contacts) {
            if (con.Next_Notify_Date__c == Date.today() & con.Participant_Opt_In_Status_Emails__c == true) {
                listOfContactEmails.add(con);
            }
        }

        if (!listOfContactEmails.isEmpty()) {
            SendEmailToParticipant.sendParticipantLoginNotification(listOfContactEmails, false);
        }
    }

    public override Type getType() {
        return Batch_CreateParticipantLoginNotification.class;
    }


}