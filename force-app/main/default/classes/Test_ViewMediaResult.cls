@IsTest
public class Test_ViewMediaResult {
    @IsTest
    public static void runTest() {
        //TestData.loadTestData();

        Terms_And_Conditions__c portalTC = new Terms_And_Conditions__c(
            Active__c = true
        );

        insert portalTC;

        List < Account > accounts = new List < Account > ();
        Account participantsAccount = new Account(
            Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
        );
        Insert participantsAccount;

        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE Name = 'View All'
            LIMIT 1
        ];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'IQVIA Customer Community Plus Login User'
            LIMIT 1
        ];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator'
            AND UserRoleId =: userRole_1.Id AND IsActive = TRUE LIMIT 1
        ];
        User user_1;
        System.runAs(admin) {
            Account account_1 = new Account(Name = 'Community');
            insert account_1;

            Contact contact_1 = new Contact(AccountId = account_1.Id, LastName = 'xgeek');
            insert contact_1;

            user_1 = new User(
                Email = 'yourusername@gmail.com',
                ProfileId = profile_1.Id,
                UserName = 'yourusername@gmail.com',
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ContactId = contact_1.Id,
                PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname'
            );
            insert user_1;
        }
        Test.startTest();
        System.runAs(user_1) {
            Account SiteAccount = new Account(
                Name = 'Study Site Account',
                BillingCountry = 'United States'
            );

            insert SiteAccount;

            Contact con = new Contact(
                FirstName = 'PITD',
                LastName = 'PITD',
                AccountId = SiteAccount.Id,
                Email = 'test@con.com'
            );
            insert con;


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
                Study_Site_Phone__c = '0000034445',
                Principal_Investigator__c = con.Id,
                Clinical_Trial_Profile__c = clinical.Id,
                Site__c = SiteAccount.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false
                
            );
            insert studySite;


            List < Media_Outreach__c > lstMO = New List < Media_Outreach__c > ();

            Media_Outreach__c MO_req = New Media_Outreach__c();
            MO_req.Requested_Start_Date__c = Date.parse('5/22/2020');
            MO_req.Requested_End_Date__c = Date.parse('5/29/2020');
            MO_req.Status__c = 'Requested';
            MO_req.Study_Name__c = studySite.Id;
            MO_req.Study_Site__c = participantsAccount.Id;
            MO_req.Preferred_contact_method__c = '123456789';
            lstMO.add(MO_req);

            Media_Outreach__c MO_inprogress = New Media_Outreach__c();
            MO_inprogress.Requested_Start_Date__c = Date.parse('5/22/2020');
            MO_inprogress.Requested_End_Date__c = Date.parse('5/29/2020');
            MO_inprogress.Status__c = 'In Progress';
            MO_inprogress.Study_Name__c = studySite.Id;
            MO_inprogress.Study_Site__c = participantsAccount.Id;
            MO_inprogress.Preferred_contact_method__c = 'test@test.com';
            lstMO.add(MO_inprogress);

            Media_Outreach__c MO_fulfilled = New Media_Outreach__c();
            MO_fulfilled.Requested_Start_Date__c = Date.parse('5/22/2020');
            MO_fulfilled.Requested_End_Date__c = Date.parse('5/29/2020');
            MO_fulfilled.Actual_Start_Date__c= Date.parse('5/22/2020');
            MO_fulfilled.Actual_End_Date__c=Date.parse('5/29/2020');
            MO_fulfilled.Status__c = 'Fulfilled';
            MO_fulfilled .Study_Name__c=studySite.Id;
            MO_fulfilled.Study_Site__c = participantsAccount.Id;
            MO_fulfilled.Preferred_contact_method__c = '0000034445';
            lstMO.add(MO_fulfilled);

            Insert lstMo;

            Media_Outreach__c MO_cancelled = New Media_Outreach__c();
            MO_cancelled.Requested_Start_Date__c = Date.parse('5/22/2020');
            MO_cancelled.Requested_End_Date__c = Date.parse('5/29/2020');
            MO_cancelled.Status__c = 'Cancelled';
            MO_cancelled .Study_Name__c=studySite.Id;
            MO_cancelled.Study_Site__c = participantsAccount.Id;
            MO_cancelled.Preferred_contact_method__c = 'test@con.com';
            Insert MO_cancelled;

            System.runAs(admin) {
                ContentNote nts = new ContentNote();
                nts.Title = 'Good';
                insert nts;

                ContentDocumentLink clnk = new ContentDocumentLink();
                clnk.LinkedEntityId = MO_inprogress.ID;
                clnk.ContentDocumentId = nts.Id;
                clnk.ShareType = 'V';
                insert clnk;
            }
            string MediaoutreachNotes = 'good';

            String filterJson = '{"mode":"PI","study":"' + studySite.id + '","trialIds":[]}';
            String PaginationJson = '{"currentPage":1,"pageRecordsCount":10}';
            viewMediaResult.getInitData(clinical.id, null, null, null, null, null);
            viewMediaResult.getRecords(clinical.id, filterJson, PaginationJson, null, 'PI', null, null);
            try {
                viewMediaResult.UpdateRecord(MO_inprogress.ID, MediaoutreachNotes, true, true, '1234567890',true);
            } catch (exception e) {}
            try {
                viewMediaResult.PreferredContactsandNotes(studySite.Id, MO_inprogress.ID);
            } catch (exception e) {}
            try {
                viewMediaResult.PreferredContactsandNotes(studySite.Id, MO_req.ID);
            } catch (exception e) {}
            try {
                viewMediaResult.PreferredContactsandNotes(studySite.Id, MO_fulfilled.ID);
            } catch (exception e) {}
             try {
                viewMediaResult.PreferredContactsandNotes(studySite.Id, MO_cancelled.ID);
            } catch (exception e) {}

        }
        Test.stopTest();

    }


}