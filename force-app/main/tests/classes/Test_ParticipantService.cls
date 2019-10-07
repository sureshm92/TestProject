/**
 * Created by Leonid Bartenev
 */

@IsTest
public class Test_ParticipantService {

    @IsTest
    static void participantServiceTest() {
        TestData.loadTestData();

        // Test logic
        Test.startTest();
        Boolean showTerms;
        Boolean isShow;
        System.runAs(new TestData().participantUser) {
            ParticipantService service = ParticipantService.getInstance();
            showTerms = service.getState().showTerms;
            isShow = service.showVisits();
        }
        Test.stopTest();
        System.assertEquals(true, showTerms);
        System.assertEquals(false, isShow);
    }

    @IsTest
    static void participantServiceGROUP_FAILEDTest() {
        TestData.loadTestData();
        TestData testData = new TestData();
        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_FAILED;
        update testData.pe;

        // Test logic
        Test.startTest();
        System.runAs(testData.participantUser) {
            ParticipantService.getInstance().getState();
        }
        Test.stopTest();
    }

    @IsTest
    static void participantServiceENROLLMENT_SUCCESSTest() {
        TestData.loadTestData();
        TestData testData = new TestData();

        // Test logic
        Test.startTest();
        testData.createPSE();
        System.runAs(testData.participantUser) {
            ParticipantService.getInstance().getState();
        }
        Test.stopTest();
    }

    @IsTest
    static void createParticipantAndUpdatePEImplTest() {
        TestData.loadTestData();

        Test.startTest();
        TestData testData = new TestData();
        System.runAs(testData.piUser) {
            ParticipantService.createParticipantAndUpdatePE(testData.participant, testData.pe);
        }
        Test.stopTest();
    }

    @IsTest
    static void getGenderLVListTest() {
        List<LabelValueItem> genderLVList = ParticipantService.getGenderLVList();
        System.assertEquals(2, genderLVList.size());
        System.assertEquals(Label.Gender_Male, genderLVList.get(0).label);
        System.assertEquals('Female', genderLVList.get(1).value);
    }
}