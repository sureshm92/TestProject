/**
 * Created by Julia Kazakevich on 18-Sep-19.
 */

public without sharing class Batch_CreateParticipantLoginNotification extends Batch_ScheduledAbstract{
    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT  Id,
                        Participating_in_Patient_Portal__c,
                        Patient_Portal_Enabled__c,
                        Logged_Out_Days_Notification__c
                FROM Clinical_Trial_Profile__c
                WHERE Participating_in_Patient_Portal__c = 'Yes'
        ]);
    }

    public void execute(Database.BatchableContext param1, List<Clinical_Trial_Profile__c> studies) {
        Set<Id> setOfStudyIds = new Set<Id>();
        Map<Id, Decimal> mapOfContactDays = new Map<Id, Decimal>();
        List<Contact> listOfContactEmails = new List<Contact>();
        DateTime currentTime = DateTime.now();
        Date currentDateTime = Date.newinstance(currentTime.year(), currentTime.month(), currentTime.day());

        for(Clinical_Trial_Profile__c study : studies){
            setOfStudyIds.add(study.Id);
        }
        List<Participant_Enrollment__c> enrollments = [
                SELECT
                        Id,
                        Clinical_Trial_Profile__c,
                        Days_After_Enrolled__c,
                        Participant_Contact__c,
                        Participant_Contact__r.Language__c,
                        Participant_Contact__r.Participant_Opt_In_Status_Emails__c,
                        Participant_Contact__r.Resource_Notifications__c,
                        Participant_Status__c
                FROM Participant_Enrollment__c
                WHERE Clinical_Trial_Profile__c IN: setOfStudyIds
                AND (Participant_Status__c !=: PSEService.PSE_STATUS_PARTICIPATION_COMPLETE AND Participant_Status__c !=: PSEService.PSE_STATUS_DROP_OUT)
        ];


        for(Participant_Enrollment__c enrollment: enrollments){
            List<Contact> peContacts = new List<Contact>();
            if(enrollment.Participant_Contact__c != null){
                peContacts.addAll(PatientDelegateService.getDelegateContacts(enrollment.Participant_Contact__c));
                for(Clinical_Trial_Profile__c study : studies){
                    if(enrollment.Clinical_Trial_Profile__c == study.Id){
                        if(study.Logged_Out_Days_Notification__c != null){
                            mapOfContactDays.put(enrollment.Participant_Contact__c, study.Logged_Out_Days_Notification__c);
                            for(Contact contactDelegate : peContacts){
                                mapOfContactDays.put(contactDelegate.Id, study.Logged_Out_Days_Notification__c);
                            }
                        }
                    }
                }
            }
        }

        for(User userObj: [SELECT  Id, ContactId, LastLoginDate, CreatedDate FROM User WHERE ContactId IN: mapOfContactDays.keySet()]){
            if(userObj.LastLoginDate != null){
                Decimal timeDifference = currentDateTime.daysBetween(Date.newinstance(userObj.LastLoginDate.year(), userObj.LastLoginDate.month(), userObj.LastLoginDate.day()));
                if(mapOfContactDays.get(userObj.ContactId) <= timeDifference){
                    listOfContactEmails.add([SELECT Id, Participant_Opt_In_Status_Emails__c FROM Contact WHERE Id =: userObj.ContactId LIMIT 1]);
                }
            }
        }

        if(!listOfContactEmails.isEmpty()) {
            SendEmailToParticipant.sendParticipantLoginNotification(listOfContactEmails, false);
        }
    }

    public override Type getType() {
        return Batch_CreateParticipantLoginNotification.class;
    }
}