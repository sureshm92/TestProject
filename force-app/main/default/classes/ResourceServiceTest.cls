@IsTest
public class ResourceServiceTest {

	@TestSetup
	public static void setup() {

	}

	@IsTest
	public static void getStudySpecificResources_SingleResource_Test() {

		ClassFactory.clearStubTypesByClassNamesMap();
		ClassFactory.putStubTypeByClassName(
				'DatabaseProxy',
				(DatabaseProxy) Test.createStub(
						DatabaseProxy.class,
						new ResourceServiceTest.DatabaseProxyStub('getStudySpecificResources_SingleResource_Test')
				)
		);

		Test.startTest();
		//List<Knowledge__ka> resources = new ResourceService().getS(new Participant__c());
		Test.stopTest();

		//System.assert(resources != null);
		//System.assertEquals(1, resources.size());
	}

	@IsTest
	public static void getStudySpecificResources_ManyResources_Test() {

		ClassFactory.clearStubTypesByClassNamesMap();
		ClassFactory.putStubTypeByClassName(
				'DatabaseProxy',
				(DatabaseProxy) Test.createStub(
						DatabaseProxy.class,
						new ResourceServiceTest.DatabaseProxyStub('getStudySpecificResources_ManyResources_Test')
				)
		);

		Test.startTest();
		//List<Knowledge__ka> resources = new ResourceService().getStudySpecificResources(new Participant__c());
		Test.stopTest();

		//System.assert(resources != null);
		//System.assertEquals(2, resources.size());
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
				if (testMethodName.contains('getStudySpecificResources_SingleResource')) {
					return new List<Knowledge__ka>{new Knowledge__ka()};
				}
				if(testMethodName.contains('getStudySpecificResources_ManyResources')) {
					return new List<Knowledge__ka>{new Knowledge__ka(), new Knowledge__ka()};
				}
			}

			return null;
		}
	}
}