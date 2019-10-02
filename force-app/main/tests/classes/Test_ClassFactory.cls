@IsTest(IsParallel=true)
public class Test_ClassFactory {

    @IsTest
    public static void newInstance_Test() {

        Test.startTest();
        ClassFactory.ClassForTestingClassFactory testClassByType = (ClassFactory.ClassForTestingClassFactory) ClassFactory.newInstance(ClassFactory.ClassForTestingClassFactory.class);
        ClassFactory.ClassForTestingClassFactory testClassByName = (ClassFactory.ClassForTestingClassFactory) ClassFactory.newInstance('ClassFactory.ClassForTestingClassFactory');
        Test.stopTest();
        System.assertEquals('Class Created', testClassByType.testingString);
        System.assertEquals('Class Created', testClassByName.testingString);
    }

    @IsTest
    public static void putStubTypeByClassName_Test() {

        ClassFactory.ClassForTestingClassFactory valueToReturnByType = new ClassFactory.ClassForTestingClassFactory();
        valueToReturnByType.testingString = 'Stubbed Value By Type';
        ClassFactory.ClassForTestingClassFactory valueToReturnByName = new ClassFactory.ClassForTestingClassFactory();
        valueToReturnByName.testingString = 'Stubbed Value By Name';
        Test.startTest();
        ClassFactory.putStubTypeByClassName(ClassFactory.class,
                StubBuilder.newInstance(ClassFactory.class)
                        .when('getClassForTestingClassFactory')
                        .then(valueToReturnByType)
                .build()
       );
        ClassFactory testClassByType = (ClassFactory) ClassFactory.newInstance(ClassFactory.class);
        ClassFactory.putStubTypeByClassName('ClassFactory',
                StubBuilder.newInstance('ClassFactory')
                        .when('getClassForTestingClassFactory')
                        .then(valueToReturnByName)
                .build()
       );
        ClassFactory testClassByName = (ClassFactory) ClassFactory.newInstance('ClassFactory');
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory testClassWithoutStub = (ClassFactory) ClassFactory.newInstance(ClassFactory.class);
        Test.stopTest();
        System.assertEquals('Stubbed Value By Type', testClassByType.getClassForTestingClassFactory().testingString);
        System.assertEquals('Stubbed Value By Name', testClassByName.getClassForTestingClassFactory().testingString);
        System.assertEquals('Class Created', testClassWithoutStub.getClassForTestingClassFactory().testingString);
        System.assertEquals(0, ClassFactory.stubTypesByClassNames.size());
    }
}