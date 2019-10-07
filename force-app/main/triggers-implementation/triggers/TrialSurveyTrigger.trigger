/**
 * Created by Igor Malyuta on 19.06.2019.
 */

trigger TrialSurveyTrigger on Trial_Survey__c (before delete) {
    TriggerHandlerExecutor.execute(
            TrialSurveyTriggerHandler.ExpireSurveyTaskAndInvitations.class);
}