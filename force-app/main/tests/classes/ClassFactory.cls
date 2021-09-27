public with sharing class ClassFactory {
    @TestVisible
    private static Map<String, Object> stubTypesByClassNames = new Map<String, Object>();
    @TestVisible
    private static Map<Type, Object> existingObjectsByTypes = new Map<Type, Object>();
    @TestVisible
    private static Boolean isCacheable = false;

    public static void setCacheable(Boolean cacheable) {
        isCacheable = cacheable;
    }

    public static Object newInstance(Type typeOfClass) {
        if (!isCacheable || !existingObjectsByTypes.containsKey(typeOfClass)) {
            Object instance = getStubOrInstance(typeOfClass);
            if (!existingObjectsByTypes.containsKey(typeOfClass)) {
                existingObjectsByTypes.put(typeOfClass, instance);
            }
            return instance;
        } else {
            return existingObjectsByTypes.get(typeOfClass);
        }
    }

    public static Object newInstance(String fullNameOfClass) {
        return newInstance(Type.forName(fullNameOfClass));
    }

    public static void clearStubTypesByClassNamesMap() {
        stubTypesByClassNames.clear();
    }

    public static void putStubTypeByClassName(String fullNameOfClass, Object instanceOfStub) {
        stubTypesByClassNames.put(fullNameOfClass, instanceOfStub);
    }

    public static void putStubTypeByClassName(Type classType, Object instanceOfStub) {
        stubTypesByClassNames.put(classType.getName(), instanceOfStub);
    }

    public ClassForTestingClassFactory getClassForTestingClassFactory() {
        return new ClassForTestingClassFactory();
    }

    private static Object getPrimitive(Type typeOfPrimitive) {
        if (typeOfPrimitive.getName() == 'Boolean')
            return false;
        if (typeOfPrimitive.getName() == 'Id')
            return Id.valueOf('001000000000000');
        if (typeOfPrimitive.getName() == 'String')
            return '';
        if (typeOfPrimitive.getName() == 'Blob')
            return Blob.valueOf('Blob');
        if (typeOfPrimitive.getName() == 'Date')
            return Date.today();
        if (typeOfPrimitive.getName() == 'Datetime')
            return Datetime.now();
        if (typeOfPrimitive.getName() == 'Time')
            return Time.newInstance(0, 0, 0, 0);
        if (typeOfPrimitive.getName() == 'Integer')
            return (Integer) 0;
        if (typeOfPrimitive.getName() == 'Long')
            return (Long) 0;
        if (typeOfPrimitive.getName() == 'Decimal')
            return (Decimal) 0.0;
        if (typeOfPrimitive.getName() == 'Double')
            return (Double) 0.0;
        return null;
    }

    private static Object getStubOrInstance(Type typeOfClass) {
        Object result;
        if (Test.isRunningTest() && stubTypesByClassNames.get(typeOfClass.getName()) != null) {
            result = stubTypesByClassNames.get(typeOfClass.getName());
        } else {
            result = getPrimitive(typeOfClass);
        }

        if (result == null) {
            result = typeOfClass.newInstance();
        }

        return result;
    }

    public class ClassForTestingClassFactory {
        public String testingString;
        public ClassForTestingClassFactory() {
            this.testingString = 'Class Created';
        }
    }
}
