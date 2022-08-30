@IsTest
public class Test_ListViewParticipantController {
 
    @testsetup
    public static void dataSetup() {
        Terms_And_Conditions__c portalTC = new Terms_And_Conditions__c(Active__c = true);
        insert portalTC;

        List<Account> accounts = new List<Account>();
        Account participantsAccount = new Account(
            Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
        );
        insert participantsAccount;

        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE Name = 'View All' LIMIT 1];
        Profile profile_1 = [
            SELECT Id
            FROM Profile
            WHERE Name = 'IQVIA Customer Community Plus Login User'
            LIMIT 1
        ];
        User admin = [
            SELECT Id, Username, UserRoleId
            FROM User
            WHERE
                Profile.Name = 'System Administrator'
                AND UserRoleId = :userRole_1.Id
                AND IsActive = TRUE
            LIMIT 1
        ];
        User user_1;
        Contact contact_1;
        Account account_1;
        System.runAs(admin) {
            account_1 = new Account(Name = 'Community', BillingCountry = 'United States');
            insert account_1;

            contact_1 = new Contact(AccountId = account_1.Id, LastName = 'xgeek');
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
            Principal_Investigator__c = contact_1.Id,
            Clinical_Trial_Profile__c = clinical.Id,
            Site__c = account_1.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false
        );
        insert studySite;

        HCP_Enrollment__c hcpEnrollment = new HCP_Enrollment__c(
            Study_Site__c = studySite.Id,
            HCP_Contact__c = contact_1.Id,
            Status__c = HCPEnrollmentService.HCP_S_ACTIVATION_PENDING
        );
        insert hcpEnrollment;

        Participant__c participant = new Participant__c(
            First_Name__c = 'ParticipantTD',
            Last_Name__c = 'ParticipantTD',
            Phone__c = '55313535',
            Email__c = 'part1@email.com',
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'AL',
            age__c = 23,
            site__c = account_1.id,
            Gender_Technical__c = 'Male',
            // Present_Age__c = 24,
            Adult__c = true,
            Ethnicity__c = ''
        );
        insert participant;

