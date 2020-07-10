/**
 * Created by Nargiz Mamedova on 6/5/2020.
 */

@IsTest
private class Test_Batch_CreateNewRPDelegates {
    @IsTest
    static void testBehavior() {
        ClassFactory.putStubTypeByClassName(CommunityService.class, StubBuilder.newInstance(CommunityService.class)
                .when('createPortalUsers')
                .then(null)
                .when('createParticipantUsers')
                .then(null)
                .build()
        );
        TestData.loadTestData();
        TestData td = new TestData();
        Contact newDelegate = new Contact(LastName = 'TestDelegate');
        insert newDelegate;
        insert new Referring_HCP_Staff__c(
                Contact__c = newDelegate.Id,
                Delegate_Level__c = 'Level 1',
                HCP_Enrollment__c = td.hcpEnrollment.Id
        );
        Test.startTest();
        Batch_CreateNewRPDelegates.run();
        Test.stopTest();

        List<RP_Delegate_Relationship__c> newRPDelegatesList = [
                SELECT Id, Delegate_Access_Level__c
                FROM RP_Delegate_Relationship__c
                WHERE Delegate__c =: newDelegate.Id
        ];
        System.assertEquals('Level 1', newRPDelegatesList[0].Delegate_Access_Level__c);
    }
}