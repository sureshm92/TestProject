/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class ResourcesDetailRemote {

    @AuraEnabled
    public static ResourceService.ResourceWrapperContainer getResourcesById(String resourceId, String resourceType) {

        try {
            System.debug('Id resource: ' + resourceId);
            ResourceService resourceService = (ResourceService) ClassFactory.newInstance(ResourceService.class);
            return resourceService.getResourcesById(resourceId, resourceType);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

}