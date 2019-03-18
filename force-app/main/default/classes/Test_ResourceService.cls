@IsTest
public class Test_ResourceService {

    @TestSetup
    public static void setup() {

    }

    @IsTest
    public static void getParticipantLanguage_Test() {
        Participant__c participantWithLanguageDefined = TestDataFactory.getParticipant(
                new Map<String, Object>{
                        'Contact__r' => TestDataFactory.getContact(new Map<String, Object>{
                                'Language__c' => 'ru'
                        })
                }
        );
        Participant__c participantWithoutLanguageDefined = TestDataFactory.getParticipant(new Map<String, Object>{
                'Contact__r' => new Contact()
        });
        Test.startTest();
        String languageRU = new ResourceService().getParticipantLanguage(participantWithLanguageDefined);
        String languageEN = new ResourceService().getParticipantLanguage(participantWithoutLanguageDefined);
        Test.stopTest();
        System.assertEquals('ru', languageRU);
        System.assertEquals(ResourceService.DEFAULT_LANGUAGE, languageEN);
    }

    @IsTest
    public static void getParticipant_Test() {
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(
                'DatabaseProxy',
                (DatabaseProxy) Test.createStub(
                        DatabaseProxy.class,
                        new Test_ResourceService.DatabaseProxyStub('getParticipant_Test')
                )
        );
        Test.startTest();
        Participant__c participant = new ResourceService().getParticipant();
        Test.stopTest();
        System.assertEquals('Test Participant', participant.First_Name__c);
    }

    @IsTest
    public static void getResourceWrappers_NoActions_Test() {
        List<Resource__c> resources = new List<Resource__c>{
                TestDataFactory.getResource(new Map<String, Object>{
                        'Id' => TestDataFactory.getFakeId(Resource__c.SObjectType)
                })
        };
        Test.startTest();
        List<ResourceService.ResourceWrapper> wrappers = new ResourceService().getResourceWrappers(resources);
        Test.stopTest();
        System.assertEquals(false, wrappers[0].isFavorite);
        System.assertEquals(false, wrappers[0].isVoted);
        System.assertEquals(resources[0].Id, wrappers[0].resourceId);
    }

    @IsTest
    public static void getResourceWrappers_OneAction_Test() {
        List<Resource__c> resources = new List<Resource__c>{
                TestDataFactory.getResource(new Map<String, Object>{
                        'Id' => TestDataFactory.getFakeId(Resource__c.SObjectType)
                })
        };
        ResourceDecoupler.resourceActionsByIds.put(resources[0].Id, new List<Resource_Action__c>{
                TestDataFactory.getResourceAction()
        });
        Test.startTest();
        List<ResourceService.ResourceWrapper> wrappers = new ResourceService().getResourceWrappers(resources);
        Test.stopTest();
        System.assertEquals(true, wrappers[0].isFavorite);
        System.assertEquals(true, wrappers[0].isVoted);
    }

    @IsTest
    public static void getResources_WithResourceType_NoTherapeuticAreas_Test() {
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(
                'DatabaseProxy',
                (DatabaseProxy) Test.createStub(
                        DatabaseProxy.class,
                        new Test_ResourceService.DatabaseProxyStub('getParticipant_Test')
                )
        );
        ResourceService service = (ResourceService) ClassFactory.newInstance(ResourceService.class);
        Test.startTest();
        ResourceService.ResourceWrapperContainer container = service.getResources(ResourceService.RESOURCE_TYPE_ARTICLE);
        Test.stopTest();
        System.assertEquals(Label.Resources_No_Therapeutic_Area, container.errorMessage);
    }

    public class DatabaseProxyStub implements System.StubProvider {

        String testMethodName;

        public DatabaseProxyStub(String testMethodName) {
            this.testMethodName = testMethodName;
        }

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName,
                Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames,
                List<Object> listOfArgs) {

            if (stubbedMethodName == 'query') {
                if (testMethodName.contains('getParticipant_Test')) {
                    return new List<Participant__c>{
                            new Participant__c(First_Name__c = 'Test Participant')
                    };
                }
            }

            return null;
        }
    }

    public class ResourceServiceStub implements System.StubProvider {

        String testMethodName;

        public ResourceServiceStub(String testMethodName) {
            this.testMethodName = testMethodName;
        }

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName,
                Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames,
                List<Object> listOfArgs) {

            if (stubbedMethodName == 'getResources_WithResourceType_NoTherapeuticAreas_Test') {
                if (testMethodName.contains('getParticipant_Test')) {
                    return TestDataFactory.getParticipant();
                }
            }
            if (stubbedMethodName == 'getResourceWrappers') {
                if (testMethodName.contains('getParticipant_Test')) {
                    return new List<Participant__c>{
                            new Participant__c(First_Name__c = 'Test Participant')
                    };
                }
            }
            if (stubbedMethodName == 'getSortedResources') {
                if (testMethodName.contains('getParticipant_Test')) {
                    return new List<Participant__c>{
                            new Participant__c(First_Name__c = 'Test Participant')
                    };
                }
            }

            return null;
        }
    }
}