/**
 * Created by user on 04-Feb-20.
 */

@IsTest(IsParallel=false)
private class Test_ReferHealthcareProviderRemote {
    /*
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }   
    */
	@IsTest 
    static void testgetDelegateParticipant() {
        Test.startTest();
		ReferHealthcareProviderRemote.getDelegateParticipant('<delegateContactId>');
        Test.stopTest();
    }	
    
    @IsTest 
    static void testcheckDelegateAge() {
        TestData.loadTestData();
        TestData testDataInstance = new TestData();
        Test.startTest();
        System.runAs(testDataInstance.hcpUser) {
            Participant__c participant = new Participant__c(
                First_Name__c = 'PTest',
                Last_Name__c = 'PTest',
                Phone__c = '13413223',
                Date_of_Birth__c = '1990-11-11',
                Email__c = 'partTest@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL'
            );
            Participant__c participantDelegate = new Participant__c(
                First_Name__c = 'PTestDelegate',
                Last_Name__c = 'PTestDelegate',
                Phone__c = '13413123',
                Email__c = 'PTestDelegate@email.com',
                Birth_Year__c = '1980',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL'
            );
         ReferHealthcareProviderRemote.checkDelegateAge(JSON.serialize(participant),JSON.serialize(participantDelegate));
       }
        Test.stopTest();
    }
  
    @IsTest 
    static void testStopSharing() {
		TestData.loadTestData();
        TestData testdata = new TestData();
        Healthcare_Provider__c hp = new Healthcare_Provider__c();
        hp.Status__c='HP_S_NOSHARING'; 
        hp.Participant_Enrollment__c = testdata.pe.Id;
        hp.Status__c = 'Invited';
        insert hp;
        Patient_Delegate__c pd = new Patient_Delegate__c(
            Participant__c = testData.participant.id,
            Status__c = 'Active',
            Contact__c = testData.piContact.id);
        insert pd;
        Patient_Delegate_Enrollment__c pder = new Patient_Delegate_Enrollment__c(
        Patient_Delegate__c = pd.id,
        Status__c = 'Active',
        Participant_Enrollment__c=testdata.pe.Id);
        insert pder;
        Test.startTest();
			ReferHealthcareProviderRemote.stopSharing(hp.Id,pder.Id);
        	ReferHealthcareProviderRemote.stopSharing(null,pder.Id);
		Test.stopTest();
    }
     
   	@IsTest
    static void testinvitePatientDelegate() {
        TestData.loadTestData();
        TestData testdata = new TestData();
        integer i=integer.valueOf(Math.random());
        Account a = new Account(name = 'Test');
        insert a;
        Contact cn = New Contact(
            LastName = 'testUser'+i,
            FirstName = 'testName'+i,
            Phone_Type__c = 'Home',
            email = 'testuser'+i+'@cc.vv',
            AccountId = a.id);
        insert cn;
      	Participant__c participantDel = new Participant__c();
        participantDel.Email__c = 'Test01@mail.ru';
        participantDel.First_Name__c = 'testName';
        participantDel.Last_Name__c = 'ParticipantTD';
        participantDel.Phone__c = '141241';
        participantDel.Phone_Type__c = 'Home';
        participantDel.Contact__c = cn.Id;
        participantDel.Delegate_Consent_SMS__c = false;
        insert participantDel;
        Patient_Delegate__c pd = new Patient_Delegate__c(
            Participant__c = testData.participant.id,
            Status__c = 'Active',
            Contact__c = testData.piContact.id);
        insert pd;
        Test.startTest();
        try{
            ReferHealthcareProviderRemote.invitePatientDelegate(json.serialize(participantDel),json.serialize(pd),pd.Id,json.serialize(participantDel),true,'1992',testdata.pe.id);
            ReferHealthcareProviderRemote.invitePatientDelegate(json.serialize(participantDel),json.serialize(pd),pd.Id,json.serialize(participantDel),false,'1992',testdata.pe.id);
        }
        catch(Exception ex){
        }
        Test.stopTest();
	}
 	
