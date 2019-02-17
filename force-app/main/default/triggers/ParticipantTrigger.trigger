/**
 * Created by Leonid Bartenev
 */

trigger ParticipantTrigger on Participant__c (before insert, before update, after insert, after update) {
    ParticipantTriggerHandler.prepareCityStateFieldsBeforeInsertOrUpdate();
    ParticipantTriggerHandler.createContactsForParticipantsBeforeInsert();
    ParticipantTriggerHandler.updatePEAndContactLastNameAfterInsert();
    ParticipantTriggerHandler.changeUserEmailOnParticipantEmailChange();
}