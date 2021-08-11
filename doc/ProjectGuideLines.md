## Rules for writing code in RH and PP

1. The interaction of the Lightning component with the Apex controller is built as follows:

    - The controller contains all the necessary wrappers to send data to the component (you do not need wrapper classes that relate exclusively to the controller logic to be shoved into service classes! wrapper classes inside service classes only if they are used in several places and this is logically justified)
    - We delegate the logic itself to the service and context classes.
    - Initialize the wrapper with the data, fill it with data from the service classes and send it to the component.
    - we wrap all the logic in try - catch and use AuraHelper.throwException(e) to transfer the error to the component
    - we call the APEX controller for Lightning components with the ending Remote, for Visualforce - with the ending Controller

2. We split the logic on the backend according to the principle:

    - all common methods we group by service classes, which should contain a set of procedures, united according to some principle, usually by the type of object. Example: All methods for working with the Participant Enrollment are located in the ParticipantEnrollmentService. Service classes that are planned to be replaced with Mock objects must be designed as an object that has a static method getInstance () this method must return an instance of the service object created through ClassFactory. This will allow in the future, when writing tests, to replace the service object with its mock stub, and for this you will need to use the ClassFactory functionality. It is recommended to use mock testing only in exceptional cases (there is no way to create an object in the database, you only need to test a small piece of functionality, you need to test interaction with external systems, etc.)
    - the logic that relates to the context is placed in the service context classes. These classes should be singletons (it is better to create an instance object through ClassFactory) and have functionality related to the corresponding context. At the moment, context methods are in service classes and often cause problems when it is necessary to use these service classes out of context. In the future, you need to move these methods into context classes, which, in turn, should use the functionality of the service classes, but within the framework of the current context. In the future, it is planned to introduce context classes ParticipantContext, ContactContext, UserContext.
    - it is desirable to make service methods immediately suitable for processing an array of input data and not single data. This is important as these methods can be used in triggers and tanks.

    **Example:**

    **_You need to write a method that returns all delegates for the current contact of the participant._**

    **Solution:**

    1. You need to create a method that for the list of contact Id returns a map containing a list of delegates for each contact (Map <Id, List <Id>>) and place this method in the ParticipantDelegateService service class.
    2. You also need to add the appropriate getDelegates method to the ParticipantContext context class (while it is in perspective), which will in turn call the service class method and pass a list of one element to it and take the desired value from the resulting map.

## Rules for writing tests

1. For testing code, the priority is integration tests, not unit tests. That is, tests that check the entire chain of interconnected logic elements and not one link in isolation. If we are talking about testing controllers, then, accordingly, it is necessary to test first of all all the methods of the controller and not all the methods of the service that it uses. This approach allows you to write and maintain tests efficiently. One integration test is able to test much more functionality compared to one unit test. At the same time, when changing the logic, you do not have to spend a lot of time changing the test.

2. To write an integration test, you must use the TestData class, which contains the logic for creating test data.

3. To save execution time, you need to place the basic data loading into a method with the @TestSetup annotation and call in this method: TestData.loadData (). And in each test, you can already initialize the dataset using testDataInstance = new TestData (). The testDataInstance object will hold the required dataset. Next, you need to execute the tested logic under the desired user and perform checks. The more tests there are in one class, the faster they will be executed, since for each test it will not be necessary to reload one data set.Thus, one should strive to group integration into classes, one integration test in one class is an ineffective approach.

An example of an integration test:

```Java
@IsTest
private class Test_IntegrationTestDemo {

    @TestSetup
    static void init(){
        TestData.loadTestData();
    }

    @IsTest
    static void test1() {
        Test.startTest();
        TestData testDataInstance = new TestData();
        System.runAs(testDataInstance.participantUser){
            //run and test some logic under participant
        }

        Test.stopTest();
    }
}
```

## Rules for writing unit tests using mock services

1. Mock testing is used only in exceptional cases.

