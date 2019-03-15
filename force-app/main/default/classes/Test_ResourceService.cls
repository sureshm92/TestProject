@IsTest
public class Test_ResourceService {

	@TestSetup
	public static void setup() {

	}

	@IsTest
	public static void getParticipantLanguage_Test() {
		Participant__c participantWithLanguageDefined = new Participant__c(Contact__r=new Contact(Language__c='ru'));
		Participant__c participantWithoutLanguageDefined =  new Participant__c(Contact__r=new Contact());
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
						new ResourceServiceTest.DatabaseProxyStub('getParticipant_Test')
				)
		);
		Test.startTest();
		Participant__c participant = new ResourceService().getParticipant();
		Test.stopTest();
		System.assertEquals('Test Participant', participant.First_Name__c);
	}

	@IsTest
	public static void getResourceWrappers_NoActions_Test() {
		ClassFactory.clearStubTypesByClassNamesMap();
		ClassFactory.putStubTypeByClassName(
				'DatabaseProxy',
				(DatabaseProxy) Test.createStub(
						DatabaseProxy.class,
						new ResourceServiceTest.DatabaseProxyStub('getResourceWrappers_NoActions_Test')
				)
		);

		List<Resource__c> resources = new List<Resource__c>{new Resource__c()};

		Test.startTest();
		List<ResourceService.ResourceWrapper> wrappers = new ResourceService().getResourceWrappers(resources);
		Test.stopTest();
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
					return new List<Participant__c>{new Participant__c(First_Name__c='Test Participant')};
				}
			}

			return null;
		}
	}
}