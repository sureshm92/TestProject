/**
 * Created by Leonid Bartenev
 */

@IsTest(IsParallel=false)
public class Test_MyTemRemote {
    @IsTest
    static void testCreatePatientDelegate() {
        TestData.loadTestData();
        Test.startTest();
        TestData testDatanstance = new TestData();
        testDatanstance.updatePEStatusEnrollmentSuccess();
        System.runAs(testDatanstance.participantUser) {
            Contact delegateContact = new Contact(
                FirstName = 'Del',
                LastName = 'Del',
                Email = 'del@del.com'
            );
            MyTeamRemote.savePatientDelegate(JSON.serialize(delegateContact));
        }
        Test.stopTest();
        List<Participant__c> partDelegates = [
            SELECT Id
            FROM Participant__c
            WHERE Email__c = 'del@del.com'
        ];
        System.assert(!partDelegates.isEmpty());
    }
}