global without sharing class Batch_UpdateConsentCheckboxesOnContact implements Database.Batchable<sObject> {
    /*global Database.QueryLocator start(Database.BatchableContext bc) {
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
            update toupdateConsent;
        }
        
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }*/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query  = 'select Id,IQVIA_Phone_Consent_Time__c, IQVIA_Artificial_Voice_Consent_Time__c, IQVIA_Assisted_Dialing_Consent_Time__c, IQVIA_Pre_recorded_Calls_Consent_Time__c,IQVIA_Direct_Mail_Consent_Time__c, IQVIA_Email_Consent_Time__c, IQVIA_SMS_Consent_Time__c, IQVIA_PI_Storage_Consent_Time__c from contact';
        query = query + ' where (IQVIA_Artificial_Voice_Consent_Time__c >= 2022-07-05T10:16:00.000+0000 and IQVIA_Artificial_Voice_Consent_Time__c <= 2022-07-05T10:19:00.000+0000 ) or (IQVIA_Direct_Mail_Consent_Time__c >= 2022-07-05T10:16:00.000+0000 and IQVIA_Direct_Mail_Consent_Time__c<= 2022-07-05T10:19:00.000+0000 )'; 
        query = query + ' or (IQVIA_PI_Storage_Consent_Time__c >= 2022-07-05T10:16:00.000+0000 and IQVIA_PI_Storage_Consent_Time__c <= 2022-07-05T10:19:00.000+0000 )';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Sobject> records){
        List<Contact> lst_Contact = (List<Contact>)records;
        List<Contact> toupdateConsent = new List<Contact>();
        for(Contact con:lst_Contact){
            contact contoupdate = new contact();
            contoupdate.Id = con.Id;
            if(con.IQVIA_Phone_Consent_Time__c == null){
                contoupdate.IQVIA_Artificial_Voice_Consent_Time__c = null;
                contoupdate.IQVIA_Assisted_Dialing_Consent_Time__c = null;
                contoupdate.IQVIA_Pre_recorded_Calls_Consent_Time__c = null;
            } 
            if(con.IQVIA_Email_Consent_Time__c == null){
                contoupdate.IQVIA_Direct_Mail_Consent_Time__c = null;
            }
            String sDatetime='2022-07-05T10:16:00.000+0000';
            String sDatetime1='2022-07-05T10:19:00.000+0000';
            String timeStr = '10:16';
            String[] ct = timeStr.split(':') ;
            Time t = Time.newInstance(Integer.valueOf(ct[0]), Integer.valueOf(ct[1]), 0, 0); 
            String timeStr1 = '10:19';
            String[] ct1 = timeStr1.split(':') ;
            Time t1 = Time.newInstance(Integer.valueOf(ct1[0]), Integer.valueOf(ct1[1]), 0, 0);
            Datetime pstDateTime = Datetime.valueOf(Datetime.newInstanceGMT(date.valueof('2022-07-05'), t).format('yyyy-MM-dd HH:mm:ss', 'EST'));
            Datetime pstDateTime1 = Datetime.valueOf(Datetime.newInstanceGMT(date.valueof('2022-07-05'), t1).format('yyyy-MM-dd HH:mm:ss', 'EST'));
            if(con.IQVIA_PI_Storage_Consent_Time__c != null && con.IQVIA_PI_Storage_Consent_Time__c >= pstDateTime && con.IQVIA_PI_Storage_Consent_Time__c <= pstDateTime1){
                contoupdate.IQVIA_PI_Storage_Consent_Time__c = null;
            }
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