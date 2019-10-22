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
        List<Id> cntIds = new List<Id>();
        for (Contact cnt : contacts) cntIds.add(cnt.Id);
        List<String> exclPEStatuses = new List<String>{
                PEStatusState.PE_STATUS_DROP_OUT,
                PEStatusState.PE_STATUS_TRIAL_COMPLETE
        };
        Map<Id, List<Id>> availablePE = PatientDelegateService.getForExclStatusPEIdsListByContactIdMap(cntIds, exclPEStatuses);
        List<Participant_Enrollment__c> peList = [
                SELECT Id, Participant_Contact__c
                FROM Participant_Enrollment__c
                WHERE Participant_Contact__c IN :availablePE.keySet() AND Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = TRUE
        ];

        List <Id> listContactIds = new List <Id>();

        for (Participant_Enrollment__c pe : peList) {
            listContactIds.add(pe.Participant_Contact__c);
        }

        List <Contact> contactList = [
                SELECT Id, Next_Notify_Date__c, Participant_Opt_In_Status_Emails__c
                FROM Contact
                WHERE Id IN: listContactIds
        ];

        List<Contact> listOfContactEmails = new List<Contact>();
        for (Contact con : contactList) {
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