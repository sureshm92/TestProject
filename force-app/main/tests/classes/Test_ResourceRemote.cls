@IsTest(IsParallel=true)
public class Test_ResourceRemote {

    @TestSetup
    public static void setup() {

        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.CreateContactsForParticipantsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdatePEAndContactLastNameHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.ChangeUserEmailOnParticipantEmailChangeHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.PrepareCityStateFieldsHandler.class);

        Participant__c singleParticipant = (Participant__c) TestDataFactory.getSObject(Participant__c.getSObjectType());
        Resource__c singleResource = (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType());
        insert new List<SObject>{
                singleParticipant,
                singleResource
        };
        Resource_Action__c singleAction = new Resource_Action__c(Participant__c = singleParticipant.Id, Resource__c = singleResource.Id, IsVoted__c = false, IsFavorite__c = false);
        insert singleAction;
    }

    @IsTest
    public static void setResourceAction_ActionExist_Test() {

        List<Participant__c> participants = [SELECT Id FROM Participant__c];
        System.assertEquals(1, participants.size());
        List<Resource__c> resources = [SELECT Id FROM Resource__c];
        System.assertEquals(1, resources.size());
        ParticipantService.ParticipantState pState = new ParticipantService.ParticipantState();
        pState.participant = participants[0];

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(ParticipantService.class, StubFactory.newInstance(ParticipantService.class)
                .when('getState')
                .then(pState)
                .getInstance()
        );

        Test.startTest();
        ResourceRemote.setResourceAction(resources[0].Id, true, true);
        Test.stopTest();

        List<Resource_Action__c> actions = [SELECT Id, IsFavorite__c, IsVoted__c FROM Resource_Action__c LIMIT 1];
        System.assertEquals(true, actions[0].IsVoted__c);
        System.assertEquals(true, actions[0].IsFavorite__c);
    }

    @IsTest
    public static void setResourceAction_ActionDoesNotExist_Test() {

        List<Participant__c> participants = [SELECT Id FROM Participant__c];
        System.assertEquals(1, participants.size());
        List<Resource__c> resources = [SELECT Id FROM Resource__c];
        System.assertEquals(1, resources.size());
        delete [SELECT Id FROM Resource_Action__c];
        ParticipantService.ParticipantState pState = new ParticipantService.ParticipantState();
        pState.participant = participants[0];

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(ParticipantService.class, StubFactory.newInstance(ParticipantService.class)
                .when('getState')
                .then(pState)
                .getInstance()
        );

        Test.startTest();
        ResourceRemote.setResourceAction(resources[0].Id, true, true);
        Test.stopTest();

        List<Resource_Action__c> actions = [SELECT Id, IsFavorite__c, IsVoted__c FROM Resource_Action__c LIMIT 1];
        System.assertEquals(true, actions[0].IsVoted__c);
        System.assertEquals(true, actions[0].IsFavorite__c);
    }

    @IsTest
    public static void setResourceAction_Exception_Test() {

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(ResourceService.class, StubFactory.newInstance(ResourceService.class)
                .when('getParticipantId')
                .then(TestDataFactory.getFakeId(Participant__c.getSObjectType()))
                .getInstance()
        );
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            ResourceRemote.setResourceAction(TestDataFactory.getFakeId(Participant__c.getSObjectType()), false, true);
        } catch (Exception e) {
            isExceptionThrown = true;
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }

    @IsTest
    public static void getResources_FavoriteResources_Test() {

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(ResourceDelegate.class, StubFactory.newInstance(ResourceDelegate.class)
                .when('getFavoriteResources')
                .then(new ResourceService.ResourceWrapperContainer(Label.Resources_No_Favorite_Articles))
                .getInstance()
        );
        Test.startTest();
        ResourceService.ResourceWrapperContainer container = ResourceRemote.getResources('Article', 'Favorite');
        Test.stopTest();

        System.assert(container.errorMessage.equalsIgnoreCase(Label.Resources_No_Favorite_Articles));
        System.assert(container.wrappers == null);
    }

    @IsTest
    public static void getResources_DefaultResources_Test() {

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(ResourceDelegate.class, StubFactory.newInstance(ResourceDelegate.class)
                .when('getResources')
                .then(new ResourceService.ResourceWrapperContainer(new List<ResourceService.ResourceWrapper>()))
                .getInstance()
        );
        Test.startTest();
        ResourceService.ResourceWrapperContainer container = ResourceRemote.getResources('Article', 'Default');
        Test.stopTest();

        System.assert(String.isBlank(container.errorMessage));
        System.assert(container.wrappers.isEmpty());
    }

    @IsTest
    public static void getResources_DocumentsResources_Test() {

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(ResourceDelegate.class, StubFactory.newInstance(ResourceDelegate.class)
                .when('getStudyDocuments')
                .then(new ResourceService.ResourceWrapperContainer(new List<ResourceService.ResourceWrapper>()))
                .getInstance()
        );
        Test.startTest();
        ResourceService.ResourceWrapperContainer container = ResourceRemote.getStudyDocuments();
        Test.stopTest();

        System.assert(String.isBlank(container.errorMessage));
        System.assert(container.wrappers.isEmpty());
    }

    @IsTest
    public static void getResources_Exception_Test() {

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(ResourceService.class, StubFactory.newInstance(ResourceService.class)
                .when('getResources')
                .then(new AuraHandledException('Test Exception'))
                .getInstance()
        );
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            ResourceService.ResourceWrapperContainer container = ResourceRemote.getResources('Article', 'Default');
        } catch (Exception e) {
            isExceptionThrown = true;
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }

    @IsTest
    public static void getTrialId_Positive_Test() {

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(ResourceService.class, StubFactory.newInstance(ResourceService.class)
                .when('getParticipantState')
                .then(Test_ResourceRemote.getParticipantState())
                .getInstance()
        );
        Test.startTest();
        String trialId = ResourceRemote.getTrialId();
        Test.stopTest();
        System.assert(String.isNotBlank(trialId));
    }

    @IsTest
    public static void getTrialId_MissingStudyException_Test() {

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(ResourceService.class, StubFactory.newInstance(ResourceService.class)
                .when('getParticipantState')
                .then(Test_ResourceRemote.getAlumniState())
                .getInstance()
        );
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            String trialId = ResourceRemote.getTrialId();
        } catch (Exception e) {
            isExceptionThrown = true;
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }

    @IsTest
    public static void getNoTAMessage_Exception_Test() {

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(ResourceService.class, StubFactory.newInstance(ResourceService.class)
                .when('getParticipantState')
                .then(new AuraHandledException(('Test Exception')))
                .getInstance()
        );
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            String noTAMessage = ResourceRemote.getNoTAMessage();
        } catch (Exception e) {
            isExceptionThrown = true;
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }

    @IsTest
    public static void getNoTAMessage_AlumniPatient_Test() {

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(ResourceService.class, StubFactory.newInstance(ResourceService.class)
                .when('getParticipantState')
                .then(Test_ResourceRemote.getAlumniState())
                .getInstance()
        );
        Test.startTest();
        String noTAMessage = ResourceRemote.getNoTAMessage();
        Test.stopTest();
        System.assert(noTAMessage.containsIgnoreCase(Label.Resources_Go_To_Your_Profile));
    }

    @IsTest
    public static void getNoTAMessage_NotAlumniPatient_Test() {

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(ResourceService.class, StubFactory.newInstance(ResourceService.class)
                .when('getParticipantState')
                .then(Test_ResourceRemote.getParticipantState())
                .getInstance()
        );
        Test.startTest();
        String noTAMessage = ResourceRemote.getNoTAMessage();
        Test.stopTest();
        System.assert(noTAMessage == null);
    }

    private static ParticipantService.ParticipantState getAlumniState() {
        Account singleAccount = (Account) TestDataFactory.getSObject(Account.getSObjectType(), new Map<String, Object>{
                'Name' => CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
        });
        insert singleAccount;
        ParticipantService.ParticipantState state = new ParticipantService.ParticipantState();
        state.value = ParticipantService.ParticipantStates.ALUMNI;
        state.participant = [SELECT Id, Conditions__c FROM Participant__c LIMIT 1][0];
        return state;
    }

    private static ParticipantService.ParticipantState getParticipantState() {
        ParticipantService.ParticipantState participantState = new ParticipantService.ParticipantState();
        participantState.value = ParticipantService.ParticipantStates.PARTICIPANT;
        participantState.ctp = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType(), new Map<String, Object>{
                'Id' => TestDataFactory.getFakeId(Clinical_Trial_Profile__c.getSObjectType())
        });
        return participantState;
    }
}