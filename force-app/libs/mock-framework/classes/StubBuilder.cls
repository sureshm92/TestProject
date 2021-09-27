/**
 * Created by Yehor Dobrovolskyi for testing today
 */
public with sharing class StubBuilder {
    private Stub stub;
    private Type typeOfClass;
    private String methodName;

    public static StubBuilder newInstance(Type typeOfClass) {
        return new StubBuilder(typeOfClass);
    }

    public static StubBuilder newInstance(String fullNameOfClass) {
        return newInstance(Type.forName(fullNameOfClass));
    }

    public StubBuilder(Type typeOfClass) {
        this.stub = new StubBuilder.Stub();
        this.typeOfClass = typeOfClass;
    }

    public StubBuilder when(String methodName) {
        this.methodName = methodName;
        return this;
    }

    public StubBuilder then(Object desiredResult) {
        this.stub.desiredResultsByMethodNames.put(methodName, desiredResult);
        return this;
    }

    public Object build() {
        return Test.createStub(this.typeOfClass, stub);
    }

    public class Stub implements System.StubProvider {
        public Map<String, Object> desiredResultsByMethodNames;

        public Stub() {
            this.desiredResultsByMethodNames = new Map<String, Object>();
        }

        public Object handleMethodCall(
            Object stubbedObject,
            String stubbedMethodName,
            Type returnType,
            List<Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs
        ) {
            Object result = desiredResultsByMethodNames.get(stubbedMethodName);
            if (result == null) {
                return result;
            }
            if (result instanceof CodeExecutor) {
                return ((CodeExecutor) result).execute(listOfArgs);
            }
            if (result instanceof Exception) {
                throw (Exception) result;
            }
            return result;
        }
    }
}
