/**
 * Created by Andrii Kryvolap.
 */

global without sharing class Batch_UpdateJanssenctCookies implements Database.Batchable<SObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        set<Id> ctpIds = new Set<id>();
        set<id> ssIds = new Set<id>();
        set<id> conIds = new Set<id>();
        for (Clinical_Trial_Profile__c ctp : [
            SELECT id
            FROM Clinical_Trial_Profile__c
            WHERE CommunityTemplate__c = 'Janssen'
        ])
            ctpIds.add(ctp.id);

        for (Study_Site__c ss : [
            SELECT id, Principal_Investigator__c
            FROM Study_Site__c
            WHERE Clinical_Trial_Profile__c = :ctpIds
        ]) {
            ssIds.add(ss.id);
            conIds.add(ss.Principal_Investigator__c);
        }

        for (Site_Staff__c ss : [
            SELECT Site_Contact__c
            FROM Site_Staff__c
            WHERE Study_Site__c = :ssIds
        ])
            conIds.add(ss.Site_Contact__c);

        String queryString = 'SELECT Id, RRJanssenCookiesAllowedCookie__c,RRJanssenLanguageAllowedCookie__c  FROM Contact WHERE id=:conIds AND RRJanssenCookiesAllowedCookie__c = false';
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext bc, List<Contact> scope) {
        List<Contact> updateConts = new List<Contact>();
        for (contact c : scope) {
            c.RRJanssenCookiesAllowedCookie__c = true;
            updateConts.add(c);
        }
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.UpdateParticipantAndUserEmailsOnEmailChangeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.CreateUserForDelegateContactHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.SetShowTourDefaultHandler.class);
        TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.PopulateOverrideFields.class);
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.CreateUserForCCContactHandler.class
        );
        update updateConts;
    }

    public void finish(Database.BatchableContext bc) {
    }
}
