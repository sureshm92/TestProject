/**
 * Created by Nikita Abrazhevitch on 13-Jan-20.
 */

public with sharing class Batch_HCPEStatusUpdate implements Database.Batchable<SObject>{

    public static final String deprecatedStatus= 'Activation Pending Orientation';
    public static final String newStatus= 'Orientation Pending';
    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT Id,
                        Status__c
                FROM HCP_Enrollment__c
                WHERE Status__c = :deprecatedStatus
        ]);
    }
    public void execute(Database.BatchableContext param1, List<HCP_Enrollment__c> enrollments) {
        List<HCP_Enrollment__c> enrollmentsToUpadte = new List<HCP_Enrollment__c>();
        for(HCP_Enrollment__c hcpe : enrollments){
            hcpe.Status__c = newStatus;
            enrollmentsToUpadte.add(hcpe);
        }
        update enrollmentsToUpadte;
    }
    public void finish(Database.BatchableContext param1) {}
}