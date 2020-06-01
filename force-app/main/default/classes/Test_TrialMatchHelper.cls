/**
 * Created by Sravani Dasari on 5/21/2020.
 */

@IsTest
private class Test_TrialMatchHelper {

    @TestSetup
    static void setup() {
        Test.startTest();
        TestDataFactory.createInitData();
        
        Test.stopTest();
    }

    @IsTest
    static void isCtpEnrolling_Test() {
        Clinical_Trial_Profile__c ctp = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType(), new Map<String, Object>{
                'Override_Recruitment_Status__c' => TrialSearchWhereClauseFactory.ACTIVELY_ENROLLING
        });
        TrialMatchHelper helper = new TrialMatchHelper();
        System.assert(helper.isCtpEnrolling(ctp));

        ctp.Override_Recruitment_Status__c = null;
        ctp.Recruitment_Status__c = TrialSearchWhereClauseFactory.OPEN_TO_ENROLLMENT;
        System.assert(helper.isCtpEnrolling(ctp));
    }


  /*  @IsTest
    static void getInitTrialMatchContainer_test() {
        Participant__c participant = [SELECT Id, Contact__c FROM Participant__c where Email__c = 'part1@email.com'LIMIT 1];
        User usr = [SELECT Id FROM User WHERE ContactId = :participant.Contact__c];
        TrialMatchPageRemote.TrialMatchContainer container;

        Test.startTest();
        Clinical_Trial_Profile__c ctp = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType(), new Map<String, Object>{
                'Override_Recruitment_Status__c' => TrialSearchWhereClauseFactory.ACTIVELY_ENROLLING
        });
        Participant_Enrollment__c pe = (Participant_Enrollment__c) TestDataFactory.getSObject(Participant_Enrollment__c.getSObjectType(), new Map<String, Object>{
                'Participant__c' => participant.id
        });
		Trial_Match__c tm = new Trial_Match__c(	
				Clinical_Trial_Profile__c = ctp.id,	
				Is_Eligible__c = true,	
				Matched_Date__c = Datetime.now().dateGmt(),	
				Matching_Details__c = 'Sample Matching Details',	
				Matching_Score__c = 77,	
				Participant_Enrollment__c = pe.id,	
				Passed__c = false,	
				Therapeutic_Area__c = 'Therapeutic Area Sample test data'	
		);	
		insert tm;
        System.runAs(usr) {
            container = new TrialMatchHelper().getInitTrialMatchContainer();
        }
        System.assertEquals(1, container.trialmatchctps.size());
        Test.stopTest();
    } */
    @IsTest
    static void getmonth_test() {
        TrialMatchHelper helper = new TrialMatchHelper();
        System.assertEquals('May', helper.getmonth(Date.today()));
    }
}