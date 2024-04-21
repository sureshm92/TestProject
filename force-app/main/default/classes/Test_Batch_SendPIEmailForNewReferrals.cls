@isTest
public class Test_Batch_SendPIEmailForNewReferrals {
    @isTest
    private static void ReceivedPIsCreated_NoBatchNotificationsCreated() {
        Test.startTest();
        DataBase.executeBatch(new Batch_SendPIEmailForNewReferrals());
        Test.stopTest();
    }
    @TestSetup
    private static void initData() {
        ClassFactory.clearStubTypesByClassNamesMap();
        Id cOIRecordTypeId = SchemaUtil.getRecordTypeIdByName(
            TherapeuticAreaService.COI_RT_NAME,
            Therapeutic_Area__c.getSObjectType()
        );
        Id tARecordTypeId = SchemaUtil.getRecordTypeIdByName(
            TherapeuticAreaService.TA_RT_NAME,
            Therapeutic_Area__c.getSObjectType()
        );

        Id articleRecordType = SchemaUtil.getRecordTypeIdByName(
            ResourceService.RESOURCE_TYPE_ARTICLE,
            Resource__c.getSObjectType()
        );
        Id videoRecordType = SchemaUtil.getRecordTypeIdByName(
            ResourceService.RESOURCE_TYPE_VIDEO,
            Resource__c.getSObjectType()
        );
        Id studyDocumentRecordType = SchemaUtil.getRecordTypeIdByName(
            ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT,
            Resource__c.getSObjectType()
        );

        Map<String, Account> accountsByTypes = new Map<String, Account>();
        List<Participant__c> participantLst = new List<Participant__c>();
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
        Contact piContact;
        System.runAs(admin) {
            accountsByTypes.put(
                'Common',
                (Account) TestDataFactory.getSObject(Account.getSObjectType())
            );
            accountsByTypes.put(
                'Participant',
                (Account) TestDataFactory.getSObject(
                    Account.getSObjectType(),
                    new Map<String, Object>{ 'Name' => 'Participant' }
                )
            );
            insert accountsByTypes.values();
            piContact = new Contact(
                AccountId = accountsByTypes.get('Common').Id,
                LastName = 'ParticipantTD12',
                FirstName = 'ParticipantTD11',
                Email = 'someexample@gmail.com'
            );
            insert piContact;
            user_1 = new User(
                Email = 'someexample@gmail.com',
                ProfileId = profile_1.Id,
                UserName = 'yourusername@gmail.com',
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ContactId = piContact.Id,
                PortalRole = 'Manager',
                FirstName = 'ParticipantTD11',
                LastName = 'ParticipantTD12'
            );
            insert user_1;
        }
        Participant__c singleParticipant = (Participant__c) TestDataFactory.getSObject(
            Participant__c.getSObjectType(),
            new Map<String, Object>{
                'Contact__c' => piContact.Id, // TODO Contact__c mustn't be piContact
                'First_Name__c' => 'ParticipantTD11',
                'Last_Name__c' => 'ParticipantTD12',
                'Phone__c' => '55313535',
                'Email__c' => 'someexample@gmail.com',
                'Mailing_Country_Code__c' => 'US',
                'Mailing_State_Code__c' => 'AL',
                'age__c' => 23,
                'site__c' => accountsByTypes.get('Common').Id
            }
        );
        insert singleParticipant;

        Map<String, Therapeutic_Area__c> tAsByNames = new Map<String, Therapeutic_Area__c>();
        tAsByNames.put(
            'TA 1',
            new Therapeutic_Area__c(RecordTypeId = tARecordTypeId, Name = 'TA 1')
        );
        insert tAsByNames.values();

        Clinical_Trial_Profile__c clinicalTrialProfile = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(
            Clinical_Trial_Profile__c.getSObjectType(),
            new Map<String, Object>{ 'Therapeutic_Area__c' => tAsByNames.get('TA 1').Id }
        );
        insert clinicalTrialProfile;

        Study_Site__c studySite = (Study_Site__c) TestDataFactory.getSObject(
            Study_Site__c.getSObjectType(),
            new Map<String, Object>{
                'Clinical_Trial_Profile__c' => clinicalTrialProfile.Id,
                'Site__c' => accountsByTypes.get('Common').Id,
                'Principal_Investigator__c' => piContact.Id,
                'Override_PI_Referral_Status__c' => 'Accepted',
                'Suppress_Study_Site_PI_Emails__c' => false
            }
        );
        insert studySite;
        List<Participant_Enrollment__c> enrollemntLST = new List<Participant_Enrollment__c>();
        Participant_Enrollment__c receiveenrollment = (Participant_Enrollment__c) TestDataFactory.getSObject(
            Participant_Enrollment__c.getSObjectType(),
            new Map<String, Object>{
                'Medical_Record_Review_Status__c' => 'Pass',
                'Pre_screening_Status__c' => 'Pass',
                'Participant_Name__c' => singleParticipant.First_Name__c,
                'Participant_Surname__c' => singleParticipant.Last_Name__c,
                'Patient_ID__c' => '12345678',
                'Participant_Status__c' => 'Received',
                'Referral_Source__c' => 'Participant',
                'Study_Site__c' => studySite.Id,
                'Participant__c' => singleParticipant.Id
            }
        );
        insert receiveenrollment;

        //Test.startTest();
        List<Participant__c> participants = [
            SELECT Id, Contact__c
            FROM Participant__c
            WHERE Id = :singleParticipant.Id
        ];
        System.assertEquals(1, participants.size());

        List<User> users = [SELECT Id FROM User WHERE ContactId = :participants[0].Contact__c];
        System.assertEquals(1, users.size());
    }
}
