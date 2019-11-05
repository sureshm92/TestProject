/**
 * Created by Julia Kazakevich on 19-Sep-19.
 * Refactored by Igor Malyuta on 27-Oct-19
 */

public without sharing class Batch_UserCreatedDateNotification extends Batch_ScheduledAbstract{

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT
                        ContactId,
                        Contact.Current_Participant_Enrollment__c,
                        Contact.Participant_Opt_In_Status_Emails__c,
                        Contact.Next_Profile_Update_DT__c
                FROM User
                WHERE Contact.Next_Profile_Update_DT__c <=: Datetime.now()
                AND Contact.userCommunityMode__c =: CommunityService.USER_MODE_PARTICIPANT
                AND Contact.Current_Participant_Enrollment__c != NULL
                AND IsActive = TRUE
        ]);
    }

    public void execute(Database.BatchableContext param1, List<User> users) {
        List<Contact> contactsToBeNotified = new List<Contact>();
        for(User user: users) contactsToBeNotified.add(user.Contact);

        if(!contactsToBeNotified.isEmpty()) {
            SendEmailToParticipant.sendParticipantLoginNotification(contactsToBeNotified, true);
            for(Contact contactObj : contactsToBeNotified){
                if(contactObj.Next_Profile_Update_DT__c != null) {
                    contactObj.Next_Profile_Update_DT__c = Datetime.now().addYears(1);
                }
            }
            update contactsToBeNotified;
        }
    }

    public override Type getType() {
        return Batch_UserCreatedDateNotification.class;
    }
}