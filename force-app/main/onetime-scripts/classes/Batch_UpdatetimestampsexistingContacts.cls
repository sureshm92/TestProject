global with sharing class Batch_UpdatetimestampsexistingContacts implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> filedsList = new List<String>{'Participant_Opt_In_Status_Emails__c','Participant_Phone_Opt_In_Permit_Phone__c','Participant_Opt_In_Status_SMS__c'};
            String query  = 'Select id,IQVIA_Email_Consent_Time__c,IQVIA_Phone_Consent_Time__c,IQVIA_SMS_Consent_Time__c,';
        query = query + '(Select id,ContactId ,Field, OldValue , NewValue,createddate from Histories where Field IN :filedsList)';
        query = query + ' from contact where (IQVIA_Email_Consent_Time__c = null or IQVIA_Phone_Consent_Time__c = null or IQVIA_SMS_Consent_Time__c = null)';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Sobject> records){
        List<Contact> lst_Contact = (List<Contact>)records;
        List<Contact> toupdateConsent = new List<Contact>();
        List<ContactHistory> ListCons = new List<ContactHistory>();
        Map<Id,Map<String,DateTime>> mapCon = new Map<Id,Map<String,DateTime>>();
        for(Contact c:lst_Contact){
            ListCons.addAll(c.Histories);
        }
        for(ContactHistory ch:ListCons){  
            Map<String,DateTime> maph = new Map<String,DateTime>();
            if(mapCon.containsKey(ch.ContactId)){
                Map<String,DateTime> maph1 = mapCon.get(ch.ContactId);
                if(maph1.keyset() != null && maph1.keyset().contains(ch.Field) && maph1.get(ch.Field) < ch.createddate){
                    maph1.put(ch.Field,ch.createddate);
                    mapCon.get(ch.ContactId).putAll(maph1);
                }else if(maph1.keyset() != null && !maph1.keyset().contains(ch.Field)){
                    maph.put(ch.Field,ch.createddate);
                    mapCon.get(ch.ContactId).putAll(maph);
                }
            }else{
                maph.put(ch.Field,ch.createddate);
                mapCon.put(ch.ContactId,maph);
            }
        }
        for(Contact con:lst_Contact){
            if(con.Histories != null && con.Histories.size() > 0 ){
                Contact contoupdate = new Contact();
                contoupdate.Id = con.Id;
                Boolean check = false;
                if(con.IQVIA_Email_Consent_Time__c == null && mapCon.get(con.Id) != null && 
                   mapCon.get(con.Id).keyset().contains('Participant_Opt_In_Status_Emails__c')){
                       
                       contoupdate.IQVIA_Email_Consent_Time__c = mapCon.get(con.Id).get('Participant_Opt_In_Status_Emails__c');
                       check = true;
                   }
                if(con.IQVIA_Phone_Consent_Time__c == null && mapCon.get(con.Id) != null && 
                   mapCon.get(con.Id).keyset().contains('Participant_Phone_Opt_In_Permit_Phone__c')){
                       
                       contoupdate.IQVIA_Phone_Consent_Time__c = mapCon.get(con.Id).get('Participant_Phone_Opt_In_Permit_Phone__c');
                       check = true;
                   } 
                if(con.IQVIA_SMS_Consent_Time__c == null && mapCon.get(con.Id) != null && 
                   mapCon.get(con.Id).keyset().contains('Participant_Opt_In_Status_SMS__c')){
                       
                       contoupdate.IQVIA_SMS_Consent_Time__c = mapCon.get(con.Id).get('Participant_Opt_In_Status_SMS__c');
                       check = true;
                   } 
                if(check){
                    toupdateConsent.add(contoupdate);
                }
            }
        }
        if(!toupdateConsent.isEmpty()){
            if(!toupdateConsent.isEmpty()){
                TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.UpdateParticipantAndUserEmailsOnEmailChangeHandler.class);
                TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.createNotificationsHandler.class);
                TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.CreateUserForDelegateContactHandler.class);
                TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.SetShowTourDefaultHandler.class);
                TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.PopulateOverrideFields.class);
                TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.CreateUserForCCContactHandler.class);
                TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.UpdateParticipantDetailsHandler.class);
                TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.UpdatePhoneNumberContactsHandler.class);
                TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.UpdateConsentTimeStamps.class);
                TriggerHandlerExecutor.bypassHandler(ContactTriggerHandler.ParticipantConsentUpdate.class);
                update toupdateConsent;
            }
        }
        
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}
