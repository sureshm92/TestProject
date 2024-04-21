@IsTest
private class Test_SendEmailTemplate {
    @testSetup
    static void setup() {
        TestData.loadTestData();
    }
    @IsTest
    static void testSendEmailNotification() {
        TestData testData = new TestData();
        Integration_Patient_Referral__c i = new Integration_Patient_Referral__c();
        i.Participant_Enrollment__c = testData.pe.id;
        i.Address_Country__c = 'US';
        i.Address_ZipCode__c = '12345';
        i.Data_Source__c = 'Test';
        i.Language_Preference__c = 'us';
        i.Referred_Date__c = String.valueOf(Date.today());
        i.acceptedTermsAndConditions__c = 'true';
        i.firstName__c = 'test';
        i.lastName__c = 'test';
        i.protocolId__c = 'E7449-E044-101';
        i.referralID__c = '700-112314';
        i.siteSelected__c = '102';
      	//insert i;
      	EmailTemplate e = new EmailTemplate (developerName = 'Covid19_Delegate', FolderId = UserInfo.getUserId() , TemplateType= 'Text', Name = 'Covid19_Delegate',isActive = true);
		insert e;
        EmailTemplate templateId = [SELECT id,name,developerName FROM EmailTemplate WHERE name = 'Covid19_Delegate'];
        OrgWideEmailAddress owa = [
            SELECT id, DisplayName, Address
            FROM OrgWideEmailAddress
            LIMIT 1
        ];
        String developerName= templateId.DeveloperName;
        String emailAddress =owa.Address;
        Id whatId = i.id;
        Id fromId = testData.piDelegateContact.id;
        String templateName =templateId.name;
        Id whatIdName=i.Name;
        Id contactId = testData.piDelegateContact.id;
        Id emailTemplateId =templateId.Id;
        Id studyId=testData.ss.Id;
        String userModePI='PI';
        String userModeHCP='HCP';
        Map<Id, String> whatIdMap = new Map<Id, String>();
        whatIdMap.put(whatId,whatIdName);
        Set<Id> whatIdSet=new Set<Id>();
        whatIdSet.add(whatId);
        Map<Id, Set<Id>> contactIdToWhatIdSet = new Map<Id, Set<Id>>();
        contactIdToWhatIdSet.put(contactId,whatIdSet);
        Test.startTest();
        System.runAs(testData.participantUser) {
        SendEmailTemplate.sendEmailNotification(templateName, whatIdMap);
        SendEmailTemplate.sendEmailNotification(templateName, contactIdToWhatIdSet);
        SendEmailTemplate.createEmail(developerName, contactId, whatId);
        SendEmailTemplate.createEmail(emailTemplateId, contactId, whatId, studyId, true, userModePI);
        SendEmailTemplate.createEmail(emailTemplateId, contactId, whatId, studyId, true, userModeHCP);
        SendEmailTemplate.getOrgWideEmailId(fromId);
        SendEmailTemplate.sendShareEmail(whatId,fromId,emailAddress,templateName);
        Test.stopTest();
    	}
    }
}