/**
 * Created by Leonid Bartenev
 */

trigger PSEProcess on Participant_Study_Enrollment__c (before insert, before update, after insert, after update) {
    PSETriggerHandler.setDefaultFieldsBeforeUpsert();
    PSETriggerHandler.processStatusHistory();
    PSETriggerHandler.createCompleteBaselineSurveyTask();
    PSETriggerHandler.deactivateDeceasedUsers();
}