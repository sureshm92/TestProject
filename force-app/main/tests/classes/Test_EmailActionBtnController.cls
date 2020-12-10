/**
 * Created by Slav on 21.08.2019.
 */

@IsTest
public with sharing class Test_EmailActionBtnController {
    @IsTest
    public static void runTest() {
        Contact recipient = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'johndoe@mail.com'

        );
        insert recipient;
        EmailTemplateProviderService.setProviderType(
            '',
            recipient.Id,
            recipient.Name,
            'en_US',
            'Default',
            recipient.Id,
            '',
            ''
        );
        EmailActionBtnController emailActionBtnController = new EmailActionBtnController();
        String resultURL = emailActionBtnController.getResultURL();
        System.assert(resultURL.length() > 0);
    }
        @IsTest
    public static void runTest2() {
        Contact recipient = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'johndoe@mail.com',
            userCommunityMode__c='Participant',
            UserCommunityIsDelegate__c=true

        );
        insert recipient;
        EmailTemplateProviderService.setProviderType(
            '',
            recipient.Id,
            null,
            'en_US',
            'Default',
            recipient.Id,
            '',
            'Yes'
        );
        EmailActionBtnController emailActionBtnController = new EmailActionBtnController();
        EmailTemplateProvider testEmail = new EmailTemplateProvider();
        testEmail.addStudySiteNumber();
        testEmail.getUserLanguage();
        String resultURL = emailActionBtnController.getResultURL();
        System.assert(resultURL.length() > 0);
    }

}