/**
 * Created by Alexey Moseev
 */
global without sharing class Batch_MigratePicklistToCheckbox implements Database.Batchable<SObject> {

    global Batch_MigratePicklistToCheckbox() {}

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id,
                Participating_in_Digital_Recruitment__c,
                Participating_in_Patient_Portal__c,
                Participating_in_Rocket_Referral__c,
                Patient_Portal_Enabled__c,
                Include_in_RP_trial_search__c,
                Synch_with_TMDH__c
        FROM Clinical_Trial_Profile__c
        WHERE Participating_in_Digital_Recruitment__c = 'Yes' OR
        Participating_in_Patient_Portal__c = 'Yes' OR
        Participating_in_Rocket_Referral__c = 'Yes']);
    }

    global void execute(Database.BatchableContext bc, List<Clinical_Trial_Profile__c> scope) {
        for (Clinical_Trial_Profile__c study : scope) {
            study.Patient_Portal_Enabled__c = study.Participating_in_Patient_Portal__c == 'Yes';
            study.Include_in_RP_trial_search__c = study.Participating_in_Rocket_Referral__c == 'Yes';
            study.Synch_with_TMDH__c = study.Participating_in_Digital_Recruitment__c == 'Yes';
        }

        update scope;
    }

    global void finish(Database.BatchableContext bc) {}

}