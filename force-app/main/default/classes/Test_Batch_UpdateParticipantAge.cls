/**
 * Created by Srinath Enugothula  on 24/09/2020.
 */

@IsTest

public class Test_Batch_UpdateParticipantAge {
  @IsTest
   static void testBehavior() {
        TestData.loadTestData();
        TestData testData = new TestData();

        testData.participant.Date_of_Birth__c = '1984-04-07';
        update testData.participant;
    
        Test.startTest();
        Database.executeBatch(new Batch_UpdateParticipantAge());
        Test.stopTest();
    
}
}