public without sharing class RH_eConsentEventTriggerHandler{
    
    public class UpdateConsentDetails extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            updatePERafterInsert((List<RH_eConsent__e>) newList);
        }
    }
    @TestVisible
    private static void updatePERafterInsert(
        List<RH_eConsent__e> newList
    ){
        System.debug('### newList ' +newList); 
        Map<String,RH_eConsent__e> eventPERList = New Map<String,RH_eConsent__e>(); 
        Map<String,Participant_Enrollment__c> perLists = New Map<String,Participant_Enrollment__c>(); 
        List<Participant_Enrollment__c> updatePER = New List<Participant_Enrollment__c>();
        List<Participant_Enrollment_Status_History__c> histories = new List<Participant_Enrollment_Status_History__c>();
        List<Participant_Enrollment_Status_History__c> updatehistories = new List<Participant_Enrollment_Status_History__c>();
        for (RH_eConsent__e evnt : newList) {
            system.debug('EVENT--->'+evnt.Subject_Id__c+':'+evnt.Subject_Consent_Status__c+':'+evnt.Subject_Consent_Date__c);
            eventPERList.put(evnt.Subject_Id__c,evnt);
        }
        List<Participant_Enrollment__c> perList = [SELECT Id, Name, Participant_Status__c, Referral_ID__c, Study_Site__c,Informed_Consent__c,Informed_Consent_Date__c,Re_consent__c,  
                                                   Initial_visit_scheduled_date__c,Initial_visit_scheduled_time__c,Non_Enrollment_Reason__c,Initial_visit_occurred_flag__c  
                                                   FROM Participant_Enrollment__c where Name IN :eventPERList.Keyset()];
        
        for(Participant_Enrollment__c per:perList){
            perLists.put(per.Name,per);
        }
        
        if(perList != null && !perList.isEmpty()){
            try{
                RH_eConsent__e eConsent;
                for(Participant_Enrollment__c per:perList){
                    
                    eConsent = eventPERList.get(per.Name);
                    if(eConsent.Subject_Consent_Status__c == 'Needs to re-consent'){
                        per.Re_consent__c  = true;
                        if(eConsent.Subject_Consent_Date__c != null){
                            per.Informed_Consent_Date__c = Date.ValueOf(eConsent.Subject_Consent_Date__c);
                        }
                        updatePER.add(per);
                    }else if(eConsent.Subject_Consent_Status__c == 'Consented'){
                        per.Informed_Consent__c = true;
                        per.Re_consent__c  = false;
                        if(eConsent.Subject_Consent_Date__c != null){
                            per.Informed_Consent_Date__c = Date.ValueOf(eConsent.Subject_Consent_Date__c);
                        }
                        
                        if(per.Participant_Status__c == 'Successfully Contacted'){
                            if(per.Initial_visit_scheduled_date__c !=null && per.Initial_visit_scheduled_time__c !=null && per.Initial_visit_occurred_flag__c){
                                histories.add(
                                    new Participant_Enrollment_Status_History__c(
                                        Date__c = Datetime.now(),
                                        Status__c = PEStatusState.PE_STATUS_READY_TO_SCREEN,
                                        ParticipantEnrollment__c = per.Id)
                                );
                            }
                        }
                        if(per.Participant_Status__c == 'Withdrew Consent'){
                            if(per.Initial_visit_scheduled_date__c !=null && per.Initial_visit_scheduled_time__c !=null && per.Initial_visit_occurred_flag__c){
                                per.Non_Enrollment_Reason__c='';
                                histories.add(
                                    new Participant_Enrollment_Status_History__c(
                                        Date__c = Datetime.now(),
                                        Status__c = PEStatusState.PE_STATUS_READY_TO_SCREEN,
                                        Notes__c = 'Received from E-Consent platform',
                                        ParticipantEnrollment__c = per.Id)
                                );
                            }
                        }
                        if(per.Participant_Status__c == 'Declined Consent'){
                            if(per.Initial_visit_scheduled_date__c !=null && per.Initial_visit_scheduled_time__c !=null && per.Initial_visit_occurred_flag__c){
                                per.Non_Enrollment_Reason__c='';  
                                histories.add(
                                    new Participant_Enrollment_Status_History__c(
                                        Date__c = Datetime.now(),
                                        Status__c = PEStatusState.PE_STATUS_READY_TO_SCREEN,
                                        Notes__c = 'Received from E-Consent platform',
                                        ParticipantEnrollment__c = per.Id)
                                );
                            }else{
                                    Participant_Enrollment_Status_History__c ph = new Participant_Enrollment_Status_History__c();
                                    per.Participant_Status__c = 'Successfully Contacted';
                                    ph = [Select Id,Status__c,Name,ParticipantEnrollment__c,Disabled_PESH__c from Participant_Enrollment_Status_History__c where ParticipantEnrollment__c =:per.Id AND Status__c= 'Declined Consent' ORDER By Name DESC limit 1];
                                    if(ph != null){
                                    ph.Id = ph.Id;
                                    ph.Disabled_PESH__c=true;
                                    ph.Notes__c='Received from E-Consent platform';
                                    //update ph;
                                    updatehistories.add(ph);
                                    }
                            }
                        }
                        if(per.Participant_Status__c == 'Withdrew Consent After Screening' ||
                           per.Participant_Status__c == 'Declined Final Consent'
                        ){
                            if(per.Initial_visit_scheduled_date__c !=null && per.Initial_visit_scheduled_time__c !=null && per.Initial_visit_occurred_flag__c){
                                per.Non_Enrollment_Reason__c='';
                                Participant_Enrollment_Status_History__c ph = new Participant_Enrollment_Status_History__c();
                                ph = [Select Id,Status__c,Name,ParticipantEnrollment__c,Disabled_PESH__c from Participant_Enrollment_Status_History__c where ParticipantEnrollment__c =:per.Id AND Status__c=:per.Participant_Status__c ORDER By Name DESC limit 1];
                                if(ph != null){
                                    ph.Id = ph.Id;
                                    ph.Disabled_PESH__c=true;
                                    //update ph;
                                    updatehistories.add(ph);
                                }
                                histories.add(
                                    new Participant_Enrollment_Status_History__c(
                                        Date__c = Datetime.now(),
                                        Status__c = PEStatusState.PE_STATUS_SCREENING_PASSED,
                                        Screening_passed_after_withdrew_declined__c = true,
                                        //Notes__c = 'Received from E-Consent platform',
                                        ParticipantEnrollment__c = per.Id)
                                );
                            }
                        }
                        updatePER.add(per);
                    }else if(eConsent.Subject_Consent_Status__c == 'Withdrawn'){ 
                         per.Re_consent__c  = false;
                         if(eConsent.Subject_Consent_Date__c != null){
                            per.Informed_Consent_Date__c = Date.ValueOf(eConsent.Subject_Consent_Date__c);
                        }
                        if(per.Participant_Status__c == 'Ready to Screen' ||
                           per.Participant_Status__c == 'Screening In Progress' ||
                           per.Participant_Status__c == 'Screening In Progress - Wash Out Period' ||
                           per.Participant_Status__c == 'Screening Failed' ||
                           per.Participant_Status__c == 'Unable to Screen' ||
                           per.Participant_Status__c == 'Withdrew Consent'
                          ){
                              per.Informed_Consent__c = false;
                              histories.add(
                                  new Participant_Enrollment_Status_History__c(
                                      Date__c = Datetime.now(),
                                      Status__c = PEStatusState.PE_STATUS_WITHDREW_CONSENT,
                                      Notes__c = 'Received from E-Consent platform',
                                      Non_Enrollment_Reason__c='Other',
                                      ParticipantEnrollment__c = per.Id)
                              ); 
                             // updatePER.add(per);       
                          }       
                        if(per.Participant_Status__c == 'Enrollment Success' ||
                           per.Participant_Status__c == 'Enrollment Failed' ||
                           per.Participant_Status__c == 'Withdrew Consent After Screening' ||
                           per.Participant_Status__c == 'Declined Final Consent' ||
                           per.Participant_Status__c == 'Randomization Success' ||
                           per.Participant_Status__c == 'Randomization Failed'  ||
                           per.Participant_Status__c == 'Screening Passed' 
                          ){
                              
                              histories.add(
                                  new Participant_Enrollment_Status_History__c(
                                      Date__c = Datetime.now(),
                                      Status__c = PEStatusState.PE_STATUS_WITHDREW_CONSENT_AFTER_SCREENING,
                                      Notes__c = 'Received from E-Consent platform',
                                      Non_Enrollment_Reason__c='Other',
                                      ParticipantEnrollment__c = per.Id)
                              );
                              
                          }   
                           updatePER.add(per);
                    }else if(eConsent.Subject_Consent_Status__c == 'Declined'){
                        //per.Informed_Consent__c = false;
                         per.Re_consent__c  = false;
                         if(eConsent.Subject_Consent_Date__c != null){
                            per.Informed_Consent_Date__c = Date.ValueOf(eConsent.Subject_Consent_Date__c);
                        }
                        if(per.Participant_Status__c == 'Successfully Contacted' ||
                           per.Participant_Status__c == 'Ready to Screen' ||
                           per.Participant_Status__c == 'Screening In Progress' ||
                           per.Participant_Status__c == 'Screening In Progress - Wash Out Period' ||
                           per.Participant_Status__c == 'Screening Failed' ||
                           per.Participant_Status__c == 'Unable to Screen' ||
                           per.Participant_Status__c == 'Screening Passed' ||
                           per.Participant_Status__c == 'Declined Consent'
                          ){
                              
                              histories.add(
                                  new Participant_Enrollment_Status_History__c(
                                      Date__c = Datetime.now(),
                                      Status__c = PEStatusState.PE_STATUS_DECLINED_CONSENT,
                                      Notes__c = 'Received from E-Consent platform',
                                      Non_Enrollment_Reason__c='Other',
                                      ParticipantEnrollment__c = per.Id)
                              );
                          }       
                        if(per.Participant_Status__c == 'Enrollment Success' ||
                           per.Participant_Status__c == 'Enrollment Failed' ||
                           per.Participant_Status__c == 'Withdrew Consent After Screening' ||
                           per.Participant_Status__c == 'Declined Final Consent' ||
                           per.Participant_Status__c == 'Randomization Success' ||
                           per.Participant_Status__c == 'Randomization Failed' 
                          ){
                              per.Final_consent__c = false;
                              histories.add(
                                  new Participant_Enrollment_Status_History__c(
                                      Date__c = Datetime.now(),
                                      Status__c = PEStatusState.PE_STATUS_DECLINED_FINAL_CONSENT,
                                      Notes__c = 'Received from E-Consent platform',
                                      Non_Enrollment_Reason__c='Other',
                                      ParticipantEnrollment__c = per.Id)
                              );
                              //updatePER.add(per);           
                          }  
                          updatePER.add(per); 
                    }else{
                        if(eConsent.Subject_Consent_Date__c != null){
                            per.Informed_Consent_Date__c = Date.ValueOf(eConsent.Subject_Consent_Date__c);
                            updatePER.add(per);
                        } 
                    }
                    eConsent = null;
                }
                if(updatehistories != null && !updatehistories.isEmpty()) {
                   //update updatehistories;
                    Database.SaveResult[] srLsts = Database.update(updatehistories,false);
                    List<Integration_Log__c> lstIntegrationLogs = New List<Integration_Log__c>();
                    for(Integer i=0;i<srLsts.size();i++){
                       if(!srLsts.get(i).isSuccess()){
                            Database.Error error = srLsts.get(i).getErrors().get(0);
                            String failedDML = error.getMessage();
                            system.debug('Failed ID'+error.getFields());
                            Integration_Log__c ilogs = new Integration_Log__c();
                            ilogs.Method__c='Econsent';
                            ilogs.Exception__c='PESH:'+error.getFields()+' '+'Error:'+''+failedDML;
                            lstIntegrationLogs.add(ilogs);
                        }
                    }
                    if(lstIntegrationLogs != null && !lstIntegrationLogs.isEmpty()) {
                        Insert lstIntegrationLogs;
                    }
                    
                }
                if(updatePER != null && !updatePER.isEmpty()) {
                   //update updatePER;
                    Database.SaveResult[] srList = Database.update(updatePER,false);
                    List<Integration_Log__c> listIntegrationLog = New List<Integration_Log__c>();
                    for(Integer i=0;i<srList.size();i++){
                       if(!srList.get(i).isSuccess()){
                            Database.Error error = srList.get(i).getErrors().get(0);
                            String failedDML = error.getMessage();
                            system.debug('Failed ID'+updatePER.get(i).Id);
                            Integration_Log__c ilog = new Integration_Log__c();
                            ilog.Method__c='Econsent';
                            ilog.Exception__c='PER ID:'+updatePER.get(i).Id+' '+'Error:'+''+failedDML;
                            listIntegrationLog.add(ilog);
                        }
                    }
                    if(listIntegrationLog != null && !listIntegrationLog.isEmpty()) {
                        Insert listIntegrationLog;
                    }
                    
                }
                if(histories != null && !histories.isEmpty()) {
                    TriggerHandlerExecutor.bypassHandler(
                        ParticipantEnrollmentSHTriggerHandler.updateEnrollmentStatus.class
                    );
                    //insert histories;
                    Database.SaveResult[] srInsertLst = Database.Insert(histories,false);
                    List<Integration_Log__c> listIntegrationLogs = New List<Integration_Log__c>();
                    for(Integer i=0;i<srInsertLst.size();i++){
                       if(!srInsertLst.get(i).isSuccess()){
                            Database.Error error = srInsertLst.get(i).getErrors().get(0);
                            String failedDML = error.getMessage();
                            system.debug('Failed ID'+error.getFields());
                            Integration_Log__c ilogs = new Integration_Log__c();
                            ilogs.Method__c='Econsent';
                            ilogs.Exception__c='PESH:'+error.getFields()+' '+'Error:'+''+failedDML;
                            listIntegrationLogs.add(ilogs);
                        }
                    }
                    if(listIntegrationLogs != null && !listIntegrationLogs.isEmpty()) {
                        Insert listIntegrationLogs;
                    }
                }
            }catch (Exception e) {
                system.debug('Error From Econsent-->'+e.getMessage());
            }
        }
    }
}