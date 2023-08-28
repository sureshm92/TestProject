@isTest
public class Test_RPRecordReviewLogController {
    @TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @isTest
    public static void TestM1(){

        List<Account> accounts = new List<Account>();

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
                Email = 'yourusername1@gmail.com',
                ProfileId = profile_1.Id,
                UserName = 'yourusername1@gmail.com',
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
        Clinical_Trial_Profile__c clinical = [SELECT ID FROM Clinical_Trial_Profile__c LIMIT 1];
        Study_Site__c studySite =[SELECT ID FROM Study_Site__c WHERE Clinical_Trial_Profile__c=:clinical.ID]; 
    
        Participant_Enrollment__c pe = [SELECT ID,Participant__c,Pre_screening_Status__c,Medical_Record_Review_Status__c,PI_Contact__c
                                        ,Initial_visit_scheduled_date__c,Study_Site__c,Patient_ID__c,Referral_Source__c,Participant_Status__c
                                        ,Birth_Month__c,YOB__c,Email__c,Participant_Name__c,Patient_Middle_Name_Initial__c,
                                        Participant_Surname__c,Patient_Sex__c,Mailing_Country_Code__c,Phone__c,Patient_Phone_Type__c
                                        ,Mailing_State_Code__c,Participant_Alternative_Phone__c,Participant_Alt_Phone_Type__c,
                                        Permit_Mail_Email_contact_for_this_study__c,Permit_SMS_Text_for_this_study__c,Participant_Opt_In_Status_Emails__c
                                        ,Participant_Opt_In_Status_SMS__c,IQVIA_Direct_Mail_Consent__c,Participant_Phone_Opt_In_Permit_Phone__c
                                        ,Permit_Voice_Text_contact_for_this_study__c,Postal_Code__c,Patient_Auth__c,Legal_Status__c
                                        ,Is_Email__c,Is_Phone__c,Is_SMS__c,RP_Site_Selected__c
                                      
                                        FROM Participant_Enrollment__c WHERE Clinical_Trial_Profile__c=:clinical.ID
                                       LIMIT 1 ]; 
        HCP_Enrollment__c hcpEnrollment = new HCP_Enrollment__c(
            Study_Site__c = studySite.Id,
            HCP_Contact__c = contact_1.Id,
            Status__c = HCPEnrollmentService.HCP_S_ACTIVATION_PENDING
        );
        insert hcpEnrollment; 
	Test.startTest();
        pe.HCP__c = hcpEnrollment.ID;
        update pe; 
        List<PreScreener_Survey__c> screenerList = new List<PreScreener_Survey__c>();
        screenerList.add(new PreScreener_Survey__c(
            Link_to_Pre_screening__c = 'https://link.test',
            MRR__c = true,
            ProviderName__c = 'surveygizmo',
            Study__c = clinical.Id,
            Survey_Name__c = 'Medical Record Review'
        ));
        insert screenerList;
        
        system.runAs(user_1){
        RPRecordReviewLogController.dateFormatChangeForCreatedDate(system.today());
        RPRecordReviewLogController.getPEDetails('HCP',null); 
        RPRecordReviewLogController.getRecordsDetails();  
        RPRecordReviewLogController.getContactList();  
        RPRecordReviewLogController.getPECountDetails('HCP',null);  
        RPRecordReviewLogController.dateFormatChange(system.today());
            RPRecordReviewLogController.getSelectedPeDetails(pe.id,'','');
        Test.stopTest();
        } 
    }
    @isTest
    public static void TestM1_checkstatusmrr(){ 
        List<Account> accounts = new List<Account>();
       
         UserRole userRole_1 = [SELECT Id FROM UserRole WHERE Name = 'View All' LIMIT 1];
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
            
        } 
        Clinical_Trial_Profile__c clinical = [SELECT ID FROM Clinical_Trial_Profile__c LIMIT 1];
        Study_Site__c studySite =[SELECT ID FROM Study_Site__c WHERE Clinical_Trial_Profile__c=:clinical.ID];
        Participant_Enrollment__c pe = [SELECT ID,Participant__c,Pre_screening_Status__c,Medical_Record_Review_Status__c,PI_Contact__c
                                        ,Initial_visit_scheduled_date__c,Study_Site__c,Patient_ID__c,Referral_Source__c,Participant_Status__c
                                        ,Birth_Month__c,YOB__c,Email__c,Participant_Name__c,Patient_Middle_Name_Initial__c,
                                        Participant_Surname__c,Patient_Sex__c,Mailing_Country_Code__c,Phone__c,Patient_Phone_Type__c
                                        ,Mailing_State_Code__c,Participant_Alternative_Phone__c,Participant_Alt_Phone_Type__c,
                                        Permit_Mail_Email_contact_for_this_study__c,Permit_SMS_Text_for_this_study__c,Participant_Opt_In_Status_Emails__c
                                        ,Participant_Opt_In_Status_SMS__c,IQVIA_Direct_Mail_Consent__c,Participant_Phone_Opt_In_Permit_Phone__c
                                        ,Permit_Voice_Text_contact_for_this_study__c,Postal_Code__c,Patient_Auth__c,Legal_Status__c
                                        ,Is_Email__c,Is_Phone__c,Is_SMS__c,RP_Site_Selected__c,Primary_Delegate_First_Name__c
                                        ,Primary_Delegate_Phone_Number__c,Primary_Delegate_Phone_Type__c,Primary_Delegate_Last_Name__c
                                        ,Primary_Delegate_YOB__c,Primary_Delegate_Email__c,Primary_Delegate_s_Alt_Phone__c
                                        ,Primary_Delegate_s_Alt_Phone_Type__c,Is_Delegate_Certify__c,Delegate_Consent__c
                                        ,Delegate_SMS_Consent__c
                                      
                                        FROM Participant_Enrollment__c WHERE Clinical_Trial_Profile__c=:clinical.ID
                                       LIMIT 1 ];
        HCP_Enrollment__c hcpEnrollment = new HCP_Enrollment__c(
            Study_Site__c = studySite.Id,
            HCP_Contact__c = contact_1.Id,
            Status__c = HCPEnrollmentService.HCP_S_ACTIVATION_PENDING
        );
        insert hcpEnrollment; 
		Test.startTest();
        pe.HCP__c = hcpEnrollment.ID; 

