/**
 * Created by Slav on 21.08.2019.
 */

@IsTest(SeeAllData=true)
public with sharing class Test_EmailActionBtnController {
    
    @IsTest
    public static void runTest() {
        EmailActionButtonController emailActionBtnController = new EmailActionButtonController();
        emailActionBtnController.getResultURL();
    }

}