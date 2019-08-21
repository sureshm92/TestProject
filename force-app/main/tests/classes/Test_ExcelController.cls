/**
 * Created by Slav on 21.08.2019.
 */

@IsTest
public with sharing class Test_ExcelController {
    
    @IsTest
    public static void runTest() {
        Test.StartTest();
        
        PageReference pageRef = Page.ExportExcelPage;
        pageRef.getParameters().put('userMode', CommunityService.USER_MODE_HCP);            // USER_MODE_PARTICIPANT
        pageRef.getParameters().put('study', 'study');
        pageRef.getParameters().put('referringClinic', 'referringClinic');
        pageRef.getParameters().put('dateRange', 'dateRange');
        Test.setCurrentPage(pageRef);
    
        ExcelController excelController = new ExcelController();
        try {
            excelController.getPEList();
        } catch (Exception e) {
            // expected Exception
        }
        
        try {
            excelController.getHCPEList();
        } catch (Exception e) {
            // expected Exception
        }
    
        Test.StopTest();
    }
}