2. Mock testing involves testing a part of the functionality and the work of the rest of the functionality is imitated by substituting mock objects instead of real objects. For this approach, it is necessary that the logic of the service class be implemented in ordinary methods of the object, and not in static methods of the class, since substitution works for objects (class instances) and not for classes.

3. The service class must be instantiated through the ClassFactory. It is convenient to immediately put the getInstance () method into the service class, which will already contain a call to the ClassFactory to get an instance of the class. If a singleton is implemented, then an instance of the class is also initially instantiated through the ClassFactory and stored in a static private variable instance. On a subsequent call, an instance of the class stored in this variable is already returned.

4. The test structure consists of first substituting the necessary mock objects instead of real services, then launching the functionality that needs to be tested. It is important to understand that mixing mock testing with integration testing does not make any sense. For example, if in the test some data is first filled in the database and then mock objects are substituted for this instead of some service classes, then the test in this case turns into fitting the results and does not perform its function, in the future such a test is very difficult support, and besides that, one of the advantages of mock testing goes away - the ability to quickly check localized functionality, since filling the database with data all over the place will take a lot of time. If mock testing is used, then you need to cut off all the functionality that does not need to be tested using mocks.

Example unit test using mock services:

```Java
@IsTest
private class Test_UnitMockDemo {

    @IsTest
    static void testBehavior() {
        //setup mocks for ServiceClass1 and ServiceClass2
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(SomeServiceClass1.class, StubBuilder.newInstance(SomeServiceClass1.class)
                .when('someMethodName1')
                .then('... put here value for method 1 (type Object)')
                .when('someMethodName2')
                .then('... put here value for method 2 (type Object)')
                .build()
        );
        ClassFactory.putStubTypeByClassName(SomeServiceClass2.class, StubBuilder.newInstance(SomeServiceClass2.class)
                .when('someMethodName1')
                .then('... put here value for method 1 (type Object)')
                .when('someMethodName2')
                .then('... put here value for method 2 (type Object)')
                .build()
        );
        Test.startTest();
        //test logic here...
        Test.stopTest();
    }
}
```

## Rules for writing triggers

1. There should be no logic in the trigger itself. There must be one trigger per object and must be named as an object with a Trigger ending. Before creating a new file for a trigger, you need to make sure that there is no trigger created for this object yet.

2. The trigger declaration must contain all possible events (before insert, before update ...)

3. Logic for a trigger must be placed in a handler class inherited from TriggerHandler. In the handler class, we overlap the methods only for the events we need. It is necessary to place several handlers in one general class, so it is clearer. Then the class that contains the handlers should be named as a trigger with the addition of the word Handler at the end. The handlers nested in it should reflect in the name what they do, one handler should be for one type of action or a group of homogeneous actions. It is not correct, for example, to combine in one handler the logic of sending records to an external system and the logic of sending email notifications. In this case, there should be two handlers with corresponding names, and these two handlers should be listed in the trigger. Then, looking into the trigger at the handlers used, it will be easy to understand by their names what is being done in the trigger. For more information on writing triggers, see the TriggerFramework.md document.

4. The handler logic should call service classes. It is possible to place private methods with additional functionality in the handler

trigger example:

```Java
trigger AlertTrigger on Alert__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
     TriggerHandlerExecutor.execute(AlertTriggerHandler.ValidateFieldsHandler.class);
 }
```

Handler example:

```Java
public without sharing class AlertTriggerHandler {

    public class ValidateFieldsHandler extends TriggerHandler{

        public override void beforeInsert(List<SObject> newList) {
            validateFields(newList);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            validateFields(newList);
        }
    }

    private static void validateFields(List<Alert__c> newList){
        // logic here
    }
}
```

## Working with the project structure

