/**
 * Created by Leonid Bartenev
 */

public without sharing class Batch_IntegrationVisitProcess extends Batch_ScheduledAbstract{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
                SELECT
                        CreatedById,
                        CreatedDate,
                        External_Key__c,
                        Id,
                        IsDeleted,
                        IsDeletedInSDH__c,
                        LastModifiedById,
                        LastModifiedDate,
                        MD5_Hash__c,
                        Name,
                        OwnerId,
                        STUDYID__c,
                        SVSTDTC__c,
                        SystemModstamp,
                        USUBJID__c,
                        VISIT__c,
                        VISITNUM__c,
                        Work_Status__c
                FROM Integration_Visit__c WHERE Processed__c = FALSE
        ]);
    }
    
    public void execute(Database.BatchableContext param1, List<SObject> scope) {
        List<Integration_Visit__c> integrationVisits = (List<Integration_Visit__c>)scope;
        IntegrationVisitTriggerHandler.updateVisits(integrationVisits);
    }

    public override void finish(Database.BatchableContext bc) {
        Batch_IntegrationVisitResultProcess batchResult = new Batch_IntegrationVisitResultProcess();
        Database.executeBatch(batchResult);
        super.finish(bc);
    }
    
    public override Type getType() {
        return Batch_IntegrationVisitProcess.class;
    }
}
