/**
 * Created by Denis on 15.04.2019.
 */

@IsTest(IsParallel=false)
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
            AccountSettingsController.updateParticipant(JSON.serialize(con), JSON.serialize(participant));
            try {
                AccountSettingsController.updateParticipant(null, null);
            } catch (Exception e) {
                // expected Exception
            }
            AccountSettingsController.updateContact(JSON.serialize(con));
            try {
                AccountSettingsController.updateContact(JSON.serialize(con.clone()));
            } catch (Exception e) {
                // expected Exception
            }
            AccountSettingsController.changeEmail('aaa@bbb.com');
            try {
                AccountSettingsController.changeEmail('11111111');
            } catch (Exception e) {
                // expected Exception: Invalid email
            }
            AccountSettingsController.changePassword('123', '123', '321');
            AccountSettingsController.changeOptInVisitResults(con.Id, true);
            try {
                AccountSettingsController.changeOptInVisitResults(con.clone().Id, true);
            } catch (Exception e) {
                // expected Exception: Missing argument
            }
            AccountSettingsController.changeOptInEmail(true, true, true, true);
            try {
                AccountSettingsController.changeOptInEmail(null, null, null, null);
            } catch (Exception e) {
                // expected Exception
            }
            AccountSettingsController.changeOptInCookies(false, false);
            try {
                AccountSettingsController.changeOptInCookies(null, null);
            } catch (Exception e) {
                // expected Exception
            }
    
            AccountSettingsController.fillParticipantContact(con);
            AccountSettingsController.createCase('description', 'type');
            AccountSettingsController.getInstituteById(acc1.Id);
            AccountSettingsController.getCookieSettings();
        }
    }

}