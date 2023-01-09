/**
 * Created by user on 23-Jul-19.
 */ 

public without sharing class Batch_IntegrationVisitResultProcess implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            [
                SELECT
                    Id,
                    OwnerId,
                    IsDeleted,
                    Name,
                    CreatedDate,
                    CreatedById,
                    LastModifiedDate,
                    LastModifiedById,
                    SystemModstamp,
                    External_Key__c,
                    IsDeletedInSDH__c,
                    MD5__c,
                    NRIND__c,
                    STNRHI__c,
                    STNRLO__c,
                    STRESN__c,
                    STRESU__c,
                    STUDYID__c,
                    TESTCD__c,
                    USUBJID__c,
                    VISITNUM__c,
                    VISIT__c,
                    VSDTC__c,
                    Vital_or_Lab__c,
                    Work_Status__c
                FROM Integration_VisitResult__c
                WHERE Processed__c = FALSE
            ]
        );
    }

    public void execute(Database.BatchableContext param1, List<SObject> scope) {
        ((IntegrationVisitResultService) ClassFactory.newInstance(
                IntegrationVisitResultService.class
            ))
            .updateVisitResults(scope);
    }

    public void finish(Database.BatchableContext param1) {
    }
}
