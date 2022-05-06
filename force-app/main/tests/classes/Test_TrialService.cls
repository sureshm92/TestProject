@isTest
public class Test_TrialService {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @isTest
    static void testTrial() {
        TestData testData = new TestData();
        testData.createPatientDelegate();
        Test.startTest();
        Id delegateId;
        System.runAs(testData.participantUser) {
            delegateId = PatientDelegateService.getInstance().getPDelegates().get(0).Id;
        }
        Map<Id, Clinical_Trial_Profile__c> trialsMap = new Map<Id, Clinical_Trial_Profile__c>();
        List<Clinical_Trial_Profile__c> study = new List<Clinical_Trial_Profile__c>();
        Clinical_Trial_Profile__c clinical = new Clinical_Trial_Profile__c(
            Protocol_ID__c = 'tt123456790',
            Override_Recruitment_Status__c = 'Actively Enrolling',
            NCT_Number__c = 'NCT00000002',
            Link_to_Pre_screening__c = 'some link',
            Study_Title__c = 'Some Title',
            Study_Code_Name__c = 'Some Code Name',
            Suppress_Participant_Emails__c = false
        );
        insert clinical;
        trialsMap.put(clinical.ID, clinical);
        study.add(clinical);
        TrialService.getTrials(new List<Id>(trialsMap.keyset()));
        TrialService.filterStudyForCurrentCommunity(study);
        TrialService.isTrialAvailable(clinical.Id, 'CommunityService.USER_MODE_PI', delegateId);
        TrialService.isTrialAvailable(clinical.Id, 'CommunityService.USER_MODE_PI');
        TrialService.getTrial(clinical.Id);
        List<Resource__c> resources = [SELECT Id, Title__c FROM Resource__c];
        TrialService ts = new TrialService();
        ts.getTrialImpl(clinical.Id);
        ts.getAvailableTrialsImpl('CommunityService.USER_MODE_PI');
        ts.getOwnTrialsImpl('CommunityService.USER_MODE_PI');
        ts.getAvailableTrialIdsImpl('CommunityService.USER_MODE_PI');
        TrialService.getOwnTrials('CommunityService.USER_MODE_PI');
        TrialService.getAvailableTrialIds('CommunityService.USER_MODE_PI');
        TrialService.getInstance();
        TrialService.getAvailableTrialIds('CommunityService.USER_MODE_PI', delegateId);
        TrialService.getAvailableTrialsWithPE(
            'active',
            'CommunityService.USER_MODE_PI',
            delegateId,
            'Id != null'
        );
        ts.getAvailableTrialsWithPEImpl(
            'active',
            'CommunityService.USER_MODE_PI',
            delegateId,
            'Id != null'
        );
        Test.stopTest();
    }
}
