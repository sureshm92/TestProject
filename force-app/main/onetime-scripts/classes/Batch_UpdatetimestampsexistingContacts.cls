global with sharing class Batch_UpdatetimestampsexistingContacts implements Database.Batchable<sObject>{
    public  List<String> perIds = new List<String>();
    public  List<String> perExcludeIds = new List<String>();
    public Batch_UpdatetimestampsexistingContacts(List<String> perIds, List<String> perExcludeIds){
        this.perIds = perIds ;
        this.perExcludeIds = perExcludeIds;
    }

    public Batch_UpdatetimestampsexistingContacts(){}

    global Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> filedsList = new List<String>{'Participant_Opt_In_Status_Emails__c','Participant_Phone_Opt_In_Permit_Phone__c','Participant_Opt_In_Status_SMS__c','IQVIA_Contact_info_storage_consent__c'};
        String query  = 'Select Id,createddate,IQVIA_Email_Consent_Time__c,IQVIA_Phone_Consent_Time__c,IQVIA_Artificial_Voice_Consent__c,IQVIA_SMS_Consent_Time__c,IQVIA_Contact_info_storage_consent__c,IQVIA_PI_Storage_Consent_Time__c,';
        query += 'Participant_Opt_In_Status_SMS__c,Participant_Opt_In_Status_Emails__c,Participant_Phone_Opt_In_Permit_Phone__c,IQVIA_Direct_Mail_Consent_Time__c,MailingCountry,';
        query += 'IQVIA_Direct_Mail_Consent__c,IQVIA_Assisted_Dialing_Consent__c,IQVIA_Pre_recorded_Voice_Consent__c,IQVIA_Assisted_Dialing_Consent_Time__c,IQVIA_Pre_recorded_Calls_Consent_Time__c,';
        query += '(Select id,ContactId ,Field, OldValue , NewValue,createddate from Histories where Field IN :filedsList)';
        query += ' from contact ';
        if(perIds.size()>0 && perExcludeIds.size()>0){
            query += ' where ID IN: perIds and ID NOT IN:perExcludeIds';
        }else if(perExcludeIds.size()>0){
            query += ' where ID NOT IN:perExcludeIds';
        }else if(perIds.size()>0){
            query += ' where ID IN: perIds';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<contact> scope){
        Map<Id, Contact> contactWithIds = new Map<Id, Contact>(scope);
        List<Contact> contactsForUpdate = new List<Contact>();
        List<ContactHistory> contactHistories = new List<ContactHistory>();
        Map<Id,Map<String,DateTime>> contactWithTimestamps = new Map<Id,Map<String,DateTime>>();
        Map<Id, Boolean> contactIdWithParticipantCountry = new Map<Id, Boolean>();
        //getting all histories
        for(Contact contact:scope){
            contactHistories.addAll(contact.Histories);
            if(contact.MailingCountry!=null){
                contactIdWithParticipantCountry.put(contact.Id,(contact.MailingCountry != 'United States'));
            }
        }
        //getting histories against contact field
        for(ContactHistory ch:contactHistories){  
            Map<String,DateTime> maph = new Map<String,DateTime>();
            if(contactWithTimestamps.containsKey(ch.ContactId)){
                maph = contactWithTimestamps.get(ch.ContactId);
                if(maph.keyset() != null && ((maph.keyset().contains(ch.Field) && maph.get(ch.Field) < ch.createddate)
                || (!maph.keyset().contains(ch.Field)))){
                    maph.put(ch.Field,ch.createddate);
                }
            }else{
                maph.put(ch.Field,ch.createddate);
            }
            contactWithTimestamps.put(ch.ContactId,maph);
        }
       
        //get associated Participant and thier country 
        for(Participant__c participant : [select Id,Mailing_Country_Code__c,Mailing_Country__c,Contact__c from Participant__c  where Contact__c  IN: contactWithIds.keySet() and Mailing_Country__c!=null]){
            contactIdWithParticipantCountry.put(participant.Contact__c,(participant.Mailing_Country__c != 'United States'));
        }

        for(Contact con:scope){
            //checks if the contact is associated with country, if yes then proceeds further to update the contact consent and timestamp
            if(contactIdWithParticipantCountry.containsKey(con.Id)){
                Contact contoupdate = new Contact();
                Boolean isRecorsUpdated = false;
                Boolean recordHistoryExists = contactWithTimestamps.get(con.Id) != null;
                
                contoupdate.Id = con.Id;
                //Timestamp for storage checkbox
                if(con.IQVIA_Contact_info_storage_consent__c && con.IQVIA_PI_Storage_Consent_Time__c == null && recordHistoryExists && 
                contactWithTimestamps.get(con.Id).keyset().contains('IQVIA_Contact_info_storage_consent__c')){
                    contoupdate.IQVIA_PI_Storage_Consent_Time__c = contactWithTimestamps.get(con.Id).get('IQVIA_Contact_info_storage_consent__c');
                    isRecorsUpdated = true;
                }
                else if(con.IQVIA_PI_Storage_Consent_Time__c == null && con.IQVIA_Contact_info_storage_consent__c){
                    contoupdate.IQVIA_PI_Storage_Consent_Time__c = con.createddate;
                    isRecorsUpdated = true;
                }
                if(!con.IQVIA_Contact_info_storage_consent__c && (con.Participant_Phone_Opt_In_Permit_Phone__c || con.Participant_Opt_In_Status_SMS__c || con.Participant_Opt_In_Status_Emails__c
                || con.IQVIA_Pre_recorded_Voice_Consent__c || con.IQVIA_Direct_Mail_Consent__c || con.IQVIA_Assisted_Dialing_Consent__c || con.IQVIA_Artificial_Voice_Consent__c)){
                    contoupdate.IQVIA_Contact_info_storage_consent__c = true;
                    if(recordHistoryExists){
                        for(DateTime dt : contactWithTimestamps.get(con.Id).values()){
                            contoupdate.IQVIA_PI_Storage_Consent_Time__c = ( contoupdate.IQVIA_PI_Storage_Consent_Time__c==null || (contoupdate.IQVIA_PI_Storage_Consent_Time__c > dt) ? dt : contoupdate.IQVIA_PI_Storage_Consent_Time__c);
                        }
                    }else{
                        contoupdate.IQVIA_PI_Storage_Consent_Time__c = con.createddate;
                    }
                    isRecorsUpdated = true;
                }

                //Timestamp for Phone
                if(con.IQVIA_Phone_Consent_Time__c == null && recordHistoryExists && 
                contactWithTimestamps.get(con.Id).keyset().contains('Participant_Phone_Opt_In_Permit_Phone__c') && con.Participant_Phone_Opt_In_Permit_Phone__c){
                    contoupdate.IQVIA_Phone_Consent_Time__c = contactWithTimestamps.get(con.Id).get('Participant_Phone_Opt_In_Permit_Phone__c');
                    isRecorsUpdated = true;
                }else if(con.IQVIA_Phone_Consent_Time__c == null && con.Participant_Phone_Opt_In_Permit_Phone__c){
                    contoupdate.IQVIA_Phone_Consent_Time__c = con.createddate;
                    isRecorsUpdated = true;
                }

                if(con.Participant_Phone_Opt_In_Permit_Phone__c){
                    contoupdate.IQVIA_Assisted_Dialing_Consent__c = true;
                }

                if(con.Participant_Phone_Opt_In_Permit_Phone__c && con.IQVIA_Assisted_Dialing_Consent_Time__c == null && recordHistoryExists && 
                contactWithTimestamps.get(con.Id).keyset().contains('Participant_Phone_Opt_In_Permit_Phone__c')){
                    contoupdate.IQVIA_Assisted_Dialing_Consent_Time__c = contactWithTimestamps.get(con.Id).get('Participant_Phone_Opt_In_Permit_Phone__c');
                    isRecorsUpdated = true;
                }else if(con.IQVIA_Assisted_Dialing_Consent_Time__c == null && con.Participant_Phone_Opt_In_Permit_Phone__c){
                    contoupdate.IQVIA_Assisted_Dialing_Consent_Time__c = con.createddate;
                    isRecorsUpdated = true;
                }

                //Derived Consents from Phone
                if(con.Participant_Phone_Opt_In_Permit_Phone__c){
                    //Derived consent only for ROW
                    if(contactIdWithParticipantCountry.containsKey(con.Id) && contactIdWithParticipantCountry.get(con.Id)){
                        contoupdate.IQVIA_Pre_recorded_Voice_Consent__c = true;
                        contoupdate.IQVIA_Artificial_Voice_Consent__c = true;
                        if(con.IQVIA_Pre_recorded_Calls_Consent_Time__c == null && recordHistoryExists && 
                        contactWithTimestamps.get(con.Id).keyset().contains('Participant_Phone_Opt_In_Permit_Phone__c')){
                            contoupdate.IQVIA_Pre_recorded_Calls_Consent_Time__c = contactWithTimestamps.get(con.Id).get('Participant_Phone_Opt_In_Permit_Phone__c');
                            contoupdate.IQVIA_Artificial_Voice_Consent_Time__c = contactWithTimestamps.get(con.Id).get('Participant_Phone_Opt_In_Permit_Phone__c');
                            isRecorsUpdated = true;
                        }else if(con.IQVIA_Pre_recorded_Calls_Consent_Time__c == null && con.Participant_Phone_Opt_In_Permit_Phone__c){
                            contoupdate.IQVIA_Pre_recorded_Calls_Consent_Time__c = con.createddate;
                            contoupdate.IQVIA_Artificial_Voice_Consent_Time__c = con.createddate;
                            isRecorsUpdated = true;
                        }
                    }
                }

                //Timestamps for Email
                if(con.IQVIA_Email_Consent_Time__c == null && recordHistoryExists && 
                contactWithTimestamps.get(con.Id).keyset().contains('Participant_Opt_In_Status_Emails__c') && con.Participant_Opt_In_Status_Emails__c){
                    contoupdate.IQVIA_Email_Consent_Time__c = contactWithTimestamps.get(con.Id).get('Participant_Opt_In_Status_Emails__c');
                    isRecorsUpdated = true;
                }else if(con.IQVIA_Email_Consent_Time__c == null && con.Participant_Opt_In_Status_Emails__c){
                    contoupdate.IQVIA_Email_Consent_Time__c = con.createddate;
                    isRecorsUpdated = true;
                }
                //Timestamps for Direct Email derives from the email
                if(con.Participant_Opt_In_Status_Emails__c){
                    contoupdate.IQVIA_Direct_Mail_Consent__c = true;
                    if(con.IQVIA_Direct_Mail_Consent_Time__c == null && recordHistoryExists && 
                    contactWithTimestamps.get(con.Id).keyset().contains('Participant_Opt_In_Status_Emails__c')){
                        contoupdate.IQVIA_Direct_Mail_Consent_Time__c = contactWithTimestamps.get(con.Id).get('Participant_Opt_In_Status_Emails__c');
                        isRecorsUpdated = true;
                    }else if(con.IQVIA_Direct_Mail_Consent_Time__c == null && con.Participant_Opt_In_Status_Emails__c){
                        contoupdate.IQVIA_Direct_Mail_Consent_Time__c = con.createddate;
                        isRecorsUpdated = true;
                    }
                    isRecorsUpdated = true;
                }
                //Timestamp for SMS
                if(con.IQVIA_SMS_Consent_Time__c == null && recordHistoryExists && 
                    contactWithTimestamps.get(con.Id).keyset().contains('Participant_Opt_In_Status_SMS__c') && con.Participant_Opt_In_Status_SMS__c){
                        contoupdate.IQVIA_SMS_Consent_Time__c = contactWithTimestamps.get(con.Id).get('Participant_Opt_In_Status_SMS__c');
                        isRecorsUpdated = true;
                }else if(con.IQVIA_SMS_Consent_Time__c == null && con.Participant_Opt_In_Status_SMS__c){
                    contoupdate.IQVIA_SMS_Consent_Time__c = con.createddate;
                    isRecorsUpdated = true;
                }
                if(isRecorsUpdated){
                    contactsForUpdate.add(contoupdate);
                }
            }
        }
        if(!contactsForUpdate.isEmpty()){
            if(!contactsForUpdate.isEmpty()){
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
                update contactsForUpdate;
            }
        }
        
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}