@isTest
public class Test_EmailTempProvidTaskWithoutType extends EmailTemplateProvider {
    @testSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @isTest
    public static void runTest() {
        TestData tstData = new TestData();

        Test.startTest();
        Task tsk = new Task();
        tsk.whatId = tstData.participant.Id;
        system.debug('whatid' + tsk.whatId);
        insert tsk;
        EmailTemplateProviderTaskWithoutType emailProvider = new EmailTemplateProviderTaskWithoutType();
        List<Participant_Enrollment__c> enrollment = [
            SELECT Participant__r.First_Name__c
            FROM Participant_Enrollment__c
            WHERE Id = :tsk.whatId
        ];
        emailProvider.initState(
            tstData.participant.Contact__c,
            tstData.participant.Last_Name__c,
            null,
            'Default',
            tstData.participant.Id,
            'HTML',
            'Yes'
        );
        emailProvider.initYourParticipantFirstName();
        EmailTemplateProviderTaskWithoutType etptwt = new EmailTemplateProviderTaskWithoutType();
        etptwt.initYourParticipantFirstName();
        Test.stopTest();
    }
}
