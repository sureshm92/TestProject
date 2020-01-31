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
        TestData.loadTestData();
        TestData testData = new TestData();
        Contact con = [
                SELECT Id, AccountId, MailingCountryCode, Participant_Opt_In_Status_SMS__c
                FROM Contact WHERE Id =: testData.participant.Contact__c];
        System.debug(JSON.serializePretty(con));
        con.MailingCountryCode = 'US';
        update con;

        Account acc1 = [SELECT Id FROM Account WHERE Id =: con.AccountId];
        acc1.Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME;
        update acc1;
        System.debug(JSON.serializePretty(acc1));
        //run test:
        Test.startTest();
        System.runAs(testData.participantUser) {
            AccountSettingsController.getInitData(CommunityService.USER_MODE_PARTICIPANT);
            AccountSettingsController.updateParticipant(JSON.serialize(con), JSON.serialize(testData.participant));
            AccountSettingsController.updateContact(JSON.serialize(con));
            AccountSettingsController.changeEmail('aaa@bbb.com');
            AccountSettingsController.changePassword('123', '123', '321');
            AccountSettingsController.changeOptInVisitResults(con.Id, true);
            AccountSettingsController.changeOptInEmail(true, true, true, true);
            AccountSettingsController.changeOptInCookies(false, false);
            AccountSettingsController.fillParticipantContact(con);
            AccountSettingsController.createCase('description', 'type');
            AccountSettingsController.getInstituteById(acc1.Id);
            AccountSettingsController.getCookieSettings();
        }
        Test.stopTest();
    }

}