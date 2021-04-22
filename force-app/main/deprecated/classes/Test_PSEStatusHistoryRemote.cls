/**
 * Created by Leonid Bartenev
 */

@IsTest
private class Test_PSEStatusHistoryRemote {
    public static list<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
    @isTest
    static void test1() {

        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();

        Participant__c participant = new Participant__c(
                First_Name__c = 'newParticipant',
                Last_Name__c = 'newParticipant',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'MS'
        );
        insert participant;

        Study_Site__c studySite = [
                SELECT Id
                FROM Study_Site__c
        ];
        Contact piContact = [
                SELECT Id
                FROM Contact
                WHERE Email = 'pi@emil.com'
        ];

        Participant_Enrollment__c pe = new Participant_Enrollment__c(
                Study_Site__c = studySite.Id,
                Participant__c = participant.Id,
                PI_Contact__c = piContact.Id
        );
        insert pe;
		Participant_Enrollment_Status_History__c peHistory = new Participant_Enrollment_Status_History__c(
            Date__c = Date.today(),
            ParticipantEnrollment__c = pe.Id,
            Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS
        );
        insert peHistory;
         PSEStatusHistoryRemote.getParticipationStatusHistory(pe.id);
    }
     
}