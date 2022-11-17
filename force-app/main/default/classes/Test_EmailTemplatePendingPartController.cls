@isTest
public class Test_EmailTemplatePendingPartController {
    @isTest
    private static void participants() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
        EmailTemplatePendingPartController etppc = new EmailTemplatePendingPartController();
        Contact pi = [
            SELECT Id, UserCommunityIsDelegate__c
            FROM Contact
            WHERE
                Id IN (
                    SELECT PI_Contact__c
                    FROM Participant_Enrollment__c
                    WHERE
                        Participant_Status__c IN ('Received','Contact Attempted','Pre-review Passed','Successfully Contacted','Successfully re-engaged')
                        AND Study_Site__r.Suppress_Study_Site_PI_Emails__c = FALSE
                )
        ][0];
        String studyName = [
            SELECT PI_Contact__c, Clinical_Trial_Profile__r.Study_Code_Name__c,High_Priority__c
            FROM Participant_Enrollment__c
            WHERE
                Participant_Status__c IN ('Received','Contact Attempted','Pre-review Passed','Successfully Contacted','Successfully re-engaged')
                AND Study_Site__r.Suppress_Study_Site_PI_Emails__c = FALSE
        ][0]
        .Clinical_Trial_Profile__r.Study_Code_Name__c;
        pi.UserCommunityIsDelegate__c = true;
        update pi;
        etppc.sourceIdValue = pi.Id;
        system.assertEquals(
            studyName,
            etppc.participants[0].studyName,
            String.valueOf(etppc.participants)
        );
    }
}