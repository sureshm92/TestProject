@isTest
public class Test_MulesoftIntegrationApi {
     @IsTest
    static void testGetAccessToken() {
        MulesoftToken__c setting = new MulesoftToken__c();
        setting.Name = 'Test';
        setting.Named_Credentials_Name__c = 'Test_Named_Credential';
        setting.Token__c = 'test_token';
        setting.Expiration_Date__c = DateTime.now().addHours(1);
        insert setting;
        
        String token = MulesoftIntegrationApi.getAccessToken('Test');
        System.assertNotEquals(null, token);
    }
    
    @IsTest
    static void testGenerateAccessToken() {
        MulesoftToken__c setting = new MulesoftToken__c();
        setting.Name = 'Test';
        setting.Named_Credentials_Name__c = 'Test_Named_Credential';
        insert setting;
        
        Test.startTest();
        HttpCalloutMock mock = new Mock_MulesoftIntegrationApi();
        Test.setMock(HttpCalloutMock.class, mock);
        String token = MulesoftIntegrationApi.generateAccessToken(setting);
        setting.Token__c =token;
        Test.stopTest();
        setting = [SELECT Token__c, Expiration_Date__c FROM MulesoftToken__c WHERE Id = :setting.Id];
        System.assertEquals('test_token', setting.Token__c);
        System.assertNotEquals(null, setting.Expiration_Date__c);
    }
    
    @IsTest
    static void testGenerateAccessTokenWithError() {
        MulesoftToken__c setting = new MulesoftToken__c();
        setting.Name = 'Test';
        setting.Named_Credentials_Name__c = 'Test';
        insert setting;
        
        Test.startTest();
        HttpCalloutMock mock = new Mock_MulesoftIntegrationApi();
        Test.setMock(HttpCalloutMock.class, mock);
        String token = MulesoftIntegrationApi.generateAccessToken(setting);
        Test.stopTest();
        
        setting = [SELECT Token__c, Expiration_Date__c FROM MulesoftToken__c WHERE Id = :setting.Id];
        
    }

}