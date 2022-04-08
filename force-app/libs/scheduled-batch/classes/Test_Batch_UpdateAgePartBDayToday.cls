@isTest
public class Test_Batch_UpdateAgePartBDayToday {
    @IsTest
    static void testAge(){
        Test.startTest();
        TestData.loadTestData();
        
        
        TestData testData = new TestData();
        
        testData.participant.Date_of_Birth__c = '1984-' + String.valueOf(Date.today().day())+'-'+String.valueOf(Date.today().month());
        testData.participant.Birth_Month__c = String.valueOf(Date.today().month());
        testData.participant.Birth_Day__c = String.valueOf(Date.today().day());
        update testData.participant;
        system.debug('&&&**'+[SELECT id,Date_of_Birth__c,Birth_Month__c,Birth_Day__c from Participant__c WHERE Id =:testData.participant.Id]);
        Database.executeBatch(new Batch_UpdateAgeOfParticipantsBDayToday());
        Test.stopTest();
    }
}