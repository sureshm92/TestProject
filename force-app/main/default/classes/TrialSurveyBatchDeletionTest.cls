@isTest(SeeAllData=true)
public class TrialSurveyBatchDeletionTest {
    @IsTest
    public static void runTest() {
        Test.startTest();
        TestData.loadTestData();
        Clinical_Trial_Profile__c clinical = [SELECT ID FROM Clinical_Trial_Profile__c LIMIT 1];
        List<Survey> survey = [SELECT Id FROM Survey WHERE ActiveVersionId != NULL LIMIT 1];
        Trial_Survey__c ts = new Trial_Survey__c(
            Active_After_Days__c = 0,
            Clinical_Trial_Profile__c = clinical.Id,
            Expires_After_Days__c = 999,
            Survey__c = survey.get(0).Id,
            RecordTypeId = Schema.sObjectType.Trial_Survey__c.getRecordTypeInfosByName().get('Status based').getRecordTypeId(),
            Whose_response_needed__c = 'Patient or any Delegate'
        );
        insert ts;



       Database.executeBatch(new TrialSurveyBatchDeletion(clinical.Id));
        Test.stopTest();
    }
}