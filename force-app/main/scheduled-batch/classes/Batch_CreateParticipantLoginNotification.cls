/**
 * Created by Julia Kazakevich on 18-Sep-19.
 * Refactored by Igor Malyuta on 27-Oct-19
 */

public without sharing class Batch_CreateParticipantLoginNotification extends Batch_ScheduledAbstract {
    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT
                        Id,
                        Current_Participant_Enrollment__c,
                        Next_Notify_Date__c,
                        Participant_Opt_In_Status_Emails__c
                FROM Contact
                WHERE Next_Notify_Date__c <=: Datetime.now().dateGmt()
                AND Participant_Opt_In_Status_Emails__c = TRUE
                AND Current_Participant_Enrollment__c != NULL
        ]);
    }

    public void execute(Database.BatchableContext param1, List<Contact> contacts) {
        List<Id> cntIds = new List<Id>();
        for (Contact cnt : contacts) cntIds.add(cnt.Id);
        Map<Id, Integer> conIdsAndNearestNotifyDate = ParticipantService.getNearestLogOutNotification(cntIds);

        List<Contact> listOfContactEmails = new List<Contact>();
        for(Contact cnt : contacts) {
            if(conIdsAndNearestNotifyDate.containsKey(cnt.Id)) {
                cnt.Next_Notify_Date__c = Datetime.now().addDays(conIdsAndNearestNotifyDate.get(cnt.Id)).dateGmt();
                listOfContactEmails.add(cnt);
            }
        }

        if (!listOfContactEmails.isEmpty()) {
            update listOfContactEmails;
            SendEmailToParticipant.sendParticipantLoginNotification(listOfContactEmails, false);
        }
    }

    public override Type getType() {
        return Batch_CreateParticipantLoginNotification.class;
    }
}