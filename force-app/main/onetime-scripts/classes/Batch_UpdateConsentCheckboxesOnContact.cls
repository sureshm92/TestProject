global without sharing class Batch_UpdateConsentCheckboxesOnContact implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query  = 'Select id,Participant_Opt_In_Status_Emails__c,Participant_Phone_Opt_In_Permit_Phone__c,Participant_Opt_In_Status_SMS__c';
        query = query + ' from contact where (Participant_Opt_In_Status_Emails__c = true or Participant_Phone_Opt_In_Permit_Phone__c = true or Participant_Opt_In_Status_SMS__c = true)'; 
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Sobject> records){
        List<Contact> lst_Contact = (List<Contact>)records;
        List<Contact> toupdateConsent = new List<Contact>();
        for(Contact con:lst_Contact){
            contact contoupdate = new contact();
            contoupdate.Id = con.Id;
            if(con.Participant_Phone_Opt_In_Permit_Phone__c){
                contoupdate.IQVIA_Artificial_Voice_Consent__c = con.Participant_Phone_Opt_In_Permit_Phone__c;
                contoupdate.IQVIA_Assisted_Dialing_Consent__c = con.Participant_Phone_Opt_In_Permit_Phone__c;
                contoupdate.IQVIA_Pre_recorded_Voice_Consent__c = con.Participant_Phone_Opt_In_Permit_Phone__c;
            } 
            if(con.Participant_Opt_In_Status_Emails__c){
                contoupdate.IQVIA_Direct_Mail_Consent__c = con.Participant_Opt_In_Status_Emails__c;
            }
            contoupdate.IQVIA_Contact_info_storage_consent__c = (con.Participant_Opt_In_Status_Emails__c || con.Participant_Opt_In_Status_SMS__c
            || con.Participant_Phone_Opt_In_Permit_Phone__c );
            toupdateConsent.add(contoupdate);
        }
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
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}