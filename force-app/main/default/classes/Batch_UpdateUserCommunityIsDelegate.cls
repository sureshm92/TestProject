global without sharing class Batch_UpdateUserCommunityIsDelegate implements Database.Batchable<SObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(
            [
                Select id,Study_Site__c,Site_Contact__r.UserCommunityIsDelegate__c,Site_Contact__c,is_Invited__c 
                from Site_Staff__c where is_Invited__c=true AND Site_Contact__r.UserCommunityIsDelegate__c = False
            ]
        );
    }
    global void execute(Database.BatchableContext bc, List<Site_Staff__c> scope) {
        List<Site_Staff__c>sitestaffLST  = new List<Site_Staff__c>();
        List<Id>contactIDSLST  = new List<Id>();
        Map<Id,Contact>updtContactLST  = new Map<Id,Contact>();
        Contact updtStaffContact;
        system.debug('scopeline16>>'+scope);
        for (Site_Staff__c staff : scope) {
           contactIDSLST.add(staff.Site_Contact__c);
       }
        system.debug('contactIDSLST19>>'+contactIDSLST);
        for(Id cntstaff : contactIDSLST){
            updtStaffContact = new Contact();
            updtStaffContact.Id = cntstaff;
            updtStaffContact.UserCommunityIsDelegate__c = true;
            updtContactLST.put(updtStaffContact.Id,updtStaffContact);
        }
        system.debug('updtContactLST>>'+updtContactLST.Values());
        //TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.UpdateParticipantAndUserEmailsOnEmailChangeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.updateParticipantAndUserEmailsOnEmailChange.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.CreateUserForDelegateContactHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.SetShowTourDefaultHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.PopulateOverrideFields.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.CreateUserForCCContactHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.UpdateParticipantDetailsHandler.class
        );
       
        Database.update(updtContactLST.Values(), false);
    }
    global void finish(Database.BatchableContext bc) {
    }
}