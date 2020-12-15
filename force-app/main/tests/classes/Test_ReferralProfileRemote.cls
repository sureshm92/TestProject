/**
 * Created by user on 09-Jan-20.
 */

@IsTest
private class Test_ReferralProfileRemote {
    @IsTest
    static void testSetMRRStatus() {
        TestData.loadTestData();
        TestData testData = new TestData();
        String srcstr = 'testdata';
        Participant_Enrollment__c part = [
            SELECT
                Id,
                Medical_Record_Review_Status__c,
                MRR_Survey_Results_URL__c,
                Medical_Record_Review_Completed_by__c,
                Pre_screening_Status__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ];
        String participant = JSON.serialize(part);
        Participant_Enrollment__c test1;
        Test.startTest();
        System.runAs(testData.participantUser) {
            try{
            test1 = ReferralProfileRemote.setMRRStatus(participant, 'Pass', 'bad');
            ReferralProfileRemote.toSentenceFont(srcstr);
            ReferralProfileRemote.getReferralProfileDetail(part.id,'PI');
            ReferralProfileRemote.savePEScreeningId(part.id,'screenid');
            } catch(exception e){
            system.debug(e);
            }
        }
        
        System.runAs(testData.participantUser) {
            try{
            ReferralProfileRemote.changePEStatusByBtn(part.id,'Pre-review Passed');
            ReferralProfileRemote.updateParticipantData(participant,participant);
            
            } catch(exception e){
             system.debug(e);
            }
        }
        Test.stopTest();
        System.assert(test1 != null);
    }

    @IsTest
    static void testCreateUser() {
        TestData.loadTestData();
        Participant_Enrollment__c part = [
            SELECT
                Id,
                Medical_Record_Review_Status__c,
                MRR_Survey_Results_URL__c,
                Medical_Record_Review_Completed_by__c,
                Pre_screening_Status__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ];
        Account a = new Account(Name = 'Test Account Name');
        insert a;
        Contact newCont = new Contact(
            LastName = 'drdr',
            Email = 'dasda@mail.com',
            FirstName = 'asdas',
            AccountId = a.Id
        );
        insert newCont;

        Test.startTest();
        ReferralProfileRemote.createUser(part.Id, newCont.Id);
        Test.stopTest();

        List<User> testUser = [SELECT Id, Account.Name FROM User WHERE ContactId = :newCont.Id];
        System.assertEquals('Test Account Name', testUser[0].Account.Name);
    }
}
