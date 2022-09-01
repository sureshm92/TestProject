/**
 * Created by Igor Malyuta on 22.04.2019.
 */

@IsTest
public class Test_ManualTaskFilter {
    @TestSetup
    static void setup() {
        
        TestData.loadTestData();
        
    }
    private static final String FIELD_JOIN_EXPECTED =
        ' Account IN (\'' +
        '0011F00000PfTigQAF' +
        ManualTaskFilter.SEPARATOR +
        '0011F00000PfTihQAF' +
        ManualTaskFilter.SEPARATOR +
        '0011F00000PfTiiQAF' +
        ManualTaskFilter.SEPARATOR +
        '0011F00000PfTijQAF' +
        '\') ';

    @IsTest
    public static void fieldJoinTest() {
        List<String> testIds = new List<String>();
        testIds.add('0011F00000PfTigQAF');
        testIds.add('0011F00000PfTihQAF');
        testIds.add('0011F00000PfTiiQAF');
        testIds.add('0011F00000PfTijQAF');
        
		Test.startTest();
        TestData td = new TestData();
        List<Participant_Enrollment__c> testPEs;
        String filterResult;
        List<String> filteredCountryCodes;

        ManualTaskFilter manualTaskFilter = new ManualTaskFilter();
        System.assertEquals(FIELD_JOIN_EXPECTED, DatabaseService.fieldInValues('Account', testIds));

        manualTaskFilter.countries.add(
            new LookupSearchResult('US', 'Participant_Status__c', 'icon', 'title', 'subtitle')
        );
        manualTaskFilter.statuses.add('Enrolled');
        manualTaskFilter.statuses.add('Referred');

        testPEs = manualTaskFilter.getContactsWithPE().get(td.participant.Contact__c);
 
        Account studySiteAccount = new Account(
            Name = 'Study Site Account',
            BillingCountry = 'United States'
        );
        insert studySiteAccount;
        List<Contact> platformContactLST = new List<Contact>();
        Contact delegateContact = new Contact(
            FirstName = 'DelegateFirst',
            LastName = 'DelegateLastName',
            Email = 'test11+16@emil.com',
            MailingCountry = 'United States',
            AccountId = studySiteAccount.Id
        );
        platformContactLST.add(delegateContact);
        insert platformContactLST;
        List<Participant__c> PlatformParticipantLST = new List<Participant__c>();
        Participant__c delegateParticipant = new Participant__c(
            First_Name__c = 'Patient22',
            Last_Name__c = 'Delegate44',
            Contact__c = delegateContact.Id
        );
        PlatformParticipantLST.add(delegateParticipant);
        insert PlatformParticipantLST;
        List<Patient_Delegate__c>patientDelegateLST = new List<Patient_Delegate__c>();
        for(Participant_Enrollment__c enroll: testPEs){
        for(Contact con: platformContactLST){
       Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = con.Id,
            Contact__r = con,
            Participant__c = enroll.Participant__c,
            Participant__r = enroll.Participant__r
        );
            patientDelegateLST.add(patientDelegate);
      }
            }
        insert patientDelegateLST;
        TaskService.TaskConfig taskConfig = new TaskService.TaskConfig();
        taskConfig.visibility ='Delegates';
        filterResult = manualTaskFilter.filterTherapeutic();
        filteredCountryCodes = manualTaskFilter.getCountryCode();
        manualTaskFilter.isPlatformLevel = true;
        manualTaskFilter.getContactsWithWhatIds(taskConfig);
        manualTaskFilter.getContactsWithParticipantIds(taskConfig.visibility);
        

        System.assertEquals('US', testPEs[0].Participant__r.Mailing_Country_Code__c);
        System.assert(filterResult.contains('Participant__c'));
        System.assert(filteredCountryCodes.contains('US'));
        Test.stopTest();
    }
    
    @IsTest
    public static void studylevelTask() {
        List<String> testIds = new List<String>();
        testIds.add('0011F00000PfTigQAF');
        testIds.add('0011F00000PfTihQAF');
        testIds.add('0011F00000PfTiiQAF');
        testIds.add('0011F00000PfTijQAF');

        //TestData.loadTestData();
        Test.startTest();
        TestData td = new TestData();

        List<Participant_Enrollment__c> testPEs;
        String filterResult;
        List<String> filteredCountryCodes;

        
        ManualTaskFilter manualTaskFilter = new ManualTaskFilter();
        System.assertEquals(FIELD_JOIN_EXPECTED, DatabaseService.fieldInValues('Account', testIds));

        manualTaskFilter.countries.add(
            new LookupSearchResult('US', 'Participant_Status__c', 'icon', 'title', 'subtitle')
        );
        manualTaskFilter.statuses.add('Enrolled');
        manualTaskFilter.statuses.add('Referred');

        testPEs = manualTaskFilter.getContactsWithPE().get(td.participant.Contact__c);
        system.debug('testPEs>>'+testPEs);
        Account studySiteAccount = new Account(
            Name = 'Study Site Account',
            BillingCountry = 'United States'
        );
        insert studySiteAccount;
        List<Contact> contactLST = new List<Contact>();
        Contact delegateContact = new Contact(
            FirstName = 'DelegateFirst',
            LastName = 'DelegateLastName',
            Email = 'test11+16@emil.com',
            MailingCountry = 'United States',
            AccountId = studySiteAccount.Id
        );
        contactLST.add(delegateContact);
        insert contactLST;
        List<Participant__c> participantLST = new List<Participant__c>();
        Participant__c delegateParticipant = new Participant__c(
            First_Name__c = 'Patient22',
            Last_Name__c = 'Delegate44',
            Contact__c = delegateContact.Id
        );
        participantLST.add(delegateParticipant);
        insert participantLST;
        List<Patient_Delegate__c>patientDelegateLST = new List<Patient_Delegate__c>();
        for(Participant_Enrollment__c enroll: testPEs){
        for(Contact con: contactLST){
       Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = con.Id,
            Contact__r = con,
            Participant__c = enroll.Participant__c,
            Participant__r = enroll.Participant__r
        );
            patientDelegateLST.add(patientDelegate);
      }
            }
        insert patientDelegateLST;
        TaskService.TaskConfig taskConfig = new TaskService.TaskConfig();
        taskConfig.visibility ='Owner';
        filterResult = manualTaskFilter.filterTherapeutic();
        filteredCountryCodes = manualTaskFilter.getCountryCode();
        manualTaskFilter.isPlatformLevel = false;
        manualTaskFilter.getContactsWithWhatIds(taskConfig);
        manualTaskFilter.getContactsWithParticipantIds(taskConfig.visibility);
        Test.stopTest();

        System.assertEquals('US', testPEs[0].Participant__r.Mailing_Country_Code__c);
        System.assert(filterResult.contains('Participant__c'));
        System.assert(filteredCountryCodes.contains('US'));
    }
}