@isTest
private class Test_CommunityTemplate {
    @isTest
    static void testCommunityTemplate(){
        Community_Template__mdt ctm= new Community_Template__mdt();
        ctm.Community_Name__c='TestCommunityName';
        ctm.Permission_Set_Developer_Name__c='TestPermissionSetName';
        ctm.DeveloperName='TestCommunityTemplateName';
        ctm.ShortCommunityName__c='TestShortCommunityName';
        
        Map<String, String> properties= new Map<String, String>();
        properties.put('testKey', 'testValue');
       CommunityTemplate ct= new CommunityTemplate(ctm,properties);
    }
}