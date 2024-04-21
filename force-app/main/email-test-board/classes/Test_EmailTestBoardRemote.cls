/**
 * Created by Igor Malyuta on 02.07.2020.
 */

@IsTest
private class Test_EmailTestBoardRemote {
    @IsTest
    static void searchTest() {
        Contact contact = [SELECT Id, FirstName FROM Contact];
        contact.FirstName='Kaitlin';
        update contact;
        Test.setFixedSearchResults(new List<String>{ contact.Id });
        EmailTestBoardRemote.searchRecipient(contact.FirstName);
        EmailTestBoardRemote.searchRecipient('');
        EmailTestBoardRemote.searchRelated(
            'Account',
            CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
        );
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
        EmailTemplateDelController obj = new EmailTemplateDelController();
        obj.commTemplateStr=CommunityTemplateService.TEMPLATE_JANSSEN;
        obj.recipId=contactId;
        obj.contactLanguage='English';
        obj.getPiDelegateLevels();
        EmailTemplateDelController obj1 = new EmailTemplateDelController();
        obj1.commTemplateStr=CommunityTemplateService.TEMPLATE_DEFAULT;
        obj1.recipId=contactId;
        obj1.contactLanguage='English';
        obj1.getPiDelegateLevels();
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
        Clinical_Trial_Profile__c clinical = new Clinical_Trial_Profile__c(
            Protocol_ID__c = 'tt123456790',
            Override_Recruitment_Status__c = 'Actively Enrolling',
            NCT_Number__c = 'NCT00000002',
            Link_to_Pre_screening__c = 'some link',
            Study_Title__c = 'Some Title',
            Study_Code_Name__c = 'Some Code Name',
            Suppress_Participant_Emails__c = false
        );
        insert clinical;
        
        Study_Site__c studySite = new Study_Site__c(
            Name = 'Test',
            Principal_Investigator__c = participantContact.Id,
            Clinical_Trial_Profile__c = clinical.Id,
            Site__c = participantsAccount.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false
        );
        insert studySite;
        Site_Staff__c siteStaff = new Site_Staff__c(
            Delegate_Level__c = 'Level 1',
            Study_Site__c = studySite.Id,
            Site_Contact__c = participantContact.Id,
            is_Invited__c = TRUE
        );
        insert siteStaff;
        RP_Delegate_Relationship__c rpDelegate = new RP_Delegate_Relationship__c(
            Referring_Provider__c = participantContact.Id,
            Delegate_Access_Level__c = DelegateService.DELEGATE_LEVEL_1,
            Delegate__c = participantContact.id
        );
        insert rpDelegate;
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.UpdateParticipantAndUserEmailsOnEmailChangeHandler.class            
        );
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdateContactDetailsFromParticipant.class);
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.ChangeUserEmailOnParticipantEmailChangeHandler.afterUpdate.class            
        );
        Participant__c participant = new Participant__c(
            First_Name__c = 'newParticipant',
            Last_Name__c = 'newParticipant',
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'MS',
            Contact__c = participantContact.id
        );
        insert participant;
    }
}