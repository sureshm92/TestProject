@IsTest
private class Test_Batch_TrialMatchNotify {
    @Testsetup
    static void init(){
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
        TestData testData = new TestData();
        testData.ctp.Trial_Match_Is_Available__c = true;
        testData.ctp.Override_Recruitment_Status__c = 'Actively Enrolling';
        //Test.startTest();
        update testData.ctp;
        Trial_Match__c tm = new Trial_Match__c(
            Clinical_Trial_Profile__c = testData.ctp.id,
            Is_Eligible__c = true,
            Matched_Date__c = Datetime.now().dateGmt(),
            Matching_Details__c = 'Sample Matching Details',
            Matching_Score__c = 77,
            Is_User_notified__c = False,
            Participant_Enrollment__c = testData.pe.id,
            Passed__c = false,
            Therapeutic_Area__c = 'Therapeutic Area Sample test data'
        );
        insert tm;
        //Test.stopTest();
    }
	@IsTest
    static void batchTrialMatch_test() {
        Test.startTest();
        TestData testData = new TestData();
        testData.participantUser.TimeZoneSidKey = 'Asia/Kolkata';
        update testData.participantUser;
        Batch_TrialMatchNotify battm = new Batch_TrialMatchNotify();
        battm.getBatchDescription();
        battm.getRecommendedIntervalMode();
        battm.getRecommendedRelaunchInterval();
        Database.executeBatch(new Batch_TrialMatchNotify());
        Test.stopTest();
    }
    @IsTest
    static void batchTrialMatch_test1() {
        Test.startTest();
        Database.executeBatch(new Batch_TrialMatchNotify());
        Test.stopTest();
    }

}