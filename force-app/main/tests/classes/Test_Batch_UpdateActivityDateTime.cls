/**
 * Created by Olga Skrynnikova on 10/31/2019.
 */

@IsTest
private class Test_Batch_UpdateActivityDateTime {
    @IsTest
    static void batchExecute() {
        TestData.loadTestData();
        Participant_Enrollment__c part = [
            SELECT
                Id,Participant_Contact__c,
                Medical_Record_Review_Status__c,
                MRR_Survey_Results_URL__c,
                Medical_Record_Review_Completed_by__c,
                Pre_screening_Status__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ];
        Account a = new Account(Name = 'Participant');
        insert a;
        Contact newCont = new Contact(
            LastName = 'drdr',
            Email = 'dasda@mail.com',
            FirstName = 'asdas',
            AccountId = a.Id
        );
        insert newCont;
        
        ReferralProfileRemote.createUser(part.Id, newCont.Id);
       
        User user = [
            SELECT Id
            FROM User
            WHERE ContactId =:part.Participant_Contact__c
            LIMIT 1
        ];
        List<Task> tasksList = new List<Task>{
            new Task(Subject = 'Some', OwnerId = user.Id, ActivityDate = Date.today())
        };
        insert tasksList;

        Test.startTest();
        new Batch_UpdateActivityDateTimeOldUsers().execute(null, tasksList);
        Test.stopTest();

        System.assertEquals(
            Datetime.newInstanceGMT(
                Date.today().year(),
                Date.today().month(),
                Date.today().day(),
                0,
                0,
                0
            ),
            tasksList[0].Activity_Datetime__c
        );
        System.assertEquals(1, tasksList.size());
    }
}