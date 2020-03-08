/**
 * Created by Olga Skrynnikova on 10/31/2019.
 */

@IsTest
private class Test_Batch_UpdateActivityDateTime {
    @IsTest
    static void batchExecute() {
        TestData.loadTestData();
        User user = [SELECT Id FROM User WHERE Account.Name = :CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME LIMIT 1];
        List<Task> tasksList = new List<Task>{new Task(
                Subject = 'Some',
                OwnerId = user.Id,
                ActivityDate = Date.today())};
        insert tasksList;

        Test.startTest();
        new Batch_UpdateActivityDateTimeOldUsers().execute(null, tasksList);
        Test.stopTest();

        System.assertEquals(Datetime.newInstanceGMT(
                Date.today().year(), Date.today().month(), Date.today().day(), 0, 0, 0 ),
                tasksList[0].Activity_Datetime__c);
        System.assertEquals(1, tasksList.size());
    }
}