@IsTest
public class Test_CovidEmailTemplateController {
    @IsTest
       public static void runTest2() {
        TestData.loadTestData();
        Test.startTest();
        TestData testDataInstance = new TestData();
        Document document;
        document = new Document();
        document.Body = Blob.valueOf('Some Text');
        document.ContentType = 'application/pdf';
        document.DeveloperName = 'Nybc_logo';
        document.IsPublic = true;
        document.Name = 'Nybc_logo';
        document.FolderId = UserInfo.getUserId();
        insert document;
        CovidEmailTemplateController controller = new CovidEmailTemplateController();
        System.runAs(testDataInstance.participantUser) {
            controller.getContactDetails();
            controller.getImageUrl();
            controller.getuserMode();
            controller.getUserLanguageCode();
            String cntid = controller.recipientcntId;
            String file = controller.fileName;

        }
           Test.stopTest();
       }
    
    @IsTest
       public static void runTest1() {
        TestData.loadTestData();
        Test.startTest();
        TestData testDataInstance = new TestData();
        Integration_Patient_Referral__c i = new Integration_Patient_Referral__c ();
        i.Participant_Enrollment__c= testDataInstance.pe.id;
        i.Address_Country__c='US';
        i.Address_ZipCode__c='12345';
        i.Data_Source__c='Test';
        i.Language_Preference__c='us';
        i.Referred_Date__c=String.valueOf(Date.today());
        i.acceptedTermsAndConditions__c ='true';
        i.firstName__c='test';
        i.lastName__c='test';
        i.protocolId__c='E7449-E044-101';
        i.referralID__c='700-112314';
        i.siteSelected__c='102';   
        insert i;   
        CovidEmailTemplateController controller = new CovidEmailTemplateController();
        EmailTemplate templateId = [Select id from EmailTemplate where name = 'Covid19 Delegate'];
        OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress limit 1];
        System.runAs(testDataInstance.participantUser) {
            
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateID(templateId.Id);
            mail.setWhatId(i.id);
            mail.setSaveAsActivity(false);
            mail.setOrgWideEmailAddressId(owa.id);
            allmsg.add(mail);
            Messaging.sendEmail(allmsg,false);

            ApexPages.currentPage().getParameters().put('emailRecipientId', String.valueOf(i.id));
            controller.emailRelatedtoId=i.id;
            controller.getContactDetails();
            controller.getImageUrl();
        }
           Account a = new Account (Name='test');
             Contact delegate = new Contact(
                FirstName = 'Patient',
                LastName = 'Delegate',
                Email = 'jsmith@somemail.com',
                AccountId = a.id,
                userCommunityMode__c ='',
                userCommunytyType__c = '',
                UserCommunityIsDelegate__c = true
        );
        insert delegate;

                User newUser = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Chatter Free User'].Id,
                Username = 'test@test56666.com',
                Email = 'test@test56666.com',
                EmailEncodingKey = 'UTF-8',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey ='en_US' ,
                //ContactId = delegate.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                LastName = 'test1',
                FirstName = 'test2',
                Alias = 'test', //todo
                IsActive = true
        );
        insert newUser;
            System.runAs(newUser) {
            controller.getContactDetails();
            controller.getImageUrl();
            controller.getuserMode();
            controller.getUserLanguageCode();
            String cntid = controller.recipientcntId;
            String file = controller.fileName;
            String CommunityURL=controller.CommunityURL;  
            String id = controller.emailRelatedtoId;    
        }
           
           Test.stopTest();
       }
}