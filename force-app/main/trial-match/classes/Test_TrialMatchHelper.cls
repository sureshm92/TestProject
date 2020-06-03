/**
 * Created by Sravani Dasari on 5/21/2020.
 */

@IsTest
private class Test_TrialMatchHelper {

    @IsTest
    static void isCtpEnrolling_Test() {
        Test.startTest();
        TestDataFactory.createInitData();
        Test.stopTest();
        Clinical_Trial_Profile__c ctp = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType(), new Map<String, Object>{
                'Override_Recruitment_Status__c' => TrialSearchWhereClauseFactory.ACTIVELY_ENROLLING
        });
        TrialMatchHelper helper = new TrialMatchHelper();
        System.assert(helper.isCtpEnrolling(ctp));

        ctp.Override_Recruitment_Status__c = null;
        ctp.Recruitment_Status__c = TrialSearchWhereClauseFactory.OPEN_TO_ENROLLMENT;
        System.assert(helper.isCtpEnrolling(ctp));
    }


    @IsTest
    static void getInitTrialMatchContainer_test() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
        TestData testData = new TestData();
        TrialMatchPageRemote.TrialMatchContainer container;
        Trial_Match__c tm = new Trial_Match__c(	
				Clinical_Trial_Profile__c = testData.ctp.id,	
				Is_Eligible__c = true,	
				Matched_Date__c = Datetime.now().dateGmt(),	
				Matching_Details__c = 'Sample Matching Details',	
				Matching_Score__c = 77,	
				Participant_Enrollment__c = testData.pe.id,	
				Passed__c = false,	
				Therapeutic_Area__c = 'Therapeutic Area Sample test data'	
		);	
		insert tm;
        System.runAs(testData.participantUser) {
            container = new TrialMatchHelper().getInitTrialMatchContainer(testData.participant.id);
        }
        System.assertEquals(1, container.trialmatchctps.size());
    } 
    
    @IsTest
    static void getmonth_test() {
        TrialMatchHelper helper = new TrialMatchHelper();
        Date myDate = Date.newInstance(2010, 6, 17);
        System.assertEquals('Jun', helper.getmonth(myDate));
    }
}