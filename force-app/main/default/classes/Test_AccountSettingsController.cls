/**
 * Created by Denis on 15.04.2019.
 */

@IsTest
private class Test_AccountSettingsController {


    public class ParticipantServiceMock implements System.StubProvider {

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if(stubbedMethodName == 'getState'){
                return new ParticipantService.ParticipantState();
            }
            return null;
        }
    }

    @IsTest
    static void getInitData() {
        ParticipantService.setMock(new ParticipantServiceMock());
        Account acc1 = new Account (
                Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
        );
        insert acc1;
        Contact con = new Contact (
                AccountId = acc1.id,
                LastName = 'portalTestUser1'
        );
        insert con;
        Participant__c participant = new Participant__c();
        participant.Contact__c = con.Id;
        insert participant;
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
                contactId = con.id
        );
        insert portalUser;

        //run test:
        System.runAs(portalUser) {
            AccountSettingsController.getInitData(CommunityService.USER_MODE_PARTICIPANT);
            AccountSettingsController.updateParticipant(JSON.serialize(participant));
            AccountSettingsController.changePassword('123', '123', '321');
            AccountSettingsController.changeOptInEmail(true, true, true, true);
            AccountSettingsController.changeOptInCookies(false, false);
            AccountSettingsController.createCase('description', 'type');
            AccountSettingsController.getCookieSettings();
        }
    }

}