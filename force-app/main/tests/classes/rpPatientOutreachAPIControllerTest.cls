@isTest
public class rpPatientOutreachAPIControllerTest {
        
    @TestSetup
    public static void setupmethod(){
        List<Account> accounts = new List<Account>();
        Account piAccount = new Account(Name = 'PI Account', BillingCountry = 'United States');
        accounts.add(piAccount);

        Account hcpAccount = new Account(Name = 'HCP Account');
        accounts.add(hcpAccount);

        Account delegateAccount = new Account(
            Name = CommunityService.COMMUNITY_DELEGATE_ACCOUNT_NAME
        );
        accounts.add(delegateAccount);

        Account studySiteAccount = new Account(
            Name = 'Study Site Account',
            BillingLatitude = 41.766594,
            BillingLongitude = -74.991509,
            BillingCountry = 'United States'
        );
        accounts.add(studySiteAccount);
        insert accounts;

        List<Contact> contacts = new List<Contact>();
        Contact piContact = new Contact(
            FirstName = 'PITD',
            LastName = 'PITD',
            Email = 'pi@emil.com',
            MailingCountry = 'United States',
            AccountId = piAccount.Id,
            userCommunytyType__c = 'PI'
        );
        contacts.add(piContact);

        Contact piDelegateContact = new Contact(
            FirstName = 'PIDelTD',
            LastName = 'PIDelTD',
            Email = 'pi_delegate@emil.com',
            AccountId = piAccount.Id,
            userCommunityMode__c = 'PI'
        );
        contacts.add(piDelegateContact);

        Contact hcpContact = new Contact(
            FirstName = 'HCPTD',
            LastName = 'HCPTD',
            Email = 'hcp@emil.com',
            AccountId = hcpAccount.Id,
            MailingLatitude = 40.766594,
            MailingLongitude = -73.991509,
            userCommunytyType__c = CommunityService.USER_MODE_HCP,
            userCommunityMode__c = CommunityService.USER_MODE_HCP,
            Language__c = 'en_US'
        );

        Contact hcpDelegateContact = new Contact(
            FirstName = 'HCPDelTD',
            LastName = 'HCPDelTD',
            Email = 'hcp_delegate@emil.com',
            AccountId = hcpAccount.Id
        );
        contacts.add(hcpDelegateContact);

        contacts.add(hcpContact);
        Contact ccContact = new Contact(
            FirstName = 'CCTD',
            LastName = 'CCTD',
            Email = 'cc@emil.com',
            AccountId = hcpAccount.Id,
            userCommunytyType__c = CommunityService.USER_MODE_CC,
            userCommunityMode__c = CommunityService.USER_MODE_CC
        );

        contacts.add(ccContact);
        insert contacts;

        Therapeutic_Area__c area = new Therapeutic_Area__c(Name = 'Test TA TD');
        insert area;
        List<Terms_And_Conditions__c> tcList = new List<Terms_And_Conditions__c>();
        Terms_And_Conditions__c portalTC = new Terms_And_Conditions__c(Active__c = true);
        tcList.add(portalTC);

        Terms_And_Conditions__c studyTC = new Terms_And_Conditions__c();
        tcList.add(studyTC);
        insert tcList;
        
        Clinical_Trial_Profile__c study = new Clinical_Trial_Profile__c(
            Protocol_ID__c = 'CTP1',
            Override_Recruitment_Status__c = 'Actively Enrolling',
            NCT_Number__c = 'NCT99999999',
            Link_to_Pre_screening__c = 'some link',
            Terms_And_Conditions_ID__c = studyTC.Id,
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
        insert study;

        List<PicklistEntry> pleList = Translation__c.Language__c.getDescribe().getPicklistValues();
        String langCode;
        for (PicklistEntry ple : pleList) {
            langCode = ple.getValue();
            if (TranslateHelper.isLanguageSupported(ple.getValue()))
                break;
        }
        Translation__c studyTranslation = new Translation__c(
            Language__c = langCode,
            Record_Id__c = study.Id,
            Field_Name__c = 'Study_Title__c',
            Value__c = 'Some translated value'
        );
        insert studyTranslation;

        Study_Site__c studySite = new Study_Site__c(
            Principal_Investigator__c = piContact.Id,
            Clinical_Trial_Profile__c = study.Id,
            Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
            Site__c = studySiteAccount.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false,
            Study_Site_Number__c = 'SS1',
            Billable_Code_CRM_Number__c = 'Test_Billable_Code',
            Enable_for_Call_Center_Support__c = true
        );
        insert studySite;
        studySite.Override_PI_Referral_Status__c = StudySiteService.PI_S_ACCEPTED;
        update studySite;

        HCP_Enrollment__c hcpEnrollment = new HCP_Enrollment__c(
            Study_Site__c = studySite.Id,
            HCP_Contact__c = hcpContact.Id,
            Status__c = HCPEnrollmentService.HCP_S_INVITATION_SENT
        );
        insert hcpEnrollment;
        hcpEnrollment.Status__c = HCPEnrollmentService.HCP_S_ACTIVATED;
        update hcpEnrollment;

        Site_Staff__c siteStaff = new Site_Staff__c(
            Site_Contact__c = piDelegateContact.Id,
            Delegate_Level__c = DelegateService.DELEGATE_LEVEL_1,
            Study_Site__c = studySite.Id
        );
        insert siteStaff;

        RP_Delegate_Relationship__c rpDelegate = new RP_Delegate_Relationship__c(
            Referring_Provider__c = hcpDelegateContact.Id,
            Delegate_Access_Level__c = DelegateService.DELEGATE_LEVEL_1,
            Delegate__c = hcpContact.Id
        );
        insert rpDelegate;

        List<Participant__c> partList = new List<Participant__c>();
        List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();

        Participant__c participant = new Participant__c(
            First_Name__c = 'ParticipantTD',
            Last_Name__c = 'ParticipantTD',
            Phone__c = '55313535',
            Email__c = 'part1@email.com',
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'AL',
            Adult__c = true,
            Site__c = piAccount.Id
        );
        
        partList.add(participant);

        insert (partList);
        Participant_Enrollment__c pe = new Participant_Enrollment__c(
            HCP__c = hcpEnrollment.Id,
            Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
            Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
            PI_Contact__c = piContact.Id,
            Study_Site__c = studySite.Id,
            Patient_ID__c = 'SomePatientId1',
            Referral_Source__c = 'HCP',
            Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_RECEIVED,
            Participant__c = participant.Id,
            Screening_ID__c = 'PESCR1',
            Invited_To_PP_Date__c = system.now(),
            HCP_Contact_HCPEnroll__r = hcpContact
        );

        peList.add(pe);
        test.startTest();
        insert peList;
        
        test.stopTest();

    }
    public class ExampleCalloutMock implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"salesforceRequestID" : "8693_54808","muleTid" : "7.40","results": [{"participantId": "something","studyCodeName": "something","studySiteName": "1234"}]}');
            return res;
        }
    }
    @future(callout = true)
    public static void testCallout(){
        List<Participant_Enrollment__c> peList = [SELECT id,Name,Patient_ID__c, Participant_Name__c, Participant_Surname__c, Email__c,Study_Name__c, 
                                                     Legal_Status__c, YOB__c, Patient_Auth__c,Outreach_Email_Status__c,Primary_Delegate_Email__c,Primary_Delegate_First_Name__c,
                                                     Primary_Delegate_Last_Name__c,CreatedDate,Mailing_Country_Code__c,
                                                     HCP_Contact_HCPEnroll__r.Name,HCP_Contact_HCPEnroll__r.Phone,HCP_Contact_HCPEnroll__r.Language__c,HCP_Contact_HCPEnroll__r.Email,HCP_Contact_HCPEnroll__r.MailingCity,HCP_Contact_HCPEnroll__r.MailingState,
                                                     HCP_Contact_HCPEnroll__r.MailingCountry, HCP_Contact_HCPEnroll__r.MailingPostalCode, HCP_Contact_HCPEnroll__r.MailingAddress,HCP_Contact_HCPEnroll__r.MailingStreet,
                                                     Clinical_Trial_Profile__r.Study_Code_Name__c,Clinical_Trial_Profile__r.Link_to_ePR_Campaign__c,Clinical_Trial_Profile__r.Protocol_ID__c,
                                                     Clinical_Trial_Profile__r.Condition_s_Therapeutic_Area__c,Clinical_Trial_Profile__r.Enable_RP_Outreach_Email__c
                                                     FROM Participant_Enrollment__c 
                                                     WHERE Screening_ID__c = 'PESCR1'];
        List<rpPatientOutreachAPIController.PatientOutreachWrapper> patientOutreachWrapperList 
        = new List<rpPatientOutreachAPIController.PatientOutreachWrapper>();
        rpPatientOutreachAPIController.PatientOutreachWrapper outreachWrapper = rpPatientOutreachAPIController.generateObjectToJSON(peList[0]);
        patientOutreachWrapperList.add(outreachWrapper);
        String json = JSON.serialize(patientOutreachWrapperList);
        rpPatientOutreachAPIController.sendDataToMuleSoft(json);
        
    }

    @istest
    public static void passperecord(){
        List<Participant_Enrollment__c> peList = [SELECT id,Name,Patient_ID__c, Participant_Name__c, Participant_Surname__c, Email__c,Study_Name__c, 
                                                     Legal_Status__c, YOB__c, Patient_Auth__c,Outreach_Email_Status__c,Primary_Delegate_Email__c,Primary_Delegate_First_Name__c,
                                                     Primary_Delegate_Last_Name__c,CreatedDate,Mailing_Country_Code__c,
                                                     HCP_Contact_HCPEnroll__r.Name,HCP_Contact_HCPEnroll__r.Phone,HCP_Contact_HCPEnroll__r.Language__c,HCP_Contact_HCPEnroll__r.Email,HCP_Contact_HCPEnroll__r.MailingCity,HCP_Contact_HCPEnroll__r.MailingState,
                                                     HCP_Contact_HCPEnroll__r.MailingCountry, HCP_Contact_HCPEnroll__r.MailingPostalCode, HCP_Contact_HCPEnroll__r.MailingAddress,HCP_Contact_HCPEnroll__r.MailingStreet,
                                                     Clinical_Trial_Profile__r.Study_Code_Name__c,Clinical_Trial_Profile__r.Link_to_ePR_Campaign__c,Clinical_Trial_Profile__r.Protocol_ID__c,
                                                     Clinical_Trial_Profile__r.Condition_s_Therapeutic_Area__c,Clinical_Trial_Profile__r.Enable_RP_Outreach_Email__c
                                                     FROM Participant_Enrollment__c 
                                                     WHERE Screening_ID__c = 'PESCR1'];
        test.startTest();
        rpPatientOutreachAPIController.generateObjectToJSON(peList[0]);  
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
         List<rpPatientOutreachAPIController.PatientOutreachWrapper> patientOutreachWrapperList 
        = new List<rpPatientOutreachAPIController.PatientOutreachWrapper>();
        rpPatientOutreachAPIController.PatientOutreachWrapper outreachWrapper = rpPatientOutreachAPIController.generateObjectToJSON(peList[0]);
        patientOutreachWrapperList.add(outreachWrapper);
        String json = JSON.serialize(patientOutreachWrapperList);
        rpPatientOutreachAPIController.sendDataToMuleSoft(json);
        test.stopTest();
    }
    

}