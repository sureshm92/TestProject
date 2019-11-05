/**
 * Created by Yulia Yakushenkova on 10/9/2019.
 */

public with sharing class Batch_UpdateNotifyDateOldUsers implements Database.Batchable<SObject> {

    public List<Clinical_Trial_Profile__c> profiles;

    public Batch_UpdateNotifyDateOldUsers(List<Clinical_Trial_Profile__c> profiles) {
        this.profiles = profiles;
    }

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT Participant__r.Contact__c
                FROM Participant_Enrollment__c
                WHERE Clinical_Trial_Profile__c IN :profiles
        ]);
    }

    public void execute(Database.BatchableContext param1, List<Participant_Enrollment__c> enrollments) {
        List<Id> allContactIds = new List<Id>();
        for (Participant_Enrollment__c pe : enrollments) allContactIds.add(pe.Participant__r.Contact__c);

        List<Patient_Delegate__c> patientDelegates = [
                SELECT Participant__r.Contact__c, Contact__c
                FROM Patient_Delegate__c
                WHERE Participant__r.Contact__c IN :allContactIds
        ];
        Map<Id, List<Patient_Delegate__c>> participantIdsByDelegates = new Map<Id, List<Patient_Delegate__c>>();
        for (Patient_Delegate__c pd : patientDelegates) {
            allContactIds.add(pd.Contact__c);
            if (!participantIdsByDelegates.containsKey(pd.Participant__r.Contact__c)) {
                participantIdsByDelegates.put(pd.Participant__r.Contact__c, new List<Patient_Delegate__c>());
            }
            participantIdsByDelegates.get(pd.Participant__r.Contact__c).add(pd);
        }

        List<User> users = [
                SELECT
                        ContactId,
                        LastLoginDate
                FROM User
                WHERE ContactId IN :allContactIds
                AND LastLoginDate != NULL
        ];
        Map<Id, Datetime> lastLoginDateByContactIds = new Map<Id, Datetime>();
        for (User us : users) lastLoginDateByContactIds.put(us.ContactId, us.LastLoginDate);

        List<Contact> contactsForUpdate = new List<Contact>();
        Map<Id, List<Participant_Enrollment__c>> enrollmentsByContactIds = getAllPEByContactIds(new List<Id>(participantIdsByDelegates.keySet()));
        for (Id participantContactId : participantIdsByDelegates.keySet()) {
            List<Decimal> minDays = new List<Decimal>();

            for (Participant_Enrollment__c pe : enrollmentsByContactIds.get(participantContactId)) {
                if (pe.Clinical_Trial_Profile__r.Logged_Out_Days_Notification__c == null) {
                    continue;
                } else {
                    minDays.add(pe.Clinical_Trial_Profile__r.Logged_Out_Days_Notification__c);
                }
            }
            if(minDays.isEmpty()) return;
            minDays.sort();
            Integer minDay = (Integer) minDays[0];

            Datetime lastLoginDateForParticipant = lastLoginDateByContactIds.get(participantContactId);
            Date nextNotifyDate = lastLoginDateForParticipant.addDays(minDay).date();
            if (Date.today().daysBetween(nextNotifyDate) < 0)  nextNotifyDate = Date.today().addDays(minDay);
                contactsForUpdate.add(new Contact(
                        Id = participantContactId,
                        Next_Notify_Date__c = nextNotifyDate
                ));

            for (Patient_Delegate__c pd : participantIdsByDelegates.get(participantContactId)) {
                Datetime lastLoginDateForDelegate = lastLoginDateByContactIds.get(pd.Contact__c);
                if(lastLoginDateForDelegate == null) continue;
                Date nextNotifyDateDelegate = lastLoginDateForDelegate.addDays(minDay).date();
                if (Date.today().daysBetween(nextNotifyDateDelegate) < 0)  nextNotifyDateDelegate = Date.today().addDays(minDay);
                contactsForUpdate.add(new Contact(
                        Id = pd.Contact__c,
                        Next_Notify_Date__c = nextNotifyDateDelegate
                ));
            }
        }
        update contactsForUpdate;
    }
    public static Map<Id, List<Participant_Enrollment__c>> getAllPEByContactIds(List<Id> cntId) {
        Map<Id, List<Participant_Enrollment__c>> enrollmentsByContactIds = new Map<Id, List<Participant_Enrollment__c>>();
        List<Participant_Enrollment__c> enrollments = [
                SELECT Clinical_Trial_Profile__r.Logged_Out_Days_Notification__c,
                        Participant__r.Contact__c
                FROM Participant_Enrollment__c
                WHERE Participant_Contact__c = :cntId
        ];
        for (Participant_Enrollment__c pe : enrollments) {
            if (!enrollmentsByContactIds.containsKey(pe.Participant__r.Contact__c)) {
                enrollmentsByContactIds.put(pe.Participant__r.Contact__c, new List<Participant_Enrollment__c>());
            }
            enrollmentsByContactIds.get(pe.Participant__r.Contact__c).add(pe);
        }
        return enrollmentsByContactIds;
    }

    public void finish(Database.BatchableContext param1) {
    }


}