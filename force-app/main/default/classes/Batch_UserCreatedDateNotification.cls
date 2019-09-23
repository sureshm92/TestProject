/**
 * Created by Julia Kazakevich on 19-Sep-19.
 */

public without sharing class Batch_UserCreatedDateNotification extends Batch_ScheduledAbstract{
    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT  Id,
                        Name,
                        Contact__c,
                        Contact__r.Profile_Update_Years_Notification__c
                FROM Participant__c
        ]);
    }

    public void execute(Database.BatchableContext param1, List<Participant__c> participants) {
        List<Contact> contactsToBeNotified = new List<Contact>();
        Set<Id> setOfContactIds = new Set<Id>();
        DateTime currentTime = DateTime.now();
        Date currentDateTime = Date.newinstance(currentTime.year(), currentTime.month(), currentTime.day());

        for(Participant__c con : participants){
            setOfContactIds.add(con.Contact__c);
        }

        List<Contact> listOfPartContacts = [
                SELECT Id,
                        Profile_Update_Years_Notification__c,
                        Participant_Opt_In_Status_Emails__c
                FROM Contact
                WHERE Id IN: setOfContactIds
        ];

        List<User> particUsers = [
                SELECT  Id,
                        CreatedDate,
                        ContactId
                FROM User
                WHERE ContactId IN: setOfContactIds
        ];
        List<Contact> participantDelegateContacts = new List<Contact>();
        for(User userObj: particUsers){
            for(Contact contactObj : listOfPartContacts){
                if(currentDateTime == Date.newinstance(userObj.CreatedDate.year(), userObj.CreatedDate.month(), userObj.CreatedDate.day()).addYears(1)){
                    participantDelegateContacts.addAll(PatientDelegateService.getDelegateContacts(contactObj.Id));
                    if(contactObj.Id == userObj.ContactId){
                        contactsToBeNotified.add(contactObj);
                        break;
                    }
                    for(Contact partContact: participantDelegateContacts){
                        if(partContact.Id == userObj.ContactId){
                            contactsToBeNotified.add(contactObj);
                            break;
                        }
                    }
                }
            }
        }

        if(!contactsToBeNotified.isEmpty()) {
            SendEmailToParticipant.sendParticipantLoginNotification(contactsToBeNotified, true);
            for(Contact contactObj : contactsToBeNotified){
                if(contactObj.Profile_Update_Years_Notification__c == null){
                    contactObj.Profile_Update_Years_Notification__c = 1;
                } else{
                    contactObj.Profile_Update_Years_Notification__c++;
                }
            }
            update contactsToBeNotified;
        }
    }

    public override Type getType() {
        return Batch_UserCreatedDateNotification.class;
    }
}