/**
* Created by Leonid Bartenev
*/

@IsTest
private without sharing class Test_ContactService {
    @IsTest
    private static void defaultPEOnContact() {
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.CreateNotificationHandler.class
        );			
		        
        TestData.loadTestData();
        TestData testData = new TestData();
        
        Test.startTest();
        
        /*System.runAs(testData.participantUser) {
CommunityFacadeRemote.isFirstLogon();
CommunityFacadeRemote.acceptTerms();
CommunityFacadeRemote.getCommunityData();
}*/
        
        //case getCurrentPe:
        Participant_Enrollment__c pe1 = ContactService.getCurrentPE(
            testData.participantUser.ContactId
        );
        System.assertEquals(testData.pe.Id, pe1.Id);
        
        //case applyRelevantNames:
        Contact contact = ContactService.getContact(testData.participantUser.ContactId);
        ContactService.applyRelevantNames(contact);
        
        pe1.Participant_Status__c = PEStatusState.PE_STATUS_TRIAL_COMPLETE;
        update pe1;
        
        System.runAs(testData.participantUser) {
            CommunityFacadeRemote.isFirstLogon();
            CommunityFacadeRemote.acceptTerms();
            CommunityFacadeRemote.getCommunityData();
        }
        User pdUser = testData.createPatientDelegate();
        System.runAs(pdUser) {
            CommunityFacadeRemote.isFirstLogon();
            CommunityFacadeRemote.acceptTerms();
            CommunityFacadeRemote.getCommunityData();
        }
        
        //case getPastStudyWrappers:     
        List<ContactService.PastStudyWrapper> pastStudyWrappers = new List<ContactService.PastStudyWrapper>();
        Id conId = testData.participantUser.ContactId;
        Therapeutic_Area__c ta = new Therapeutic_Area__c();
        ta.Name = 'Sample data';
        insert ta;
        Therapeutic_Area_Patient__c tp = new Therapeutic_Area_Patient__c();
        tp.Therapeutic_Area__c = ta.id;
        tp.Participant__c = testData.pe.Participant__c;
        insert tp;
        Id recordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName().get('Relevant Link').getRecordTypeId();
        Resource__c rs = new Resource__c();
        rs.Expiration_Date__c = system.today()+10;
        rs.Resource_Type__c = 'Study Document';
        rs.RecordTypeId = recordTypeId;
        insert rs;
        Res_study__c res = new Res_study__c();
        res.Clinical_Trial_Profile__c = testData.ctp.Id;
        res.Resource__c = rs.Id;
        insert res;
        pastStudyWrappers.addAll(ContactService.getPastStudyWrappers(conId));
        System.assertEquals(testData.ctp.Id, pastStudyWrappers[0].ctp.Id);
        
        //case getPastEnrollments
        List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
        peList.addAll(ContactService.getPastEnrollments(conId));
        System.assertEquals(testData.pe.Id, peList[0].Id);
        
        //case NextNotifyDate
        Datetime dt = Datetime.newInstance(2020, 1, 1);
        ContactService.updateNextNotifyDate(conId, dt);
        Contact delCon = [SELECT Id, LastName FROM Contact WHERE Id = :pdUser.ContactId];
        ContactService.updateNextNotifyDate(delCon.Id, dt);
        Contact testCont = [SELECT Id, Next_Notify_Date__c FROM Contact WHERE Id = :conId];
        Test.stopTest();
        Contact testDelCont = [SELECT Id, Next_Notify_Date__c FROM Contact WHERE Id = :delCon.Id];
        System.assert(testCont.Next_Notify_Date__c != Null);
        // System.assertEquals(null, testDelCont.Next_Notify_Date__c); 
    }    
    @IsTest
    private static void testContactSite(){
      
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.UpdateParticipantAndUserEmailsOnEmailChangeHandler.afterUpdate.class            
        );
        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.afterUpdate.class            
        );
        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateTriggerHandler.updatePermissionSets.afterUpdate.class            
        );
           TriggerHandlerExecutor.bypassHandler(
            PatientDelegateTriggerHandler.CreateReactivatedNotification.afterUpdate.class            
        );
           TriggerHandlerExecutor.bypassHandler(
            PatientDelegateTriggerHandler.CreatePrimaryDelegateForMinor.afterUpdate.class            
        );
        TriggerHandlerExecutor.bypassHandler(
            TriggerHandlerExecutor.contextExecuteHandler.afterUpdate.class            
        );
        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateTriggerHandler.CreateNewAssignmentNotification.afterUpdate.class            
        );
        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateTriggerHandler.createDelegateAssignmentNotification.afterUpdate.class            
        );
           TriggerHandlerExecutor.bypassHandler(
            PatientDelegateTriggerHandler.SetDefaultPatientDelegateStatusHandler.afterUpdate.class            
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.createNotificationsHandler.afterUpdate.class            
        );
        
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.CreateUserForDelegateContactHandler.afterUpdate.class            
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.UpdatePhoneNumberContactsHandler.afterUpdate.class            
        );
                TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.UpdateConsentTimeStamps.afterUpdate.class            
        );
                TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.ParticipantConsentUpdate.afterUpdate.class            
        );
                TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.SetShowTourDefaultHandler.afterUpdate.class            
        );
                TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.PopulateOverrideFields.afterUpdate.class            
        );
                TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.CreateUserForCCContactHandler.afterUpdate.class            
        );  
		
        Account piAccount = new Account(Name = 'PI Account', BillingCountry = 'United States');
        insert piAccount;
        Account pianotherconatctAccount = new Account(Name = 'John Williams', BillingCountry = 'United States');
        insert pianotherconatctAccount;
        Contact delegateContact = new Contact(
            FirstName = 'Albert',
            LastName = 'Thomas',
            Email = 'pitest+456666@emil.com',
            MailingCountry = 'United States',
            AccountId = pianotherconatctAccount.Id,
            userCommunytyType__c = 'PI',
            Visited_Communities__c = 'Default'
        );
        insert delegateContact;
        Participant__c delegateParticipant = new Participant__c(
            First_Name__c = 'Albert',
            Last_Name__c = 'Thomas',
            Phone__c = '999999999',
            Contact__c = delegateContact.Id,
            Email__c = 'pitest+456666@emil.com',
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'AL',
            Adult__c = true,
            Site__c = pianotherconatctAccount.Id
        );
        insert delegateParticipant;
        List<Contact> contactLst = new List<Contact>();
        Contact piContact = new Contact(
            FirstName = 'PITD',
            LastName = 'PITD',
            Email = 'pi@emil.com',
            MailingCountry = 'United States',
            AccountId = piAccount.Id,
            userCommunytyType__c = 'PI'
        );
        insert piContact;
        
        Therapeutic_Area__c area = new Therapeutic_Area__c(Name = 'Test TA TD');
        insert area;
        
        Clinical_Trial_Profile__c ctpstudy = new Clinical_Trial_Profile__c(
            Protocol_ID__c = 'CTP1',
            Override_Recruitment_Status__c = 'Actively Enrolling',
            NCT_Number__c = 'NCT99999999',
            Link_to_Pre_screening__c = 'some link',
            // Terms_And_Conditions_ID__c = studyTC.Id,
            Study_Title__c = 'Some Title',
            Study_Code_Name__c = 'Some Code Name',
            Suppress_Participant_Emails__c = false,
            Therapeutic_Area__c = area.Id,
            Synch_with_TMDH__c = true,
            Include_in_RP_trial_search__c = true,
            Patient_Portal_Enabled__c = true,
            Shareback_Settings_On_Participant_Level__c = true,
            Shareback_Availability_Timing__c = 1,
            Visit_Data_Shareback__c = true,
            Visit_Schedule_Is_Available__c = true,
            Tasks_Are_Available__c = true,
            Study_Documents_Are_Available__c = true,
            Video_And_Articles_Are_Available__c = true,
            Travel_Vendor_Is_Available__c = true,
            Relevant_Links_Are_Available__c = true,
            Sponsor_Pays_for_Referral_Activity__c = 'Yes',
            CommunityTemplate__c = CommunityTemplateService.TEMPLATE_DEFAULT,
            Logged_Out_Days_Notification__c = 1,
            Enable_for_Call_Center_Support__c = true
        );
        insert ctpstudy;
        Study_Site__c studySite = new Study_Site__c(
            Principal_Investigator__c = piContact.Id,
            Clinical_Trial_Profile__c = ctpstudy.Id,
            Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
            Site__c = piAccount.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false,
            Study_Site_Number__c = 'SS1',
            Billable_Code_CRM_Number__c = 'Test_Billable_Code',
            Enable_for_Call_Center_Support__c = true
        );
        insert studySite;
        List<Participant__c> participantLst = new List<Participant__c>();
        Participant__c participantupdate = new Participant__c(
            First_Name__c = 'ParticipantTD4',
            Last_Name__c = 'ParticipantTD4',
            Phone__c = '55313538',
            Contact__c = piContact.Id,
            Email__c = 'part4@email.com',
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'AL',
            Adult__c = true,
            Site__c = piAccount.Id
        );
        insert participantupdate;
        List<Participant_Enrollment__c> participantPeList = new List<Participant_Enrollment__c>();
        Participant_Enrollment__c pe4 = new Participant_Enrollment__c(
            //PI_Contact__c = piContact.Id,
            Participant_Contact__c = piContact.Id,
            Study_Site__c = studySite.Id,
            Patient_ID__c = 'SomePatientId4',
            Referral_Source__c = 'PI',
            //Initial_visit_scheduled_date__c = Date.today()-1,
            //Initial_visit_occurred_flag__c = true,
            Participant_Status__c = DashboardRemoteNew.STATUS_SCREENING_IN_PROGRESS,
            Participant__c = participantupdate.Id,
            Screening_ID__c = 'PESCR4'
        );
        participantPeList.add(pe4);
        insert participantPeList;
 
        Test.startTest();
        participantLst.add(participantupdate);
        piContact.AccountId = pianotherconatctAccount.Id;
        contactLst.add(piContact);
        update contactLst;
        System.assertEquals(participantupdate.Contact__c, piContact.Id);
        System.assertEquals(delegateParticipant.Contact__c, delegateContact.Id);
        System.assertNotEquals(delegateParticipant.Contact__c, participantupdate.Contact__c);  
        ContactService.updateContactSite(participantLst);
        List<Patient_Delegate__c>patientDelegateLst = new List<Patient_Delegate__c>();
        Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = delegateContact.Id,
            Participant__c = participantupdate.Id
        );
        insert patientDelegate;
        patientDelegateLst.add(patientDelegate);
        
        ContactService.updatePatientDelegates(patientDelegateLst);
        CommunityTemplate communityTemplate = CommunityTemplateService.getTemplate('Default');
        ContactService.updateVisitedCommunity(delegateContact,communityTemplate);
        ContactService.checkVisitedCommunity(piContact.Id);
        ContactService.addwelcomeNotifications(string.valueof(participantPeList[0].Participant_Contact__c),string.valueof(participantupdate.Id),'Message_to_HCP_Patient_Accepted_Type',true);
        System.assertEquals(communityTemplate, CommunityTemplateService.getTemplate('Default'));
        System.assertEquals(delegateParticipant.Site__c, pianotherconatctAccount.Id);
        System.assertNotEquals(delegateParticipant.Site__c, participantupdate.Site__c);
        Test.stopTest();
    }
}