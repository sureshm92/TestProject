/**
 * Created by user on 19-Feb-20.
 */

@IsTest
private class Test_Batch_UpdatePatientDelegateStatuses {
    @IsTest
    static void testPicklistOnDelegates() {
            Test.startTest();

        TestData.loadTestData();
                Test.stopTest();

        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        Participant__c part = [SELECT Id FROM Participant__c LIMIT 1];
        Patient_Delegate__c oldDelegate = new Patient_Delegate__c();
        oldDelegate.Status__c = 'On Hold';
        oldDelegate.Contact__c = cont.Id;
        oldDelegate.Participant__c = part.Id;
        insert oldDelegate;

        Database.executeBatch(new Batch_UpdatePatientDelegateStatuses());
        Patient_Delegate__c newDelegate = [
            SELECT Id, Status__c
            FROM Patient_Delegate__c
            WHERE Id = :oldDelegate.Id
        ];

       // System.assertEquals(newDelegate.Status__c, 'Active');
    }
}