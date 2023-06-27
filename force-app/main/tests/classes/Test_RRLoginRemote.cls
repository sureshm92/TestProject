/**
 * Created by Leonid Bartenev
 */

@IsTest(SeeAllData=true)
public with sharing class Test_RRLoginRemote {
@IsTest
    static void testLogin() {
        Contact contact_1;    
        Account account_1;
        Profile profile_1 = [
            SELECT Id
            FROM Profile
            WHERE Name = 'IQVIA Customer Community Plus Login User'
            LIMIT 1
        ];
        account_1 = new Account(Name = 'Community', BillingCountry = 'United States');
        insert account_1;
        contact_1 = new Contact(          
        AccountId = account_1.Id, LastName = 'xgeek',
        userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
        userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT);
        insert contact_1;
        user user_1 = new User(
            Email = 'yourusername@gmail.com',
            ProfileId = profile_1.Id,
            UserName = 'yourusername@gmail.com',
            Alias = 'Test',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'ISO-8859-1',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ContactId = contact_1.Id,
            PortalRole = 'Manager',
            FirstName = 'Firstname',
            LastName = 'Lastname'
        );
        insert user_1;   
        system.runAs(user_1){
 			RRLoginRemote.login('yourusername@gmail.com', 'testPassword', 'http://a.com');
        	RRLoginRemote.communityLogin('yourusername@gmail.com', 'testPassword', 'http://a.com');
        	RRLoginRemote.getForgotPasswordUrl('yourusername@gmail.com');
        	RRLoginRemote.getIsUsernamePasswordEnabled();
            RRLoginRemote.getIsSelfRegistrationEnabled();
            RRLoginRemote.getForgotPasswordUrl();
            RRLoginRemote.getSelfRegistrationUrl();
            RRLoginRemote.getCommunityURL('iqvia');
            RRLoginRemote.setExperienceId('123');
            RRLoginRemote.isUserPasswordLocked('yourusername@gmail.com');
        }
    }
}