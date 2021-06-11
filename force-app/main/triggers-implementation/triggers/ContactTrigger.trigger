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
    if(UserInfo.getUserName() != Label.UserName){
    TriggerHandlerExecutor.execute(
        ContactTriggerHandler.UpdateParticipantAndUserEmailsOnEmailChangeHandler.class
    );
    TriggerHandlerExecutor.execute(ContactTriggerHandler.CreateUserForDelegateContactHandler.class);
    TriggerHandlerExecutor.execute(ContactTriggerHandler.SetShowTourDefaultHandler.class);
    TriggerHandlerExecutor.execute(ContactTriggerHandler.PopulateOverrideFields.class);
    TriggerHandlerExecutor.execute(ContactTriggerHandler.CreateUserForCCContactHandler.class);
    TriggerHandlerExecutor.execute(ContactTriggerHandler.UpdateParticipantDetailsHandler.class);
    }
}
