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
        TestedClass testInstance = new TestedClass('Test');
        SettingStoreService.save('TestingClass', testInstance, TestedClass.class);
        TestedClass settings = (TestedClass) SettingStoreService.get('TestingClass');
        System.assertEquals(testInstance.value, settings.value);
    }

    @IsTest
    static void testGetOrgDefault() {
        TestedClass testInstance = new TestedClass('Test');
        SettingStoreService.saveOrgDefault('TestingClass', testInstance, TestedClass.class);
        TestedClass noSettings = (TestedClass) SettingStoreService.getOrgDefault('TestingClass');
        System.assertEquals(testInstance.value, noSettings.value);
    }

    @IsTest
    static void testGetWithUserIdPassed() {
        TestedClass testInstance = new TestedClass('Test');
        SettingStoreService.save('TestingClass', UserInfo.getUserId(), testInstance, TestedClass.class);
        TestedClass noSettings = (TestedClass) SettingStoreService.get('TestingClass', UserInfo.getUserId());
        System.assertEquals(testInstance.value, noSettings.value);
    }
}