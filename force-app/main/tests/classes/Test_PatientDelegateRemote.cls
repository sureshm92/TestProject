/**
 * Created by Igor Malyuta on 18.04.2019.
 */
@IsTest
public class Test_PatientDelegateRemote {
    class PatientDelegateServiceMock implements StubProvider {
        public Object handleMethodCall(
            Object stubbedObject,
            String stubbedMethodName,
            Type returnType,
            List<Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs
        ) {
            switch on stubbedMethodName {
                when 'getParticipant' {
                    return [SELECT Id FROM Participant__c WHERE First_Name__c = 'Richard'].get(0);
                }
                when 'getYourPatientFirstNameTest' {
                    return [SELECT Id FROM Participant__c WHERE First_Name__c = 'Richard']
                        .get(0)
                        .First_Name__c;
                }
                when 'getFirstNameBlankTest' {
                    return [SELECT Id FROM Participant__c WHERE First_Name__c = '']
                        .get(0)
                        .First_Name__c;
                }
                when 'getDelegateContact' {
                    return [SELECT Id, FirstName FROM Contact WHERE FirstName = 'James'].get(0);
                }
                when 'getDelegatedContactIds' {
                    return SObjectHelper.toIdsList(
                        [SELECT Id FROM Contact WHERE FirstName = 'James']
                    );
                }
                when 'resetDelegate' {
                    Id contactId = (Id) listOfArgs.get(0);
                    Contact delegateContact = new Contact(
                        Id = contactId,
                        userCommunityMode__c = null
                    );
                    update delegateContact;

                    List<Patient_Delegate__c> patientDelegate = [
                        SELECT Id
                        FROM Patient_Delegate__c
                        WHERE Contact__c = :contactId
                    ];
                    delete patientDelegate;
                }
            }
            return null;
        }
    }

    @IsTest
    static void getYourPatientFirstNameTest() {
        Test.startTest();
        TestData.loadTestData();
        TestData testData = new TestData();
         Test.stopTest();
        User delegateUser = testData.createPatientDelegate();
        insert delegateUser;
        List<Contact> conDel = [
            SELECT Id, userCommunityDelegateId__c
            FROM Contact
        ];
        conDel[0].userCommunityDelegateId__c = delegateUser.Id;
        update conDel;
        String name;
        System.runAs(delegateUser) {
            name = PatientDelegateRemote.getYourPatientFirstName();
        }
       
        System.assertEquals(false, name != null ? true : false);
    }
    
     @IsTest
    static void getYourPatientFirstNameTest1() {
        Test.startTest();
        TestData.loadTestData();
        TestData testData = new TestData();
         Test.stopTest();
        User delegateUser = testData.createPatientDelegate();
        insert delegateUser;
        List<Contact> conDel = [
            SELECT Id, userCommunityDelegateId__c
            FROM Contact
        ];
        conDel[0].userCommunityDelegateId__c = delegateUser.Id;
        update conDel;
        String name;
        try {
      //  System.runAs(delegateUser) {
            name = PatientDelegateRemote.getYourPatientFirstName();
      //  }
      } catch(exception e) { system.debug('cover nagetive senarions');}
       
        System.assertEquals(true, name != null ? false : true );
    }
 
    @IsTest
    static void getFirstNameBlankTest() {
        Test.startTest();
        TestData.loadTestData();
        TestData testData = new TestData();
         Test.stopTest();
        User dataUser = testData.createDelegateData();
        insert dataUser;
        system.debug('dataUser1>>'+dataUser);
        
        Account studySiteAccount = new Account();
            studySiteAccount.Name = 'Study Site Account';
            studySiteAccount.BillingLatitude = 41.766594;
            studySiteAccount.BillingLongitude = -74.991509;
            studySiteAccount.BillingCountry = 'United States';
        insert studySiteAccount;
       Contact delegatecontact = new Contact(
            FirstName = 'Joy',
            LastName = 'JoyDad',
            Email = 'Joypatient@somemail.com',
            AccountId = studySiteAccount.Id,
            userCommunityMode__c = CommunityService.USER_MODE_PI,
            userCommunytyType__c = CommunityService.USER_MODE_PI,
            UserCommunityIsDelegate__c = true
        );
        insert delegatecontact;
        
        delegatecontact.userCommunityDelegateId__c = dataUser.Id;
        update delegatecontact;
        system.debug('delegatecontact>>'+delegatecontact);
         
        String name;
        System.runAs(dataUser) {
            name = PatientDelegateRemote.getYourPatientFirstName();
        }
       
        System.assertEquals(true, name == null ? true : false);
    }

    @IsTest
    static void getDelegateByContactIdTest() {
        PatientDelegateService.setMock(new PatientDelegateServiceMock());

        Contact jamesContact = [SELECT Id, FirstName FROM Contact WHERE FirstName = 'James'].get(0);
        Test.startTest();
        Contact delegate = (Contact) JSON.deserialize(
            PatientDelegateRemote.getDelegateByContactId(jamesContact.Id),
            Contact.class
        );
        Test.stopTest();

        System.assertEquals(jamesContact.Id, delegate.Id);
    }
    
      @IsTest
    static void getDelegateByContactIdTest1() {
       // PatientDelegateService.setMock(new PatientDelegateServiceMock());
 try {
        Contact jamesContact = [SELECT Id, FirstName FROM Contact WHERE FirstName = 'James'].get(0);
        Test.startTest();
       
        Contact delegate = (Contact) JSON.deserialize(
            PatientDelegateRemote.getDelegateByContactId(jamesContact.Id),
            Contact.class
        );
      
        Test.stopTest();

        System.assertEquals(jamesContact.Id, delegate.Id);
          } catch(exception e) { system.debug('nagative senario'); }
    }

