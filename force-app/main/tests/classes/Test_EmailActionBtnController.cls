/**
 * Created by Slav on 21.08.2019.
 */

@IsTest(SeeAllData=true)
public with sharing class Test_EmailActionBtnController {
    
    @IsTest
    public static void runTest() {
        Contact recipient = new Contact(FirstName = 'John', LastName = 'Doe');
        insert recipient;
        List<Contact> contacts = [
                SELECT Id,
                        Name
                FROM Contact
                WHERE Name = 'John Doe'
        ];
        Contact recipientContact = contacts.get(0);
        EmailTemplateProviderService.setProviderType('', recipientContact.Id, recipientContact.Name,
                'en_US', 'IQVIA', recipientContact.Id, '');
        EmailActionBtnController emailActionBtnController = new EmailActionBtnController();
        emailActionBtnController.getResultURL();
    }

}