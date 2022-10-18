/**
 * Created by Leonid Bartenev
 */

trigger ParticipantTrigger on Participant__c(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    //TriggerHandlerExecutor.execute(ParticipantTriggerHandler.CheckDuplicatesHandler.class);
    TriggerHandlerExecutor.execute(ParticipantTriggerHandler.PrepareCityStateFieldsHandler.class);
    TriggerHandlerExecutor.execute(
        ParticipantTriggerHandler.CreateContactsForParticipantsHandler.class
    );
    TriggerHandlerExecutor.execute(
        ParticipantTriggerHandler.UpdateContactDetailsFromParticipant.class
    );
    TriggerHandlerExecutor.execute(ParticipantTriggerHandler.CheckBecomesAdultHandler.class);
    TriggerHandlerExecutor.execute(
        ParticipantTriggerHandler.UpdatePEAndContactLastNameHandler.class
    );
    TriggerHandlerExecutor.execute(
        ParticipantTriggerHandler.ChangeUserEmailOnParticipantEmailChangeHandler.class
    );
    TriggerHandlerExecutor.execute(ParticipantTriggerHandler.UpdateDOBDetails.class);
    TriggerHandlerExecutor.execute(ParticipantTriggerHandler.UpdateNameOnPE.class);
    TriggerHandlerExecutor.execute(ParticipantTriggerHandler.UpdateParticipantAge.class);
}