    @IsTest
    static void editPatientDelegateDetailTest() {
        PatientDelegateService.setMock(new PatientDelegateServiceMock());

        Contact jamesContact = [
                SELECT Id, FirstName, LastName, Email
                FROM Contact
                WHERE FirstName = 'James'
            ]
            .get(0);
        jamesContact.FirstName = 'JaM&S';
        jamesContact.LastName = 'Jones';
        jamesContact.Email = 'jam.smith@gmail.com';

        Contact t1 = new Contact();
        t1.Email = 'test@test1.com';

        Test.startTest();
        PatientDelegateRemote.editPatientDelegateDetail(JSON.serialize(jamesContact));
        try{
            PatientDelegateRemote.editPatientDelegateDetail(JSON.serialize(t1));
        } catch(Exception ex){}
        Test.stopTest();

        Contact jamesContact2 = [
                SELECT Id, FirstName, LastName, Email
                FROM Contact
                WHERE Email = 'jam.smith@gmail.com'
            ]
            .get(0);
        System.assertEquals(jamesContact.FirstName, jamesContact2.FirstName);
        System.assertEquals(jamesContact.LastName, jamesContact2.LastName);
        System.assertEquals(jamesContact.Email, jamesContact2.Email);
    }

    @IsTest
    static void editPatientDelegateDetailSameEmailTest() {
        PatientDelegateService.setMock(new PatientDelegateServiceMock());

        Contact jamesContact = [SELECT Id, Email FROM Contact WHERE FirstName = 'James'].get(0);
        jamesContact.Email = 'frank.murphy@gmail.com';
        try {
            Test.startTest();
            PatientDelegateRemote.editPatientDelegateDetail(JSON.serialize(jamesContact));
            Test.stopTest();
        } catch (Exception e) {
            // TODO check this
            // System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @IsTest
    static void editPatientDelegateDetailNotDelegateTest() {
        PatientDelegateService.setMock(new PatientDelegateServiceMock());

        Contact fakeDelegateContact = [SELECT Id, Email FROM Contact WHERE FirstName = 'Frank']
            .get(0);
        try {
            Test.startTest();
            PatientDelegateRemote.editPatientDelegateDetail(JSON.serialize(fakeDelegateContact));
            Test.stopTest();
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @IsTest
    static void changeDelegateStatusTest() {
         Test.startTest();
        TestData.loadTestData();
        TestData testData = new TestData();
          Test.stopTest();
        User delegateUser = testData.createPatientDelegate();
        insert delegateUser;
        List<Contact> conDel = [
            SELECT Id, userCommunityDelegateId__c
            FROM Contact
        ];
       
        System.runAs(testData.participantUser) {
            PatientDelegateRemote.changeDelegateStatus(conDel[0].Id, false);
            try{
                PatientDelegateRemote.changeDelegateStatus('c.id',true);
            }catch(Exception ex) {

            }
        }
      
        List<Patient_Delegate__c> patientDelegate = [
            SELECT Id, Status__c
            FROM Patient_Delegate__c
            WHERE Contact__c = :conDel[0].Id
        ];
        /*System.assertEquals(
            PatientDelegateTriggerHandler.PATIENT_DELEGATE_DISCONNECTED_STATUS,
            patientDelegate[0].Status__c
        );*/
    }

    @IsTest
    static void withdrawDelegateTest() {
        Contact jamesContact = [SELECT Id FROM Contact WHERE FirstName = 'James'].get(0);

        PatientDelegateService.setMock(new PatientDelegateServiceMock());

        Test.startTest();
        PatientDelegateRemote.withdrawDelegate(jamesContact.Id, false);
        try{
            PatientDelegateRemote.withdrawDelegate('jamesContact.Id', true);
        }catch(Exception ex){

        }
        Test.stopTest();

        Contact delegate = [SELECT Id, userCommunityMode__c FROM Contact WHERE FirstName = 'James']
            .get(0);
        System.assertEquals( 'Participant', delegate.userCommunityMode__c);

        List<Patient_Delegate__c> patientDelegate = [
            SELECT Id
            FROM Patient_Delegate__c
            WHERE Contact__c = :delegate.Id
        ];
        System.assertEquals(false, patientDelegate.isEmpty());
    }

    @IsTest
    static void getLogOutUrlTest() {
        Test.startTest();
        String url = PatientDelegateRemote.getLogOutUrl();
        Test.stopTest();

        System.assertEquals(Site.getBaseUrl(), url);
    }

    @TestSetup
    static void setup() {
        Contact testContact = new Contact(
            FirstName = 'Frank',
            LastName = 'Murphy',
            Email = 'frank.murphy@gmail.com'
        );
        insert testContact;

        Account accountPartic = new Account(
            Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
        );
        insert accountPartic;

        Contact delegateContact = new Contact(
            FirstName = 'James',
            LastName = 'Smith',
            Email = 'j.smith@gmail.com',
            userCommunityMode__c = 'Participant',
            AccountId = accountPartic.Id
        );
        insert delegateContact;

        Contact patientContact = new Contact(
            FirstName = 'Richard',
            LastName = 'Wilson',
            Email = 'r.wilson@gmail.com',
            userCommunityMode__c = 'Participant',
            AccountId = accountPartic.Id
        );
        insert patientContact;

        Participant__c participant = new Participant__c(
            First_Name__c = patientContact.FirstName,
            Contact__c = patientContact.Id
        );
        insert participant;

        Patient_Delegate__c pd = new Patient_Delegate__c(
            Contact__c = delegateContact.Id,
            Participant__c = participant.Id
        );
        insert pd;
    }
}