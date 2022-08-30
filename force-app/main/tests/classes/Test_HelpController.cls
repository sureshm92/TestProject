/**
 * Created by Slav on 22.08.2019.
 */

@IsTest
public class Test_HelpController {
    private class HelpInitData {
        HelpController.UserContact userContact;
        List<Participant_Enrollment__c> participantEnrollList;
        List<LabelValueItem> participantEnrollOptions;
        List<Study_Site__c> siteList;
        List<LabelValueItem> siteOptions;
        List<HelpTopicWrapper> helpTopicSettings;
        List<LabelValueItem> helpTopicOptions;
    }

    private class HelpTopicWrapper {
        Boolean userDescriptionRequired;
        String knowledgeArticleLink;
        String type;
        String subject;
        String priority;
        String reason;
        String description;
        String userTypes;
        Integer order;
        String displayName;
        String displaySolution;
        String descriptionPlaceholder;
        Boolean submitRequired;
        Boolean escalated;
    }

    @IsTest
    public static void runTest() {
        Test.startTest();
        TestData.loadTestData();
          Test.stopTest();
        TestData testDataInstance = new TestData();

        HelpInitData initDataPart;
        String initExceptionMessage;
        String fileExceptionMessage;

        
        try {
            HelpController.getHelpInitData('PI','Default');
        } catch (Exception e) {
            initExceptionMessage = e.getMessage();
        }

        System.runAs(testDataInstance.participantUser) {
            initDataPart = (HelpInitData) JSON.deserialize(
                HelpController.getHelpInitData('PI','Default'),
                HelpInitData.class
            );
        }

        List<HelpController.FileContainer> files = new List<HelpController.FileContainer>();
        HelpController.FileContainer file = new HelpController.FileContainer();
        file.tmpId = '11111';
        file.base64Data = EncodingUtil.base64Encode(Blob.valueOf('Test file'));
        file.fileName = 'some.txt';
        file.contentType = 'text/plain';
        files.add(file);
        HelpController.createCase(
            'Some case',
            'Seme Description',
            'Question',
            'Low',
            'Some Reason',
            JSON.serialize(files),
            false,
            false
        );

        try {
            HelpController.createCase(
                'Some case',
                'Seme Description',
                'Question',
                'Low',
                'Some Reason',
                'wrong',
                false,
                false
            );
        } catch (Exception e) {
            fileExceptionMessage = e.getMessage();
        }
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Some case'];
        ContentDocumentLink testFile = [
            SELECT Id, ContentDocument.Title
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :testCase.Id
        ];
      
        System.assert(initExceptionMessage.contains('Attempt to de-reference a null object'));
        System.assert(initDataPart.helpTopicSettings[0].userTypes.contains('PI'));

        
        System.assertEquals(file.fileName, testFile.ContentDocument.Title);
        System.assert(fileExceptionMessage.contains('Unexpected character'));
    }
}