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
        TestedClass testedClass = new TestedClass('Test');
        SettingStoreService.save('TestingClass', testedClass, TestedClass.class);
        TestedClass restoredClass = (TestedClass) SettingStoreService.get('TestingClass');
        System.assertEquals(testedClass.value, restoredClass.value);
    }

    @IsTest
    static void testGetOrgDefault() {
        TestedClass testedClass = new TestedClass('Test');
        SettingStoreService.saveOrgDefault('TestingClass', testedClass, TestedClass.class);
        TestedClass restoredClass = (TestedClass) SettingStoreService.getOrgDefault('TestingClass');
        System.assertEquals(testedClass.value, restoredClass.value);
    }

    @IsTest
    static void testGetWithUserIdPassed() {
        TestedClass testedClass = new TestedClass('Test');
        SettingStoreService.save('TestingClass', UserInfo.getUserId(), testedClass, TestedClass.class);
        TestedClass restoredClass = (TestedClass) SettingStoreService.get('TestingClass', UserInfo.getUserId());
        System.assertEquals(testedClass.value, restoredClass.value);
    }
}