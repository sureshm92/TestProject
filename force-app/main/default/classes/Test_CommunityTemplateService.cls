@isTest
private class Test_CommunityTemplateService {
    @isTest
    static void testCommunityTemplateService(){
        
        CommunityTemplateService.getTemplate('TestTemplate');
        CommunityTemplateService.getTemplateByCommunityName('TestCommunityName');
        CommunityTemplateService.getTemplateByPermissionSetName('TestPermissionSet');
        CommunityTemplateService.getTemplateByPrefix('TestTemplatePrefix');
        CommunityTemplateService.getDefaultTemplate();
        CommunityTemplateService.getAllPermissionSets();
        CommunityTemplateService.getCommunityURL('TestCommunityName');
        CommunityTemplateService.getUrlPathPrefix('TestTemplate');
        CommunityTemplateService.getNetworkId('TestCommunityName');
        CommunityTemplateService.getNetworksMap();
        CommunityTemplateService.getResourcesURLMap();
        CommunityTemplateService.replaceResourceParameter('TestSourceString');
    }
}