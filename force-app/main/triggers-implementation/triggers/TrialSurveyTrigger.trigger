/**
 * Created by Igor Malyuta on 19.06.2019.
 */

trigger TrialSurveyTrigger on Trial_Survey__c(
before insert,
before update,
before delete,
after update) {
    TriggerHandlerExecutor.execute(TrialSurveyTriggerHandler.ExpireSurveyTaskAndInvitations.class);
    TriggerHandlerExecutor.execute(TrialSurveyTriggerHandler.UpdateTrialSurveyAndInvitations.class);
}
