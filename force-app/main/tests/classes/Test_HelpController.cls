/**
 * Created by Slav on 22.08.2019.
 */

@IsTest
public class Test_HelpController {

    @IsTest
    public static void runTest() {
        TestData.loadTestData();
        TestData testDataInstance = new TestData();
    
        Test.startTest();
    
        try {
            HelpController.getUserInfo();
        } catch (Exception e) {
            // expected Exception
        }
        
        System.runAs(testDataInstance.participantUser) {
            HelpController.getUserInfo();
        }

        List<HelpController.FileContainer> files = new List<HelpController.FileContainer>();
        HelpController.FileContainer file = new HelpController.FileContainer();
        file.tmpId = '11111';
        file.base64Data = EncodingUtil.base64Encode(Blob.valueOf('Test file'));
        file.fileName = 'some.txt';
        file.contentType = 'text/plain';
        files.add(file);
        HelpController.createCase('Some case', 'Question', JSON.serialize(files));

        try {
            HelpController.createCase('Some case', 'Question', 'wrong_param');
        } catch (Exception e) {
            // expected Exception
        }
        
        Test.StopTest();
    }
}