/**
 * Created by user on 19-Feb-20.
 */

global without sharing class Batch_UpdatePatientDelegateStatuses implements Database.Batchable<SObject> {
    private static final String Active = 'Active';

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id,
                                                Status__c
                                         FROM Patient_Delegate__c
                                         WHERE Status__c !=: Active]);
    }

    global void execute(Database.BatchableContext bc, List<Patient_Delegate__c> scope) {
        TriggerHandlerExecutor.bypassHandler(PatientDelegateTriggerHandler.SetDefaultPatientDelegateStatusHandler.class);

        for (Patient_Delegate__c del : scope) {
            del.Status__c = Active;
        }
        update scope;
    }

    global void finish(Database.BatchableContext bc) {}

}