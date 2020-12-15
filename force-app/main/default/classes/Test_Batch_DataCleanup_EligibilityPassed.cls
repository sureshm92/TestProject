@isTest
private class Test_Batch_DataCleanup_EligibilityPassed {
    @isTest
    private static void Batch_DataCleanup_Eligibility() {
     
        testdata.loadTestData();
        test.startTest();
        Participant_Enrollment__c pe = [
            SELECT id, Participant_Status__c, Is_Virtual_Study_Site__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ];
        pe.Participant_Status__c = 'Eligibility Passed';
        update pe;
        database.executeBatch(new Batch_DataCleanup_EligibilityPassed());

        test.stopTest();
    }

    @isTest
    private static void Batch_DataCleanup_OnHold() {
        
        testdata.loadTestData();
        test.startTest();
        Participant_Enrollment__c pe = [
            SELECT id, Participant_Status__c, Is_Virtual_Study_Site__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ];

        pe.Participant_Status__c = 'Referral On Hold';
        update pe;
        database.executeBatch(new Batch_DataCleanup_OnHoldDeclined());

        test.stopTest();
    }

    @isTest
    private static void Batch_DataCleanup_Received() {
       
        testdata.loadTestData();
         test.startTest();
        Participant_Enrollment__c pe = [
            SELECT id, Participant_Status__c, Is_Virtual_Study_Site__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ];

        pe.Participant_Status__c = 'Referral Accepted';
        update pe;
        database.executeBatch(new Batch_DataCleanup_Received());

        test.stopTest();
    }
}
