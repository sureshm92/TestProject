/**
 * Created by Denis on 15.04.2019.
 */

@IsTest(IsParallel=false)
private class Test_AccountSettingsController {
    public class ParticipantServiceMock implements System.StubProvider {
        public Object handleMethodCall(
            Object stubbedObject,
            String stubbedMethodName,
            Type returnType,
            List<Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs
        ) {
            if (stubbedMethodName == 'getState') {
                return new ParticipantService.ParticipantState();
            }
            return null;
        }
    }

    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void getMaxLength() {
        List<String> fieldNames = new List<String>();
        Id delContId;
        Id contId;
        Id ParticipantId;
        fieldNames.add('FirstName');
        String sObjectName = 'Contact';
        Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectName); // obtain sObject description from the schema
        Sobject so = t.newSObject();
        Map<String, Integer> m = CommunityService.getMaxLength(so, fieldNames);
        System.assert(m != null);
        AccountSettingsController.getCommunityUrl();
        // AccountSettingsController.updateTheRegCookieAcceptance();
        AccountSettingsController.checkIfDelegateIsAlsoAparticipant(delContId);
        AccountSettingsController.changePassword('123', '13', '321');
    }

    @IsTest
    static void getInitData() {
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.ChangeUserEmailOnParticipantEmailChangeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(ContentDocumentLinkTriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(
            TranslationTriggerHandler.CheckFieldsConsistencyHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(NotificationTriggerHandler.CheckFieldsHandler.class);
        TriggerHandlerExecutor.bypassHandler(
            NotificationTriggerHandler.UpdateNotificationHandler.class
        );

        TestData testData = new TestData();
		//ParticipantService.setMock(new ParticipantServiceMock());
        Contact con = [
            SELECT Id, AccountId, MailingCountryCode, Participant_Opt_In_Status_SMS__c
            FROM Contact
            WHERE Id = :testData.participant.Contact__c
        ];
        System.debug(JSON.serializePretty(con));
        con.MailingCountryCode = 'US';
        update con;
		
        Account acc1 = [SELECT Id FROM Account WHERE Id = :con.AccountId];
        acc1.Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME;
        update acc1;
        Account acc;
        List<AccountSettingsController.CookieSettings> cookieList = new List<AccountSettingsController.CookieSettings>();
        System.debug(JSON.serializePretty(acc1));
        //run test:
        //Test.startTest();
        System.runAs(testData.participantUser) {
            String rawInitData = AccountSettingsController.getInitData(
                CommunityService.USER_MODE_PARTICIPANT
            );
            AccountSettingsController.updateParticipant(
                JSON.serialize(con),
                JSON.serialize(testData.participant)
            );
            AccountSettingsController.updateContact(JSON.serialize(con));
            //  AccountSettingsController.updateAccount('test');

            AccountSettingsController.changeEmail(
                'aaa@bbb.com',
                CommunityService.USER_MODE_PARTICIPANT
            );
            AccountSettingsController.getInitDataSettingsEdit(
                CommunityService.USER_MODE_PARTICIPANT
            );
            Test.startTest();
            AccountSettingsController.getInitDataforAccPage();
            AccountSettingsController.changePassword('123', '123', '321');
            AccountSettingsController.changeOptInEmail(
                true,
                true,
                true,
                true,
                CommunityService.USER_MODE_PARTICIPANT
            );
            AccountSettingsController.changeOptInCookies(false, false);
            AccountSettingsController.fillParticipantContact(con);
            AccountSettingsController.createCase('description', 'type');
            AccountSettingsController.getCountryCodes(CommunityService.USER_MODE_PARTICIPANT);
            acc = AccountSettingsController.getInstituteById(acc1.Id);
            cookieList = AccountSettingsController.getCookieSettings();
			//Test.stopTest();
            AccountSettingsController.AccountData initData = (AccountSettingsController.AccountData) JSON.deserialize(
                rawInitData,
                AccountSettingsController.AccountData.class
            );
            
            AccountSettingsController.PersonWrapper personWrapper = initData.contactSectionData.personWrapper;
            /*AccountSettingsController.changeOptInSMS(
                personWrapper.isOptInSMS(),
                CommunityService.USER_MODE_PARTICIPANT
            );*/
            //Test.stopTest();
            //AccountSettingsController.updatePerson(JSON.serialize(personWrapper));
            //personWrapper = new AccountSettingsController.PersonWrapper(initData.myContact, null);
            // AccountSettingsController.updatePerson(JSON.serialize(personWrapper));
        }
        List<Contact> contacts = [
            SELECT
                Id,
                HCP_Opt_In_Patient_Status_Emails__c,
                HCP_Opt_In_Referral_Status_Emails__c,
                HCP_Opt_In_Study_Emails__c,
                Participant_Opt_In_Status_Emails__c,
                RRCookiesAllowedCookie__c,
                RRLanguageAllowedCookie__c,
                FirstName,
                LastName,
                Participant_Opt_In_Status_SMS__c
            FROM Contact
            WHERE Email = 'aaa@bbb.com'
        ];
        contacts[0].Participant_Opt_In_Status_SMS__c = true;
        update contacts[0];
        Test.stopTest();
        /*Participant__c participant = [
            SELECT Id, First_Name__c, Last_Name__c
            FROM Participant__c
            WHERE Contact__c = :contacts[0].Id
        ];
        List<Case> cases = [
            SELECT Id
            FROM Case
            WHERE Contact.Id = :contacts[0].Id AND Status = 'New'
        ];*/
        AccountSettingsController.getCommunityUrl();
        // AccountSettingsController.updateAccount('name');
        System.assertEquals(1, contacts.size());
        System.assertEquals(true, contacts[0].HCP_Opt_In_Patient_Status_Emails__c);
        System.assertEquals(true, contacts[0].HCP_Opt_In_Referral_Status_Emails__c);
        System.assertEquals(true, contacts[0].HCP_Opt_In_Study_Emails__c);
        //System.assertEquals(false, contacts[0].RRCookiesAllowedCookie__c);
        //System.assertEquals(false, contacts[0].RRLanguageAllowedCookie__c);
        //System.assertEquals(contacts[0].FirstName, participant.First_Name__c);
        // System.assertEquals(contacts[0].LastName, participant.Last_Name__c);
        //System.assertEquals(1, cases.size());
        //System.assertEquals(acc1.Id, acc.Id);
        //System.assertEquals(12, cookieList.size());
        //System.assertEquals(true, contacts[0].Participant_Opt_In_Status_SMS__c);
    }
    @IsTest
    static void getInitData2(){
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.ChangeUserEmailOnParticipantEmailChangeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(ContentDocumentLinkTriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(
            TranslationTriggerHandler.CheckFieldsConsistencyHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(NotificationTriggerHandler.CheckFieldsHandler.class);
        TriggerHandlerExecutor.bypassHandler(
            NotificationTriggerHandler.UpdateNotificationHandler.class
        );
        TestData testData = new TestData();
        Contact con = [
            SELECT Id, AccountId, MailingCountryCode, Participant_Opt_In_Status_SMS__c
            FROM Contact
            WHERE Id = :testData.participant.Contact__c
        ];
        List<AccountSettingsController.CookieSettings> cookieList = new List<AccountSettingsController.CookieSettings>();
        System.runAs(testData.participantUser){
            Test.startTest();
            String rawInitData = AccountSettingsController.getInitData(
                CommunityService.USER_MODE_PARTICIPANT
            );
            AccountSettingsController.AccountData initData = (AccountSettingsController.AccountData) JSON.deserialize(
                rawInitData,
                AccountSettingsController.AccountData.class
            );
            AccountSettingsController.PersonWrapper personWrapper = initData.contactSectionData.personWrapper;
            AccountSettingsController.ConsentPreferenceData consentWrapper = initData.consentPreferenceData;
            AccountSettingsController.changeOptInSMS(
                personWrapper.isOptInSMS(),
                CommunityService.USER_MODE_PARTICIPANT
            );
            Test.stopTest();
            AccountSettingsController.updatePerson(JSON.serialize(personWrapper));
            personWrapper = new AccountSettingsController.PersonWrapper(initData.myContact, null);
            AccountSettingsController.updatePerson(JSON.serialize(personWrapper));
            AccountSettingsController.updatePersonMain(JSON.serialize(personWrapper),JSON.serialize(consentWrapper),CommunityService.USER_MODE_PARTICIPANT);

        }
    }
    
    @IsTest
    static void getInitData3(){
        TestData testData = new TestData();
        User delegateUser = testData.createPatientDelegate();
        Contact con = [SELECT Id, userCommunityDelegateId__c FROM Contact Where Id =: delegateUser.ContactId];
        Patient_Delegate__c pd = [SELECT Id FROM Patient_Delegate__c Where Contact__c =: con.Id];
        Patient_delegate_enrollment__c patientDelEnrollment =new Patient_delegate_enrollment__c(
            Participant_Enrollment__c = testData.pe.Id,
            Patient_Delegate__c= pd.id,
            Study_Email_Consent__c=true,
            Study_SMS_Consent__c=true,
            Study_Phone_Consent__c=true,
            Study_Direct_Mail_Consent__c=true
        );
        insert patientDelEnrollment;
        System.assert(patientDelEnrollment.id != null);
        con.userCommunityDelegateId__c = testData.participantUser.ContactId;
        update con;
        Test.startTest();
        System.runAs(delegateUser) {
            String rawInitData = AccountSettingsController.getInitData(
                CommunityService.USER_MODE_PARTICIPANT
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void testAccountnew() {
        Account acc1 = new Account(Name = 'newAcc1');
        insert acc1;
        Contact conCase = new Contact(
            AccountId = acc1.Id,
            LastName = 'portalTestUser1',
            RRCookiesAllowedCookie__c = false,
            RRLanguageAllowedCookie__c = true,
            userCommunytyType__c = CommunityService.USER_MODE_HCP
        );
        insert conCase;

        //Create user
        Profile profile = [
            SELECT Id
            FROM Profile
            WHERE Name = :CommunityService.COMMUNITY_USER_PROFILE_NAME
        ];
        User portalUser = new User(
            ProfileId = profile.Id,
            Username = 'newUser@yahoo.com',
            Email = 'pb@f.com',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'nuser',
            LastName = 'lastname',
            ContactId = conCase.Id
        ); 
        insert portalUser;
        System.runAs(portalUser) {
            try {
                AccountSettingsController.updateAccount('name');
                AccountSettingsController.updateAccount('');
                AccountSettingsController.changeEmail('ss', CommunityService.USER_MODE_PARTICIPANT);
                AccountSettingsController.changePassword('123', '123', '222');
                AccountSettingsController.updateTheRegCookieAcceptance();
            } catch (Exception e) {
                System.debug(e);
            }
        }

    }
}