        List<PreScreener_Survey__c> screenerList = new List<PreScreener_Survey__c>();
        screenerList.add(new PreScreener_Survey__c(
            Link_to_Pre_screening__c = 'https://link.test',
            MRR__c = true,
            ProviderName__c = 'surveygizmo',
            Study__c = clinical.Id,
            Survey_Name__c = 'Medical Record Review'
        ));
        insert screenerList; 
       
        RPRecordReviewLogController.changeStatusToExcludeFromReferring(pe.id);
        RPRecordReviewLogController.setMRRStatus(pe.id,'Pass',null,screenerList[0].Id); 
        RPRecordReviewLogController.patientValidation('SomePatientId1','SomePatientId1','US','NY','04','2000','Yes');
        RPRecordReviewLogController.patientValidation(pe.Participant__c,'SomePatientId1','US','NY','04','2015','Yes');
        RPRecordReviewLogController.checkPatientAge('US','NY','04','2000');
        test.stoptest();
        
        try 
        {
         RPRecordReviewLogController.checkDelegateAge('US','NY','2000');
         RPRecordReviewLogController.checkDelegateAge(null,null,null);
        }
        catch (AuraHandledException e)
        {
          system.debug('Error handled');
        }
        try
        {
          RPRecordReviewLogController.undoChangeStatusToExcludeFromReferring(pe.id);
         RPRecordReviewLogController.undoChangeStatusToExcludeFromReferring(null);
        }
        catch (AuraHandledException e)
        {
          system.debug('Error handled');
        }
        RPRecordReviewLogController.updatePeRecords(pe);
        RPRecordReviewLogController.delegateUpdatePeRecords(pe);
        RPRecordReviewLogController.peInitData pei =  new RPRecordReviewLogController.peInitData(null,null,null);
        system.assert(pei!=null);
        
    }
     @isTest
    public static void testMinorPart(){
       
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
                Email = 'yourusername1@gmail.com',
                ProfileId = profile_1.Id,
                UserName = 'yourusername1@gmail.com',
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
            Suppress_Participant_Emails__c = false,
            Override_PI_Referral_Status__c='Accepted'
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
            // Present_Age__c =
            Adult__c = true
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
            Participant_Status__c = 'Pending Referral',
            Participant__c = participant.Id,
            Screening_ID__c = 'PESCR1',
            Birth_Month__c='04',
            YOB__c='2016',
            Primary_Delegate_s_Alt_Phone_Type__c='Home',
            Participant_Alt_Phone_Type__c='Home' 
        );
        insert pe;
        system.runAs(user_1){
        RPRecordReviewLogController.getSelectedPeDetails(pe.Id,'','');
        RPRecordReviewLogController.updatePeRecords(pe);
        }
        system.assert(pe!=null);
    }
    
    
    @isTest
    public static void TestM2(){
        Contact delegateCon = [select Id from contact where LastName = 'PIDelTD'];
        Participant_Enrollment__c pe = [select Id from Participant_Enrollment__c limit 1];
        TestData testData = new TestData();
        RPRecordReviewLogController.getPEDetails('Delegate',delegateCon.Id);  
        RPRecordReviewLogController.getRecordsDetails();  
        RPRecordReviewLogController.getContactList();  
        RPRecordReviewLogController.getPECountDetails('Delegate',delegateCon.Id);  
        RPRecordReviewLogController.dateFormatChange(system.today());
        RPRecordReviewLogController.peInitData pei =  new RPRecordReviewLogController.peInitData(null,null,null);
        system.assert(pei!=null);
    }
    @isTest
    public static void TestM4(){
        Contact delegateCon = [select Id from contact where LastName = 'PIDelTD'];
        List<Participant_Enrollment__c> peList = [select Id from Participant_Enrollment__c];
        List<String> piIds = new List<String>();
        for(Participant_Enrollment__c pe : peList){
            piIds.add(pe.Id);
        }
        //User usr = [select Id from user where contactId = :delegateCon.Id];
        TestData testData = new TestData();
        
        RPRecordReviewLogController.bulkChangeStatusToExcludeFromReferring(piIds);
        RPRecordReviewLogController.bulkUndoChangeStatusToExcludeFromReferring(piIds);
        RPRecordReviewLogController.getExportRecords(piIds);
        List<RPRecordReviewLogController.peNoteData> notes = RPRecordReviewLogController.getNotesDetails(piIds[0]);
        RPRecordReviewLogController.checkDelegateRole();
        RPRecordReviewLogController.createNotes('Test',piIds[0],null);
        RPRecordReviewLogController.peNoteData pen =  new RPRecordReviewLogController.peNoteData(null,null,null);
        system.assert(notes!=null);
    }
    
}