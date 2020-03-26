/**
 * Created by AlexKetch on 4/16/2019.
 */

trigger ClinicalTrialProfileTrigger on Clinical_Trial_Profile__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    TriggerHandlerExecutor.execute(ClinicalTrialProfileTriggerHandler.UpdateClinicalTrialProfile.class);
    TriggerHandlerExecutor.execute(CTPNotificationTriggerHandler.CreateNotificationHandler.class);
}