/**
 * Created by Igor Malyuta on 02.07.2020.
 */

@IsTest
private class Test_EmailTestBoardRemote {

    @IsTest
    static void searchTest() {
        Contact contact = [SELECT Id, FirstName FROM Contact];
        Test.setFixedSearchResults(new List<String>{
                contact.Id
        });

        EmailTestBoardRemote.searchRecipient(contact.FirstName);
        EmailTestBoardRemote.searchRelated('Contact', contact.FirstName);
    }

    @IsTest
    static void getPreviewHTMLTest() {
        Id contactId = [SELECT Id FROM Contact].Id;
        EmailTestBoardRemote.getPreviewHTML(getWrapperJSON(), contactId, contactId);
    }

    @IsTest
    static void sendEmailTest() {
        Id contactId = [SELECT Id FROM Contact].Id;
        EmailTestBoardRemote.sendEmail(getWrapperJSON(), contactId, contactId, 'notification');
        EmailTestBoardRemote.sendEmail(getWrapperJSON(), contactId, contactId, '');
    }

    private static String getWrapperJSON() {
        EmailTestBoardRemote.EmailTemplateWrapper wrapper;
        List<EmailTestBoardRemote.EmailTemplateWrapper> wrappers = EmailTestBoardRemote.getEmailTemplateWrappers();
        if (!wrappers.isEmpty()) {
            for (EmailTestBoardRemote.EmailTemplateWrapper wr : wrappers) {
                if (wr.emailDevName.equals('Delegate_New_Email')) {
                    wrapper = wr;
                    break;
                }
            }
        }
        String wrapperJSON = JSON.serialize(wrapper);
        return wrapperJSON;
    }

    @TestSetup
    static void setup() {
        Account participantsAccount = new Account(
                Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
        );
        insert participantsAccount;

        Contact participantContact = new Contact(
                FirstName = 'Kaitlin',
                LastName = 'Duke',
                Email = 'kd@fakeemail.com',
                MailingCountry = 'United States',
                AccountId = participantsAccount.Id
        );
        insert participantContact;
    }
}