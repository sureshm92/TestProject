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

        Account acc1 = new Account (
                Name = 'newAcc1'
        );
        insert acc1; 
        Contact conCase = new Contact (
                AccountId = acc1.Id,
                LastName = 'portalTestUser1',
                RRCookiesAllowedCookie__c = false,
                RRLanguageAllowedCookie__c = true,
                userCommunytyType__c = CommunityService.USER_MODE_HCP
        );
        insert conCase;

        //Create user
        Profile profile = [SELECT Id FROM Profile WHERE Name =: CommunityService.COMMUNITY_USER_PROFILE_NAME];
        User portalUser = new User(
                ProfileId = profile.Id,
                Username = 'newUser@yahoo.com',
                Email = 'pb@f.com',
                EmailEncodingKey = 'UTF-8',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles',
                Alias='nuser',
                LastName='lastname',
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
        System.runAs(portalUser){
            Test.startTest();
            testFirstLogon = CommunityFacadeRemote.isFirstLogon();
            CommunityFacadeRemote.acceptTerms();
            testExistsUrl = CommunityFacadeRemote.urlExists('test_url');
            localizedUrl = CommunityFacadeRemote.getLocalizedURL('https://login.salesforce.com/');
            contactChangeMode = CommunityFacadeRemote.changeMode('HCP', null, null, null);
            testTcAccepted = CommunityFacadeRemote.isTCAccepted();
            communityData = (CommunityData) JSON.deserialize(CommunityFacadeRemote.getCommunityData(), CommunityData.class);
            try {
                CommunityFacadeRemote.getPreferredLanguageCode('us');
            } catch (Exception ex) {

            }

            Test.stopTest();
        }
        System.assert(testFirstLogon);
        System.assert(testExistsUrl);
        System.assert(testTcAccepted);
        System.assert(localizedUrl.contains('login.salesforce'));

        System.assertEquals('HCP', contactChangeMode.userCommunytyType__c);
        System.assertEquals('HCP', communityData.currentUserMode.userMode);

        Contact testCont = [SELECT Id, Is_First_Logon__c FROM Contact WHERE Id = :portalUser.ContactId];
        System.assert(!testCont.Is_First_Logon__c);
    }
}