    @IsTest
    static void testinvitePatientDelegate1() {
        TestData.loadTestData();
        TestData testdata = new TestData();
        integer i=integer.valueOf(Math.random());
        Account a = new Account(name = 'Test');
        insert a;
        Contact cn = New Contact(
            LastName = 'testUser'+i,
            FirstName = 'testName'+i,
            Phone_Type__c = 'Home',
            email = 'testuser'+i+'@cc.vv',
            AccountId = a.id);
        insert cn;
      	Participant__c participantDel = new Participant__c();
        participantDel.Email__c = 'Test01@mail.ru';
        participantDel.First_Name__c = 'testName';
        participantDel.Last_Name__c = 'ParticipantTD';
        participantDel.Phone__c = '141241';
        participantDel.Phone_Type__c = 'Mobile';
        participantDel.Contact__c = cn.Id;
        participantDel.Delegate_Consent_SMS__c = false;
        participantDel.Status__c = 'Status';
        participantDel.Mailing_Country_Code__c = 'US';
        participantDel.Mailing_State_Code__c = 'TN';
        participantDel.Country_Code__c = participantDel.Mailing_Country_Code__c;
        insert participantDel;
        
        Patient_Delegate__c pd = new Patient_Delegate__c(
            Participant__c = testData.participant.id,
			Status__c = 'Active',
            Contact__c = testData.piContact.id);
        insert pd;
        ReferHealthcareProviderRemote.PDWrapper ddi = new  ReferHealthcareProviderRemote.PDWrapper();
        ddi.delegateId = participantDel.Id;
        ddi.firstName = participantDel.First_Name__c;
        ddi.lastName = participantDel.Last_Name__c;
        ddi.email = participantDel.Email__c;
        ddi.status = participantDel.Status__c;
        Test.startTest();
		ReferHealthcareProviderRemote.invitePatientDelegate(json.serialize(participantDel),json.serialize(ddi),null,json.serialize(participantDel),false,'1992',testdata.pe.id);
        ReferHealthcareProviderRemote.invitePatientDelegate(json.serialize(participantDel),json.serialize(ddi),null,json.serialize(participantDel),true,'1992',testdata.pe.id);
        Test.stopTest();
	}
    
    @IsTest
    static void testinviteHP() {
		TestData.loadTestData();
        TestData td = new TestData();
		integer i=integer.valueOf(Math.random());
        Account a = new Account(name = 'Test');
        insert a;
        Contact cn = New Contact(
            LastName = 'testUser'+i,
            FirstName = 'testName'+i,
            Phone_Type__c = 'Home',
            email = 'testuser'+i+'@cc.vv',
            AccountId = a.id);
        insert cn;
        Participant_Enrollment__c pe = new Participant_Enrollment__c(
                HCP__c = td.hcpEnrollment.Id,
                Study_Site__c = td.ss.Id,
                Patient_ID__c = 'SomePatientId1',
                Referral_Source__c = 'HCP',
                Screening_ID__c = 'TestScrId12345'
            );
        Healthcare_Provider__c hp = new Healthcare_Provider__c();
		hp.Participant_Enrollment__c = td.pe.Id;
        hp.Status__c = 'Invited';
       	hp.Email__c = cn.Email;
      //  insert hp;
        Participant_Enrollment__c partEnroll = [
            SELECT Id, Show_Referring_Provider__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ];
        Test.startTest();
        System.runAs(td.participantUser){ 
            List<Healthcare_Provider__c> hp1 = new List<Healthcare_Provider__c>(ReferHealthcareProviderRemote.inviteHP(td.pe.Id,JSON.serialize(hp)));
        }
		Test.stopTest();
    }
    
