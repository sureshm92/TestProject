/**
 * Created by Leonid Bartenev
 */ 

public without sharing class Batch_IntegrationVisitProcess extends Batch_ScheduledAbstract implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    set<ID> pvIds = new Set<ID>();
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            [
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
                FROM Integration_Visit__c
                WHERE Processed__c = FALSE
            ]
        );
    }

    public void execute(Database.BatchableContext param1, List<SObject> scope) {
        List<Integration_Visit__c> integrationVisits = (List<Integration_Visit__c>) scope;
        pvIds = IntegrationVisitTriggerHandler.updateVisits(integrationVisits);
    }

    public override void finish(Database.BatchableContext bc) {
        system.debug('pvIds----->' + pvIds);
        Batch_CreateECOAEventOnPVUpdate objBatch = new Batch_CreateECOAEventOnPVUpdate(pvIds);
        Database.executeBatch(objBatch, 50);
        Database.executeBatch(new Batch_IntegrationVisitResultProcess());
        super.finish(bc);
    }

    public override Type getType() {
        return Batch_IntegrationVisitProcess.class;
    }

    public override String getBatchDescription() {
        return 'This job processes Integration Visits and Integration Visit Results and updates relevant Patient Visits and Visit Results';
    }

    public override String getRecommendedIntervalMode() {
        return Batch_ScheduledAbstract.INTERVAL_HOURS;
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 1;
    }
}
