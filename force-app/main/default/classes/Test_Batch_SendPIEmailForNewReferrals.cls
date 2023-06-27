@isTest
public class Test_Batch_SendPIEmailForNewReferrals {
    @isTest
    private static void ReceivedPIsCreated_NoBatchNotificationsCreated() {
        initData();

        DataBase.executeBatch(new Batch_SendPIEmailForNewReferrals());
        Test.stopTest();
    }

    private static void initData() {
       // delete [SELECT Id FROM Participant__c];
     //   delete [SELECT Id FROM Resource__c];
      //  delete [SELECT Id FROM Resource_Action__c];

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
       List<Participant__c>participantLst = new List<Participant__c>();
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
            piContact = new Contact(AccountId = accountsByTypes.get('Common').Id, LastName = 'ParticipantTD12', FirstName = 'ParticipantTD11', Email = 'someexample@gmail.com');
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
            'Contact__c' => piContact.Id,  // TODO Contact__c mustn't be piContact
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
      Map<String, Resource__c> resourcesByTypes = new Map<String, Resource__c>();
        resourcesByTypes.put(
            'Article_Platform',
            (Resource__c) TestDataFactory.getSObject(
                Resource__c.getSObjectType(),
                new Map<String, Object>{
                    'Content_Class__c' => ResourceService.RESOURCE_SOURCE_PLATFORM,
                    'Title__c' => 'Resource 1',
                    'RecordTypeId' => articleRecordType
                }
            )
        );
        resourcesByTypes.put(
            'Video_Platform',
            (Resource__c) TestDataFactory.getSObject(
                Resource__c.getSObjectType(),
                new Map<String, Object>{
                    'Content_Class__c' => ResourceService.RESOURCE_SOURCE_PLATFORM,
                    'Title__c' => 'Resource 2',
                    'RecordTypeId' => videoRecordType
                }
            )
        );
        resourcesByTypes.put(
            'Article_Study',
            (Resource__c) TestDataFactory.getSObject(
                Resource__c.getSObjectType(),
                new Map<String, Object>{
                    'Content_Class__c' => ResourceService.RESOURCE_SOURCE_STUDY,
                    'Title__c' => 'Resource 3',
                    'RecordTypeId' => articleRecordType
                }
            )
        );
        resourcesByTypes.put(
            'Article_Third_Party',
            (Resource__c) TestDataFactory.getSObject(
                Resource__c.getSObjectType(),
                new Map<String, Object>{
                    'Content_Class__c' => ResourceService.RESOURCE_SOURCE_THIRD_PARTY,
                    'Title__c' => 'Resource 4',
                    'RecordTypeId' => articleRecordType
                }
            )
        );
        resourcesByTypes.put(
            'Study_Document',
            (Resource__c) TestDataFactory.getSObject(
                Resource__c.getSObjectType(),
                new Map<String, Object>{
                    'document_type__c' => ResourceService.RESOURCE_TYPE_DOCUMENT,
                    'Title__c' => 'Resource 5',
                    'RecordTypeId' => studyDocumentRecordType
                }
            )
        );
        insert resourcesByTypes.values();

        Map<String, Therapeutic_Area__c> tAsByNames = new Map<String, Therapeutic_Area__c>();
        tAsByNames.put(
            'COI 1',
            new Therapeutic_Area__c(RecordTypeId = cOIRecordTypeId, Name = 'COI 1')
        );
        tAsByNames.put(
            'COI 2',
            new Therapeutic_Area__c(RecordTypeId = cOIRecordTypeId, Name = 'COI 2')
        );
        tAsByNames.put(
            'TA 1',
            new Therapeutic_Area__c(RecordTypeId = tARecordTypeId, Name = 'TA 1')
        );
        insert tAsByNames.values();

        List<Therapeutic_Area_Patient__c> tAPs = new List<Therapeutic_Area_Patient__c>();
        tAPs.add(
            new Therapeutic_Area_Patient__c(
                Participant__c = singleParticipant.Id,
                Therapeutic_Area__c = tAsByNames.get('COI 1').Id,
                Condition_Of_Interest_Order__c = 1
            )
        );
        tAPs.add(
            new Therapeutic_Area_Patient__c(
                Participant__c = singleParticipant.Id,
                Therapeutic_Area__c = tAsByNames.get('COI 2').Id,
                Condition_Of_Interest_Order__c = 2
            )
        );
        insert tAPs;

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
                 'Suppress_Study_Site_PI_Emails__c' => FALSE
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
        List<Therapeutic_Area_Assignment__c> assignments = new List<Therapeutic_Area_Assignment__c>();
        assignments.add(
            new Therapeutic_Area_Assignment__c(
                Resource__c = resourcesByTypes.get('Article_Platform').Id,
                Therapeutic_Area__c = tAsByNames.get('COI 1').Id
            )
        );
        assignments.add(
            new Therapeutic_Area_Assignment__c(
                Resource__c = resourcesByTypes.get('Video_Platform').Id,
                Therapeutic_Area__c = tAsByNames.get('COI 2').Id
            )
        );
        assignments.add(
            new Therapeutic_Area_Assignment__c(
                Resource__c = resourcesByTypes.get('Article_Third_Party').Id,
                Therapeutic_Area__c = tAsByNames.get('COI 2').Id
            )
        );
        insert assignments;

        List<Res_study__c> resStudies = new List<Res_study__c>();
        resStudies.add(
            new Res_study__c(
                Clinical_Trial_Profile__c = clinicalTrialProfile.Id,
                Resource__c = resourcesByTypes.get('Article_Study').Id
            )
        );
        resStudies.add(
            new Res_study__c(
                Clinical_Trial_Profile__c = clinicalTrialProfile.Id,
                Resource__c = resourcesByTypes.get('Study_Document').Id
            )
        );
        insert resStudies;
		Test.startTest();
        List<Participant__c> participants = [
            SELECT Id, Contact__c
            FROM Participant__c
            WHERE Id = :singleParticipant.Id
        ];
        System.assertEquals(1, participants.size());

        List<User> users = [SELECT Id FROM User WHERE ContactId = :participants[0].Contact__c];
        System.assertEquals(1, users.size());

        List<Resource__Share> shares = new List<Resource__Share>();
        for (Resource__c singleResource : resourcesByTypes.values()) {
            shares.add(
                new Resource__Share(
                    ParentId = singleResource.Id,
                    UserOrGroupId = users[0].Id,
                    AccessLevel = 'Edit'
                )
            );
        }
        //inse resource shares
        insert shares;

        List<Resource_Action__c> resourceActions = new List<Resource_Action__c>();
        resourceActions.add(
            new Resource_Action__c(
                Resource__c = resourcesByTypes.get('Article_Platform').Id,
                IsFavorite__c = true,
                Participant__c = singleParticipant.Id
            )
        );
        resourceActions.add(
            new Resource_Action__c(
                Resource__c = resourcesByTypes.get('Video_Platform').Id,
                IsFavorite__c = true,
                Participant__c = singleParticipant.Id
            )
        );
        insert resourceActions;
    }
}