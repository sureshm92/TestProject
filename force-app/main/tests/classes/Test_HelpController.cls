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
            HelpController.getHelpInitData('PI');
        } catch (Exception e) {
            // expected Exception
        }
        
        System.runAs(testDataInstance.participantUser) {
            HelpController.getHelpInitData('PI');
        }

        List<HelpController.FileContainer> files = new List<HelpController.FileContainer>();
        HelpController.FileContainer file = new HelpController.FileContainer();
        file.tmpId = '11111';
        file.base64Data = EncodingUtil.base64Encode(Blob.valueOf('Test file'));
        file.fileName = 'some.txt';
        file.contentType = 'text/plain';
        files.add(file);
        HelpController.createCase('Some case','Seme Description', 'Question', 'Low', 'Some Reason', JSON.serialize(files), false, false);

        try {
            HelpController.createCase('Some case','Seme Description', 'Question', 'Low', 'Some Reason', 'wrong', false, false);
        } catch (Exception e) {
            // expected Exception
        }
        
        Test.StopTest();
    }
}