    @IsTest
    static void testinviteHP1() {
		TestData.loadTestData();
        TestData td = new TestData();
        List<Account> accounts = new List<Account>();
		integer i=integer.valueOf(Math.random());
        Account a = new Account(name = 'Test');
        Account hcpAccount = new Account(Name = 'HCP Account');
        accounts.add(hcpAccount);
        insert a;
        Contact cn = New Contact(
            LastName = 'testUser'+i,
            FirstName = 'testName'+i,
            Phone_Type__c = 'Home',
            email = 'testuser'+i+'@cc.vv',
            AccountId = a.id);
        insert cn;
        Participant_Enrollment__c pe = new Participant_Enrollment__c(
                HCP__c = td.hcpEnrollment.Id,
                Study_Site__c = td.ss.Id,
                Patient_ID__c = 'SomePatientId1',
                Referral_Source__c = 'HCP',
                Screening_ID__c = 'TestScrId12345'
            );
        List<Contact> contacts = new List<Contact>();
            Contact hcpContact = new Contact(
                FirstName = 'HCPTD',
                LastName = 'HCPTD',
                Email = 'hcp@emil.com',
                AccountId = hcpAccount.Id,
                MailingLatitude = 40.766594,
                MailingLongitude = -73.991509,
                userCommunytyType__c = CommunityService.USER_MODE_HCP,
                userCommunityMode__c = CommunityService.USER_MODE_HCP
            );
            contacts.add(hcpContact);
            insert contacts;
        Study_Site__c studySite = [
            SELECT Id
            FROM Study_Site__c
        ]; 
        Clinical_Trial_Profile__c  ctp = td.ctp;
        Study_Site__c st= new Study_Site__c(
            Name = 'Test Site',
            Site__c = a.id,
            Clinical_Trial_Profile__c = ctp.Id,
            Principal_Investigator__c = td.piContact.Id,
            Study_Site_Key__c = 'AEWR5436');
        insert st;
        HCP_Enrollment__c hcpEnrollment = new HCP_Enrollment__c();
        	hcpEnrollment.Study_Site__c = st.Id;
            hcpEnrollment.HCP_Contact__c = hcpContact.Id;
            hcpEnrollment.Status__c = HCPEnrollmentService.HCP_S_ACTIVATION_PENDING;
        insert hcpEnrollment;
        
        Healthcare_Provider__c hp = new Healthcare_Provider__c();
		hp.Participant_Enrollment__c = td.pe.Id;
        hp.Status__c = ReferHealthcareProviderRemote.HP_S_NOSHARING;
       	hp.Email__c = cn.Email;
		hp.HCP_Enrollment__c = hcpEnrollment.Id;
        insert hp; 
        
 		Healthcare_Provider__c hp3 = new Healthcare_Provider__c();
		hp3.Participant_Enrollment__c = td.pe.Id;
        hp3.Status__c = ReferHealthcareProviderRemote.HP_S_NOSHARING;
       	hp3.Email__c = cn.Email;
		//hp3.HCP_Enrollment__c = hcpEnrollment.Id;
        insert hp3; 
          
        Test.startTest();
        System.runAs(td.participantUser){
            List<Healthcare_Provider__c> hp1 = new List<Healthcare_Provider__c>(ReferHealthcareProviderRemote.inviteHP(td.pe.Id,JSON.serialize(hp)));
            try{
            List<Healthcare_Provider__c> hp2 = new List<Healthcare_Provider__c>(ReferHealthcareProviderRemote.inviteHP(td.pe.Id,JSON.serialize(hp3)));
            }
            catch(Exception ex){                
            }
            try{
                List<Healthcare_Provider__c> hp2 = new List<Healthcare_Provider__c>(ReferHealthcareProviderRemote.inviteHP(td.pe.Id,'testhp'));
                }
                catch(Exception ex){                
                }
        }
		Test.stopTest();
    }
    
    @IsTest
    static void testShowOrHideProvider() {
        TestData.loadTestData();
        Participant_Enrollment__c partEnroll = [
            SELECT Id, Show_Referring_Provider__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ];
        Test.startTest();
        ReferHealthcareProviderRemote.showOrHideProvider(partEnroll.Id);
		Test.stopTest();
        Participant_Enrollment__c partEnroll2 = [
            SELECT Id, Show_Referring_Provider__c
            FROM Participant_Enrollment__c
            WHERE Id = :partEnroll.Id
        ];  
        System.assert(
            partEnroll.Show_Referring_Provider__c != partEnroll2.Show_Referring_Provider__c
        );
    }
   
