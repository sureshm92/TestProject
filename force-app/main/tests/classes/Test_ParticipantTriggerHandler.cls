/*
Test class for ParticipantTriggerHandler
*/
@IsTest
public class Test_ParticipantTriggerHandler {
    @isTest
    private static void test(){
        TestData.loadTestData();
        TestData testData = new TestData();
        List<Participant__c> participants = [SELECT Id,Contact__r.Id,Mailing_State_Code__c,Mailing_State__c,Mailing_Zip_Postal_Code__c,
                                             Mailing_Country_Code__c FROM Participant__c WHERE Contact__c !=NULL AND Mailing_State_Code__c !=NULL];
        system.debug('participants'+participants);
        if(participants.size()>0){
            Participant__c participant = participants[0];
            String oldMailingStateCode = participant.Mailing_State_Code__c;
            participant.Mailing_State_Code__c = null;
            participant.Mailing_State__c = null;
            participant.Mailing_Zip_Postal_Code__c = '37373';
            update participant;
            Contact newConVal = [SELECT MailingState,MailingStateCode,MailingPostalCode 
                                 FROM Contact WHERE Id =: participant.Contact__r.Id];
            system.assertEquals(participant.Mailing_Zip_Postal_Code__c, newConVal.MailingPostalCode);
        }
    }
}