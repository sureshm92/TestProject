/**
 * Created by Nargiz Mamedova on 11/26/2019.
 */

@IsTest
private class Test_SettingStoreService {
    public class TestedClass{
        public String value;

        public TestedClass(String value){
            this.value = value;
        }
    }
    @IsTest
    static void testGetInUserContext() {
        TestData.loadTestData();
        TestData testData = new TestData();
        System.runAs(testData.participantUser){
            TestedClass testedClass = new TestedClass('Test');
            SettingStoreService.save('TestingClass', testedClass, TestedClass.class);
            Object settings = SettingStoreService.get('TestingClass');
        }
    }

    @IsTest
    static void testGetOrgDefault() {
        TestedClass testedClass = new TestedClass('Test');
        SettingStoreService.saveOrgDefault('TestingClass', testedClass, TestedClass.class);
        Object noSettings = SettingStoreService.getOrgDefault('TestingClass');
    }

    @IsTest
    static void testGetWithUserIdPassed() {
        TestData.loadTestData();
        TestData testData = new TestData();
        TestedClass testedClass = new TestedClass('Test');
        SettingStoreService.save('TestingClass', testData.participantUser.Id, testedClass, TestedClass.class);
        Object noSettings = SettingStoreService.get('TestingClass', testData.participantUser.Id);
    }
}