    @IsTest
    static void testGetContactsDelegates() {
        TestData.loadTestData();
        Participant_Enrollment__c partEnroll = [
            SELECT Id, Participant__c, Show_Referring_Provider__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ];
        ReferHealthcareProviderRemote.InitData result;
        Test.startTest();
        
        TestData testData = new TestData();
        System.runAs(testData.participantUser) {
        Contact parDelegateContact = new Contact(
            FirstName = 'PADelTD',
            LastName = 'PADelTD',
            Email = 'pa_delegate@emil.com'
        );
        insert parDelegateContact;
        Participant__c participantDelegate = new Participant__c( Adult__c = true,
                                                                Contact__c = parDelegateContact.Id,
                                                                First_Name__c = parDelegateContact.FirstName,
                                                                Last_Name__c = parDelegateContact.LastName,
                                                                Email__c = parDelegateContact.Email,
                                                                Phone__c = '98723333');
        insert participantDelegate;
        Patient_Delegate__c deleg = new Patient_Delegate__c();
        deleg.Participant__c = partEnroll.Participant__c;
        deleg.Contact__c = parDelegateContact.Id;
         deleg.Status__c = 'Disconnected';
        insert deleg;
        Patient_Delegate_Enrollment__c pder = new Patient_Delegate_Enrollment__c(
        Patient_Delegate__c = deleg.id,
        Status__c = 'Active',
        Participant_Enrollment__c=testdata.pe.Id);
        insert pder;
        result = ReferHealthcareProviderRemote.getInitData(
            partEnroll.Id,
            partEnroll.Participant__c
        );
        }
        Test.stopTest();
        System.assert(!result.listWrapp.isEmpty());
    }
	 
    @IsTest
    static void testCheckDuplicate() {
        TestData.loadTestData();
        TestData td = new TestData();
        Healthcare_Provider__c hp = new Healthcare_Provider__c();
        hp.Status__c='HP_S_NOSHARING'; 
        hp.Participant_Enrollment__c = td.pe.Id;
        hp.Status__c = 'Invited';
        insert hp;
        Participant_Enrollment__c partEnroll = [
            SELECT Id, Show_Referring_Provider__c
            FROM Participant_Enrollment__c
            LIMIT 1  
        ];
        Contact parDelegateContact = new Contact(
            FirstName = 'PADelTD',
            LastName = 'PADelTD',
            Email = 'pa_delegate@emil.com'
        ); 
        insert parDelegateContact;
        Participant__c participant = new Participant__c( Adult__c = true,
                                                                Contact__c = parDelegateContact.Id,
                                                                First_Name__c = parDelegateContact.FirstName,
                                                                Last_Name__c = parDelegateContact.LastName,
                                                                Email__c = parDelegateContact.Email,
                                                                Phone__c = '98723333');
        insert participant;
        Test.startTest();
        ReferHealthcareProviderRemote.checkDuplicate('peID',null,null,null,'<peID>');
        ReferHealthcareProviderRemote.checkDuplicate(partEnroll.Id,null,null,null,participant.Id);
        ReferHealthcareProviderRemote.checkDuplicate(partEnroll.Id,null,'<fname>',null,participant.Id);
		ReferHealthcareProviderRemote.checkDuplicate(partEnroll.Id,null,null,'<lname>',participant.Id);
        ReferHealthcareProviderRemote.checkDuplicate(partEnroll.Id,'<email>',null,null,participant.Id);
        ReferHealthcareProviderRemote.checkDuplicate(partEnroll.Id,'<email>',null,'<lname>',participant.Id);
        ReferHealthcareProviderRemote.checkDuplicate('peID','<email>','<fname>',null,participant.Id);
		ReferHealthcareProviderRemote.checkDuplicate('peID','<email>','<fname>','<lname>','<peID>');
        ReferHealthcareProviderRemote.checkDuplicate('peID','<email>','<fname>','<lname>','null');
        ReferHealthcareProviderRemote.checkDuplicate(partEnroll.Id,'<email>','<fname>','<lname>','null');
		ReferHealthcareProviderRemote.checkDuplicate('peID','<email>','<fname>','<lname>',hp.Id);

        ReferHealthcareProviderRemote.checkDuplicate(td.pe.Id,td.participant.Email__c,td.participant.First_Name__c,td.participant.Last_Name__c,hp.Id);
        Test.stopTest();
    }
     
