/**
 * Created by Yehor Dobrovolskyi
 */
public without sharing class ResourcesDetailRemote {

    @AuraEnabled
    public static ResourceService.ResourceWrapperContainer getResourcesById(String resourceId, String resourceType) {
        try {
            return ResourceDelegate.getInstance().getResourcesById(resourceId, resourceType);
        } catch (Exception e) {
            return (ResourceService.ResourceWrapperContainer) AuraHelper.throwException(e);
        }
    }

}