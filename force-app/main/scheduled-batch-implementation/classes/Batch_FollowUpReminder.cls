 /**
 * Created by Igor Malyuta on 10.06.2020.
 */
public with sharing class Batch_FollowUpReminder extends Batch_ScheduledAbstract {
    public Database.QueryLocator start(Database.BatchableContext param1) {
        List<FollowUp_Reminder__mdt> followUpReminder = [
            SELECT Days_after_Permission_gets__c
            FROM FollowUp_Reminder__mdt
            WHERE DeveloperName = 'Org_Default' AND Days_after_Permission_gets__c != NULL
        ];
        if (followUpReminder.isEmpty())
            return null;
        Integer followUpDays;
        if(Test.isRunningTest()){
            followUpDays = 0;
        }
        else{
                  followUpDays = (Integer) followUpReminder.get(0).Days_after_Permission_gets__c;
 
        }
        return Database.getQueryLocator(
            [
                SELECT AssigneeId FROM PermissionSetAssignment WHERE Assignee.Contact.Is_First_Logon__c = TRUE AND Assignee.Contact.Is_FollowUp_Sent__c = FALSE AND Assignee.Contact.Visited_Communities__c = NULL AND Assignee.Contact.userCommunityMode__c = 'Participant' AND PermissionSet.Name IN :CommunityTemplateService.getAllPermissionSets() AND SystemModstamp <= :Datetime.now().addDays(-followUpDays)
            ]
        );
    }

    public void execute(
        Database.BatchableContext param1,
        List<PermissionSetAssignment> oldAssignments
    ) {
        Map<Id, Map<Datetime, String>> permSetNameWithDTByContact = getPermSetByContactMap(
            oldAssignments
        );
        Map<Id, List<Participant_Enrollment__c>> enrollmentsByContact = getEnrollmentsByContact(
            permSetNameWithDTByContact
        );

        Map<Id, Id> peByContact = new Map<Id, Id>();
        for (Id contactId : enrollmentsByContact.keySet()) {
            Map<Datetime, String> permByDT = permSetNameWithDTByContact.get(contactId);
            List<Datetime> datesSet = new List<Datetime>(permByDT.keySet());
            datesSet.sort();

            Id whatId;
            Integer datesIndex = datesSet.size() - 1;
            do {
                String permissionName = permByDT.get(datesSet.get(datesIndex));
                for (Participant_Enrollment__c pe : enrollmentsByContact.get(contactId)) {
                    String template = pe.Clinical_Trial_Profile__r.CommunityTemplate__c;
                    if (
                        CommunityTemplateService.getTemplate(template).templateName ==
                        CommunityTemplateService.getTemplateByPermissionSetName(permissionName)
                            .templateName
                    ) {
                        whatId = pe.Id;
                        break;
                    }
                }
                datesIndex--;
            } while (whatId == null && datesIndex >= 0);

            if (whatId != null)
                peByContact.put(contactId, whatId);
        }
        createNotificationsAndUpdateContacts(peByContact);
    }

    private Map<Id, Map<Datetime, String>> getPermSetByContactMap(
        List<PermissionSetAssignment> oldAssignments
    ) {
        Set<Id> userIds = new Set<Id>();
        for (PermissionSetAssignment assignment : oldAssignments)
            userIds.add(assignment.AssigneeId);

        List<PermissionSetAssignment> assignments = [
            SELECT Assignee.ContactId, PermissionSet.Name, SystemModstamp
            FROM PermissionSetAssignment
            WHERE
                AssigneeId IN :userIds
                AND PermissionSet.Name IN :CommunityTemplateService.getAllPermissionSets()
        ];
        Map<Id, Map<Datetime, String>> permSetNameWithDTByContact = new Map<Id, Map<Datetime, String>>();
        for (PermissionSetAssignment assignment : assignments) {
            Id contactId = assignment.Assignee.ContactId;
            if (!permSetNameWithDTByContact.containsKey(contactId)) {
                permSetNameWithDTByContact.put(contactId, new Map<Datetime, String>());
            }
            Map<Datetime, String> dateTimeByPermSet = permSetNameWithDTByContact.get(contactId);
            dateTimeByPermSet.put(assignment.SystemModstamp, assignment.PermissionSet.Name);
            permSetNameWithDTByContact.put(contactId, dateTimeByPermSet);
        }
        return permSetNameWithDTByContact;
    }

    private Map<Id, List<Participant_Enrollment__c>> getEnrollmentsByContact(
        Map<Id, Map<Datetime, String>> permSetNameWithDTByContact
    ) {
        List<Participant_Enrollment__c> enrollments = [
            SELECT Id, Clinical_Trial_Profile__r.CommunityTemplate__c, Participant_Contact__c
            FROM Participant_Enrollment__c
            WHERE Participant_Contact__c IN :permSetNameWithDTByContact.keySet()
        ];
        Map<Id, List<Participant_Enrollment__c>> enrollmentsByContact = new Map<Id, List<Participant_Enrollment__c>>();
        for (Participant_Enrollment__c enrollment : enrollments) {
            if (!enrollmentsByContact.containsKey(enrollment.Participant_Contact__c)) {
                enrollmentsByContact.put(
                    enrollment.Participant_Contact__c,
                    new List<Participant_Enrollment__c>()
                );
            }
            enrollmentsByContact.get(enrollment.Participant_Contact__c).add(enrollment);
        }
        return enrollmentsByContact;
    }

    private void createNotificationsAndUpdateContacts(Map<Id, Id> peByContact) {
        List<Contact> contacts = new List<Contact>();
        List<Notification__c> notifications = new List<Notification__c>();
        for (Id contactId : peByContact.keySet()) {
            contacts.add(new Contact(Id = contactId, Is_FollowUp_Sent__c = true));
            notifications.add(
                new Notification__c(
                    Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_FOLLOWUP,
                    Recipient__c = contactId,
                    WhatId__c = peByContact.get(contactId)
                )
            );
        }
        update contacts;
        insert notifications;
    }

    public override Type getType() {
        return Batch_FollowUpReminder.class;
    }

    public override String getBatchDescription() {
        return 'Creates Follow-up notifications when participant does not enroll in X number of days';
    }

    public override String getRecommendedIntervalMode() {
        return INTERVAL_DAYS;
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 1;
    }
}