        Participant_Enrollment__c pe = new Participant_Enrollment__c(
            HCP__c = hcpEnrollment.Id,
            Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
            Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
            PI_Contact__c = contact_1.Id,
            Initial_visit_scheduled_date__c = date.today(),
            Study_Site__c = studySite.Id,
            Patient_ID__c = 'SomePatientId1',
            Referral_Source__c = 'HCP',
            Source_Type__c = 'Referring Provider',
            HighRisk_Indicator__c = 'Yes',
            Participant__c = participant.Id,
            Screening_ID__c = 'PESCR1',
            Comorbidities__c = 'Yes'
        );
        insert pe;
        Participant_Enrollment_Status_History__c pesh = new Participant_Enrollment_Status_History__c(
            Date__c = date.today(),
            ParticipantEnrollment__c = pe.Id,
            Status__c = 'Contact Attempted'
        );
       insert pesh;
    }
    @IsTest
    public static void runTest() {
        Clinical_Trial_Profile__c clinical = [SELECT ID FROM Clinical_Trial_Profile__c LIMIT 1];
        Study_Site__c studySite = [SELECT ID,Override_PI_Referral_Status__c  FROM Study_Site__c LIMIT 1];
        studySite.Override_PI_Referral_Status__c ='Accepted';
        update studySite;
        Participant_Enrollment__c pe = [SELECT ID FROM Participant_Enrollment__c LIMIT 1];
        
        participant__c p = [SELECT Age__c FROM participant__c LIMIT 1];
        Incentive_Plan__c ip = new Incentive_Plan__c(
        Clinical_Trial_Profile__c = clinical.id,
            Plan_Name__c = 'test'
        );
        insert ip;
        Study_Incentive_Plan__c si = new Study_Incentive_Plan__c(
            Clinical_Trial_Profile__c = clinical.id,
            Study_Site__c = studySite.id,
            Incentive_Plan__c = ip.id
        );
        insert si;
        
        Incentive_Plan_Task__c ipt = new Incentive_Plan_Task__c(
            Incentive_Task_Catalog__c = 'PI_TASK03',
            Enabled__c=TRUE,
            Incentive_Plan__c= ip.id
        );
        insert ipt;
        Participant_Enrollment__c pen = [SELECT ID,Participant_Status__c FROM Participant_Enrollment__c LIMIT 1];
        pen.Participant_Status__c ='Enrollment Success';
        update pen;
        Clinical_Trial_Profile__c clinical1 = [SELECT ID,Promote_to_SH__c FROM Clinical_Trial_Profile__c LIMIT 1];
        clinical1.Promote_to_SH__c=true;
        clinical1.DCT_Platform__c='Study Hub';
        update clinical1;
        contact con = [SELECT id FROM contact LIMIT 1];
        user u = [SELECT id FROM user WHERE email = 'yourusername@gmail.com' LIMIT 1];
        List<Id> peList = new List<Id>{ pe.id };
        List<List_View_Status__mdt> lvs =[ SELECT Managed_in_SH__c, Initial_Visit__c, Available_Statuses__c
        FROM List_View_Status__mdt ];
        ListViewParticipantController.ListWrapper lw = new ListViewParticipantController.ListWrapper();
        lw.SelectedIds = new List<Id>{ pe.id };
        lw.pageSize = 5;
        lw.pageNumber = 3;
        lw.Sortby = 'Ascending';
        lw.Status = 'Active';
        lw.Study = clinical.id;
        lw.StudySites = '';
        lw.Source = '';
        lw.isHighRiskOccupation = 'true';
        lw.isComorbidities = 'false';
        lw.Ethnicity = '';
        lw.AgeFrom = '0';
        lw.AgeTo = '25';
        lw.highPrioritySelected_YesIds = new List<Id>{ pe.id };
        lw.highPrioritySelected_NoIds = new List<id>();
        lw.isInitialVisitScheduled = 'true';
        lw.Sex = '';
        lw.isExport = 'true';
        lw.startPos = 1;
        lw.endPos = 45000;

        System.runAs(u) {
            ListViewParticipantController.getInitData(
                clinical.ID,
                studySite.Id,
                'PI',
                null,
                'Janssen'
            );

            ListViewParticipantController.getSSList(clinical.Id,'Active');
            ListViewParticipantController.getAvailableStatuses('Received',clinical.Id);
            ListViewParticipantController.getAvailableStatuses('Randomization Success',clinical.Id);
            ListViewParticipantController.statusDetail('Received',clinical.Id);
            ListViewParticipantController.statusDetail('Pre-review Failed',clinical.Id);
            Test.startTest();
            ListViewParticipantController.createUserForPatientProtal(peList,True);
            
            
            List<Id> peListnew = new List<Id>{ pen.id };
            ListViewParticipantController.updateParticipantStatus(peList,
                                                                  'Received',
                                                                  'Test Notes',
                                                                  'Other',
                                                                  clinical.Id,
                                                                  'Contact Attempted',
                                                                  True);
             ListViewParticipantController.updateParticipantStatus(peList,
                                                                  'In Wash Out Period',
                                                                  'Test Notes',
                                                                  'Other',
                                                                  clinical.Id,
                                                                  'Contact Attempted',
                                                                  True);
            ListViewParticipantController.updateParticipantStatus(peList,
                                                                  'Sent to Study Hub',
                                                                  'Test Notes',
                                                                  'Other',
                                                                  clinical.Id,
                                                                  'Contact Attempted',
                                                                  True);
            ListViewParticipantController.updateParticipantStatus(peList,
                                                                  'Screening In Progress',
                                                                  'Test Notes',
                                                                  'Other',
                                                                  clinical.Id,
                                                                  'Ready To Screen',
                                                                  True);
             ListViewParticipantController.updateParticipantStatus(peListnew,
                                                                  'Screening In Progress',
                                                                  'Test Notes',
                                                                  'Other',
                                                                  clinical.Id,
                                                                  'Ready to Screen',
                                                                  True);
            ListViewParticipantController.updateParticipantStatus(peList,
                                                                  'Contact Attempted',
                                                                  'Test Notes',
                                                                  'Other',
                                                                  clinical.Id,
                                                                  'Received',
                                                                  True);

            ListViewParticipantController.getParticipantStatus(clinical.ID,'Active');
            ListViewParticipantController.getParticipantStatus(clinical1.ID,'Active');
			
            ListViewParticipantController.getParticipantStatus(clinical.ID,'Inactive');

            ListViewParticipantController.updateParticipantData(
                new List<String>{ pe.id },
                new List<String>{ pe.id },
                new List<String>{ pe.id }
            );
            ListViewParticipantController.updateParticipantData(
                new List<String>{  pe.id},
                new List<String>{ 'Test' },
                new List<String>{ pe.id }
            );
            ListViewParticipantController.updateParticipantData(
                new List<String>{  pe.id},
                new List<String>{ 'Test' },
                new List<String>{ 'Test' }
            );
            ListViewParticipantController.fetchData(
                JSON.serialize(new List<ListViewParticipantController.ListWrapper>{ lw }),null,null
            );
            LabelValueItem lv = new LabelValueItem(Label.Referring_Provider, 'Referring Provider');

            ListViewParticipantController.labelValueItemsHaveItem(
                new List<LabelValueItem>{ lv },
                'Referring Provider'
            );
            ListViewParticipantController.labelValueItemsHaveItem(
                new List<LabelValueItem>{ lv },
                ''
            );
            ListViewParticipantController.SearchResult sr = new ListViewParticipantController.SearchResult();
            sr.peList = new List<ListViewParticipantController.PEWrapper>();
            sr.PaginationData = new PaginationData();
            ListViewParticipantService.PEFilter pef;
            sr.peFilter = new ListViewParticipantService.PEFilter(
                new ListViewParticipantService.PEFilterData()
            ); //PEFilter;

            sr.peList = new List<ListViewParticipantController.PEWrapper>();

            ListViewParticipantController.updateSearchResultAccordingItemChanged(sr, 'Inactive');
            ListViewParticipantController.updateSearchResultAccordingItemChanged(sr, 'active');
            ListViewParticipantController.updateSearchResultAccordingItemChanged(sr, 'test');
            ListViewParticipantController.getParticipantData(pe.id, con.id);
            Test.stopTest();
        }
    }

    @IsTest
    public static void runTest1() {
        Clinical_Trial_Profile__c clinical = [SELECT ID FROM Clinical_Trial_Profile__c LIMIT 1];
        Study_Site__c studySite = [SELECT ID FROM Study_Site__c LIMIT 1];
        Participant_Enrollment__c pe = [SELECT ID FROM Participant_Enrollment__c LIMIT 1];
        participant__c p = [SELECT Age__c FROM participant__c LIMIT 1];
        system.debug(p.Age__c);
        contact con = [SELECT id FROM contact LIMIT 1];
        user u = [SELECT id FROM user WHERE email = 'yourusername@gmail.com' LIMIT 1];
        ListViewParticipantController.ListWrapper lw = new ListViewParticipantController.ListWrapper();
        lw.SelectedIds = new List<Id>();
        lw.pageSize = 5;
        lw.pageNumber = 3;
        lw.Sortby = 'Ascending';
        //lw.Status = 'Active';
        lw.Study = clinical.id;
        lw.StudySites = '';
        lw.Source = '';
        lw.isHighRiskOccupation = 'true';
        lw.isComorbidities = 'false';
        lw.Ethnicity = '';
        lw.AgeFrom = '0';
        lw.AgeTo = '25';
        lw.highPrioritySelected_YesIds = new List<Id>{ pe.id };
        lw.highPrioritySelected_NoIds = new List<id>();
        lw.isInitialVisitScheduled = 'true';
        lw.Sex = '';
        lw.isExport = 'true';
        lw.startPos = 1;
        lw.endPos = 45000;
        
        
        
        

        System.runAs(u) {
            ListViewParticipantController.getInitData(
                clinical.ID,
                studySite.Id,
                'PI',
                null,
                'Janssen'
            );
            ListViewParticipantController.getInitData(
                clinical.ID,
                studySite.Id,
                'HCP',
                null,
                'Janssen'
            );

            ListViewParticipantController.getSSList(clinical.Id,'Active');

            ListViewParticipantController.getParticipantStatus(clinical.ID,'Active');

            ListViewParticipantController.getParticipantStatus(clinical.ID,'Inactive');

            ListViewParticipantController.updateParticipantData(
                new List<String>{ pe.id },
                new List<String>{ pe.id },
                new List<String>{ pe.id }
            );

            ListViewParticipantController.fetchData(
                JSON.serialize(new List<ListViewParticipantController.ListWrapper>{ lw }),null,null
            );
            
            
            ListViewParticipantController.fetchData(
                JSON.serialize(new List<ListViewParticipantController.ListWrapper>{ lw }),'Invite to Patient Portal',null
            );
            LabelValueItem lv = new LabelValueItem(Label.Referring_Provider, 'Referring Provider');

            ListViewParticipantController.labelValueItemsHaveItem(
                new List<LabelValueItem>{ lv },
                'Referring Provider'
            );
            ListViewParticipantController.SearchResult sr = new ListViewParticipantController.SearchResult();
            sr.peList = new List<ListViewParticipantController.PEWrapper>();
            sr.PaginationData = new PaginationData();
            ListViewParticipantService.PEFilter pef;
            sr.peFilter = new ListViewParticipantService.PEFilter(
                new ListViewParticipantService.PEFilterData()
            ); //PEFilter;

            sr.peList = new List<ListViewParticipantController.PEWrapper>();

            ListViewParticipantController.updateSearchResultAccordingItemChanged(sr, 'Inactive');
            ListViewParticipantController.updateSearchResultAccordingItemChanged(sr, 'active');
            ListViewParticipantController.updateSearchResultAccordingItemChanged(sr, 'test');
            ListViewParticipantController.getParticipantData(pe.id, con.id);
            
        }
    }
    
    @IsTest
    public static void runTest2() {
        Clinical_Trial_Profile__c clinical = [SELECT ID FROM Clinical_Trial_Profile__c LIMIT 1];
        Study_Site__c studySite = [SELECT ID FROM Study_Site__c LIMIT 1];
        Participant_Enrollment__c pe = [SELECT ID,Study_Hub_Log__c,Participant_Status__c,Clinical_Trial_Profile__r.Promote_to_SH__c FROM Participant_Enrollment__c LIMIT 1];
        participant__c p = [SELECT Age__c FROM participant__c LIMIT 1];
        system.debug(p.Age__c);
        contact con = [SELECT id FROM contact LIMIT 1];
        user u = [SELECT id FROM user WHERE email = 'yourusername@gmail.com' LIMIT 1];
        ListViewParticipantController.ListWrapper lw = new ListViewParticipantController.ListWrapper();
        lw.SelectedIds = new List<Id>{pe.id};
        lw.pageSize = 5;
        lw.pageNumber = 3;
        lw.Sortby = 'Received Date(Oldest First)';
        lw.Study = clinical.id;
        lw.StudySites = '';
        lw.Source = '';
        lw.isHighRiskOccupation = 'true';
        lw.isComorbidities = 'true';
        lw.Ethnicity = 'Indian';
        lw.AgeFrom = '0';
        lw.AgeTo = '150';
        lw.highPrioritySelected_YesIds = new List<Id>{ pe.id };
        lw.highPrioritySelected_NoIds = new List<id>();
        lw.isInitialVisitScheduled = 'true';
        lw.Sex = 'Male';
        lw.isExport = 'true';
        lw.startPos = 1;
        lw.endPos = 45000;
        lw.ParticipantStatus = 'Received';

        System.runAs(u) {
            ListViewParticipantController.getInitData(
                clinical.ID,
                studySite.Id,
                'PI',
                null,
                'Janssen'
            );
            
            List<String> strList =new List<String>{'Received'};
            
            ListViewParticipantController.ifAllowedForSH(pe,strList);

            
            ListViewParticipantController.fetchData(
                JSON.serialize(new List<ListViewParticipantController.ListWrapper>{ lw }),'Invite to Patient Portal',null
            );
            try{
            ListViewParticipantController.fetchData(
                '',null,null
            );
            ListViewParticipantController.updateParticipantData(
                new List<String>{ 'null'},
                new List<String>{  'null'},
                new List<String>{  ''}
            );
            
            }
            catch(Exception ex) {System.assertEquals(ex.getMessage(),'Script-thrown exception' );}

            LabelValueItem lv = new LabelValueItem(Label.Referring_Provider, 'Referring Provider');

            ListViewParticipantController.labelValueItemsHaveItem(
                new List<LabelValueItem>{ lv },
                'Referring Provider'
            );
            ListViewParticipantController.SearchResult sr = new ListViewParticipantController.SearchResult();
            sr.peList = new List<ListViewParticipantController.PEWrapper>();
            sr.PaginationData = new PaginationData();
            ListViewParticipantService.PEFilter pef;
            sr.peFilter = new ListViewParticipantService.PEFilter(
                new ListViewParticipantService.PEFilterData()
            ); //PEFilter;

        }
    }
    
}