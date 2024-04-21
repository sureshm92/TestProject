/**
 * Created by Leonid Bartenev
 */

@IsTest(IsParallel=false)
private class Test_CommunityFacadeRemote {
    private class CommunityData {
        String communityMode;
        String communityDelegateId;
        Boolean isDelegate;
        String state;
        Boolean isTCAccepted;
        String language;
        List<String> preventedCookies;
        Boolean isNewSession;
        String baseUrl;
        String pathPrefix;
        String subDomain;
        List<CommunityMode> allUserModes;
        CommunityMode currentUserMode;
        Boolean isDummy;
        String communityName;
        String sponsorName;
        Boolean messagesVisible;
        Boolean trialMatchVisible;
        Boolean isMobileApp;
        Boolean hasIQVIAStudiesPI;
    }

    static testMethod void test1() {
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

        Boolean testFirstLogon;
        Boolean testExistsUrl;
        Boolean testTcAccepted;
        String localizedUrl;
        CommunityData communityData;
        Contact contactChangeMode;

        //run test:
        System.runAs(portalUser) {
            Test.startTest();
            testFirstLogon = CommunityFacadeRemote.isFirstLogon();
            CommunityFacadeRemote.acceptTerms();
            testExistsUrl = CommunityFacadeRemote.urlExists('test_url');
            localizedUrl = CommunityFacadeRemote.getLocalizedURL('https://login.salesforce.com/');
            contactChangeMode = CommunityFacadeRemote.changeMode('HCP', null, null, null);
            contactChangeMode = CommunityFacadeRemote.changeMode('PI', null, null, null);
            contactChangeMode = CommunityFacadeRemote.changeMode('Participant', null, null, null);
            testTcAccepted = CommunityFacadeRemote.isTCAccepted();
            CommunityFacadeRemote.checkStudyMessage();
            CommunityFacadeRemote.isDummyMode();
            CommunityFacadeRemote.getCommunityUserVisibility();
            CommunityFacadeRemote.isCurrentSessionMobileApp();
            communityData = (CommunityData) JSON.deserialize(
                CommunityFacadeRemote.getCommunityData(),
                CommunityData.class
            );
            try {
                CommunityFacadeRemote.getPreferredLanguageCode('us');
            } catch (Exception ex) {
            }

            Test.stopTest();
        }
        System.assert(testFirstLogon); 

        Contact testCont = [
            SELECT Id, Is_First_Logon__c
            FROM Contact
            WHERE Id = :portalUser.ContactId
        ];
        CommunityFacadeRemote.CommunityType cc = new CommunityFacadeRemote.CommunityType('test','test','test');
        CommunityFacadeRemote.extractCookieName('AllowedCookie__c');
        CommunityFacadeRemote.extractCookieName('');
    }
    static testMethod void test2() {
        Account acc1 = new Account(Name = 'newAcc11');
        insert acc1;
        Contact conCase = new Contact(
            AccountId = acc1.Id,
            LastName = 'portalTestUser11',
            RRCookiesAllowedCookie__c = false,
            RRLanguageAllowedCookie__c = true,
            userCommunytyType__c = 'PI',
            Email = 'reviteja@gmail.com'
        );
        insert conCase;
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
            CommunityTemplate__c = CommunityTemplateService.TEMPLATE_JANSSEN,
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
            Principal_Investigator__c = conCase.Id,
            Clinical_Trial_Profile__c = study.Id,
            Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
            Site__c = acc1.Id,
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
            HCP_Contact__c = conCase.Id,
            Status__c = HCPEnrollmentService.HCP_S_INVITATION_SENT
        );
        insert hcpEnrollment;
        hcpEnrollment.Status__c = HCPEnrollmentService.HCP_S_ACTIVATED;
        update hcpEnrollment;

        Site_Staff__c siteStaff = new Site_Staff__c(
            Site_Contact__c = conCase.Id,
            Delegate_Level__c = DelegateService.DELEGATE_LEVEL_1,
            Study_Site__c = studySite.Id,
            is_Invited__c = true
        );
        insert siteStaff;
        //Create user
        Profile profile = [
            SELECT Id
            FROM Profile
            WHERE Name = :CommunityService.COMMUNITY_USER_PROFILE_NAME
        ];
        User portalUser = [select id from user where ContactId =: conCase.Id];

        Boolean testFirstLogon;
        Boolean testExistsUrl;
        Boolean testTcAccepted;
        String localizedUrl;
        CommunityData communityData;
        Contact contactChangeMode;

        //run test:
        System.runAs(portalUser) {
            Test.startTest();
            testFirstLogon = CommunityFacadeRemote.isFirstLogon();
            CommunityFacadeRemote.acceptTerms();
            testExistsUrl = CommunityFacadeRemote.urlExists('test_url');
            localizedUrl = CommunityFacadeRemote.getLocalizedURL('https://login.salesforce.com/');
            contactChangeMode = CommunityFacadeRemote.changeMode('HCP', null, null, null);
            testTcAccepted = CommunityFacadeRemote.isTCAccepted();
            CommunityFacadeRemote.checkStudyMessage();
            CommunityFacadeRemote.isDummyMode();
            CommunityFacadeRemote.getCommunityUserVisibility();
            CommunityFacadeRemote.isCurrentSessionMobileApp();
            CommunityFacadeRemote.getSponsorName('Janssen');
            communityData = (CommunityData) JSON.deserialize(
                CommunityFacadeRemote.getCommunityData(),
                CommunityData.class
            );
            try {
                CommunityFacadeRemote.getPreferredLanguageCode('us');
                CommunityFacadeRemote.getSessionId();
                CommunityFacadeRemote.getSendResults(conCase.id,'true');
                CommunityFacadeRemote.isActivate(conCase.Id);
                CommunityFacadeRemote.updateReadNotification(conCase.Id);
             } catch (Exception ex) {
            }

            Test.stopTest();
        }
    }

    static testMethod void testException(){
        test.startTest();
        try{
            CommunityFacadeRemote.changeMode('PI',userInfo.getUserId(),null,null);
        }
        catch(Exception ex){
            
        }
        test.stopTest();
    }
}