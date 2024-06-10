/**
 * Created by Leonid Bartenev
 */

@IsTest(IsParallel=false)
private class Test_RRChangePasswordController {
    @IsTest(SeeAllData=true)
    public static void testChangePasswordController() {
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SendDropOutEmailHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateWelcomeToStudyAlertHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.CreateNotificationHandler.class
        );

        TestData.loadTestData();
        TestData testData = new TestData();
        //run test:
        Test.startTest();
        Contact delegate = new Contact(
            FirstName = 'Patient',
            LastName = 'Delegate',
            Email = 'jsmith@somemail.com',
            Is_First_Logon__c = false,    
            AccountId = testData.participant.Contact__r.AccountId,
            Current_Participant_Enrollment__c = testData.pe.Id,
            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
            userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT,
            UserCommunityIsDelegate__c = true
        );
        insert delegate;
        HCP_Enrollment__c hcpEnrollment = new HCP_Enrollment__c(
            Study_Site__c = testData.ss.Id,
            HCP_Contact__c = testData.participant.Contact__c,
            Status__c = HCPEnrollmentService.HCP_S_ON_HOLD_ACTIVATION
        );
        insert hcpEnrollment;

        Contact cc = [Select Id,Is_First_Logon__c From Contact where id =: testData.participantUser.ContactId];
        cc.Is_First_Logon__c = false;
         cc.IQVIA_Direct_Mail_Consent__c = true;
        cc.Participant_Opt_In_Status_SMS__c = true;
        cc.Participant_Opt_In_Status_Emails__c = true;
        cc.Participant_Phone_Opt_In_Permit_Phone__c = true;
        cc.UserCommunityIsDelegate__c = true;
        update cc;
        
        Participant__c objParticipant = [
            SELECT Id, Birth_Year__c
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
        objParticipant.Birth_Year__c = '1994';
        update objParticipant;
		String mockPathPrefix = '/some/path';
        System.runAs(testData.participantUser) {
            // Instantiate a new controller with all parameters in the page
            RRChangePasswordController controller = new RRChangePasswordController();
            controller.oldPassword = '123456';
            controller.mainPortal = !mockPathPrefix.startsWith('/gsk');
            controller.failingPageResponse = '7328hsfj';
            controller.US = 'nsdkak';
            controller.userLocale = 'vsajkak';
            controller.userLanguage = 'bnshds';
            controller.tcId = 'jhamcka';
            controller.newPassword = 'qwerty1';
            controller.verifyNewPassword = 'qwerty1';
            controller.CPRAlabel  = 'jhamcnka';
            controller.CPRALink  = 'jhamsbcka';
            controller.CPRAlabel = 'jhanssnmcka';
            controller.ctpName = 'gjajs';
            controller.ctpName = 'gjajs';
            controller.studyConsentSelection = false;
            controller.changePassword();
            controller.showProfileAction();
            controller.ppChangePassword();

            controller.oldPassword = 'qwerty1';
            controller.newPassword = 'NewPas1234';
            controller.mainPortal = !mockPathPrefix.startsWith('/gsk');
            controller.failingPageResponse = '7328hsfj';
            controller.US = 'nsdkak';
            controller.userLocale = 'vsajkak';
            controller.userLanguage = 'bnshds';
            controller.tcId = 'jhamcka';
            controller.CPRAlabel  = 'jhamcnka';
            controller.ctpName = 'gjajs';
            controller.CPRALink  = 'jhamsbcka';
            controller.CPRAlabel = 'jhanssnmcka';
            controller.ctpName = 'gjajs';
            controller.studyConsentSelection = false;
            controller.verifyNewPassword = 'NewPas1234';
            controller.browserLanguage = '["en_US","ru-ru",""]';

            controller.updateBrowserLanguageAction();
            controller.updateLanguageAction();
            controller.initTemplateData();
          //  controller.ppValidateSaveButton();  
            controller.getCPRALink('IQVIA Referral Hub');
             controller.getCPRALink('Janssen Community');
              controller.getCPRALink('GSK Community');
              controller.getCPRALink('IQVIA Patient Portal');
           

            controller.notEnrollNow = false;
            controller.states = new List<SelectOption>{
                new SelectOption('CA', 'CA'),
                new SelectOption('TX', 'TX')
            };

            /* Check with empty fields */
            controller.contact.LastName = null;
            controller.account.Name = null;
            Boolean checkPasswordSuccess = true;
            try {
                controller.checkPasswords();
            } catch (Exception e) {
                checkPasswordSuccess = false;
            }
            System.assertEquals(true, checkPasswordSuccess);
            Test.clearApexPageMessages();

            /* Check with full fields */
            controller.contact.FirstName = 'TestFirstName';
            controller.contact.LastName = 'TestLastName';
            controller.contact.userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT;
            controller.contact.MailingCountryCode = 'US';
            controller.contact.MailingStateCode = 'TX';
            controller.contact.MailingStreet = 'Test st.';
            controller.contact.MailingCity = 'Test City';
            controller.contact.MailingCountry = 'US';
            controller.contact.MailingPostalCode = '123000';
            controller.contact.Phone = '(999)555-0000';
            controller.account.Name = 'TestAccountName';
            List<SelectOption> testStates = new List<SelectOption>();
            testStates.add(new SelectOption('CA', 'California'));
            controller.states = testStates;
            List<String> Stringtest = new List<String>{'aa','bb','cc','dd'};
            controller.studyConsentss = Stringtest;
            try {
                controller.checkPasswords();
            } catch (Exception e) {
                checkPasswordSuccess = false;
            }
            System.assertEquals(true, checkPasswordSuccess);
            controller.country = 'US';
            controller.state = 'AL';
            //controller.postalCode = '12313';
            controller.birthYear = '1994';
            controller.isAttested = true;
            controller.validateAgeOfMajority();
            controller.validateSaveButton();
            controller.translateFieldsAction();
            controller.updateStatesAction();
            controller.blobValue = EncodingUtil.base64Decode(
                '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'
            );
            controller.contentType = 'image/jpeg';
            controller.filename = 'some.jpeg';
            controller.upload();
            controller.deletePicture();
        }
        Test.stopTest();
    }
    
