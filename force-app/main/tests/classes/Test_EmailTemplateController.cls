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
            provider.isDelegate             = true;
            provider.userMode               = CommunityService.USER_MODE_PARTICIPANT;
            String s = controller.bodyValue;
    
            controller = new EmailTemplateController();
            provider                    = getDataProvider(controller);
            provider.isDelegate         = true;
            provider.userMode           = CommunityService.USER_MODE_PI;
            s = controller.bodyValue;
    
            controller = new EmailTemplateController();
            provider                    = getDataProvider(controller);
            provider.isDelegate         = false;
            provider.userMode           = CommunityService.USER_MODE_PARTICIPANT;
            provider.parameters.put('ReferralSource', 'OTHER');
            s = controller.bodyValue;
    
            controller = new EmailTemplateController();
            provider                    = getDataProvider(controller);
            provider.isDelegate         = false;
            provider.userMode           = CommunityService.USER_MODE_PARTICIPANT;
            provider.parameters.put('ReferralSource', 'PI');
            s = controller.bodyValue;
    
            controller = new EmailTemplateController();
            provider                    = getDataProvider(controller);
            provider.isDelegate         = false;
            provider.userMode           = CommunityService.USER_MODE_PARTICIPANT;
            provider.parameters.put('ReferralSource', 'HCP');
            s = controller.bodyValue;
    
            controller = new EmailTemplateController();
            provider                    = getDataProvider(controller);
            provider.isDelegate         = false;
            provider.userMode           = CommunityService.USER_MODE_PI;
            s = controller.bodyValue;
    
            controller = new EmailTemplateController();
            provider                    = getDataProvider(controller);
            provider.isDelegate         = false;
            provider.userMode           = CommunityService.USER_MODE_HCP;
            s = controller.bodyValue;
            Test.stopTest();
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
    
    private static ParametersDataProvider getDataProvider (EmailTemplateController controller) {
        controller.sourceRecordId = UserInfo.getUserId();
        controller.replaceLineBreaksOnHTMLBreaks = true;

        ParametersDataProvider provider = controller.getDataProvider();
        provider.userMode               = 'userType';
        provider.recipientName          = 'recipientName';
        provider.recipientId            = UserInfo.getUserId();
        provider.recipientLanguage      = 'recipientLanguage';
        provider.parametersProviderName = 'parametersProviderName';
        return provider;
    }
}