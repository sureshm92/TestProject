/**
 * Created by Dmitry Ivakhnenko on 20-Mar-20.
 */

public without sharing class Batch_RemoveDuplicateDelegates implements Database.Batchable<SObject> {

    public Iterable<SObject> start(Database.BatchableContext bc) {
        Integer maxRows = Limits.getLimitQueryRows() - Limits.getQueryRows();

        List<Patient_Delegate__c> allPatientDelegates = [
                SELECT Participant__c, Contact__c
                FROM Patient_Delegate__c
                ORDER BY LastModifiedDate DESC
                LIMIT :maxRows
        ];

        Map<Id, List<Id>> delegatesByParticipant = new Map<Id, List<Id>>();
        List<Patient_Delegate__c> patientDelegatesToRemove = new List<Patient_Delegate__c>();

        for (Patient_Delegate__c patientDelegate : allPatientDelegates) {
            Boolean isDuplicate = false;
            List<Id> delegateIds = delegatesByParticipant.get(patientDelegate.Participant__c);

            if (delegateIds != null) {
                for (Id delegateId : delegateIds) {
                    if (delegateId == patientDelegate.Contact__c) {
                        isDuplicate = true;
                        break;
                    }
                }
            }

            if (isDuplicate) {
                patientDelegatesToRemove.add(patientDelegate);
            } else {
                if (delegateIds == null) {
                    delegateIds = new List<Id> {patientDelegate.Contact__c};
                } else {
                    delegateIds.add(patientDelegate.Contact__c);
                }
                delegatesByParticipant.put(patientDelegate.Participant__c, delegateIds);
            }
        }

        return patientDelegatesToRemove;
    }

    public void execute(Database.BatchableContext bc, List<Patient_Delegate__c> records) {
        Database.delete(records, false);
    }

    public void finish(Database.BatchableContext bc) {}

    public static void run() {
        Database.executeBatch(new Batch_RemoveDuplicateDelegates(), 200);
    }
}