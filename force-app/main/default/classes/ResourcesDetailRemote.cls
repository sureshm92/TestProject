/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class ResourcesDetailRemote {

    @AuraEnabled
    public static List<ResourceService.ResourceWrapper> getResourcesById(String resourceId) {

        System.debug('Id resource: ' + resourceId);
        ResourceService resourceService = (ResourceService) ClassFactory.newInstance(ResourceService.class);
        return resourceService.getResourcesById(resourceId);
    }

}