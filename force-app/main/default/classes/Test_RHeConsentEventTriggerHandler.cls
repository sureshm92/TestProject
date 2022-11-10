@isTest
public class Test_RHeConsentEventTriggerHandler {
    
    @isTest
    static void testUpdatePERafterInsert(){
        TestData.loadTestData();
        
        
        Account studySiteAccount = [Select Id from Account LIMIT 1];
        Clinical_Trial_Profile__c ctp = [Select Id, Suppress_PI_Emails__c from Clinical_Trial_Profile__c limit 1];
        ctp.Suppress_PI_Emails__c = true;
        update ctp;
        
        
        Participant_Enrollment__c  peRecord = [Select Id, Name,Participant_Status__c from Participant_Enrollment__c LIMIT 1];
        peRecord.Participant_Status__c = 'Successfully Contacted';
        peRecord.Initial_visit_scheduled_date__c =  Date.valueOf('2015-12-31');
        peRecord.Initial_visit_scheduled_time__c = Time.newInstance(18, 30, 2, 20);
        peRecord.Initial_visit_occurred_flag__c = true;
        update peRecord;
        RH_eConsent__e newEvent1 = new RH_eConsent__e(Subject_Id__c = peRecord.Name,
                                                    Subject_Consent_Status__c = 'Needs to re-consent',
                                                     Subject_Consent_Date__c = '2021-10-10'
                                                    );
        
        List<RH_eConsent__e> listEvents = new List<RH_eConsent__e>();
        listEvents.add(newEvent1);
        RH_eConsentEventTriggerHandler.updatePERafterInsert(listEvents);
        Participant_Enrollment__c  peRecord1 = [Select Id, Name,Participant_Status__c from Participant_Enrollment__c LIMIT 1];
        peRecord1.Participant_Status__c = 'Withdrew Consent';
        peRecord1.Initial_visit_scheduled_date__c =  Date.valueOf('2015-12-31');
        peRecord1.Initial_visit_scheduled_time__c = Time.newInstance(18, 30, 2, 20);
        peRecord1.Initial_visit_occurred_flag__c = true;
        update peRecord1;
        RH_eConsent__e newEvent2 = new RH_eConsent__e(Subject_Id__c = peRecord1.Name,
                                                    Subject_Consent_Status__c = 'Consented',
                                                     Subject_Consent_Date__c = '2021-10-10'
                                                    );
        listEvents.add(newEvent2);
        
        RH_eConsentEventTriggerHandler.updatePERafterInsert(listEvents);
        Participant_Enrollment__c  peRecord2 = [Select Id, Name,Participant_Status__c from Participant_Enrollment__c LIMIT 1];
        peRecord2.Participant_Status__c = 'Declined Consent';
        peRecord2.Initial_visit_scheduled_time__c = Time.newInstance(18, 30, 2, 20);
        peRecord2.Initial_visit_occurred_flag__c = true;
        update peRecord2;
        RH_eConsent__e newEvent3 = new RH_eConsent__e(Subject_Id__c = peRecord2.Name,
                                                    Subject_Consent_Status__c = 'Consented',
                                                     Subject_Consent_Date__c = '2021-10-10'
                                                    );
        listEvents.add(newEvent3);
        
        RH_eConsentEventTriggerHandler.updatePERafterInsert(listEvents);
        
        Participant_Enrollment__c  peRecord3 = [Select Id, Name,Participant_Status__c from Participant_Enrollment__c 
                                                LIMIT 1];
        peRecord3.Participant_Status__c = 'Withdrew Consent After Screening';
        peRecord3.Initial_visit_scheduled_date__c =  Date.valueOf('2015-12-31');
        peRecord3.Initial_visit_scheduled_time__c = Time.newInstance(18, 30, 2, 20);
        peRecord3.Initial_visit_occurred_flag__c = true;
        update peRecord3;
        RH_eConsent__e newEvent4 = new RH_eConsent__e(Subject_Id__c = peRecord3.Name,
                                                    Subject_Consent_Status__c = 'Consented',
                                                     Subject_Consent_Date__c = '2021-10-10'
                                                    );
        listEvents.add(newEvent4);
        
        RH_eConsentEventTriggerHandler.updatePERafterInsert(listEvents);
        
        Participant_Enrollment__c  peRecord4 = [Select Id, Name,Participant_Status__c from Participant_Enrollment__c 
                                                LIMIT 1];
        peRecord4.Participant_Status__c = 'Ready to Screen';
        peRecord4.Initial_visit_scheduled_date__c =  Date.valueOf('2015-12-31');
        peRecord4.Initial_visit_scheduled_time__c = Time.newInstance(18, 30, 2, 20);
        peRecord4.Initial_visit_occurred_flag__c = true;
        update peRecord4;
        
        RH_eConsent__e newEvent5 = new RH_eConsent__e(Subject_Id__c = peRecord4.Name,
                                                    Subject_Consent_Status__c = 'Withdrawn',
                                                     Subject_Consent_Date__c = '2021-10-10'
                                                    );
        listEvents.add(newEvent5);
        
        RH_eConsentEventTriggerHandler.updatePERafterInsert(listEvents);
        
        
        Participant_Enrollment__c  peRecord5 = [Select Id, Name,Participant_Status__c from Participant_Enrollment__c 
                                                LIMIT 1];
        peRecord5.Participant_Status__c = 'Ready to Screen';
        peRecord5.Initial_visit_scheduled_date__c =  Date.valueOf('2015-12-31');
        peRecord5.Initial_visit_scheduled_time__c = Time.newInstance(18, 30, 2, 20);
        peRecord5.Initial_visit_occurred_flag__c = true;
        update peRecord5;
        
        RH_eConsent__e newEvent6 = new RH_eConsent__e(Subject_Id__c = peRecord5.Name,
                                                    Subject_Consent_Status__c = 'Declined',
                                                     Subject_Consent_Date__c = '2021-10-10'
                                                    );
        listEvents.add(newEvent6);
        
        RH_eConsentEventTriggerHandler.updatePERafterInsert(listEvents);
    }
    @isTest
    static void testUpdatePERafterInsert2(){
        TestData.loadTestData();
		Account studySiteAccount = [Select Id from Account LIMIT 1];
        Clinical_Trial_Profile__c ctp = [Select Id, Suppress_PI_Emails__c from Clinical_Trial_Profile__c limit 1];
        ctp.Suppress_PI_Emails__c = true;
        update ctp;
     
        Participant_Enrollment__c  peRecord1 = [Select Id, Name,Participant_Status__c from Participant_Enrollment__c LIMIT 1];
        peRecord1.Participant_Status__c = 'Declined Consent';
        update peRecord1;
        
        Participant_Enrollment_Status_History__c ph = [Select Id, ParticipantEnrollment__c,Status__c from Participant_Enrollment_Status_History__c
                                                      limit 1];
        ph.Status__c= 'Declined Consent';
        update ph;
        RH_eConsent__e newEvent1 = new RH_eConsent__e(Subject_Id__c = peRecord1.Name,
                                                    Subject_Consent_Status__c = 'Consented',
                                                     Subject_Consent_Date__c = '2021-10-10'
                                                    );
        List<RH_eConsent__e> listEvents = new List<RH_eConsent__e>();
        listEvents.add(newEvent1);
        RH_eConsentEventTriggerHandler.updatePERafterInsert(listEvents);
        
        
        Participant_Enrollment__c  peRecord3 = [Select Id, Name,Participant_Status__c from Participant_Enrollment__c 
                                                LIMIT 1];
        peRecord3.Participant_Status__c = 'Enrollment Success';
        peRecord3.Initial_visit_scheduled_date__c =  Date.valueOf('2015-12-31');
        peRecord3.Initial_visit_scheduled_time__c = Time.newInstance(18, 30, 2, 20);
        peRecord3.Initial_visit_occurred_flag__c = true;
        update peRecord3;
        
        RH_eConsent__e newEvent3 = new RH_eConsent__e(Subject_Id__c = peRecord3.Name,
                                                    Subject_Consent_Status__c = 'Declined',
                                                     Subject_Consent_Date__c = '2021-10-10'
                                                    );
        listEvents.add(newEvent3);
        
        RH_eConsentEventTriggerHandler.updatePERafterInsert(listEvents);
        Participant_Enrollment__c  peRecord2 = [Select Id, Name,Participant_Status__c from Participant_Enrollment__c 
                                                LIMIT 1];
        peRecord2.Participant_Status__c = 'Enrollment Success';
        peRecord2.Initial_visit_scheduled_date__c =  Date.valueOf('2015-12-31');
        peRecord2.Initial_visit_scheduled_time__c = Time.newInstance(18, 30, 2, 20);
        peRecord2.Initial_visit_occurred_flag__c = true;
        update peRecord2;
        
        RH_eConsent__e newEvent2 = new RH_eConsent__e(Subject_Id__c = peRecord2.Name,
                                                    Subject_Consent_Status__c = 'Withdrawn',
                                                     Subject_Consent_Date__c = '2021-10-10'
                                                    );
        listEvents.add(newEvent2);
        RH_eConsentEventTriggerHandler.updatePERafterInsert(listEvents);
        
        Participant_Enrollment__c  peRecord4 = [Select Id, Name,Participant_Status__c from Participant_Enrollment__c 
                                                LIMIT 1];
        peRecord4.Participant_Status__c = 'Successfully Contacted';
        peRecord4.Initial_visit_scheduled_date__c =  Date.valueOf('2015-12-31');
        peRecord4.Initial_visit_scheduled_time__c = Time.newInstance(18, 30, 2, 20);
        peRecord4.Initial_visit_occurred_flag__c = true;
        update peRecord4;
        
        RH_eConsent__e newEvent4 = new RH_eConsent__e(Subject_Id__c = peRecord4.Name,
                                                    Subject_Consent_Status__c = 'Consented',
                                                     Subject_Consent_Date__c = '2021-10-10'
                                                    );
        listEvents.add(newEvent4);
        RH_eConsentEventTriggerHandler.updatePERafterInsert(listEvents);
    }
}