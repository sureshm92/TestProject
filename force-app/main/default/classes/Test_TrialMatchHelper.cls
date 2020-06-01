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


    @IsTest
    static void getInitTrialMatchContainer_test() {
        Participant__c participant = [SELECT Id, Contact__c FROM Participant__c LIMIT 1];
        User usr = [SELECT Id FROM User WHERE ContactId = :participant.Contact__c];
        TrialMatchPageRemote.TrialMatchContainer container;

        Test.startTest();
        System.runAs(usr) {
            container = new TrialMatchHelper().getInitTrialMatchContainer();
        }
        Test.stopTest();

        System.assertEquals(1, container.trialmatchctps.size());
    }
    @IsTest
    static void getmonth_test() {
        TrialMatchHelper helper = new TrialMatchHelper();
        System.assertEquals('May', helper.getmonth(Date.today()));
    }
}