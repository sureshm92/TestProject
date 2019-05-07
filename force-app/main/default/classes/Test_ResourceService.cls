@IsTest
public class Test_ResourceService {

    @TestSetup
    public static void setup() {

    }

    @IsTest
    public static void getParticipantLanguage_Test() {
        Participant__c participantWithLanguageDefined = (Participant__c) TestDataFactory.getSObject(Participant__c.getSObjectType(),
                new Map<String, Object>{
                        'Contact__r' => (Contact) TestDataFactory.getSObject(Contact.getSObjectType(), new Map<String, Object>{
                                'Language__c' => 'ru'
                        })
                }
        );
        Participant__c participantWithoutLanguageDefined = (Participant__c) TestDataFactory.getSObject(Participant__c.getSObjectType(), new Map<String, Object>{
                'Contact__r' => (Contact) TestDataFactory.getSObject(Contact.getSObjectType())
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
        ClassFactory.putStubTypeByClassName(
                'CommunityService',
                (CommunityService) Test.createStub(
                        CommunityService.class,
                        new Test_ResourceService.CommunityServiceStub('getParticipant_Test')
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
                (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object>{
                        'Id' => TestDataFactory.getFakeId(Resource__c.getSObjectType())
                })
        };
        Test.startTest();
        List<ResourceService.ResourceWrapper> wrappers = new ResourceService().getResourceWrappers(resources);
        Test.stopTest();
        System.assertEquals(false, wrappers[0].isFavorite);
        System.assertEquals(false, wrappers[0].isVoted);
        System.assertEquals(resources[0].Id, wrappers[0].resource.Id);
    }

    @IsTest
    public static void getResourceWrappers_OneAction_Test() {
        List<Resource__c> resources = new List<Resource__c>{
                (Resource__c) TestDataFactory.getSObject(Resource__c.getSObjectType(), new Map<String, Object>{
                        'Id' => TestDataFactory.getFakeId(Resource__c.getSObjectType())
                })
        };
        ResourceDecoupler.resourceActionsByResourceIds.put(resources[0].Id, new List<Resource_Action__c>{
                (Resource_Action__c) TestDataFactory.getSObject(Resource_Action__c.getSObjectType())
        });
        Test.startTest();
        List<ResourceService.ResourceWrapper> wrappers = new ResourceService().getResourceWrappers(resources);
        Test.stopTest();
        System.assertEquals(true, wrappers[0].isFavorite);
        System.assertEquals(true, wrappers[0].isVoted);
    }

    @IsTest
    public static void getResources_WithResourceType_Article_NoTherapeuticAreas_Test() {
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(
                'DatabaseProxy',
                (DatabaseProxy) Test.createStub(
                        DatabaseProxy.class,
                        new Test_ResourceService.DatabaseProxyStub('getResources_WithResourceType_Article_NoTherapeuticAreas_Test')
                )
        );
        ClassFactory.putStubTypeByClassName(
                'CommunityService',
                (CommunityService) Test.createStub(
                        CommunityService.class,
                        new Test_ResourceService.CommunityServiceStub('getParticipant_Test')
                )
        );
        Test.startTest();
        ResourceService.ResourceWrapperContainer container = new ResourceService().getResources(ResourceService.RESOURCE_TYPE_ARTICLE);
        Test.stopTest();
        System.assertEquals(Label.Resources_No_Articles, container.errorMessage);
    }

    @IsTest
    public static void getResources_WithResourceType_Article_NoResources_Test() {
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(
                'DatabaseProxy',
                (DatabaseProxy) Test.createStub(
                        DatabaseProxy.class,
                        new Test_ResourceService.DatabaseProxyStub('getResources_WithResourceType_Article_NoResources_Test')
                )
        );
        ClassFactory.putStubTypeByClassName(
                'CommunityService',
                (CommunityService) Test.createStub(
                        CommunityService.class,
                        new Test_ResourceService.CommunityServiceStub('getParticipant_Test')
                )
        );
        Test.startTest();
        ResourceService.ResourceWrapperContainer container = new ResourceService().getResources(ResourceService.RESOURCE_TYPE_ARTICLE);
        Test.stopTest();
        System.assertEquals(Label.Resources_No_Articles, container.errorMessage);
    }

    @IsTest
    public static void getResources_WithResourceType_Video_NoResources_Test() {
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(
                'DatabaseProxy',
                (DatabaseProxy) Test.createStub(
                        DatabaseProxy.class,
                        new Test_ResourceService.DatabaseProxyStub('getResources_WithResourceType_Video_NoResources_Test')
                )
        );
        ClassFactory.putStubTypeByClassName(
                'CommunityService',
                (CommunityService) Test.createStub(
                        CommunityService.class,
                        new Test_ResourceService.CommunityServiceStub('getParticipant_Test')
                )
        );
        Test.startTest();
        ResourceService.ResourceWrapperContainer container = new ResourceService().getResources(ResourceService.RESOURCE_TYPE_VIDEO);
        Test.stopTest();
        System.assertEquals(Label.Resources_No_Videos, container.errorMessage);
    }

    @IsTest
    public static void getResources_Integration_Test() {

        Account singleAccount = (Account) TestDataFactory.getSObject(Account.getSObjectType());
        Account participantAccount = (Account) TestDataFactory.getSObject(Account.getSObjectType(), new Map<String, Object>{
                'Name' => 'Participant'
        });
        insert new List<Account>{
                singleAccount, participantAccount
        };

        Contact piContact = (Contact) TestDataFactory.getSObject(Contact.getSObjectType(), new Map<String, Object>{
                'AccountId' => singleAccount.Id,
                'LastName' => 'portalTestUser1',
                'Email' => 'some@email.com'
        });
        insert piContact;

        Participant__c singleParticipant = (Participant__c) TestDataFactory.getSObject(Participant__c.getSObjectType());
        insert singleParticipant;

        Therapeutic_Area__c tA = (Therapeutic_Area__c) TestDataFactory.getSObject(Therapeutic_Area__c.getSObjectType());
        insert tA;

        Clinical_Trial_Profile__c clinicalTrialProfile = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(Clinical_Trial_Profile__c.getSObjectType(),
                new Map<String, Object>{
                    'Therapeutic_Area__c' => tA.Id
                });
        insert clinicalTrialProfile;

        Study_Site__c studySite = (Study_Site__c) TestDataFactory.getSObject(Study_Site__c.getSObjectType(), new Map<String, Object>{
                'Clinical_Trial_Profile__c' => clinicalTrialProfile.Id,
                'Site__c' => singleAccount.Id,
                'Principal_Investigator__c' => piContact.Id,
                'Override_PI_Referral_Status__c' => 'Invitation Sent'
        });
        insert studySite;

        Participant_Enrollment__c enrollment = (Participant_Enrollment__c) TestDataFactory.getSObject(Participant_Enrollment__c.getSObjectType(),
                new Map<String, Object>{
                        'Medical_Record_Review_Status__c' => 'Pass',
                        'Pre_screening_Status__c' => 'Pass',
                        'Participant_Name__c' => singleParticipant.First_Name__c,
                        'Participant_Surname__c' => singleParticipant.Last_Name__c,
                        'Patient_ID__c' => '12345678',
                        'Participant_Status__c' => 'Referral Sent to PI',
                        'Referral_Source__c' => 'HCP',
                        'Study_Site__c' => studySite.Id,
                        'Participant__c' => singleParticipant.Id
                });
        insert enrollment;

        System.debug([SELECT Name FROM User]);
//        Test.startTest();
//        ResourceService.ResourceWrapperContainer container = new ResourceService().getResources(ResourceService.RESOURCE_TYPE_VIDEO);
//        Test.stopTest();
//        System.assertEquals(Label.Resources_No_Videos, container.errorMessage);
    }

    public class CommunityServiceStub implements System.StubProvider {

        String testMethodName;

        public CommunityServiceStub(String testMethodName) {
            this.testMethodName = testMethodName;
        }

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName,
                Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames,
                List<Object> listOfArgs) {

            if (stubbedMethodName == 'getParticipantId') {
                return TestDataFactory.getFakeId(Participant__c.getSObjectType());
            }

            return null;
        }
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
                if (String.valueOf(listOfArgs[0]).containsIgnoreCase('FROM Participant__c')) {
                    return this.getParticipantsList();
                }
                if (String.valueOf(listOfArgs[0]).containsIgnoreCase('FROM Resource__c')) {
                    return this.getResourcesList();
                }
                if (String.valueOf(listOfArgs[0]).containsIgnoreCase('FROM Therapeutic_Area_Assignment__c')) {
                    return this.getTherapeuticAreaAssignmentsList();
                }
            }

            return null;
        }

        private List<Participant__c> getParticipantsList() {
            if (testMethodName.contains('getParticipant_Test')) {
                return new List<Participant__c>{
                        (Participant__c) TestDataFactory.getSObject(Participant__c.getSObjectType(), new Map<String, Object>{
                                'First_Name__c' => 'Test Participant'
                        })
                };
            }
            if (testMethodName.contains('getResources_WithResourceType_Article_NoTherapeuticAreas_Test')) {
                return new List<Participant__c>{
                        (Participant__c) TestDataFactory.getSObject(Participant__c.getSObjectType())
                };
            }
            if (this.testMethodName.contains('getResources_WithResourceType_Article_NoResources_Test') || this.testMethodName.containsIgnoreCase('getResources_WithResourceType_Video_NoResources_Test')) {
                Participant__c participant = (Participant__c) TestDataFactory.getSObject(Participant__c.getSObjectType(), new Map<String, Object>{
                        'Contact__r' => (Contact) TestDataFactory.getSObject(Contact.getSObjectType(), new Map<String, Object>{
                                'Language__c' => 'ru'
                        }),
                        'Id' => TestDataFactory.getFakeId(Participant__c.SObjectType)
                });
                ParticipantDecoupler.therapeuticAreaPatientsByParticipantIds.put(
                        participant.Id,
                        new List<Therapeutic_Area_Patient__c>{
                                (Therapeutic_Area_Patient__c) TestDataFactory.getSObject(Therapeutic_Area_Patient__c.getSObjectType(), new Map<String, Object>{
                                        'Therapeutic_Area__r' => (Therapeutic_Area__c) TestDataFactory.getSObject(Therapeutic_Area__c.getSObjectType())
                                })
                        }
                );
                return new List<Participant__c>{
                        participant
                };
            }
            return null;
        }

        private List<Resource__c> getResourcesList() {
            if (this.testMethodName.contains('getResources_WithResourceType_Article_NoResources_Test') ||
                    this.testMethodName.containsIgnoreCase('getResources_WithResourceType_Video_NoResources_Test')) {
                return new List<Resource__c>();
            }
            return null;
        }

        private List<Therapeutic_Area_Assignment__c> getTherapeuticAreaAssignmentsList() {
            if (this.testMethodName.contains('getResources_WithResourceType_Article_NoResources_Test') ||
                    this.testMethodName.containsIgnoreCase('getResources_WithResourceType_Video_NoResources_Test')) {
                return new List<Therapeutic_Area_Assignment__c>();
            }
            return null;
        }
    }


}