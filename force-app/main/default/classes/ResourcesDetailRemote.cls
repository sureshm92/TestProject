/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class ResourcesDetailRemote {

    @AuraEnabled
    public static ResourceService.ResourceWrapperContainer getResourcesById(String resourceId, String resourceType) {

        try {
            return ((ResourceDelegate) ClassFactory.newInstance(ResourceDelegate.class)).getResourcesById(resourceId, resourceType);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

}