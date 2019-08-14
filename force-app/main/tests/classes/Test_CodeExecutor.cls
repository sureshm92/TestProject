@IsTest(IsParallel=true)
public class Test_CodeExecutor {

    @IsTest
    public static void execute_Test() {

        TestCodeExecutor executor = new TestCodeExecutor();
        CodeExecutor virtualExecutor = new CodeExecutor();
        Test.startTest();
        virtualExecutor.execute(new List<Object>{'String', 0});
        executor.execute(new List<Object>{'String', 0});
        Test.stopTest();
        System.assertEquals('String', executor.result[0]);
        System.assertEquals(0, executor.result[1]);
        System.assertEquals(null, virtualExecutor.result);
    }

    private class TestCodeExecutor extends CodeExecutor {

        public override List<Object> getResult(List<Object> arguments) {
            return arguments;
        }
    }
}