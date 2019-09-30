/**
 * Created by Vitalii Aheienko on 9/20/2019.
 */

@IsTest
private class Test_TrialSearchHelper {

    @IsTest
    static void getInitTrialSearchContainer_Test() {
        User usr = makePortalUser();
        System.runAs(usr) {
            Participant__c participant = new Participant__c();
        }
    }


    private static User makePortalUser() {
        Account acc = new Account (
                Name = 'newAcc1'
        );
        insert acc;
        Contact cont = new Contact (
                AccountId = acc.Id,
                LastName = 'portalTestUser1',
                RRCookiesAllowedCookie__c = false,
                RRLanguageAllowedCookie__c = true
        );
        insert cont;

        Profile profile = [SELECT Id FROM Profile WHERE Name = :CommunityService.COMMUNITY_USER_PROFILE_NAME];
        return new User(
                ProfileId = profile.Id,
                Username = 'asdfghjkl@test.unittest',
                Email = 'pb@f.com',
                EmailEncodingKey = 'UTF-8',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles',
                Alias = 'nuser',
                LastName = 'lastname',
                ContactId = cont.Id
        );
    }

}