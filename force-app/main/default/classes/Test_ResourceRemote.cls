@IsTest(IsParallel=true)
public class Test_ResourceRemote {

    @TestSetup
    public static void setup() {

    }

    @IsTest
    public static void setResourceAction_ActionExist_Test() {

        DatabaseProxyCodeExecutor executor = new DatabaseProxyCodeExecutor();
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(CommunityService.class, StubFactory.newInstance(CommunityService.class)
                .when('getParticipantId')
                .then(TestDataFactory.getFakeId(Participant__c.getSObjectType()))
                .getInstance()
        );
        ClassFactory.putStubTypeByClassName(DatabaseProxy.class, StubFactory.newInstance(DatabaseProxy.class)
                .when('query')
                .then(new List<Resource_Action__c>{
                        new Resource_Action__c(IsFavorite__c = true, IsVoted__c = false)
                })
                .when('upsertRecord')
                .then(executor)
                .getInstance()
        );
        Test.startTest();
        ResourceRemote.setResourceAction(TestDataFactory.getFakeId(Participant__c.getSObjectType()), true, true);
        Test.stopTest();

        System.assertEquals(true, Boolean.valueOf(((SObject) executor.result[0]).get('IsVoted__c')));
        System.assertEquals(true, Boolean.valueOf(((SObject) executor.result[0]).get('IsFavorite__c')));
        System.assert(String.isBlank(String.valueOf(((SObject) executor.result[0]).get('Resource__c'))));
    }

    @IsTest
    public static void setResourceAction_ActionDoesNotExist_Test() {

        DatabaseProxyCodeExecutor executor = new DatabaseProxyCodeExecutor();
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(CommunityService.class, StubFactory.newInstance(CommunityService.class)
                .when('getParticipantId')
                .then(TestDataFactory.getFakeId(Participant__c.getSObjectType()))
                .getInstance()
        );
        ClassFactory.putStubTypeByClassName(DatabaseProxy.class, StubFactory.newInstance(DatabaseProxy.class)
                .when('query')
                .then(new List<Resource_Action__c>())
                .when('upsertRecord')
                .then(executor)
                .getInstance()
        );
        Test.startTest();
        ResourceRemote.setResourceAction(TestDataFactory.getFakeId(Participant__c.getSObjectType()), false, true);
        Test.stopTest();

        System.assertEquals(true, Boolean.valueOf(((SObject) executor.result[0]).get('IsVoted__c')));
        System.assertEquals(false, Boolean.valueOf(((SObject) executor.result[0]).get('IsFavorite__c')));
    }

    @IsTest
    public static void setResourceAction_Exception_Test() {

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(ResourceService.class, StubFactory.newInstance(ResourceService.class)
                .when('getParticipantId')
                .then(new AuraHandledException('Test Exception'))
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
        ClassFactory.putStubTypeByClassName(ResourceService.class, StubFactory.newInstance(ResourceService.class)
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
        ClassFactory.putStubTypeByClassName(ResourceService.class, StubFactory.newInstance(ResourceService.class)
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
        ClassFactory.putStubTypeByClassName(ResourceService.class, StubFactory.newInstance(ResourceService.class)
                .when('getStudyDocuments')
                .then(new ResourceService.ResourceWrapperContainer(new List<ResourceService.ResourceWrapper>()))
                .getInstance()
        );
        Test.startTest();
        ResourceService.ResourceWrapperContainer container = ResourceRemote.getResources(null, 'Documents');
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

    public class DatabaseProxyCodeExecutor extends CodeExecutor {

        public override List<Object> getResult(List<Object> arguments) {
            return arguments;
        }
    }

    private static ParticipantService.ParticipantState getAlumniState() {
        Account singleAccount = (Account) TestDataFactory.getSObject(Account.getSObjectType(), new Map<String, Object>{
                'Name' => CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
        });
        insert singleAccount;
        Participant__c participant = (Participant__c) TestDataFactory.getSObject(Participant__c.getSObjectType());
        insert participant;
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