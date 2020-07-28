@IsTest
public class Test_NoteSection {
    @IsTest
    public static void runTest() {
        Account studySiteAccount = new Account(
            Name = 'Study Site Account',
            BillingCountry = 'United States'
        );
        
        insert studySiteAccount;
        
        Contact piContact = new Contact(
            FirstName = 'PITD',
            LastName = 'PITD',
            Email = 'pi@emil.com',
            MailingCountry = 'United States',
            AccountId = studySiteAccount.Id
        );
        insert piContact;
       
        Clinical_Trial_Profile__c testStudy = new Clinical_Trial_Profile__c(
            Protocol_ID__c = 'tt123456790',
            Override_Recruitment_Status__c = 'Actively Enrolling',
            NCT_Number__c = 'NCT00000002',
            Link_to_Pre_screening__c = 'some link',
            Study_Title__c = 'Some Title',
            Study_Code_Name__c = 'Some Code Name',
            Suppress_Participant_Emails__c = false
        );
        insert testStudy;
        
        Study_Site__c studySite = new Study_Site__c(
            Name = 'Test',
            Principal_Investigator__c = piContact.Id,
            Clinical_Trial_Profile__c = testStudy.Id,
            Override_PI_Referral_Status__c = StudySiteService.PI_S_ACCEPTED,
            Site__c = studySiteAccount.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false
        );
        insert studySite;
        Media_Outreach__c MO_inprogress = new Media_Outreach__c(
            Study_Name__c = studySite.Id,
            Study_Site__c = studySiteAccount.Id,
            Media_Type__c = 'Radio;Television;Social Media;',
            Preferred_contact_method__c = 'test@gmail.com',
            Status__c = 'Requested',
            Requested_Start_Date__c = Date.parse('5/22/2020'),
            Requested_End_Date__c = Date.parse('5/29/2020'),
            Alternate_Email_Phone_Number__c = 'nks11@gmail.com'
        );
        insert MO_inprogress;

        ContentNote nts = new ContentNote();
        nts.Title = 'Good';
        insert nts;

        ContentDocumentLink clnk = new ContentDocumentLink();
        clnk.LinkedEntityId = MO_inprogress.ID;
        clnk.ContentDocumentId = nts.Id;
        clnk.ShareType = 'V';
        insert clnk;
        string MediaoutreachNotes = 'good';
        Test.startTest();
        try {
            GetNotes.UpdateNotes(MO_inprogress.ID, MediaoutreachNotes);
        } catch (exception e) {}
        try {
            GetNotes.getNotesdata(MO_inprogress.ID);
        } catch (exception e) {}
        Test.stopTest();

    }
}