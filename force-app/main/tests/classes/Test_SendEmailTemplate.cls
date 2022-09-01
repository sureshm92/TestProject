@IsTest
private class Test_SendEmailTemplate {
    @testSetup
    static void setup() {
        TestData.loadTestData();
    }
    @IsTest
    static void testSendEmailNotification() {
        Test.startTest();
        TestData testData = new TestData();
        Id whatId;
        Id fromId;
        String templateName;
        Id contactId;
        Id emailTemplateId;
        Map<Id, String> whatIdMap = new Map<Id, String>();
        Map<Id, Set<Id>> contactIdToWhatIdSet = new Map<Id, Set<Id>>();
        SendEmailTemplate.sendEmailNotification(templateName, whatIdMap);
        SendEmailTemplate.sendEmailNotification(templateName, contactIdToWhatIdSet);
        SendEmailTemplate.createEmail(emailTemplateId, contactId, whatId);
        SendEmailTemplate.getOrgWideEmailId(fromId);
        Test.stopTest();
    }
}
