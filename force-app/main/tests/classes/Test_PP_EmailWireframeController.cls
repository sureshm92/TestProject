@IsTest
public with sharing class Test_PP_EmailWireframeController {
    @TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @IsTest
    public static void runTest() {
        TestData tstData = new TestData();
        Test.startTest();
        EmailTemplateProviderService.setProviderType(
            '',
            tstData.participantUser.ContactId,
            null,
            'en_US',
            'PatientPortal',
            tstData.participantUser.ContactId,
            '',
            'Yes'
        );
        System.runAs(tstData.participantUser) {
            Document document;
            document = new Document();
            document.Body = Blob.valueOf('Some Text');
            document.ContentType = 'application/pdf';
            document.DeveloperName = 'PP_Community_Email_Top_Background';
            document.IsPublic = true;
            document.Name = 'PP_Community_Email_Top_Background';
            document.FolderId = tstData.participantUser.Id;
            insert document;
            Document document1;
            document1 = new Document();
            document1.Body = Blob.valueOf('Some Text');
            document1.ContentType = 'application/pdf';
            document1.DeveloperName = 'PP_IQVIA_Logo';
            document1.IsPublic = true;
            document1.Name = 'PP_IQVIA_Logo';
            document1.FolderId = tstData.participantUser.Id;
            insert document1;

            PP_EmailWireframeController ppwireFrame = new PP_EmailWireframeController();
            String userMode = ppwireFrame.userMode;
            string communitytypeURL = ppwireFrame.communityTypeURL;
            Id recipientId = ppwireFrame.recipientcntId;
            EmailTemplateProvider tempProvider = ppwireFrame.getProvider();
            ppwireFrame.sourceRecordId = tstData.participantUser.Id;
            ppwireFrame.headerValue = '##Header';
            ppwireFrame.titleValue = '##Title';
            ppwireFrame.preSignatureValue = '##Title';
            ppwireFrame.preBodyButtonNameValue = '##Title';
            ppwireFrame.signatureValue = '##Title';
            ppwireFrame.greetingValue = '##Title';
            ppwireFrame.headerValue = '##Header';
            Boolean isPreBodyButtonVal = ppwireFrame.isPreBodyButtonValue;
            String userModeValu = ppwireFrame.userModeValue;
            String displayoptOut = ppwireFrame.displayOptOut;
            Id surveyIdStr = ppwireFrame.surveyIdString;
            String preBodyButtonURLVa = ppwireFrame.preBodyButtonURLValue;
            String uLanguageCode = ppwireFrame.getUserLanguageCode();
            Boolean enableStyl = ppwireFrame.getEnableNewStyle();
            Boolean isRTL = ppwireFrame.getisRTL();
            String headerText = ppwireFrame.getHeaderText();
            String headerBackgroundUrl = ppwireFrame.getHeaderBackgroundUrl();
            String footerLogoUrl = ppwireFrame.getFooterLogoUrl();
            String titleText = ppwireFrame.getTitleText();
            String greetingText = ppwireFrame.getGreetingText();
            String preSignatureText = ppwireFrame.getPreSignatureText();
            String signatureText = ppwireFrame.getSignatureText();
            String emailCommunityURL = ppwireFrame.getEmailCommunityURL();
            Map<String, String> tempMap = ppwireFrame.getTemplateMap();
            String preBodyButtonNameText = ppwireFrame.getpreBodyButtonNameText();
            Boolean isInitialized = ppwireFrame.getIsInitialized();
            ppwireFrame.titleValue = '';
            String titleText1 = ppwireFrame.getTitleText();
            ppwireFrame.titleValue = 'Title';
            String titleText2 = ppwireFrame.getTitleText();
            ppwireFrame.titleValue = '';
            tempProvider.userMode = 'Participant';
            String titleText3 = ppwireFrame.getTitleText();
            ppwireFrame.titleValue = '';
            tempProvider.userMode = 'HCP';
            String titleText5 = ppwireFrame.getTitleText();
        }
        Test.stopTest();
    }
}
