/**
 * Created by Alexey Moseev
 */
@IsTest
public class Test_Batch_MigratePicklistToCheckbox {

    @IsTest
    public static void testMigratePicklistToCheckboxBatch() {
        TestData.loadTestData();
        TestData tstData = new TestData();
        tstData.ctp.Participating_in_Digital_Recruitment__c = 'Yes';
        update tstData.ctp;

        Test.startTest();
        Database.executeBatch(new Batch_MigratePicklistToCheckbox());
        Test.stopTest();

        Clinical_Trial_Profile__c result = [SELECT  Id,
                Participating_in_Digital_Recruitment__c,
                Participating_in_Patient_Portal__c,
                Participating_in_Rocket_Referral__c,
                Patient_Portal_Enabled__c,
                Include_in_RP_trial_search__c,
                Synch_with_TMDH__c
        FROM Clinical_Trial_Profile__c
        WHERE Id = :tstData.ctp.Id];

        System.assertEquals(result.Participating_in_Digital_Recruitment__c == 'Yes', result.Synch_with_TMDH__c);
    }

}