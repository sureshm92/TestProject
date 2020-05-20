/**
 * Created by Leonid Bartenev
 */

@IsTest(IsParallel=false)
private class Test_CommunityFacadeRemote {

    static testMethod void test1() {

        Account acc1 = new Account (
                Name = 'newAcc1'
        );
        insert acc1; 
        Contact conCase = new Contact (
                AccountId = acc1.id,
                LastName = 'portalTestUser1',
                RRCookiesAllowedCookie__c = false,
                RRLanguageAllowedCookie__c = true,
                userCommunytyType__c = CommunityService.USER_MODE_HCP
        );
        insert conCase;

        //Create user
        Profile profile = [SELECT Id FROM Profile WHERE Name =: CommunityService.COMMUNITY_USER_PROFILE_NAME];
        User portalUser = new User(
                profileId = profile.id,
                username = 'newUser@yahoo.com',
                email = 'pb@f.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='nuser',
                lastname='lastname',
                contactId = conCase.id
        );
        insert portalUser;


        //run test:
        System.runAs(portalUser){
            Test.startTest();
            CommunityFacadeRemote.isFirstLogon();
            CommunityFacadeRemote.acceptTerms();
            CommunityFacadeRemote.urlExists('test_url');
            CommunityFacadeRemote.getLocalizedURL('https://login.salesforce.com/');
            CommunityFacadeRemote.changeMode('HCP', null, null);
            CommunityFacadeRemote.isTCAccepted();
            CommunityFacadeRemote.getCommunityData();
             CommunityFacadeRemote.getUserContact();
            try {
                CommunityFacadeRemote.getPreferredLanguageCode('us');
            } catch (Exception ex) {

            }

            Test.stopTest();
        }
    }
}