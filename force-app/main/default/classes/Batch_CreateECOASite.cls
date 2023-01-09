public class Batch_CreateECOASite extends Batch_ScheduledAbstract implements Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            [ 
                SELECT Id, name, Clinical_Trial_Profile__r.Study_GUID__c, ECOA_Site_Guid__c,site__r.billingcountrycode,site__r.billingcountry,site__r.BillingCity,site__r.BillingStreet,site__r.BillingPostalCode,site__r.billingState 
                FROM Study_Site__c
                WHERE
                    ECOA_Site_Guid__c = NULL
                    AND Clinical_Trial_Profile__r.ECOA_Is_Avaialble__c = TRUE
                    AND Clinical_Trial_Profile__r.Study_GUID__c != NULL
            ]
        );
    }
    public void execute(Database.BatchableContext bc, List<Study_Site__c> sitelist) {
        ECOAService.createSite(sitelist);
    }
    public override Type getType() {
        return Batch_CreateECOASite.class;
    }

    public override virtual String getBatchDescription() {
        return 'Create Sites in ECOA Platform';
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 5;
    }

    public override Integer getRecommendedScopeSize() {
        return 50;
    }
}