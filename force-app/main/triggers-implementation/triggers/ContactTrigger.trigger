/**
 * Created by D.Yasinskyi on 05.05.2018
 * Refacored by Leonid Bartenev
 */

trigger ContactTrigger on Contact(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    if (UserInfo.getUserName() != Label.UserName) {
        TriggerHandlerExecutor.execute(
            ContactTriggerHandler.UpdateParticipantAndUserEmailsOnEmailChangeHandler.class
        );
        /*For Welcome Msg -- Added by Anitha Start*/
        TriggerHandlerExecutor.execute(
            ContactTriggerHandler.createNotificationsHandler.class
        );
        
        TriggerHandlerExecutor.execute(
            ContactTriggerHandler.CreateUserForDelegateContactHandler.class
        );
        TriggerHandlerExecutor.execute(ContactTriggerHandler.SetShowTourDefaultHandler.class);
        TriggerHandlerExecutor.execute(ContactTriggerHandler.PopulateOverrideFields.class);
        TriggerHandlerExecutor.execute(ContactTriggerHandler.CreateUserForCCContactHandler.class);
        TriggerHandlerExecutor.execute(ContactTriggerHandler.UpdateParticipantDetailsHandler.class);
        TriggerHandlerExecutor.execute(
            ContactTriggerHandler.UpdatePhoneNumberContactsHandler.class
        );
        //Timestamp should not be bypassed when consents are changed
        TriggerHandlerExecutor.execute(ContactTriggerHandler.ParticipantConsentUpdate.class);
        TriggerHandlerExecutor.execute(ContactTriggerHandler.UpdateConsentTimeStamps.class);
    }
}