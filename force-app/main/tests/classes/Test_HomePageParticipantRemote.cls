/**
 * Created by Slav on 22.08.2019.
 */

@IsTest
public class Test_HomePageParticipantRemote {

    @IsTest
    public static void runTest() {
        TestData.loadTestData();
        TestData td = new TestData();
        ParticipantService.ParticipantState initData;

        Test.startTest();
        System.runAs(td.participantUser) {
            initData = (ParticipantService.ParticipantState) JSON.deserialize(HomePageParticipantRemote.getInitData(), ParticipantService.ParticipantState.class);
        }
        Test.stopTest();
        System.assert(initData.welcomeMessage.contains(td.participant.First_Name__c));
        System.assertEquals(ParticipantService.ParticipantStates.REFERRAL, initData.value);
    }
}