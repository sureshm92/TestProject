/**
 * Created by Srinath Enugothula  on 24/09/2020.
 */

@IsTest
public class Test_Batch_UpdateParticipantAge {
    @IsTest
    static void testBehavior() {
            Test.startTest();

    TestData.loadTestData();
            Test.stopTest();

        TestData testData = new TestData();

        testData.participant.Date_of_Birth__c = '1984-04-07';
        update testData.participant;

        Database.executeBatch(new Batch_UpdateParticipantAge());
    }
}