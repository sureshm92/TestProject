/**
 * Created by Slav on 21.08.2019.
 */

@IsTest
public with sharing class Test_EmailActionBtnController {
    
    @IsTest
    public static void runTest() {
        Contact recipient = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'johndoe@mail.com');
        insert recipient;
        EmailTemplateProviderService.setProviderType('', recipient.Id, recipient.Name,
                'en_US', 'Default', recipient.Id, '');
        EmailActionBtnController emailActionBtnController = new EmailActionBtnController();
        emailActionBtnController.getResultURL();
    }
}