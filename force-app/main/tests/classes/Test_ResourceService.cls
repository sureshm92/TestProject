@IsTest(IsParallel=false)
public class Test_ResourceService {
    @TestSetup
    public static void setup() {
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.CreateContactsForParticipantsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.UpdatePEAndContactLastNameHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.ChangeUserEmailOnParticipantEmailChangeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.PrepareCityStateFieldsHandler.class
        );
        
        Participant__c singleParticipant = (Participant__c) TestDataFactory.getSObject(
            Participant__c.getSObjectType()
        );
        Resource__c singleResource = (Resource__c) TestDataFactory.getSObject(
            Resource__c.getSObjectType()
        );
        insert new List<SObject>{ singleParticipant, singleResource };
            Resource_Action__c singleAction = new Resource_Action__c(
                Participant__c = singleParticipant.Id,
                Resource__c = singleResource.Id,
                IsVoted__c = true,
                IsFavorite__c = true
            );
        insert singleAction;
    }
    
    @IsTest
    public static void getParticipant_Test() {
        List<Participant__c> participants = [SELECT Id, First_Name__c FROM Participant__c];
        System.assertEquals(1, participants.size());
        ParticipantService.ParticipantState pState = new ParticipantService.ParticipantState();
        pState.participant = participants[0];
        
        ClassFactory.putStubTypeByClassName(
            ParticipantService.class,
            StubBuilder.newInstance(ParticipantService.class).when('getState').then(pState).build()
        );
        Test.startTest();
        Participant__c participant = new ResourceService().getParticipant('Video');
        System.assertEquals(participants[0].Id, participant.Id);
        ResourceService.getInstance();
        Test.stopTest();
    }
    
    @IsTest
    public static void getResourceWrappers_NoActions_Test() {
        delete [SELECT Id FROM Resource_Action__c];
        List<Resource__c> resources = [
            SELECT Id, (SELECT Id, IsVoted__c, IsFavorite__c FROM Resource_Actions__r)
            FROM Resource__c
        ];
        ClassFactory.putStubTypeByClassName(
            ParticipantService.class,
            StubBuilder.newInstance(ParticipantService.class)
            .when('getState')
            .then(new ParticipantService.ParticipantState())
            .build()
        );
        Test.startTest();
        List<ResourceService.ResourceWrapper> wrappers = new ResourceService()
            .getResourceWrappers(resources);
        ResourceService rs = new ResourceService();
        rs.getResourceWrapperContainer(resources);
        rs.init('ResourceService.RESOURCE_TYPE_ARTICLE');
        rs.getResourceWrapperContainer();
        rs.getParticipantLanguage();
        ResourceService.sortResourcesByCOI(wrappers);
        Test.stopTest();
        System.assertEquals(false, wrappers[0].isFavorite);
        System.assertEquals(false, wrappers[0].isVoted);
        System.assertEquals(resources[0].Id, wrappers[0].resource.Id);
    }
    
    @IsTest
    public static void getResourceWrappers_OneAction_Test() {
        List<Resource__c> resources = [
            SELECT Id, (SELECT Id, IsVoted__c, IsFavorite__c FROM Resource_Actions__r)
            FROM Resource__c
        ];
        ClassFactory.putStubTypeByClassName(
            ParticipantService.class,
            StubBuilder.newInstance(ParticipantService.class)
            .when('getState')
            .then(new ParticipantService.ParticipantState())
            .build()
        );
        Test.startTest();
        List<ResourceService.ResourceWrapper> wrappers = new ResourceService()
            .getResourceWrappers(resources);
        Test.stopTest();
        System.assertEquals(true, wrappers[0].isFavorite);
        System.assertEquals(true, wrappers[0].isVoted);
    }
    
    @IsTest
    public static void getExceptions_Test() {
        System.assertEquals(
            CommunityService.ERROR_MISSING_STUDY,
            ResourceService.getErrorMissingStudy().errorMessage
        );
        System.assertEquals(
            Label.Resources_No_Study_Documents,
            ResourceService.getErrorNoStudyDocuments().errorMessage
        );
        System.assertEquals(
            Label.Resources_No_Articles,
            ResourceService.getErrorNoArticles(false).errorMessage
        );
        System.assertEquals(
            Label.Resources_No_Favorite_Articles,
            ResourceService.getErrorNoArticles(true).errorMessage
        );
        System.assertEquals(
            Label.Resources_No_Videos,
            ResourceService.getErrorNoVideos(false).errorMessage
        );
        System.assertEquals(
            Label.Resources_No_Favorite_Videos,
            ResourceService.getErrorNoVideos(true).errorMessage
        );
        System.assertEquals('Unhandled Error.', ResourceService.getErrorUnhandled().errorMessage);
    }
    
    @IsTest
    public static void getSingleResource_Integration_Test() {
        initData();
        List<Participant__c> participants = [SELECT Id, Contact__c FROM Participant__c];
        System.assertEquals(1, participants.size());
        List<User> users = [SELECT Id FROM User WHERE ContactId = :participants[0].Contact__c];
        System.assertEquals(1, users.size());
        List<Resource__c> resources = [SELECT Id FROM Resource__c ORDER BY Title__c ASC];
        System.assertEquals(5, resources.size());
        
        ResourceService.ResourceWrapperContainer singleResourceArticleContainer;
        ResourceService.ResourceWrapperContainer singleResourceVideoContainer;
        ResourceService.ResourceWrapperContainer singleResourceStudyDocumentContainer;
        System.runAs(users[0]) {
            ResourceDelegate rDelegate = new ResourceDelegate();
            singleResourceArticleContainer = rDelegate.getResourcesById(
                resources[2].Id,
                ResourceService.RESOURCE_TYPE_ARTICLE
            );
            singleResourceVideoContainer = rDelegate.getResourcesById(
                resources[1].Id,
                ResourceService.RESOURCE_TYPE_VIDEO
            );
            singleResourceStudyDocumentContainer = rDelegate.getResourcesById(
                resources[4].Id,
                ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT
            );
        }
        
        System.assertEquals(
            'Resource 3',
            singleResourceArticleContainer.wrappers[0].resource.Title__c
        );
        System.assertEquals(
            'Resource 2',
            singleResourceVideoContainer.wrappers[0].resource.Title__c
        );
        System.assertEquals(
            'Resource 5',
            singleResourceStudyDocumentContainer.wrappers[0].resource.Title__c
        );
    }
    
    private static void initData() {
        delete [SELECT Id FROM Participant__c];
        delete [SELECT Id FROM Resource__c];
        delete [SELECT Id FROM Resource_Action__c];
        
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
        
        Contact piContact = (Contact) TestDataFactory.getSObject(
            Contact.getSObjectType(),
            new Map<String, Object>{
                'AccountId' => accountsByTypes.get('Common').Id,
                    'LastName' => 'portalTestUser1',
                    'Email' => 'some@email.com'
                    }
        );
        insert piContact;
        
        Participant__c singleParticipant = (Participant__c) TestDataFactory.getSObject(
            Participant__c.getSObjectType(),
            new Map<String, Object>{
                'Contact__c' => piContact.Id // TODO Contact__c mustn't be piContact
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
        Test.startTest();
        
        Study_Site__c studySite = (Study_Site__c) TestDataFactory.getSObject(
            Study_Site__c.getSObjectType(),
            new Map<String, Object>{
                'Clinical_Trial_Profile__c' => clinicalTrialProfile.Id,
                    'Site__c' => accountsByTypes.get('Common').Id,
                    'Principal_Investigator__c' => piContact.Id,
                    'Override_PI_Referral_Status__c' => 'Invitation Sent'
                    }
        );
        insert studySite;
        
        Participant_Enrollment__c enrollment = (Participant_Enrollment__c) TestDataFactory.getSObject(
            Participant_Enrollment__c.getSObjectType(),
            new Map<String, Object>{
                'Medical_Record_Review_Status__c' => 'Pass',
                    'Pre_screening_Status__c' => 'Pass',
                    'Participant_Name__c' => singleParticipant.First_Name__c,
                    'Participant_Surname__c' => singleParticipant.Last_Name__c,
                    'Patient_ID__c' => '12345678',
                    'Participant_Status__c' => 'Received',
                    'Referral_Source__c' => 'HCP',
                    'Study_Site__c' => studySite.Id,
                    'Participant__c' => singleParticipant.Id
                    }
        );
        insert enrollment;
        Test.stopTest();
        
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
    
    @IsTest
    public static void getResourceWrappers_sort_Test() {
        initData();
        delete [SELECT Id FROM Resource_Action__c];
        List<Resource__c> resources = [SELECT Id, Content_Type__c,CreatedDate, (SELECT Id, IsVoted__c, IsFavorite__c FROM Resource_Actions__r)
                                       FROM Resource__c ORDER BY CReatedDate ASC];
        ClassFactory.putStubTypeByClassName(
            ParticipantService.class,
            StubBuilder.newInstance(ParticipantService.class)
            .when('getState')
            .then(new ParticipantService.ParticipantState())
            .build()
        );
        List<ResourceService.ResourceWrapper> wrappers = new ResourceService().getResourceWrappers(resources);
        ResourceService rs = new ResourceService();
        rs.getResourceWrapperContainer(resources);
        rs.init('ResourceService.RESOURCE_TYPE_ARTICLE');
        rs.getResourceWrapperContainer();
        rs.getParticipantLanguage();
        ResourceService.sortResourcesByCreatedDate(wrappers);
        System.assertEquals(false, wrappers[0].isFavorite);
        System.assertEquals(resources[0].Id, wrappers[0].resource.Id);
        System.assertEquals(resources[0].Id, ResourceService.sortResourcesByCreatedDate(wrappers)[0].resource.Id);
    }
    
    @IsTest
    public static void getUpdatesCounter_Test() {
        TestData.loadTestData();
        delete [SELECT Id FROM Resource_Action__c];
        List<Resource__c> resources = [SELECT Id, CreatedDate, (SELECT Id, IsVoted__c, IsFavorite__c, CreatedDate 
                                                                FROM Resource_Actions__r) FROM Resource__c];
        ClassFactory.putStubTypeByClassName(
            ParticipantService.class,
            StubBuilder.newInstance(ParticipantService.class)
            .when('getState')
            .then(new ParticipantService.ParticipantState())
            .build()
        );
        List<ResourceService.ResourceWrapper> wrappers = new ResourceService().getResourceWrappers(resources);
        ResourceService rs = new ResourceService();
        rs.getResourceWrapperContainer(resources);
        rs.init('ResourceService.RESOURCE_TYPE_ARTICLE');
        rs.getResourceWrapperContainer();
        rs.getParticipantLanguage();
        Test.startTest();
        ResourceService.getUpdatesCounter(wrappers);
        Test.stopTest();
        System.assertEquals(1, ResourceService.getUpdatesCounter(wrappers));
    }
    
    @IsTest
    public static void sortUpdateResourcesByCOI_Test() {
        initData();
        
        Id cOIRecordTypeId = SchemaUtil.getRecordTypeIdByName(TherapeuticAreaService.COI_RT_NAME,Therapeutic_Area__c.getSObjectType());
        
        delete [SELECT Id FROM Resource_Action__c];
        List<Resource__c> resources = [SELECT Id, Content_Type__c, (SELECT Id, IsVoted__c, IsFavorite__c FROM Resource_Actions__r) FROM Resource__c ORDER BY CreatedDate ASC];
        
        Map<String, Therapeutic_Area__c> tAsByNames = new Map<String, Therapeutic_Area__c>();
        tAsByNames.put('COI 1', new Therapeutic_Area__c(RecordTypeId = cOIRecordTypeId, Name = 'COI 1'));
        tAsByNames.put('COI 2', new Therapeutic_Area__c(RecordTypeId = cOIRecordTypeId, Name = 'COI 2'));
        insert tAsByNames.values();
        
        List<Therapeutic_Area_Assignment__c> assignments = new List<Therapeutic_Area_Assignment__c>();
        assignments.add(
            new Therapeutic_Area_Assignment__c(
                Resource__c = resources[0].Id,
                Therapeutic_Area__c = tAsByNames.get('COI 1').Id
            )
        );
        assignments.add(
            new Therapeutic_Area_Assignment__c(
                Resource__c = resources[1].Id,
                Therapeutic_Area__c = tAsByNames.get('COI 2').Id
            )
        );
        insert assignments;
        
        List<Resource__c> res = [SELECT Id,Title__c,Type__c,URL__c,description__c,CreatedDate,Content_Type__c,
                                 (SELECT Id, Therapeutic_Area__c FROM Therapeutic_Area_Assignments__r ) 
                                 FROM Resource__c ORDER BY CreatedDate ASC];
        
        ClassFactory.putStubTypeByClassName(ParticipantService.class,StubBuilder.newInstance(ParticipantService.class)
            .when('getState')
            .then(new ParticipantService.ParticipantState())
            .build()
        );
        List<ResourceService.ResourceWrapper> wrappers = new ResourceService().getResourceWrappers(res);
        ResourceService rs = new ResourceService();
        rs.getResourceWrapperContainer(res);
        rs.init('ResourceService.RESOURCE_TYPE_ARTICLE');
        rs.getResourceWrapperContainer();
        rs.getParticipantLanguage();
        ResourceService.sortUpdateResourcesByCOI(wrappers);
        System.assertEquals(resources[0].Id, ResourceService.sortUpdateResourcesByCOI(wrappers)[0].resource.Id);
    }
    
    @IsTest
    public static void sortUpdateResources_Test() {
        initData();
        
        Id cOIRecordTypeId = SchemaUtil.getRecordTypeIdByName(TherapeuticAreaService.COI_RT_NAME,Therapeutic_Area__c.getSObjectType());
        
        delete [SELECT Id FROM Resource_Action__c];
        List<Resource__c> resources = [SELECT Id, Content_Type__c, (SELECT Id, IsVoted__c, IsFavorite__c FROM Resource_Actions__r) FROM Resource__c ORDER BY CreatedDate ASC];
        resources[0].Content_Type__c = ResourceService.RESOURCE_TYPE_RELEVANT_LINK;
        resources[1].Content_Type__c = ResourceService.RESOURCE_TYPE_RELEVANT_LINK;
        update resources;
        
        Map<String, Therapeutic_Area__c> tAsByNames = new Map<String, Therapeutic_Area__c>();
        tAsByNames.put('COI 1', new Therapeutic_Area__c(RecordTypeId = cOIRecordTypeId, Name = 'COI 1'));
        tAsByNames.put('COI 2', new Therapeutic_Area__c(RecordTypeId = cOIRecordTypeId, Name = 'COI 2'));
        insert tAsByNames.values();
        
        List<Therapeutic_Area_Assignment__c> assignments = new List<Therapeutic_Area_Assignment__c>();
        assignments.add(
            new Therapeutic_Area_Assignment__c(
                Resource__c = resources[0].Id,
                Therapeutic_Area__c = tAsByNames.get('COI 1').Id
            )
        );
        assignments.add(
            new Therapeutic_Area_Assignment__c(
                Resource__c = resources[1].Id,
                Therapeutic_Area__c = tAsByNames.get('COI 2').Id
            )
        );
        insert assignments;
        
        List<Resource__c> res = [SELECT Id,Title__c,Type__c,URL__c,description__c,CreatedDate,Content_Type__c,
                                 (SELECT Id, Therapeutic_Area__c FROM Therapeutic_Area_Assignments__r ) 
                                 FROM Resource__c ORDER BY CreatedDate ASC];
        
        ClassFactory.putStubTypeByClassName(ParticipantService.class,StubBuilder.newInstance(ParticipantService.class)
            .when('getState')
            .then(new ParticipantService.ParticipantState())
            .build()
        );
        List<ResourceService.ResourceWrapper> wrappers = new ResourceService().getResourceWrappers(res);
        ResourceService rs = new ResourceService();
        rs.getResourceWrapperContainer(res);
        rs.init('ResourceService.RESOURCE_TYPE_ARTICLE');
        rs.getResourceWrapperContainer();
        rs.getParticipantLanguage();
        ResourceService.sortUpdateResourcesByCOI(wrappers);
        System.assertEquals(resources[0].Id, ResourceService.sortUpdateResourcesByCOI(wrappers)[0].resource.Id);
    }
    
}