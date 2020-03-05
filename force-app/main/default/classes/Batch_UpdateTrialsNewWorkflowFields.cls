/**
 * Created by Andrii Kryvolap.
 */

global without sharing class Batch_UpdateTrialsNewWorkflowFields implements Database.Batchable<SObject> {

    global Batch_UpdateTrialsNewWorkflowFields() {

    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String queryString = 'SELECT ID, Initial_Visit_Required__c, Participant_Workflow_Final_Step__c FROM Clinical_Trial_Profile__c';
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext bc, List<Clinical_Trial_Profile__c> scope) {
        Set<Id> ctpIds = new Set<Id>();
        for (Clinical_Trial_Profile__c ctp : scope) {
            ctpIds.add(ctp.Id);
        }
        Set<Id> ctpIdsInitialVisitRequired = new Set<Id>();
        for(Study_Site__c ss: [SELECT Id, Clinical_Trial_Profile__c
        FROM Study_Site__c
        WHERE Clinical_Trial_Profile__c IN :ctpIds
        AND Study_Site_Type__c != :StudySiteService.SS_TYPE_VIRTUAL]){
            ctpIdsInitialVisitRequired.add(ss.Clinical_Trial_Profile__c);
        }
        for (Clinical_Trial_Profile__c ctp : scope) {
            ctp.Participant_Workflow_Final_Step__c = PEStatusState.PW_FINAL_STEP_ENROLLMENT;
            if(ctpIdsInitialVisitRequired.contains(ctp.Id)){
                ctp.Initial_Visit_Required__c = true;
            }
        }
        TriggerHandlerExecutor.bypassHandler(ClinicalTrialProfileTriggerHandler.UpdateClinicalTrialProfile.class);
        TriggerHandlerExecutor.bypassHandler(CTPNotificationTriggerHandler.CreateNotificationHandler.class);
        update scope;
    }

    global void finish(Database.BatchableContext bc) {

    }
}