    @IsTest
    static void testDuplicatePDelegatesQeryFormedCorrectly() {
        TestData.loadTestData();
        Participant_Enrollment__c partEnroll = [
            SELECT Id, Show_Referring_Provider__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ];
        Test.startTest();
		ReferHealthcareProviderRemote.checkDuplicatePDelegates('<participantId>',null,'<fname>','<lname>');
        ReferHealthcareProviderRemote.checkDuplicatePDelegates('<participantId>',null,null,null);
        ReferHealthcareProviderRemote.checkDuplicatePDelegates('<participantId>',null,'<fname>',null);
        ReferHealthcareProviderRemote.checkDuplicatePDelegates('<participantId>',null,null,'<lname>');
        ReferHealthcareProviderRemote.checkDuplicatePDelegates('<participantId>','<email>',null,null);
        ReferHealthcareProviderRemote.checkDuplicatePDelegates('<participantId>','<email>',null,'<lname>');
        ReferHealthcareProviderRemote.checkDuplicatePDelegates('<participantId>','<email>','<fname>',null);
        ReferHealthcareProviderRemote.checkDuplicatePDelegates('<participantId>','<email>','<fname>','<lname>');
		Test.stopTest();
    }
    
    @IsTest
    static void testcreateSurveyTaskforpatientDelegate() {
        TestData.loadTestData();
       
        Participant_Enrollment__c partEnroll = [
            SELECT Id, Show_Referring_Provider__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ];

        
     Test.startTest();
     ReferHealthcareProviderRemote.createSurveyTaskforpatientDelegate(partEnroll.Id);
     Test.stopTest();
    } 
    