When writing code, one should strive to group logic. If, for example, you create some new functionality and it is absolutely independent, then it is logical to place it in a separate folder with a name that reflects its functionality, this will allow you to better navigate the project in the future and make it possible to reuse this code in another project by simply copying it into his folder. Or, in the future, you can transfer this module / feature to a separate project and make an Unlocked Package based on it. Accordingly, when designing logic, you should try to immediately divide it into functional, maximally independent parts. And place these parts in separate folders. This approach increases the culture of the code and the general order in the project, rather than thoughtlessly throwing logic into the first classes that come across, without worrying about how to work with this code later, how to reuse it, and so on.

Example:

The logic for writing triggers, TriggerHandlerExecutor and TriggerHandler. By placing all the logic in one place (the trigger-framework folder), you can easily transfer it to another project in the future, besides this, the project becomes more orderly.

## Project structure

#### Currently the project contains two main folders with code:

-   ** unpackaged ** - this folder contains all files that should not be included in the deployment in the future and are needed to initialize the Scratch orgi)
-   ** force-app ** (the main project folder, which contains all the code and metadata that should be included in the project distribution kit for deployment) Consists of two main folders:
    1.lib - it contains all the universal features that are not specific to the project, which can be reused in other projects
    2.main - it contains everything related to the project

#### Force-app / lib folder structure:

-   **_action-queue_** - asynchronous launch and reprocessing of actions that were executed with an error
-   **_integration-framework_** - core for making calls to an external system with logging
-   **_mock-framework_** - core for doing mock testing
-   **_parameters-provider_**
-   **_scheduled-batch_** - core for scheduled batch execution with control panel
-   **_search-framework_** - kernel for performing full or page-by-page searches using filters
-   **_setting-store_** - the core for storing any objects / settings in the database in the context of a user or organization
-   **_translation-framework_** - core for data translation (Translation table, triggers, service class, etc.)
-   **_trigger-framework_** - a framework for writing trigger logic
-   **_ui-common_** - in this folder you need to place all universal components that can be reused
-   **_utilities_** - contains utility helper classes for working with databases, data types, costume objects, and so on

#### The structure of the force-app / main folder:

-   **_backend-ctp-setup_**- contains components for configuring CTP on the back (tabs on the CTP page) and all auxiliary components
-   **_community-common_**- universal components used within the community (not suitable for use on backing, as they have specific CSS for the community)
-   **_community-pages-common_**- contain common pages for PP and RH
-   **_community-pages-rh_**- pages and components for RH
-   **_community-pages-pp_**- pages and components for PP
-   **_community-template_**- in this folder we place everything related to the community template, navigation menu, profile menu, themes, layouts, etc.
-   **_default_**- contains everything that is pulled from the scratch org, all new fields, objects, layouts, and so on. New objects created in the scratch org will accordingly fall into the main / default / objects folder. If you are working with some isolated feature and want to place all its components in a separate folder, then after the pull procedure, you need to look at the new metadata in this folder and move them to the desired folder, then push. In general, this folder contains "happy soup" from everything that is in the project and has not yet been ordered in some special folder
-   **_deprecated_**- contains everything that is no longer needed and can later be removed when migrating to Unlocked packages. In the current version of the deployment, we do not have the ability to delete something from the target org during deployment, so we just mark the metadata for now by transferring it to this folder. Deprecated classes must be moved to the deprectaed / classes folder, and the entire body must be removed from these classes so that they do not affect the code coverage. The rest of the metadata should also be deactivated if possible and transferred here. You cannot just delete anything from the project!
-   **_integration_**- integration logic (all staging tables, triggers for integration, services, etc.)
-   **_messaging_**- everything related to notifications, email templates, visualforce components, etc.
-   **_scheduled-batch-implementation_**- scheduled batch
-   **_tests_**- all tests, tests for functionally independent parts should be placed together in the same folder where the module is
-   **_translation_**- everything related to translations for the project
-   **_trigger-implementation_**- implementation of trigger logic (again, for functionally independent modules, trigger logic must be inside the module folder)

At the moment, the division of the project into subfolders is still in the process and those folders that are described above do not contain all the metadata that relate to them and some of them are still in the default folder
