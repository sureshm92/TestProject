/**
 * Created by Slav on 21.08.2019.
 */

@IsTest(SeeAllData=true)
public with sharing class Test_EmailTemplateController {

    @IsTest
    public static void runTest() {
        TestData.loadTestData();
        Test.startTest();

        TestData testDataInstance = new TestData();
        System.runAs(testDataInstance.participantUser) {

            EmailTemplateController controller = new EmailTemplateController();
            ParametersDataProvider provider = getDataProvider(controller);
            provider.isDelegate = true;
            provider.userMode = CommunityService.USER_MODE_PARTICIPANT;
            String s = controller.bodyValue;

            controller = new EmailTemplateController();
            provider = getDataProvider(controller);
            provider.isDelegate = true;
            provider.userMode = CommunityService.USER_MODE_PI;
            s = controller.bodyValue;

            controller = new EmailTemplateController();
            provider = getDataProvider(controller);
            provider.isDelegate = false;
            provider.userMode = CommunityService.USER_MODE_PARTICIPANT;
            provider.parameters.put('ReferralSource', 'OTHER');
            s = controller.bodyValue;

            controller = new EmailTemplateController();
            provider = getDataProvider(controller);
            provider.isDelegate = false;
            provider.userMode = CommunityService.USER_MODE_PARTICIPANT;
            provider.parameters.put('ReferralSource', 'PI');
            s = controller.bodyValue;

            controller = new EmailTemplateController();
            provider = getDataProvider(controller);
            provider.isDelegate = false;
            provider.userMode = CommunityService.USER_MODE_PARTICIPANT;
            provider.parameters.put('ReferralSource', 'HCP');
            s = controller.bodyValue;

            controller = new EmailTemplateController();
            provider = getDataProvider(controller);
            provider.isDelegate = false;
            provider.userMode = CommunityService.USER_MODE_PI;
            s = controller.bodyValue;

            controller = new EmailTemplateController();
            provider = getDataProvider(controller);
            provider.isDelegate = false;
            provider.userMode = CommunityService.USER_MODE_HCP;
            s = controller.bodyValue;
        }
    }

    @IsTest
    public static void runTestHCP() {
        TestData.loadTestData();
        Test.startTest();
        TestData testDataInstance = new TestData();
        System.runAs(testDataInstance.hcpUser) {
            EmailTemplateController controller = new EmailTemplateController();
            controller.sourceRecordId = testDataInstance.hcpUser.Id;
            controller.multiplePIMessageValue = false;
            controller.getDataProvider();
            controller.setDefaultValues();
            String emailTemplateBackground = controller.emailTemplateBackground;
            Boolean hasPIRPDelegationRecords = controller.hasPIRPDelegationRecords;
            String emailTemplateTextBackground = controller.emailTemplateTextBackground;
            String emailTemplateHeaderBackground = controller.emailTemplateHeaderBackground;
            String emailTemplateHeader = controller.emailTemplateHeader;
            String emailTemplateTitle = controller.emailTemplateTitle;
            String emailTemplateBrandLogo = controller.emailTemplateBrandLogo;
            String emailTemplateBottomLogo = controller.emailTemplateBottomLogo;
            String emailTemplateBrandLogoCSS = controller.emailTemplateBrandLogoCSS;
            String dataParametersValue = controller.dataParametersValue;
        }

        testDataInstance.hcpEnrollment = [
                SELECT Id,
                        HCP_Contact__c
                FROM HCP_Enrollment__c
                WHERE Id = :testDataInstance.hcpEnrollment.Id
        ];
        Healthcare_Provider__c provider = new Healthcare_Provider__c(Participant_Enrollment__c = testDataInstance.pe.Id, HCP_Enrollment__c = testDataInstance.hcpEnrollment.Id);
        insert provider;
        System.runAs(testDataInstance.hcpUser) {
            EmailTemplateController controller = new EmailTemplateController();
            controller.sourceRecordId = testDataInstance.hcpUser.Id;
            controller.multiplePIMessageValue = true;
            controller.getDataProvider();
            controller.setDefaultValues();
        }
        Account acc = [
                SELECT Id
                FROM Account
                WHERE Name = 'PI Account'
        ];
        Contact piContact = new Contact(
                FirstName = 'PITD2',
                LastName = 'PITD2',
                Email = 'pi2@emil.com',
                AccountId = acc.Id
        );
        insert piContact;
        Clinical_Trial_Profile__c ctp = [
                SELECT Id
                FROM Clinical_Trial_Profile__c
                WHERE NCT_Number__c = 'NCT99999999'
        ];
        Account ssAccount = [
                SELECT Id
                FROM Account
                WHERE Name = 'Study Site Account'
        ];
        Study_Site__c studySite = new Study_Site__c(
                Principal_Investigator__c = piContact.Id,
                Clinical_Trial_Profile__c = ctp.Id,
                Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
                Site__c = ssAccount.Id,
                Study_Site_Key__c = '001',
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false,
                Study_Site_Number__c = 'SS1'
        );
        insert studySite;
        HCP_Enrollment__c hcpEnrollment = new HCP_Enrollment__c(
                Study_Site__c = studySite.Id,
                HCP_Contact__c = testDataInstance.hcpEnrollment.HCP_Contact__c,
                Status__c = HCPEnrollmentService.HCP_S_ACTIVATED
        );
        insert hcpEnrollment;

        System.runAs(testDataInstance.hcpUser) {
            EmailTemplateController controller = new EmailTemplateController();
            controller.sourceRecordId = testDataInstance.hcpUser.Id;
            controller.multiplePIMessageValue = true;
            controller.getDataProvider();
            controller.setDefaultValues();
        }
    }

    @IsTest
    public static void runTestHCP2() {
        TestData.loadTestData();
        Test.startTest();
        TestData testDataInstance = new TestData();
        delete [
                SELECT Id
                FROM HCP_Enrollment__c
        ];
        System.runAs(testDataInstance.hcpUser) {
            EmailTemplateController controller = new EmailTemplateController();
            controller.sourceRecordId = testDataInstance.hcpUser.Id;
            controller.multiplePIMessageValue = true;
            controller.getDataProvider();
            controller.setDefaultValues();
        }
    }

    @IsTest
    public static void runTest2() {
        TestData.loadTestData();
        Test.startTest();
        TestData testDataInstance = new TestData();
        EmailTemplateController controller = new EmailTemplateController();
        System.runAs(testDataInstance.participantUser) {
            String s = controller.bodyValue;
            controller = new EmailTemplateController();
            controller.bodyValue = 'body ## value';
            try {
                s = controller.bodyValue;
            } catch (Exception e) {
                //
            }

            s = controller.titleValue;

            controller.headerValue = 'header ## value';
            try {
                s = controller.headerValue;
            } catch (Exception e) {
                //
            }

            controller.headerValue = 'header value';
            s = controller.headerValue;

            s = controller.preSignatureValue;
            controller.preSignatureValue = 'string\n new line';
            try {
                s = controller.preSignatureValue;
            } catch (Exception e) {
                //
            }
            s = controller.signatureValue;

            controller.userGreetingValue = 'greeting ## value';
            try {
                s = controller.userGreetingValue;
            } catch (Exception e) {
                //
            }

            controller.buttonLabelValue = 'button ## value';
            s = controller.buttonLabelValue;

            controller.buttonUrlValue = 'button URL ## value';
            s = controller.buttonUrlValue;

            controller.getDelegateLevelsPI();
            controller.getDelegateLevelsHCP();
            controller.getResultUserMode();
            controller.getIsDelegate();
            controller.getUserName();
            controller.getParameters();
        }
    }

    private static ParametersDataProvider getDataProvider(EmailTemplateController controller) {
        controller.sourceRecordId = UserInfo.getUserId();
        controller.replaceLineBreaksOnHTMLBreaks = true;
        controller.communityTemplateValue = CommunityTemplateService.TEMPLATE_DEFAULT;

        ParametersDataProvider provider = controller.getDataProvider();
        provider.userMode = 'userType';
        provider.recipientName = 'recipientName';
        provider.recipientId = UserInfo.getUserId();
        provider.recipientLanguage = 'recipientLanguage';
        provider.parametersProviderName = 'parametersProviderName';
        return provider;
    }

}