 	@IsTest
    static void testcreateHCPinPlatform() {
		TestData.loadTestData();
        TestData td = new TestData();
        Participant__c participant = new Participant__c(
                First_Name__c = 'PTest',
                Last_Name__c = 'PTest',
                Phone__c = '13413223',
                Date_of_Birth__c = '1990-11-11',
                Email__c = 'partTest@email.com', 
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL'
            );
		Account a = new Account(name = 'Test');
        insert a;
        Clinical_Trial_Profile__c  ctp = td.ctp;
        Study_Site__c st= new Study_Site__c(
            Name = 'Test Site',
            Site__c = a.id,
            Clinical_Trial_Profile__c = ctp.Id,
            Principal_Investigator__c = td.piContact.Id,
            Study_Site_Key__c = 'AEWR5436');
        insert st;
        
        Account newAcc = new Account(
                Name = ' temporary account',
                OwnerId = UserInfo.getUserId()
            );
		insert newAcc; 
        Contact parDelegateContact = new Contact(
            FirstName = 'John',
            LastName = 'Smith',
            Email = 'pa_delegate@emil.com'
        );
        insert parDelegateContact; 
        Healthcare_Provider__c hp = new Healthcare_Provider__c();
        hp.Status__c='HP_S_NOSHARING'; 
        hp.Participant_Enrollment__c = td.pe.Id;
        hp.Status__c = 'Invited';
        insert hp;
        Patient_Delegate__c pd = new Patient_Delegate__c(
            Participant__c = td.participant.id,
            Status__c = 'Active',
            Contact__c = td.piContact.id);
        insert pd;
        
        List<Account> accounts = new List<Account>();
            Account participantsAccount = new Account(
                Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
            );
            accounts.add(participantsAccount);
            
            Account piAccount = new Account(Name = 'PI Account', BillingCountry = 'United States');
            accounts.add(piAccount);
            
            Account hcpAccount = new Account(Name = 'HCP Account');
            accounts.add(hcpAccount);
            
            Account delegateAccount = new Account(
                Name = CommunityService.COMMUNITY_DELEGATE_ACCOUNT_NAME
            );
            accounts.add(delegateAccount);
            
            Account studySiteAccount = new Account(
                Name = 'Study Site Account',
                BillingLatitude = 41.766594,
                BillingLongitude = -74.991509,
                BillingCountry = 'United States'
            );
            accounts.add(studySiteAccount);
            insert accounts;
            
            List<Contact> contacts = new List<Contact>();
            Contact piContact = new Contact(
                FirstName = 'PITD',
                LastName = 'PITD',
                Email = 'pi@emil.com',
                MailingCountry = 'United States',
                AccountId = piAccount.Id,
                userCommunytyType__c = 'PI'
            );
    	
        List<String> contactId = new List<String>();
        for(contact c : contacts){
            contactId.add(c.Id);
        }   
        Test.startTest();
        System.runAs (td.hcpUser){
            ClassFactory.clearStubTypesByClassNamesMap();
            ClassFactory.putStubTypeByClassName(CommunityService.class,StubBuilder.newInstance(CommunityService.class)
                                                .when('createPortalUsers')
                                                .then(null)
                                                .when('createParticipantUsers')
                                                .then(null)
                                                .build()
                                               );
         ReferHealthcareProviderRemote.createHCPinPlatform(st.Id,'<fname>','<lname>','<email@abc.com','34543675',parDelegateContact,hp,parDelegateContact.Id,contactId);
         ReferHealthcareProviderRemote.createHCPinPlatform(st.Id,'<fname>','<lname>','<email@abc.com','34543675',parDelegateContact,hp,parDelegateContact.Id,null);
         //ReferHealthcareProviderRemote.createHCPinPlatform('','<fname>','<lname>','<email@abc.com','34543675',parDelegateContact,hp,parDelegateContact.Id,null);
         try{
             ReferHealthcareProviderRemote.createHCPinPlatform(st.Id,'<fname>','<lname>','<email@abc.com','34543675',td.piContact);
         }catch(Exception ex){}
         try{
            ReferHealthcareProviderRemote.createHCPinPlatform(td.piContact.Id,parDelegateContact.Id, new List<Id>());
        }catch(Exception ex){}
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testcreateHCPinPlatform1() {
		TestData.loadTestData();
        TestData td = new TestData();
        Participant__c participant = new Participant__c(
                First_Name__c = 'PTest',
                Last_Name__c = 'PTest',
                Phone__c = '13413223',
                Date_of_Birth__c = '1990-11-11',
                Email__c = 'partTest@email.com', 
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL'
            );
		Account a = new Account(name = 'Test');
        insert a;
        Clinical_Trial_Profile__c  ctp = td.ctp;
        Study_Site__c st= new Study_Site__c(
            Name = 'Test Site',
            Site__c = a.id,
            Clinical_Trial_Profile__c = ctp.Id,
            Principal_Investigator__c = td.piContact.Id,
            Study_Site_Key__c = 'AEWR5436');
        insert st;
        
        Account newAcc = new Account(
                Name = ' temporary account',
                OwnerId = UserInfo.getUserId()
            );
		insert newAcc; 
        Contact parDelegateContact = new Contact(
            FirstName = 'John',
            LastName = 'Smith',
            Email = 'pa_delegate@emil.com'
        );
        insert parDelegateContact; 
        Healthcare_Provider__c hp = new Healthcare_Provider__c();
        hp.Status__c='HP_S_NOSHARING'; 
        hp.Participant_Enrollment__c = td.pe.Id;
        hp.Status__c = 'Invited';
        insert hp;
        Patient_Delegate__c pd = new Patient_Delegate__c(
            Participant__c = td.participant.id,
            Status__c = 'Active',
            Contact__c = td.piContact.id);
        insert pd;
        
        List<Account> accounts = new List<Account>();
            Account participantsAccount = new Account(
                Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
            );
            accounts.add(participantsAccount);
             
            Account piAccount = new Account(Name = 'PI Account', BillingCountry = 'United States');
            accounts.add(piAccount);
            
            Account hcpAccount = new Account(Name = 'HCP Account');
            accounts.add(hcpAccount);
            
            Account delegateAccount = new Account(
                Name = CommunityService.COMMUNITY_DELEGATE_ACCOUNT_NAME
            );
            accounts.add(delegateAccount);
            
            Account studySiteAccount = new Account(
                Name = 'Study Site Account',
                BillingLatitude = 41.766594,
                BillingLongitude = -74.991509,
                BillingCountry = 'United States'
            );
            accounts.add(studySiteAccount);
            insert accounts;
            
            List<Contact> contacts = new List<Contact>();
            Contact piContact = new Contact(
                FirstName = 'PITD',
                LastName = 'PITD',
                Email = 'pi@emil.com',
                MailingCountry = 'United States',
                AccountId = piAccount.Id,
                userCommunytyType__c = 'PI'
            );
     	Contact hcpContact = new Contact(
                FirstName = 'HCPTD',
                LastName = 'HCPTD',
                Email = 'hcp@emil.com',
                AccountId = hcpAccount.Id,
                MailingLatitude = 40.766594,
                MailingLongitude = -73.991509,
                userCommunytyType__c = CommunityService.USER_MODE_HCP,
                userCommunityMode__c = CommunityService.USER_MODE_HCP
            );
        insert hcpContact;
        List<String> contactId = new List<String>();
        for(contact c : contacts){
            contactId.add(c.Id);
        }  
        Test.startTest();
        System.runAs (td.hcpUser){
            ClassFactory.clearStubTypesByClassNamesMap();
            ClassFactory.putStubTypeByClassName(CommunityService.class,StubBuilder.newInstance(CommunityService.class)
                                                .when('createPortalUsers')
                                                .then(null)
                                                .when('createParticipantUsers')
                                                .then(null)
                                                .build()
                                               );
            ReferHealthcareProviderRemote.createHCPinPlatform(st.Id,'<fname>','<lname>','email@abc.com','34543675',parDelegateContact,contactId);
            try{
                ReferHealthcareProviderRemote.createHCPinPlatform('','<fname>','<lname>','<email@abc.com','34543675',parDelegateContact,hp,parDelegateContact.Id,null);
            }catch(Exception ex){} 
        }
        Test.stopTest();
    }   
    
    @IsTest
    static void testsendNotificationForRPInvite() {
        TestData.loadTestData();
        List<Account> accounts = new List<Account>();
            Account participantsAccount = new Account(
                Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
            );
            accounts.add(participantsAccount);
            
            Account piAccount = new Account(Name = 'PI Account', BillingCountry = 'United States');
            accounts.add(piAccount);
            
            Account hcpAccount = new Account(Name = 'HCP Account');
            accounts.add(hcpAccount);
            
            Account delegateAccount = new Account(
                Name = CommunityService.COMMUNITY_DELEGATE_ACCOUNT_NAME
            );
            accounts.add(delegateAccount);
            
            Account studySiteAccount = new Account(
                Name = 'Study Site Account',
                BillingLatitude = 41.766594,
                BillingLongitude = -74.991509,
                BillingCountry = 'United States'
            );
            accounts.add(studySiteAccount);
            insert accounts;
            
            List<Contact> contacts = new List<Contact>();
            Contact piContact = new Contact(
                FirstName = 'PITD',
                LastName = 'PITD',
                Email = 'pi@emil.com',
                MailingCountry = 'United States',
                AccountId = piAccount.Id,
                userCommunytyType__c = 'PI'
            );
            contacts.add(piContact);
            
            Contact piDelegateContact = new Contact(
                FirstName = 'PIDelTD',
                LastName = 'PIDelTD',
                Email = 'pi_delegate@emil.com',
                AccountId = piAccount.Id,
                userCommunityMode__c = 'PI'
            );
            contacts.add(piDelegateContact);
            
            Contact hcpContact = new Contact(
                FirstName = 'HCPTD',
                LastName = 'HCPTD',
                Email = 'hcp@emil.com',
                AccountId = hcpAccount.Id,
                MailingLatitude = 40.766594,
                MailingLongitude = -73.991509,
                userCommunytyType__c = CommunityService.USER_MODE_HCP,
                userCommunityMode__c = CommunityService.USER_MODE_HCP
            );
            contacts.add(hcpContact);
            
            Contact hcpDelegateContact = new Contact(
                FirstName = 'HCPDelTD',
                LastName = 'HCPDelTD',
                Email = 'hcp_delegate@emil.com',
                AccountId = hcpAccount.Id
            );
            contacts.add(hcpDelegateContact);
            
            Contact ccContact = new Contact(
                FirstName = 'CCTD',
                LastName = 'CCTD',
                Email = 'cc@emil.com',
                AccountId = hcpAccount.Id,
                userCommunytyType__c = CommunityService.USER_MODE_CC,
                userCommunityMode__c = CommunityService.USER_MODE_CC
            );
            
            contacts.add(ccContact);
            insert contacts;
        Study_Site__c studySite = [
            SELECT Id
            FROM Study_Site__c
        ]; 

        HCP_Enrollment__c hcpEnrollment = new HCP_Enrollment__c();
        	hcpEnrollment.Study_Site__c = studySite.Id;
            hcpEnrollment.HCP_Contact__c = hcpContact.Id;
            hcpEnrollment.Status__c = HCPEnrollmentService.HCP_S_ACTIVATION_PENDING;
        insert hcpEnrollment;
        
		List<String> contactId = new List<String>();
        for(contact c : contacts){
            contactId.add(c.Id);
        }
        Test.startTest();
        ReferHealthcareProviderRemote.sendNotificationForRPInvite(hcpEnrollment.Id,hcpContact.Id,contactId);
        Test.stopTest();
    }
}