/*
Test class for ParticipantTriggerHandler
*/
@IsTest
public class Test_ParticipantTriggerHandler {
    @TestSetup
    static void init(){
        TestData.loadTestData();
    }
    @isTest
    private static void test() {
        TestData testData = new TestData();
        Test.startTest();
        List<Participant__c> participants = [
            SELECT
                Id,
                Contact__r.Id,
                Mailing_State_Code__c,
                Mailing_State__c,
                Mailing_Zip_Postal_Code__c,
                Mailing_Country_Code__c
            FROM Participant__c
            WHERE Contact__c != NULL AND Mailing_State_Code__c != NULL
        ];
        if (participants.size() > 0) {
            Participant__c participant = participants[0];
            String oldMailingStateCode = participant.Mailing_State_Code__c;
            participant.Mailing_State_Code__c = null;
            participant.Mailing_State__c = null;
            participant.Mailing_Zip_Postal_Code__c = '37373';
            update participant;
            Contact newConVal = [
                SELECT MailingState, MailingStateCode, MailingPostalCode
                FROM Contact
                WHERE Id = :participant.Contact__r.Id
            ];
            system.assertEquals(
                participant.Mailing_Zip_Postal_Code__c,
                newConVal.MailingPostalCode
            );
            List<Participant__c> newList = new List<Participant__c>();
            ParticipantTriggerHandler.getParticipantAccountId();
            ParticipantTriggerHandler.checkDuplicates(newList);
        }
        Test.stopTest();
    }
}