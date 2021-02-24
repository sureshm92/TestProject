@IsTest
public class Test_PdfViewerController {
    
    @TestSetup
    static void setup() {
        Test_RRPDFViewerController.setup();
    }
    
    @IsTest
    public static void runTest() {
        List<Resource__c> resources = [SELECT Id, Title__c FROM Resource__c];
        PdfViewerController.getBase64Resource(resources[0].Id,'en_US');    
    }
}