    @IsTest(SeeAllData=true)
    public static void testChangePasswordControllerpositive() {
      
        TestData.loadTestData();
        TestData testData = new TestData();
        
        Test.startTest();
        update new Clinical_Trial_Profile__c(id=testData.ss.Clinical_Trial_Profile__c,IQVIA_Outreach__c=true,Patient_Portal_Enabled__c = true,
                                            Terms_And_Conditions_ID__c = null,CommunityTemplate__c = 'Janssen');
        Contact delegate = new Contact(
            FirstName = 'Patient',
            LastName = 'Delegate',
            Email = 'jsmith@somemail.com',
            Is_First_Logon__c = false,    
            AccountId = testData.participant.Contact__r.AccountId,
            Current_Participant_Enrollment__c = testData.pe.Id,
            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
            userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT,
            UserCommunityIsDelegate__c = true
        );
        insert delegate;
        HCP_Enrollment__c hcpEnrollment = new HCP_Enrollment__c(
            Study_Site__c = testData.ss.Id,
            HCP_Contact__c = testData.participant.Contact__c,
            Status__c = HCPEnrollmentService.HCP_S_ON_HOLD_ACTIVATION
        );
        insert hcpEnrollment;

        Contact cc = [Select Id,Is_First_Logon__c From Contact where id =: testData.participantUser.ContactId];
        cc.Is_First_Logon__c = true;
        cc.IQVIA_Direct_Mail_Consent__c = true;
        cc.Participant_Opt_In_Status_SMS__c = true;
        cc.Participant_Opt_In_Status_Emails__c = true;
        cc.Participant_Phone_Opt_In_Permit_Phone__c = true;
        cc.UserCommunityIsDelegate__c = true;
        update cc;
        
        Participant__c objParticipant = [
            SELECT Id, Birth_Year__c
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
        objParticipant.Birth_Year__c = '1994';
        update objParticipant;
		String mockPathPrefix = '/some/path';
        System.runAs(testData.participantUser) {
            // Instantiate a new controller with all parameters in the page
            RRChangePasswordController controller = new RRChangePasswordController();
            controller.oldPassword = '123456';
            controller.mainPortal = !mockPathPrefix.startsWith('/gsk');
            controller.failingPageResponse = '7328hsfj';
            controller.US = 'nsdkak';
            controller.userLocale = 'vsajkak';
            controller.userLanguage = 'bnshds';
            controller.tcId = 'jhamcka';
            controller.newPassword = 'qwerty1';
            controller.verifyNewPassword = 'qwerty1';
            controller.CPRAlabel  = 'jhamcnka';
            controller.CPRALink  = 'jhamsbcka';
            controller.CPRAlabel = 'jhanssnmcka';
            controller.ctpName = 'gjajs';
            controller.ctpName = 'gjajs';
            controller.studyConsentSelection = false;
            controller.changePassword();
            controller.showProfileAction();

            controller.oldPassword = 'qwerty1';
            controller.newPassword = 'NewPas1234';
            controller.mainPortal = !mockPathPrefix.startsWith('/gsk');
            controller.failingPageResponse = '7328hsfj';
            controller.US = 'nsdkak';
            controller.userLocale = 'vsajkak';
            controller.userLanguage = 'bnshds';
            controller.tcId = 'jhamcka';
            controller.CPRAlabel  = 'jhamcnka';
            controller.ctpName = 'gjajs';
            controller.CPRALink  = 'jhamsbcka';
            controller.CPRAlabel = 'jhanssnmcka';
            controller.ctpName = 'gjajs';
            controller.studyConsentSelection = false;
            controller.verifyNewPassword = 'NewPas1234';
            controller.browserLanguage = '["en_US","ru-ru",""]';

            controller.updateBrowserLanguageAction();
            controller.updateLanguageAction();
            controller.initTemplateData();
          //  controller.ppValidateSaveButton();  
            controller.getCPRALink('IQVIA Referral Hub');
             controller.getCPRALink('Janssen Community');
              controller.getCPRALink('GSK Community');
              controller.getCPRALink('IQVIA Patient Portal');
           

            controller.notEnrollNow = false;
            controller.states = new List<SelectOption>{
                new SelectOption('CA', 'CA'),
                new SelectOption('TX', 'TX')
            };

            /* Check with empty fields */
            controller.contact.LastName = null;
            controller.account.Name = null;
            Boolean checkPasswordSuccess = true;
            try {
                controller.checkPasswords();
            } catch (Exception e) {
                checkPasswordSuccess = false;
            }
            System.assertEquals(true, checkPasswordSuccess);
            Test.clearApexPageMessages();

            /* Check with full fields */
            controller.contact.FirstName = 'TestFirstName';
            controller.contact.LastName = 'TestLastName';
            controller.contact.userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT;
            controller.contact.MailingCountryCode = 'US';
            controller.contact.MailingStateCode = 'TX';
            controller.contact.MailingStreet = 'Test st.';
            controller.contact.MailingCity = 'Test City';
            controller.contact.MailingCountry = 'US';
            controller.contact.MailingPostalCode = '123000';
            controller.contact.Phone = '(999)555-0000';
            controller.account.Name = 'TestAccountName';
            List<SelectOption> testStates = new List<SelectOption>();
            testStates.add(new SelectOption('CA', 'California'));
            controller.states = testStates;
           List<String> Stringtest = new List<String>{'aa','bb','cc','dd'};
            controller.studyConsentss = Stringtest;
            try {
                controller.checkPasswords();
            } catch (Exception e) {
                checkPasswordSuccess = false;
            }
            System.assertEquals(true, checkPasswordSuccess);
            controller.country = 'US';
            controller.state = 'AL';
            //controller.postalCode = '12313';
            controller.birthYear = '1994';
            controller.isAttested = true;
            controller.validateAgeOfMajority();
            controller.validateSaveButton();
            controller.translateFieldsAction();
            controller.updateStatesAction();
            controller.blobValue = EncodingUtil.base64Decode(
                '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'
            );
            controller.contentType = 'image/jpeg';
            controller.filename = 'some.jpeg';
            controller.upload();
            controller.deletePicture();
        }
        Test.stopTest();
    }
    @IsTest(SeeAllData=true)
    public static void testChangePasswordControllerpositivejkj() {
      
        TestData.loadTestData();
        TestData testData = new TestData();
        
        Test.startTest();
        update new Clinical_Trial_Profile__c(id=testData.ss.Clinical_Trial_Profile__c,CommunityTemplate__c = 'PatientPortal',IQVIA_Outreach__c=true,Patient_Portal_Enabled__c = true,
                                            Terms_And_Conditions_ID__c = null);
        Contact delegate = new Contact(
            FirstName = 'Patient',
            LastName = 'Delegate',
            Email = 'jsmith@somemail.com',
            Is_First_Logon__c = false,    
            AccountId = testData.participant.Contact__r.AccountId,
            Current_Participant_Enrollment__c = testData.pe.Id,
            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
            userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT,
            UserCommunityIsDelegate__c = true
        );
        insert delegate;
        HCP_Enrollment__c hcpEnrollment = new HCP_Enrollment__c(
            Study_Site__c = testData.ss.Id,
            HCP_Contact__c = testData.participant.Contact__c,
            Status__c = HCPEnrollmentService.HCP_S_ON_HOLD_ACTIVATION
        );
        insert hcpEnrollment;

        Contact cc = [Select Id,Is_First_Logon__c From Contact where id =: testData.participantUser.ContactId];
        cc.Is_First_Logon__c = true;
        cc.IQVIA_Direct_Mail_Consent__c = true;
        cc.Participant_Opt_In_Status_SMS__c = true;
        cc.Participant_Opt_In_Status_Emails__c = true;
        cc.Participant_Phone_Opt_In_Permit_Phone__c = true;
        cc.UserCommunityIsDelegate__c = true;
        update cc;
        
        Participant__c objParticipant = [
            SELECT Id, Birth_Year__c
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
        objParticipant.Birth_Year__c = '1994';
        update objParticipant;
		String mockPathPrefix = '/some/path';
        System.runAs(testData.participantUser) {
            // Instantiate a new controller with all parameters in the page
            RRChangePasswordController controller = new RRChangePasswordController();
            controller.oldPassword = '123456';
            controller.mainPortal = !mockPathPrefix.startsWith('/gsk');
            controller.failingPageResponse = '7328hsfj';
            controller.US = 'nsdkak';
            controller.userLocale = 'vsajkak';
            controller.userLanguage = 'bnshds';
            controller.tcId = 'jhamcka';
            controller.newPassword = 'qwerty1';
            controller.verifyNewPassword = 'qwerty1';
            controller.CPRAlabel  = 'jhamcnka';
            controller.CPRALink  = 'jhamsbcka';
            controller.CPRAlabel = 'jhanssnmcka';
            controller.ctpName = 'gjajs';
            controller.ctpName = 'gjajs';
            controller.studyConsentSelection = false;
            controller.changePassword();
            controller.showProfileAction();

            controller.oldPassword = 'qwerty1';
            controller.newPassword = 'NewPas1234';
            controller.mainPortal = !mockPathPrefix.startsWith('/gsk');
            controller.failingPageResponse = '7328hsfj';
            controller.US = 'nsdkak';
            controller.userLocale = 'vsajkak';
            controller.userLanguage = 'bnshds';
            controller.tcId = 'jhamcka';
            controller.CPRAlabel  = 'jhamcnka';
            controller.ctpName = 'gjajs';
            controller.CPRALink  = 'jhamsbcka';
            controller.CPRAlabel = 'jhanssnmcka';
            controller.ctpName = 'gjajs';
            controller.studyConsentSelection = false;
            controller.verifyNewPassword = 'NewPas1234';
            controller.browserLanguage = '["en_US","ru-ru",""]';

            controller.updateBrowserLanguageAction();
            controller.updateLanguageAction();
            controller.initTemplateData();
          //  controller.ppValidateSaveButton();  
            controller.getCPRALink('IQVIA Referral Hub');
             controller.getCPRALink('Janssen Community');
              controller.getCPRALink('GSK Community');
              controller.getCPRALink('IQVIA Patient Portal');
           

            controller.notEnrollNow = false;
            controller.states = new List<SelectOption>{
                new SelectOption('CA', 'CA'),
                new SelectOption('TX', 'TX')
            };

            /* Check with empty fields */
            controller.contact.LastName = null;
            controller.account.Name = null;
            Boolean checkPasswordSuccess = true;
            try {
                controller.checkPasswords();
            } catch (Exception e) {
                checkPasswordSuccess = false;
            }
            System.assertEquals(true, checkPasswordSuccess);
            Test.clearApexPageMessages();

            /* Check with full fields */
            controller.contact.FirstName = 'TestFirstName';
            controller.contact.LastName = 'TestLastName';
            controller.contact.userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT;
            controller.contact.MailingCountryCode = 'US';
            controller.contact.MailingStateCode = 'TX';
            controller.contact.MailingStreet = 'Test st.';
            controller.contact.MailingCity = 'Test City';
            controller.contact.MailingCountry = 'US';
            controller.contact.MailingPostalCode = '123000';
            controller.contact.Phone = '(999)555-0000';
            controller.account.Name = 'TestAccountName';
            List<SelectOption> testStates = new List<SelectOption>();
            testStates.add(new SelectOption('CA', 'California'));
            controller.states = testStates;
            List<String> Stringtest = new List<String>{'aa','bb','cc','dd'};
            controller.studyConsentss = Stringtest;
            try {
                controller.checkPasswords();
            } catch (Exception e) {
                checkPasswordSuccess = false;
            }
            System.assertEquals(true, checkPasswordSuccess);
            controller.country = 'US';
            controller.state = 'AL';
            //controller.postalCode = '12313';
            controller.birthYear = '1994';
            controller.isAttested = true;
            controller.validateAgeOfMajority();
            controller.validateSaveButton();
            controller.translateFieldsAction();
            controller.updateStatesAction();
            controller.blobValue = EncodingUtil.base64Decode(
                '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'
            );
            controller.contentType = 'image/jpeg';
            controller.filename = 'some.jpeg';
            controller.upload();
            controller.deletePicture();
        }
        Test.stopTest();
    }
    @IsTest(SeeAllData=true)
    public static void testChangePasswordControllerpositivejkjfasjd() {
      
        TestData.loadTestData();
        TestData testData = new TestData();
        
        Test.startTest();
        update new Clinical_Trial_Profile__c(id=testData.ss.Clinical_Trial_Profile__c,CommunityTemplate__c = 'PatientPortal',IQVIA_Outreach__c=true,Patient_Portal_Enabled__c = true,
                                            Terms_And_Conditions_ID__c = null);
        Contact delegate = new Contact(
            FirstName = 'Patient',
            LastName = 'Delegate',
            Email = 'jsmith@somemail.com',
            Is_First_Logon__c = false,    
            AccountId = testData.participant.Contact__r.AccountId,
            Current_Participant_Enrollment__c = testData.pe.Id,
            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
            userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT,
            UserCommunityIsDelegate__c = true
        );
        insert delegate;
        HCP_Enrollment__c hcpEnrollment = new HCP_Enrollment__c(
            Study_Site__c = testData.ss.Id,
            HCP_Contact__c = testData.participant.Contact__c,
            Status__c = HCPEnrollmentService.HCP_S_ON_HOLD_ACTIVATION
        );
        insert hcpEnrollment;

        Contact cc = [Select Id,Is_First_Logon__c From Contact where id =: testData.participantUser.ContactId];
        cc.Is_First_Logon__c = true;
        cc.IQVIA_Direct_Mail_Consent__c = true;
        cc.Participant_Opt_In_Status_SMS__c = true;
        cc.Participant_Opt_In_Status_Emails__c = true;
        cc.Participant_Phone_Opt_In_Permit_Phone__c = true;
        cc.UserCommunityIsDelegate__c = true;
        update cc;
        
        Participant__c objParticipant = [
            SELECT Id, Birth_Year__c
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
        objParticipant.Birth_Year__c = String.valueOf((Date.today()).year()-2);
        update objParticipant;
		String mockPathPrefix = '/some/path';
        System.runAs(testData.participantUser) {
            // Instantiate a new controller with all parameters in the page
            RRChangePasswordController controller = new RRChangePasswordController();
            controller.oldPassword = '123456';
            controller.mainPortal = !mockPathPrefix.startsWith('/gsk');
            controller.failingPageResponse = '7328hsfj';
            controller.US = 'nsdkak';
            controller.userLocale = 'vsajkak';
            controller.userLanguage = 'bnshds';
            controller.tcId = 'jhamcka';
            controller.newPassword = 'qwerty1';
            controller.verifyNewPassword = 'qwerty1';
            controller.CPRAlabel  = 'jhamcnka';
            controller.CPRALink  = 'jhamsbcka';
            controller.CPRAlabel = 'jhanssnmcka';
            controller.ctpName = 'gjajs';
            controller.ctpName = 'gjajs';
            controller.studyConsentSelection = false;
            controller.changePassword();
            controller.showProfileAction();
            controller.oldPassword = 'qwerty1';
            controller.newPassword = 'NewPas1234';
            controller.mainPortal = !mockPathPrefix.startsWith('/gsk');
            controller.failingPageResponse = '7328hsfj';
            controller.US = 'nsdkak';
            controller.userLocale = 'vsajkak';
            controller.userLanguage = 'bnshds';
            controller.tcId = 'jhamcka';
            controller.CPRAlabel  = 'jhamcnka';
            controller.ctpName = 'gjajs';
            controller.CPRALink  = 'jhamsbcka';
            controller.CPRAlabel = 'jhanssnmcka';
            controller.ctpName = 'gjajs';
            controller.studyConsentSelection = false;
            controller.verifyNewPassword = 'NewPas1234';
            controller.browserLanguage = '["en_US","ru-ru",""]';

            controller.updateBrowserLanguageAction();
            controller.updateLanguageAction();
            controller.initTemplateData();
          //  controller.ppValidateSaveButton();  
            controller.getCPRALink('IQVIA Referral Hub');
             controller.getCPRALink('Janssen Community');
              controller.getCPRALink('GSK Community');
              controller.getCPRALink('IQVIA Patient Portal');
           

            controller.notEnrollNow = false;
            controller.states = new List<SelectOption>{
                new SelectOption('CA', 'CA'),
                new SelectOption('TX', 'TX')
            };

            /* Check with empty fields */
            controller.contact.LastName = null;
            controller.account.Name = null;
            Boolean checkPasswordSuccess = true;
            try {
                controller.checkPasswords();
            } catch (Exception e) {
                checkPasswordSuccess = false;
            }
            System.assertEquals(true, checkPasswordSuccess);
            Test.clearApexPageMessages();

            /* Check with full fields */
            controller.contact.FirstName = 'TestFirstName';
            controller.contact.LastName = 'TestLastName';
            controller.contact.userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT;
            controller.contact.MailingCountryCode = 'US';
            controller.contact.MailingStateCode = 'TX';
            controller.contact.MailingStreet = 'Test st.';
            controller.contact.MailingCity = 'Test City';
            controller.contact.MailingCountry = 'US';
            controller.contact.MailingPostalCode = '123000';
            controller.contact.Phone = '(999)555-0000';
            controller.account.Name = 'TestAccountName';
            List<SelectOption> testStates = new List<SelectOption>();
            testStates.add(new SelectOption('CA', 'California'));
            controller.states = testStates;
            List<String> Stringtest = new List<String>{'aa','bb','cc','dd'};
            controller.studyConsentss = Stringtest;
            try {
                controller.checkPasswords();
            } catch (Exception e) {
                checkPasswordSuccess = false;
            }
            System.assertEquals(true, checkPasswordSuccess);
            controller.country = 'US';
            controller.state = 'AL';
            //controller.postalCode = '12313';
            controller.birthYear = '1994';
            controller.isAttested = true;
            controller.validateAgeOfMajority();
            controller.validateSaveButton();
            controller.translateFieldsAction();
            controller.updateStatesAction();
            controller.blobValue = EncodingUtil.base64Decode(
                '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'
            );
            controller.contentType = 'image/jpeg';
            controller.filename = 'some.jpeg';
            controller.upload();
            controller.deletePicture();
        }
        Test.stopTest();
    }
    @IsTest(SeeAllData=true)
    public static void testChangePasswordControllerpositiveuii() {
      
        TestData.loadTestData();
        TestData testData = new TestData();
        //run test:
        Test.startTest();
        Contact delegate = new Contact(
            FirstName = 'Patient',
            LastName = 'Delegate',
            Email = 'jsmith@somemail.com',
            Is_First_Logon__c = false,    
            AccountId = testData.participant.Contact__r.AccountId,
            Current_Participant_Enrollment__c = testData.pe.Id,
            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
            userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT,
            UserCommunityIsDelegate__c = true
        );
        insert delegate;
        HCP_Enrollment__c hcpEnrollment = new HCP_Enrollment__c(
            Study_Site__c = testData.ss.Id,
            HCP_Contact__c = testData.participant.Contact__c,
            Status__c = HCPEnrollmentService.HCP_S_ON_HOLD_ACTIVATION
        );
        insert hcpEnrollment;

        Contact cc = [Select Id,Is_First_Logon__c,userCommunityMode__c From Contact where id =: testData.participantUser.ContactId];
        cc.userCommunityMode__c = CommunityService.USER_MODE_HCP;
        cc.Is_First_Logon__c = true;
         cc.IQVIA_Direct_Mail_Consent__c = true;
        cc.Participant_Opt_In_Status_SMS__c = true;
        cc.Participant_Opt_In_Status_Emails__c = true;
        cc.Participant_Phone_Opt_In_Permit_Phone__c = true;
        cc.UserCommunityIsDelegate__c = true;
        update cc;
        
        Participant__c objParticipant = [
            SELECT Id, Birth_Year__c
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
        objParticipant.Birth_Year__c = '1994';
        update objParticipant;
		String mockPathPrefix = '/some/path';
        System.runAs(testData.participantUser) {
            // Instantiate a new controller with all parameters in the page
            RRChangePasswordController controller = new RRChangePasswordController();
            controller.oldPassword = '123456';
            controller.mainPortal = !mockPathPrefix.startsWith('/gsk');
            controller.failingPageResponse = '7328hsfj';
            controller.US = 'nsdkak';
            controller.userLocale = 'vsajkak';
            controller.userLanguage = 'bnshds';
            controller.tcId = 'jhamcka';
            controller.newPassword = 'qwerty1';
            controller.verifyNewPassword = 'qwerty1';
            controller.CPRAlabel  = 'jhamcnka';
            controller.CPRALink  = 'jhamsbcka';
            controller.CPRAlabel = 'jhanssnmcka';
            controller.ctpName = 'gjajs';
            controller.ctpName = 'gjajs';
            controller.studyConsentSelection = false;
            controller.changePassword();
            controller.showProfileAction();
            controller.ppChangePassword();

            controller.oldPassword = 'qwerty1';
            controller.newPassword = 'NewPas1234';
            controller.mainPortal = !mockPathPrefix.startsWith('/gsk');
            controller.failingPageResponse = '7328hsfj';
            controller.US = 'nsdkak';
            controller.userLocale = 'vsajkak';
            controller.userLanguage = 'bnshds';
            controller.tcId = 'jhamcka';
            controller.CPRAlabel  = 'jhamcnka';
            controller.ctpName = 'gjajs';
            controller.CPRALink  = 'jhamsbcka';
            controller.CPRAlabel = 'jhanssnmcka';
            controller.ctpName = 'gjajs';
            controller.studyConsentSelection = false;
            controller.verifyNewPassword = 'NewPas1234';
            controller.browserLanguage = '["en_US","ru-ru",""]';

            controller.updateBrowserLanguageAction();
            controller.updateLanguageAction();
            controller.initTemplateData();
          //  controller.ppValidateSaveButton();  
            controller.getCPRALink('IQVIA Referral Hub');
             controller.getCPRALink('Janssen Community');
              controller.getCPRALink('GSK Community');
              controller.getCPRALink('IQVIA Patient Portal');
           

            controller.notEnrollNow = false;
            controller.states = new List<SelectOption>{
                new SelectOption('CA', 'CA'),
                new SelectOption('TX', 'TX')
            };

            /* Check with empty fields */
            controller.contact.LastName = null;
            controller.account.Name = null;
            Boolean checkPasswordSuccess = true;
            try {
                controller.checkPasswords();
            } catch (Exception e) {
                checkPasswordSuccess = false;
            }
            System.assertEquals(true, checkPasswordSuccess);
            Test.clearApexPageMessages();

            /* Check with full fields */
            controller.contact.FirstName = 'TestFirstName';
            controller.contact.LastName = 'TestLastName';
            controller.contact.userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT;
            controller.contact.MailingCountryCode = 'US';
            controller.contact.MailingStateCode = 'TX';
            controller.contact.MailingStreet = 'Test st.';
            controller.contact.MailingCity = 'Test City';
            controller.contact.MailingCountry = 'US';
            controller.contact.MailingPostalCode = '123000';
            controller.contact.Phone = '(999)555-0000';
            controller.account.Name = 'TestAccountName';
            List<SelectOption> testStates = new List<SelectOption>();
            testStates.add(new SelectOption('CA', 'California'));
            controller.states = testStates;
            List<String> Stringtest = new List<String>{'aa','bb','cc','dd'};
            controller.studyConsentss = Stringtest;
            try {
                controller.checkPasswords();
            } catch (Exception e) {
                checkPasswordSuccess = false;
            }
            System.assertEquals(true, checkPasswordSuccess);
            controller.country = 'US';
            controller.state = 'AL';
            //controller.postalCode = '12313';
            controller.birthYear = '1994';
            controller.isAttested = true;
            controller.blobValue = EncodingUtil.base64Decode(
                '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'
            );
            controller.contentType = 'image/jpeg';
            controller.filename = 'some.jpeg';
            controller.upload();
            controller.deletePicture();
        }
        Test.stopTest();
    }
    @isTest
      public static void testchangepasswordcontrollerNew() {
           TestData.loadTestData();
        TestData testData = new TestData();
        update new Clinical_Trial_Profile__c(id=testData.ss.Clinical_Trial_Profile__c,CommunityTemplate__c = 'PatientPortal',IQVIA_Outreach__c=true,Patient_Portal_Enabled__c = true);
           Contact delegate = new Contact(
            FirstName = 'Patient',
            LastName = 'Delegate',
            Email = 'jsmith@somemail.com',
            Is_First_Logon__c = false,    
            AccountId = testData.participant.Contact__r.AccountId,
            Current_Participant_Enrollment__c = testData.pe.Id,
            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
            userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT,
            UserCommunityIsDelegate__c = true
        );
        insert delegate;
        Participant__c p = new Participant__c(
            First_Name__c = 'Patient',
            Last_Name__c = 'Delegate',
            Contact__c = delegate.Id
        );
        insert p;

        update new Participant_Enrollment__c(id=testData.pe.Id, Permit_Voice_Text_contact_for_this_study__c = true,Permit_Mail_Email_contact_for_this_study__c = true,
        Permit_SMS_Text_for_this_study__c = true,Study_Direct_Mail_Consent__c = true);
        Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = delegate.Id,
            Contact__r = delegate,
            Participant__c = testData.participant.Id,
            Participant__r = testData.participant
        );
        insert patientDelegate;
       	
        Patient_Delegate_Enrollment__c objPDER = new Patient_Delegate_Enrollment__c();
        objPDER.Participant_Enrollment__c = testData.pe.Id;
        objPDER.Patient_Delegate__c =patientDelegate.ID;
        objPDER.Primary_Delegate__c = TRUE;
        objPDER.Status__c = 'Active';
        objPDER.Study_Phone_Consent__c = true;
        objPDER.Study_Email_Consent__c = true;
        objPDER.Study_SMS_Consent__c = true;
        objPDER.Study_Direct_Mail_Consent__c = true;
        insert objPDER;
          List<Participant_Enrollment__c> lstPER = new list<Participant_Enrollment__c> ();
          lstPER = [SELECT ID,Clinical_Trial_Profile__C,Clinical_Trial_Profile__r.IQVIA_Outreach__c from Participant_Enrollment__c
                   where id=:testData.pe.Id];
          List<Patient_Delegate_Enrollment__c> lstPDER = new List<Patient_Delegate_Enrollment__c> ();
          lstPDER = [SELECT ID,Participant_Enrollment__c,Participant_Enrollment__R.Clinical_Trial_Profile__r.IQVIA_Outreach__c
                     	from Patient_Delegate_Enrollment__c where id=:objPDER.id];
           Participant__c objParticipant = [
            SELECT Id, Birth_Year__c
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
        //objParticipant.Birth_Year__c = '1994';
       // update objParticipant;
       String mockPathPrefix = '/some/path';
		test.startTest();
        System.runAs(testData.participantUser) {
          
          RRChangePasswordController objcontroller = new RRChangePasswordController(); 
          objcontroller.setPartIQVIAOurtreachToggle(lstPER);
          objcontroller.setDelIQVIAOurtreachToggle(lstPDER);
            objcontroller.toggleNewPassword();
                objcontroller.togglePassword();
           objcontroller.ppValidateSaveButton();
            objcontroller.oldPassword = '123456';
            objcontroller.isParticipant = true;
            objcontroller.newPassword = 'qwerty111113333';
            objcontroller.mainPortal = !mockPathPrefix.startsWith('/gsk');
            objcontroller.failingPageResponse = '7328hsfj';
            objcontroller.US = 'nsdkak';
            objcontroller.perListforCommPref = lstPER;
            objcontroller.allPdeList = lstPDER;
            objcontroller.userLocale = 'vsajkak';
            objcontroller.userLanguage = 'bnshds';
            objcontroller.tcId = 'jhamcka';
            objcontroller.ctpName = 'gjajs';
            objcontroller.ctpName = 'gjajs';
            objcontroller.CPRAlabel  = 'jhamcnka';
            objcontroller.CPRALink  = 'jhamsbcka';
            objcontroller.CPRAlabel = 'jhanssnmcka';
            objcontroller.studyConsentSelection = false;
            objcontroller.verifyNewPassword = 'qwerty111113333';
             objcontroller.ppChangePassword();
            objcontroller.changePassword();
         
        }
           test.stopTest();
      }
      @isTest
      public static void testchangepasswordcontrollerNewJannnsenpp() {
           TestData.loadTestData();
        TestData testData = new TestData();
        update new Clinical_Trial_Profile__c(id=testData.ss.Clinical_Trial_Profile__c,CommunityTemplate__c = 'PatientPortal',IQVIA_Outreach__c=true,Patient_Portal_Enabled__c = true,
        Terms_And_Conditions_ID__c = null);
           Contact delegate = new Contact(
            FirstName = 'Patient',
            LastName = 'Delegate',
            Email = 'jsmith@somemail.com',
            Is_First_Logon__c = false,    
            AccountId = testData.participant.Contact__r.AccountId,
            Current_Participant_Enrollment__c = testData.pe.Id,
            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
            userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT,
            UserCommunityIsDelegate__c = true
        );
        insert delegate;
        Participant__c p = new Participant__c(
            First_Name__c = 'Patient',
            Last_Name__c = 'Delegate',
            Contact__c = delegate.Id
        );
        insert p;

        update new Participant_Enrollment__c(id=testData.pe.Id, Permit_Voice_Text_contact_for_this_study__c = true,Permit_Mail_Email_contact_for_this_study__c = true,
        Permit_SMS_Text_for_this_study__c = true,Study_Direct_Mail_Consent__c = true);
        Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = delegate.Id,
            Contact__r = delegate,
            Participant__c = testData.participant.Id,
            Participant__r = testData.participant
        );
        insert patientDelegate;
       	
        Patient_Delegate_Enrollment__c objPDER = new Patient_Delegate_Enrollment__c();
        objPDER.Participant_Enrollment__c = testData.pe.Id;
        objPDER.Patient_Delegate__c =patientDelegate.ID;
        objPDER.Primary_Delegate__c = TRUE;
        objPDER.Status__c = 'Active';
        objPDER.Study_Phone_Consent__c = true;
        objPDER.Study_Email_Consent__c = true;
        objPDER.Study_SMS_Consent__c = true;
        objPDER.Study_Direct_Mail_Consent__c = true;
        insert objPDER;
          List<Participant_Enrollment__c> lstPER = new list<Participant_Enrollment__c> ();
          lstPER = [SELECT ID,Clinical_Trial_Profile__C,Clinical_Trial_Profile__r.IQVIA_Outreach__c from Participant_Enrollment__c
                   where id=:testData.pe.Id];
          List<Patient_Delegate_Enrollment__c> lstPDER = new List<Patient_Delegate_Enrollment__c> ();
          lstPDER = [SELECT ID,Participant_Enrollment__c,Participant_Enrollment__R.Clinical_Trial_Profile__r.IQVIA_Outreach__c
                     	from Patient_Delegate_Enrollment__c where id=:objPDER.id];
           Participant__c objParticipant = [
            SELECT Id, Birth_Year__c
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
        //objParticipant.Birth_Year__c = '1994';
       // update objParticipant;
       String mockPathPrefix = '/some/path';
		test.startTest();
        System.runAs(testData.participantUser) {
          
          RRChangePasswordController objcontroller = new RRChangePasswordController(); 
          objcontroller.setPartIQVIAOurtreachToggle(lstPER);
          objcontroller.setDelIQVIAOurtreachToggle(lstPDER);
            objcontroller.toggleNewPassword();
                objcontroller.togglePassword();
           objcontroller.ppValidateSaveButton();
            objcontroller.oldPassword = '123456';
            objcontroller.isParticipant = true;
            objcontroller.newPassword = 'qwerty111113333';
            objcontroller.mainPortal = !mockPathPrefix.startsWith('/gsk');
            objcontroller.failingPageResponse = '7328hsfj';
            objcontroller.US = 'nsdkak';
            objcontroller.perListforCommPref = lstPER;
            objcontroller.allPdeList = lstPDER;
            objcontroller.userLocale = 'vsajkak';
            objcontroller.userLanguage = 'bnshds';
            objcontroller.tcId = 'jhamcka';
            objcontroller.ctpName = 'gjajs';
            objcontroller.ctpName = 'gjajs';
            objcontroller.CPRAlabel  = 'jhamcnka';
            objcontroller.CPRALink  = 'jhamsbcka';
            objcontroller.CPRAlabel = 'jhanssnmcka';
            objcontroller.studyConsentSelection = false;
            objcontroller.verifyNewPassword = 'qwerty111113333';
             objcontroller.ppChangePassword();
            objcontroller.changePassword();
         
        }
           test.stopTest();
      }
      @isTest
      public static void testchangepasswordcontrollerNewJannnsenpplask() {
           TestData.loadTestData();
        TestData testData = new TestData();
        update new Clinical_Trial_Profile__c(id=testData.ss.Clinical_Trial_Profile__c,CommunityTemplate__c = 'Janssen',IQVIA_Outreach__c=true,Patient_Portal_Enabled__c = true,
        Terms_And_Conditions_ID__c = null);
           Contact delegate = new Contact(
            FirstName = 'Patient',
            LastName = 'Delegate',
            Email = 'jsmith@somemail.com',
            Is_First_Logon__c = false,    
            AccountId = testData.participant.Contact__r.AccountId,
            Current_Participant_Enrollment__c = testData.pe.Id,
            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
            userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT,
            UserCommunityIsDelegate__c = true
        );
        insert delegate;
        Participant__c p = new Participant__c(
            First_Name__c = 'Patient',
            Last_Name__c = 'Delegate',
            Contact__c = delegate.Id
        );
        insert p;

        update new Participant_Enrollment__c(id=testData.pe.Id, Permit_Voice_Text_contact_for_this_study__c = true,Permit_Mail_Email_contact_for_this_study__c = true,
        Permit_SMS_Text_for_this_study__c = true,Study_Direct_Mail_Consent__c = true);
        Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = delegate.Id,
            Contact__r = delegate,
            Participant__c = testData.participant.Id,
            Participant__r = testData.participant
        );
        insert patientDelegate;
       	
        Patient_Delegate_Enrollment__c objPDER = new Patient_Delegate_Enrollment__c();
        objPDER.Participant_Enrollment__c = testData.pe.Id;
        objPDER.Patient_Delegate__c =patientDelegate.ID;
        objPDER.Primary_Delegate__c = TRUE;
        objPDER.Status__c = 'Active';
        objPDER.Study_Phone_Consent__c = true;
        objPDER.Study_Email_Consent__c = true;
        objPDER.Study_SMS_Consent__c = true;
        objPDER.Study_Direct_Mail_Consent__c = true;
        insert objPDER;
          List<Participant_Enrollment__c> lstPER = new list<Participant_Enrollment__c> ();
          lstPER = [SELECT ID,Clinical_Trial_Profile__C,Clinical_Trial_Profile__r.IQVIA_Outreach__c from Participant_Enrollment__c
                   where id=:testData.pe.Id];
          List<Patient_Delegate_Enrollment__c> lstPDER = new List<Patient_Delegate_Enrollment__c> ();
          lstPDER = [SELECT ID,Participant_Enrollment__c,Participant_Enrollment__R.Clinical_Trial_Profile__r.IQVIA_Outreach__c
                     	from Patient_Delegate_Enrollment__c where id=:objPDER.id];
           Participant__c objParticipant = [
            SELECT Id, Birth_Year__c
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
        //objParticipant.Birth_Year__c = '1994';
       // update objParticipant;
       String mockPathPrefix = '/some/path';
		test.startTest();
        System.runAs(testData.participantUser) {
          
          RRChangePasswordController objcontroller = new RRChangePasswordController(); 
          objcontroller.setPartIQVIAOurtreachToggle(lstPER);
          objcontroller.setDelIQVIAOurtreachToggle(lstPDER);
            objcontroller.toggleNewPassword();
                objcontroller.togglePassword();
           objcontroller.ppValidateSaveButton();
            objcontroller.oldPassword = '123456';
            objcontroller.isParticipant = true;
            objcontroller.newPassword = 'qwerty111113333';
            objcontroller.mainPortal = !mockPathPrefix.startsWith('/gsk');
            objcontroller.failingPageResponse = '7328hsfj';
            objcontroller.US = 'nsdkak';
            objcontroller.perListforCommPref = lstPER;
            objcontroller.allPdeList = lstPDER;
            objcontroller.userLocale = 'vsajkak';
            objcontroller.userLanguage = 'bnshds';
            objcontroller.tcId = 'jhamcka';
            objcontroller.ctpName = 'gjajs';
            objcontroller.ctpName = 'gjajs';
            objcontroller.CPRAlabel  = 'jhamcnka';
            objcontroller.CPRALink  = 'jhamsbcka';
            objcontroller.CPRAlabel = 'jhanssnmcka';
            objcontroller.studyConsentSelection = false;
            objcontroller.verifyNewPassword = 'qwerty111113333';
             objcontroller.ppChangePassword();
            objcontroller.changePassword();
         
        }
           test.stopTest();
      }
      @isTest
      public static void testchangepasswordcontrollerDelegatejanssenP() {
           TestData.loadTestData();
        TestData testData = new TestData();
        update new Clinical_Trial_Profile__c(id=testData.ss.Clinical_Trial_Profile__c,CommunityTemplate__c = 'PatientPortal',IQVIA_Outreach__c=true,Patient_Portal_Enabled__c = true,
        Terms_And_Conditions_ID__c = null);
          
          
          User delegate = testData.createPatientDelegate();
        insert delegate;
          Id delegateContactId = [SELECT ContactId FROM User WHERE Id = :delegate.Id].ContactId;
          Patient_Delegate__c patientDelegate = [
            SELECT Id, Participant__c, Contact__c
            FROM Patient_Delegate__c
            WHERE Contact__c = :delegateContactId
        ];
        patientDelegate.Status__c = 'Active';
        update patientDelegate;
          Patient_Delegate_Enrollment__c pde = new Patient_Delegate_Enrollment__c();
        pde.Participant_Enrollment__c = testData.pe.Id;
        pde.Patient_Delegate__c  = patientDelegate.id;
        pde.Status__c = 'Active';
        pde.Primary_Delegate__c=true;
        pde.Study_Phone_Consent__c = true;
        pde.Study_Email_Consent__c = true;
        pde.Study_SMS_Consent__c = true;
        pde.Study_Direct_Mail_Consent__c = true;
        insert pde;
       
          List<Participant_Enrollment__c> lstPER = new list<Participant_Enrollment__c> ();
          lstPER = [SELECT ID,Clinical_Trial_Profile__C,Clinical_Trial_Profile__r.IQVIA_Outreach__c from Participant_Enrollment__c
                   where id=:testData.pe.Id];
          List<Patient_Delegate_Enrollment__c> lstPDER = new List<Patient_Delegate_Enrollment__c> ();
          lstPDER.add(pde);
           Participant__c objParticipant = [
            SELECT Id, Birth_Year__c
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
        objParticipant.Birth_Year__c = '1994';
        update objParticipant;
          String mockPathPrefix = '/some/path';
		test.startTest();
        System.runAs(delegate) {
          
          RRChangePasswordController objcontroller = new RRChangePasswordController(); 
          objcontroller.setPartIQVIAOurtreachToggle(lstPER);
          objcontroller.setDelIQVIAOurtreachToggle(lstPDER);
            objcontroller.toggleNewPassword();
                objcontroller.togglePassword();
             objcontroller.updateYearOfBirth();
            objcontroller.oldPassword = '123456';
            objcontroller.newPassword = 'qwerty111113333';
            objcontroller.perListforCommPref = lstPER;
            objcontroller.allPdeList = lstPDER;
            objcontroller.mainPortal = !mockPathPrefix.startsWith('/gsk');
            objcontroller.failingPageResponse = '7328hsfj';
            objcontroller.US = 'nsdkak';
            objcontroller.userLocale = 'vsajkak';
            objcontroller.userLanguage = 'bnshds';
            objcontroller.tcId = 'jhamcka';
            objcontroller.CPRAlabel  = 'jhamcnka';
            objcontroller.ctpName = 'gjajs';
            objcontroller.CPRALink  = 'jhamsbcka';
            objcontroller.CPRAlabel = 'jhanssnmcka';
            objcontroller.studyConsentSelection = false;
            objcontroller.verifyNewPassword = 'qwerty111113333';
             objcontroller.ppChangePassword();
            objcontroller.changePassword();
         
        }
           test.stopTest();
      }
      @isTest
      public static void testchangepasswordcontrollerDelegatejanssen() {
           TestData.loadTestData();
        TestData testData = new TestData();
        update new Clinical_Trial_Profile__c(id=testData.ss.Clinical_Trial_Profile__c,CommunityTemplate__c = 'Janssen',IQVIA_Outreach__c=true,Patient_Portal_Enabled__c = true,
        Terms_And_Conditions_ID__c = null);
          
          
          User delegate = testData.createPatientDelegate();
        insert delegate;
          Id delegateContactId = [SELECT ContactId FROM User WHERE Id = :delegate.Id].ContactId;
          Patient_Delegate__c patientDelegate = [
            SELECT Id, Participant__c, Contact__c
            FROM Patient_Delegate__c
            WHERE Contact__c = :delegateContactId
        ];
        patientDelegate.Status__c = 'Active';
        update patientDelegate;
          Patient_Delegate_Enrollment__c pde = new Patient_Delegate_Enrollment__c();
        pde.Participant_Enrollment__c = testData.pe.Id;
        pde.Patient_Delegate__c  = patientDelegate.id;
        pde.Status__c = 'Active';
        pde.Primary_Delegate__c=true;
        pde.Study_Phone_Consent__c = true;
        pde.Study_Email_Consent__c = true;
        pde.Study_SMS_Consent__c = true;
        pde.Study_Direct_Mail_Consent__c = true;
        insert pde;
       
          List<Participant_Enrollment__c> lstPER = new list<Participant_Enrollment__c> ();
          lstPER = [SELECT ID,Clinical_Trial_Profile__C,Clinical_Trial_Profile__r.IQVIA_Outreach__c from Participant_Enrollment__c
                   where id=:testData.pe.Id];
          List<Patient_Delegate_Enrollment__c> lstPDER = new List<Patient_Delegate_Enrollment__c> ();
          lstPDER.add(pde);
           Participant__c objParticipant = [
            SELECT Id, Birth_Year__c
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
        objParticipant.Birth_Year__c = '1994';
        update objParticipant;
          String mockPathPrefix = '/some/path';
		test.startTest();
        System.runAs(delegate) {
          
          RRChangePasswordController objcontroller = new RRChangePasswordController(); 
          objcontroller.setPartIQVIAOurtreachToggle(lstPER);
          objcontroller.setDelIQVIAOurtreachToggle(lstPDER);
            objcontroller.toggleNewPassword();
                objcontroller.togglePassword();
             objcontroller.updateYearOfBirth();
            objcontroller.oldPassword = '123456';
            objcontroller.newPassword = 'qwerty111113333';
            objcontroller.perListforCommPref = lstPER;
            objcontroller.allPdeList = lstPDER;
            objcontroller.mainPortal = !mockPathPrefix.startsWith('/gsk');
            objcontroller.failingPageResponse = '7328hsfj';
            objcontroller.US = 'nsdkak';
            objcontroller.userLocale = 'vsajkak';
            objcontroller.userLanguage = 'bnshds';
            objcontroller.tcId = 'jhamcka';
            objcontroller.CPRAlabel  = 'jhamcnka';
            objcontroller.ctpName = 'gjajs';
            objcontroller.CPRALink  = 'jhamsbcka';
            objcontroller.CPRAlabel = 'jhanssnmcka';
            objcontroller.studyConsentSelection = false;
            objcontroller.verifyNewPassword = 'qwerty111113333';
             objcontroller.ppChangePassword();
            objcontroller.changePassword();
         
        }
           test.stopTest();
      }
   
     @isTest
      public static void testchangepasswordcontrollerDelegate() {
           TestData.loadTestData();
        TestData testData = new TestData();
        update new Clinical_Trial_Profile__c(id=testData.ss.Clinical_Trial_Profile__c,CommunityTemplate__c = 'PatientPortal',IQVIA_Outreach__c=true,Patient_Portal_Enabled__c = true);
          
          
          User delegate = testData.createPatientDelegate();
        insert delegate;
          Id delegateContactId = [SELECT ContactId FROM User WHERE Id = :delegate.Id].ContactId;
          Patient_Delegate__c patientDelegate = [
            SELECT Id, Participant__c, Contact__c
            FROM Patient_Delegate__c
            WHERE Contact__c = :delegateContactId
        ];
        patientDelegate.Status__c = 'Active';
        update patientDelegate;
          Patient_Delegate_Enrollment__c pde = new Patient_Delegate_Enrollment__c();
        pde.Participant_Enrollment__c = testData.pe.Id;
        pde.Patient_Delegate__c  = patientDelegate.id;
        pde.Status__c = 'Active';
        pde.Primary_Delegate__c=true;
        pde.Study_Phone_Consent__c = true;
        pde.Study_Email_Consent__c = true;
        pde.Study_SMS_Consent__c = true;
        pde.Study_Direct_Mail_Consent__c = true;
        insert pde;
       
          List<Participant_Enrollment__c> lstPER = new list<Participant_Enrollment__c> ();
          lstPER = [SELECT ID,Clinical_Trial_Profile__C,Clinical_Trial_Profile__r.IQVIA_Outreach__c from Participant_Enrollment__c
                   where id=:testData.pe.Id];
          List<Patient_Delegate_Enrollment__c> lstPDER = new List<Patient_Delegate_Enrollment__c> ();
          lstPDER.add(pde);
           Participant__c objParticipant = [
            SELECT Id, Birth_Year__c
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
        objParticipant.Birth_Year__c = '1994';
        update objParticipant;
          String mockPathPrefix = '/some/path';
		test.startTest();
        System.runAs(delegate) {
          
          RRChangePasswordController objcontroller = new RRChangePasswordController(); 
          objcontroller.setPartIQVIAOurtreachToggle(lstPER);
          objcontroller.setDelIQVIAOurtreachToggle(lstPDER);
            objcontroller.toggleNewPassword();
                objcontroller.togglePassword();
             objcontroller.updateYearOfBirth();
            objcontroller.oldPassword = '123456';
            objcontroller.newPassword = 'qwerty111113333';
            objcontroller.perListforCommPref = lstPER;
            objcontroller.allPdeList = lstPDER;
            objcontroller.mainPortal = !mockPathPrefix.startsWith('/gsk');
            objcontroller.failingPageResponse = '7328hsfj';
            objcontroller.US = 'nsdkak';
            objcontroller.userLocale = 'vsajkak';
            objcontroller.userLanguage = 'bnshds';
            objcontroller.tcId = 'jhamcka';
            objcontroller.CPRAlabel  = 'jhamcnka';
            objcontroller.ctpName = 'gjajs';
            objcontroller.CPRALink  = 'jhamsbcka';
            objcontroller.CPRAlabel = 'jhanssnmcka';
            objcontroller.studyConsentSelection = false;
            objcontroller.verifyNewPassword = 'qwerty111113333';
             objcontroller.ppChangePassword();
            objcontroller.changePassword();
         
        }
           test.stopTest();
      }
    @isTest
    static void testchange(){
        Account SiteAccount = new Account(
                Name = 'Study Site Account'
            );
        
            insert SiteAccount;
            
            Contact con = new Contact(
                FirstName = 'PITD',
                LastName = 'PITD',
                AccountId = SiteAccount.Id,
                Email = 'part1@email.com'
            );
            insert con;
        
           Clinical_Trial_Profile__c clinical = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'tt123456790',
               Override_Recruitment_Status__c = 'Actively Enrolling',
                NCT_Number__c = 'NCT00000002',
                Link_to_Pre_screening__c = 'some link',
                Study_Title__c = 'Some Title',
                Study_Code_Name__c = 'Some Code Name',
                Suppress_Participant_Emails__c = false,
                 Initial_Visit_Required__c= False
                );
                insert clinical;
        
             Study_Site__c studySite = new Study_Site__c(
                Name = 'Test',
                Principal_Investigator__c = con.Id,
                Clinical_Trial_Profile__c = clinical.Id,
                Site__c = SiteAccount.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false
            );
            insert studySite;
            Participant__c participant = new Participant__c(
            First_Name__c = 'ParticipantTD',
            Last_Name__c = 'ParticipantTD',
            Phone__c = '55313535',
            Email__c = 'part1@email.com',
            Contact__c = con.Id,
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'AL',
            Mailing_Zip_Postal_Code__c = '132112',
            Adult__c = true,
            Site__c=SiteAccount.Id
        );
        insert participant;

            Participant_Enrollment__c pe2 = new Participant_Enrollment__c(
            Medical_Record_Review_Status__c= 'Pass',
            Pre_screening_Status__c= 'Pass',
            PI_Contact__c = con.Id,
            Study_Site__c = studySite.Id,
            Patient_ID__c = 'SomePatientId2',
            Referral_Source__c = 'PI',
            Initial_visit_occurred_flag__c = false,    
            Participant_Status__c = DashboardRemoteNew.PE_STATUS_SUCCESSFULLY_CONTACTED,   
            Participant__c = participant.Id,
            Screening_ID__c = 'PESCR2'

        );
         insert pe2;  
        Test.startTest();
     RRChangePasswordController.perListCommPreferences pref = new RRChangePasswordController.perListCommPreferences(
            pe2,
            true,
            'http://example.com/tc',
            'http://example.com/pp'
        );
        Test.stopTest();
    }
    @isTest
    static void testchangeyesy(){
        Account SiteAccount = new Account(
                Name = 'Study Site Account'
            );
        
            insert SiteAccount;
            
            Contact con = new Contact(
                FirstName = 'PITD',
                LastName = 'PITD',
                AccountId = SiteAccount.Id,
                Email = 'part1@email.com'
            );
            insert con;
        
           Clinical_Trial_Profile__c clinical = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'tt123456790',
               Override_Recruitment_Status__c = 'Actively Enrolling',
                NCT_Number__c = 'NCT00000002',
                Link_to_Pre_screening__c = 'some link',
                Study_Title__c = 'Some Title',
                Study_Code_Name__c = 'Some Code Name',
                Suppress_Participant_Emails__c = false,
                 Initial_Visit_Required__c= False
                );
                insert clinical;
        
             Study_Site__c studySite = new Study_Site__c(
                Name = 'Test',
                Principal_Investigator__c = con.Id,
                Clinical_Trial_Profile__c = clinical.Id,
                Site__c = SiteAccount.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false
            );
            insert studySite;
            Participant__c participant = new Participant__c(
            First_Name__c = 'ParticipantTD',
            Last_Name__c = 'ParticipantTD',
            Phone__c = '55313535',
            Email__c = 'part1@email.com',
            Contact__c = con.Id,
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'AL',
            Mailing_Zip_Postal_Code__c = '132112',
            Adult__c = true,
            Site__c=SiteAccount.Id
        );
        insert participant;
        
            Participant_Enrollment__c pe2 = new Participant_Enrollment__c(
            Medical_Record_Review_Status__c= 'Pass',
            Pre_screening_Status__c= 'Pass',
            PI_Contact__c = con.Id,
            Study_Site__c = studySite.Id,
            Patient_ID__c = 'SomePatientId2',
            Referral_Source__c = 'PI',
            Initial_visit_occurred_flag__c = false,    
            Participant_Status__c = DashboardRemoteNew.PE_STATUS_SUCCESSFULLY_CONTACTED,   
            Participant__c = participant.Id,
            Screening_ID__c = 'PESCR2'

        );
         insert pe2;
        Contact delegate = new Contact(
            FirstName = 'Patient',
            LastName = 'Delegate',
            Email = 'delegate@somemail.com',
            AccountId = SiteAccount.id,
            Current_Participant_Enrollment__c = pe2.Id,
            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
            userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT,
            UserCommunityIsDelegate__c = true
        );
        insert delegate; 
         Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = delegate.Id,
            Contact__r = delegate,
            Participant__c = participant.Id,
            Participant__r = participant,
            Primary_Delegate__c = true
        );
        
        insert patientDelegate;
        
        Patient_delegate_enrollment__c patientEnrollment =new Patient_delegate_enrollment__c(
            Participant_Enrollment__c = pe2.Id,
            Patient_Delegate__c= patientDelegate.id,
            Study_Email_Consent__c=true,
            Study_SMS_Consent__c=true,
            Study_Phone_Consent__c=true,
            Study_Direct_Mail_Consent__c=true
        ); 
        insert patientEnrollment;
        Test.startTest();
     RRChangePasswordController.perListCommPreferencesDel pref = new RRChangePasswordController.perListCommPreferencesDel(
            patientEnrollment,
            true,
            'http://example.com/tc',
            'http://example.com/pp'
        );
        Test.stopTest();
    }
    @isTest
    static void testchangeui(){
         TestData.loadTestData();
        TestData testData = new TestData();
        update new Clinical_Trial_Profile__c(id=testData.ss.Clinical_Trial_Profile__c,CommunityTemplate__c = 'PatientPortal',IQVIA_Outreach__c=true,Patient_Portal_Enabled__c = true);
          User delegate = testData.createPatientDelegate();
        insert delegate;
          Id delegateContactId = [SELECT ContactId FROM User WHERE Id = :delegate.Id].ContactId;
          Patient_Delegate__c patientDelegate = [
            SELECT Id, Participant__c, Contact__c
            FROM Patient_Delegate__c
            WHERE Contact__c = :delegateContactId
        ];
        patientDelegate.Status__c = 'Active';
        update patientDelegate;
          Patient_Delegate_Enrollment__c pde = new Patient_Delegate_Enrollment__c();
        pde.Participant_Enrollment__c = testData.pe.Id;
        pde.Patient_Delegate__c  = patientDelegate.id;
        pde.Status__c = 'Active';
        pde.Primary_Delegate__c=true;
        pde.Study_Phone_Consent__c = true;
        pde.Study_Email_Consent__c = true;
        pde.Study_SMS_Consent__c = true;
        pde.Study_Direct_Mail_Consent__c = true;
        insert pde;
       
          List<Participant_Enrollment__c> lstPER = new list<Participant_Enrollment__c> ();
          lstPER = [SELECT ID,Clinical_Trial_Profile__C,Clinical_Trial_Profile__r.IQVIA_Outreach__c from Participant_Enrollment__c
                   where id=:testData.pe.Id];
          List<Patient_Delegate_Enrollment__c> lstPDER = new List<Patient_Delegate_Enrollment__c> ();
          lstPDER.add(pde);
           Participant__c objParticipant = [
            SELECT Id, Birth_Year__c
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
		test.startTest();
        System.runAs(delegate) {
     RRChangePasswordController objcontroller = new RRChangePasswordController(); 
     ApexPages.currentPage().getHeaders().put('User-Agent', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1');  
     ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Pswd_Val_strng1);
     ApexPages.addMessage(msg1);

     objcontroller.ppValidateSaveButton();
          objcontroller.validateSaveButton();
          objcontroller.validateAgeOfMajority();
          objcontroller.checkPasswords();
            objcontroller.ppChangePassword();
            objcontroller.changePassword();
         objcontroller.updateStatesAction();
         objcontroller.togglePassword();
         objcontroller.updateLanguageAction();
         //objcontroller.updateBrowserLanguageAction();
            objcontroller.oldPassword = '123456';
            objcontroller.newPassword = 'qwerty111113333';
            objcontroller.verifyNewPassword = 'qwerty111113333';
            objcontroller.isRTL = true;
           objcontroller.contact.Is_First_Logon__c = false; 
       }
        Test.stopTest();
    }
    @isTest
    static void testchangeuioajxmkas(){
         TestData.loadTestData();
        TestData testData = new TestData();
        update new Clinical_Trial_Profile__c(id=testData.ss.Clinical_Trial_Profile__c,CommunityTemplate__c = 'PatientPortal',IQVIA_Outreach__c=true,Patient_Portal_Enabled__c = true);
          User delegate = testData.createPatientDelegate();
        insert delegate;
          Id delegateContactId = [SELECT ContactId FROM User WHERE Id = :delegate.Id].ContactId;
          Patient_Delegate__c patientDelegate = [
            SELECT Id, Participant__c, Contact__c
            FROM Patient_Delegate__c
            WHERE Contact__c = :delegateContactId
        ];
        patientDelegate.Status__c = 'Active';
        update patientDelegate;
          Patient_Delegate_Enrollment__c pde = new Patient_Delegate_Enrollment__c();
        pde.Participant_Enrollment__c = testData.pe.Id;
        pde.Patient_Delegate__c  = patientDelegate.id;
        pde.Status__c = 'Active';
        pde.Primary_Delegate__c=true;
        pde.Study_Phone_Consent__c = true;
        pde.Study_Email_Consent__c = true;
        pde.Study_SMS_Consent__c = true;
        pde.Study_Direct_Mail_Consent__c = true;
        insert pde;
       
          List<Participant_Enrollment__c> lstPER = new list<Participant_Enrollment__c> ();
          lstPER = [SELECT ID,Clinical_Trial_Profile__C,Clinical_Trial_Profile__r.IQVIA_Outreach__c from Participant_Enrollment__c
                   where id=:testData.pe.Id];
          List<Patient_Delegate_Enrollment__c> lstPDER = new List<Patient_Delegate_Enrollment__c> ();
          lstPDER.add(pde);
           Participant__c objParticipant = [
            SELECT Id, Birth_Year__c
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
		test.startTest();
        System.runAs(delegate) {
     RRChangePasswordController objcontroller = new RRChangePasswordController(); 
     ApexPages.currentPage().getHeaders().put('User-Agent', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1');  
     ApexPages.Message msg2 = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Pswd_ValidationMsg5);
     ApexPages.addMessage(msg2);

     objcontroller.ppValidateSaveButton();
          objcontroller.validateSaveButton();
          objcontroller.validateAgeOfMajority();
          objcontroller.checkPasswords();
            objcontroller.ppChangePassword();
            objcontroller.changePassword();
         objcontroller.updateStatesAction();
         objcontroller.togglePassword();
         objcontroller.updateLanguageAction();
         //objcontroller.updateBrowserLanguageAction();
            objcontroller.oldPassword = '123456';
            objcontroller.newPassword = 'qwerty111113333';
            objcontroller.verifyNewPassword = 'qwerty111113333';
            objcontroller.isRTL = true;
           objcontroller.contact.Is_First_Logon__c = false; 
       }
        Test.stopTest();
    }
    @isTest
    static void testchangeuiopahda(){
         TestData.loadTestData();
        TestData testData = new TestData();
        update new Clinical_Trial_Profile__c(id=testData.ss.Clinical_Trial_Profile__c,CommunityTemplate__c = 'PatientPortal',IQVIA_Outreach__c=true,Patient_Portal_Enabled__c = true);
          User delegate = testData.createPatientDelegate();
        insert delegate;
          Id delegateContactId = [SELECT ContactId FROM User WHERE Id = :delegate.Id].ContactId;
          Patient_Delegate__c patientDelegate = [
            SELECT Id, Participant__c, Contact__c
            FROM Patient_Delegate__c
            WHERE Contact__c = :delegateContactId
        ];
        patientDelegate.Status__c = 'Active';
        update patientDelegate;
          Patient_Delegate_Enrollment__c pde = new Patient_Delegate_Enrollment__c();
        pde.Participant_Enrollment__c = testData.pe.Id;
        pde.Patient_Delegate__c  = patientDelegate.id;
        pde.Status__c = 'Active';
        pde.Primary_Delegate__c=true;
        pde.Study_Phone_Consent__c = true;
        pde.Study_Email_Consent__c = true;
        pde.Study_SMS_Consent__c = true;
        pde.Study_Direct_Mail_Consent__c = true;
        insert pde;
       
          List<Participant_Enrollment__c> lstPER = new list<Participant_Enrollment__c> ();
          lstPER = [SELECT ID,Clinical_Trial_Profile__C,Clinical_Trial_Profile__r.IQVIA_Outreach__c from Participant_Enrollment__c
                   where id=:testData.pe.Id];
          List<Patient_Delegate_Enrollment__c> lstPDER = new List<Patient_Delegate_Enrollment__c> ();
          lstPDER.add(pde);
           Participant__c objParticipant = [
            SELECT Id, Birth_Year__c
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
		test.startTest();
        System.runAs(delegate) {
     RRChangePasswordController objcontroller = new RRChangePasswordController(); 
     ApexPages.currentPage().getHeaders().put('User-Agent', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1');  
     ApexPages.Message msg3 = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.PP_CantReuseOldPwd);
     ApexPages.addMessage(msg3);

     objcontroller.ppValidateSaveButton();
          objcontroller.validateSaveButton();
          objcontroller.validateAgeOfMajority();
          objcontroller.checkPasswords();
            objcontroller.ppChangePassword();
            objcontroller.changePassword();
         objcontroller.updateStatesAction();
         objcontroller.togglePassword();
         objcontroller.updateLanguageAction();
         //objcontroller.updateBrowserLanguageAction();
            objcontroller.oldPassword = '123456';
            objcontroller.newPassword = 'qwerty111113333';
            objcontroller.verifyNewPassword = 'qwerty111113333';
            objcontroller.isRTL = true;
           objcontroller.contact.Is_First_Logon__c = false; 
       }
        Test.stopTest();
    }
   

    @isTest
    static void testRTLHandling() {
         TestData.loadTestData();
        TestData testData = new TestData();
        update new Clinical_Trial_Profile__c(id=testData.ss.Clinical_Trial_Profile__c,IQVIA_Outreach__c=true,Patient_Portal_Enabled__c = true,CommunityTemplate__c = 'PatientPortal');
          User delegate = testData.createPatientDelegate();
        delegate.LanguageLocalekey = 'ar';
        insert delegate;
        
          Id delegateContactId = [SELECT ContactId FROM User WHERE Id = :delegate.Id].ContactId;
        Contact cc = new Contact();
        cc.Id = delegateContactId;
        cc.Language__c = 'ar';
        update cc;
        
          Patient_Delegate__c patientDelegate = [
            SELECT Id, Participant__c, Contact__c
            FROM Patient_Delegate__c
            WHERE Contact__c = :delegateContactId
        ];
        patientDelegate.Status__c = 'Active';
        update patientDelegate;
          Patient_Delegate_Enrollment__c pde = new Patient_Delegate_Enrollment__c();
        pde.Participant_Enrollment__c = testData.pe.Id;
        pde.Patient_Delegate__c  = patientDelegate.id;
        pde.Status__c = 'Active';
        pde.Primary_Delegate__c=true;
        pde.Study_Phone_Consent__c = true;
        pde.Study_Email_Consent__c = true;
        pde.Study_SMS_Consent__c = true;
        pde.Study_Direct_Mail_Consent__c = true;
        insert pde;
       
          List<Participant_Enrollment__c> lstPER = new list<Participant_Enrollment__c> ();
          lstPER = [SELECT ID,Clinical_Trial_Profile__C,Clinical_Trial_Profile__r.IQVIA_Outreach__c from Participant_Enrollment__c
                   where id=:testData.pe.Id];
          List<Patient_Delegate_Enrollment__c> lstPDER = new List<Patient_Delegate_Enrollment__c> ();
          lstPDER.add(pde);
           Participant__c objParticipant = [
            SELECT Id, Birth_Year__c
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
        Test.startTest();
        System.runAs(delegate) {
            ApexPages.currentPage().getHeaders().put('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Safari/537.36');
            
            RRChangePasswordController controller = new RRChangePasswordController();
            controller.updateLanguageAction();
            controller = new RRChangePasswordController();
            controller.contact.Is_First_Logon__c = false; 
        }
        Test.stopTest();
    }
    @isTest
    public static void testchangepasswordcontrollerNewdeletePER() {
         TestData.loadTestData();
      TestData testData = new TestData();
      update new Clinical_Trial_Profile__c(id=testData.ss.Clinical_Trial_Profile__c,CommunityTemplate__c = 'PatientPortal',IQVIA_Outreach__c=true,Patient_Portal_Enabled__c = true);
      Contact cc = [Select Id,Is_First_Logon__c From Contact where id =: testData.hcpUser.ContactId];
      cc.UserCommunityIsDelegate__c = true;
      update cc;


        List<Participant_Enrollment__c> lstPER = new list<Participant_Enrollment__c> ();
        lstPER = [SELECT ID,Clinical_Trial_Profile__C,Clinical_Trial_Profile__r.IQVIA_Outreach__c from Participant_Enrollment__c
                 where id=:testData.pe.Id];

                 if(!lstPER.isEmpty()){        
                    delete lstPER; 
                     }
        
      test.startTest();
      System.runAs(testData.hcpUser) {
        
        RRChangePasswordController objcontroller = new RRChangePasswordController(); 
              objcontroller.checkPasswords();
         
       
      }
         test.stopTest();
    }
   
}