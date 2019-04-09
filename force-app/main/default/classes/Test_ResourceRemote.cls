@IsTest
public class Test_ResourceRemote {

	@TestSetup
	public static void setup() {

	}

	@IsTest
	public static void setResourceAction_ActionExist_Test() {

		ClassFactory.clearStubTypesByClassNamesMap();
		ClassFactory.putStubTypeByClassName(
				'DatabaseProxy',
				(DatabaseProxy) Test.createStub(
						DatabaseProxy.class,
						new Test_ResourceRemote.DatabaseProxyStub('setResourceAction_ActionExist_Test')
				)
		);
		Test.startTest();
//		ResourceRemote.setResourceAction(ResourceRemote.RESOURCE_TEST_ID, true, true);
		Test.stopTest();
	}

	@IsTest
	public static void setResourceAction_ActionDoesNotExist_Test() {

		ClassFactory.clearStubTypesByClassNamesMap();
		ClassFactory.putStubTypeByClassName(
				'DatabaseProxy',
				(DatabaseProxy) Test.createStub(
						DatabaseProxy.class,
						new Test_ResourceRemote.DatabaseProxyStub('setResourceAction_ActionDoesNotExist_Test')
				)
		);
		Test.startTest();
//		ResourceRemote.setResourceAction(ResourceRemote.RESOURCE_TEST_ID, false, true);
		Test.stopTest();
	}

	@IsTest
	public static void getResources_FavoriteResources_Test() {

		ClassFactory.clearStubTypesByClassNamesMap();
		ClassFactory.putStubTypeByClassName(
				'ResourceService',
				(ResourceService) Test.createStub(
						ResourceService.class,
						new Test_ResourceRemote.ResourceServiceStub('getResources_FavoriteResources_Test')
				)
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
		ClassFactory.putStubTypeByClassName(
				'ResourceService',
				(ResourceService) Test.createStub(
						ResourceService.class,
						new Test_ResourceRemote.ResourceServiceStub('getResources_DefaultResources_Test')
				)
		);
		Test.startTest();
		ResourceService.ResourceWrapperContainer container = ResourceRemote.getResources('Article', 'Default');
		Test.stopTest();

		System.assert(String.isBlank(container.errorMessage));
		System.assert(container.wrappers.isEmpty());
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
				if (testMethodName.contains('setResourceAction_ActionExist_Test')) {
					return new List<Resource_Action__c>{new Resource_Action__c(IsFavorite__c=true, IsVoted__c=false)};
				}
				if(testMethodName.contains('setResourceAction_ActionDoesNotExist_Test')) {
					return new List<Resource_Action__c>();
				}
			}
			if(stubbedMethodName == 'upsertRecord') {
				if (testMethodName.contains('setResourceAction_ActionExist_Test')) {
					System.assertEquals(true, Boolean.valueOf(((SObject)listOfArgs[0]).get('IsVoted__c')));
					System.assertEquals(true, Boolean.valueOf(((SObject)listOfArgs[0]).get('IsFavorite__c')));
					System.assert(String.isBlank(String.valueOf(((SObject)listOfArgs[0]).get('Resource__c'))));
					return null;
				}
				if (testMethodName.contains('setResourceAction_ActionDoesNotExist_Test')) {
					System.assertEquals(true, Boolean.valueOf(((SObject)listOfArgs[0]).get('IsVoted__c')));
					System.assertEquals(false, Boolean.valueOf(((SObject)listOfArgs[0]).get('IsFavorite__c')));
//					System.assertEquals(ResourceRemote.RESOURCE_TEST_ID, String.valueOf(((SObject)listOfArgs[0]).get('Resource__c')));
//					System.assertEquals(ResourceRemote.PARTICIPANT_TEST_ID, String.valueOf(((SObject)listOfArgs[0]).get('Participant__c')));
					return null;
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

			if (stubbedMethodName == 'getFavoriteResources') {
				return new ResourceService.ResourceWrapperContainer(Label.Resources_No_Favorite_Articles);
			}
			if(stubbedMethodName == 'getResources') {
				return new ResourceService.ResourceWrapperContainer(new List<ResourceService.ResourceWrapper>());
			}
			return null;
		}
	}
}