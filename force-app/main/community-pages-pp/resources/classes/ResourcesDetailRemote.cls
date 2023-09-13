/**
 * Created by Yehor Dobrovolskyi
 */
public without sharing class ResourcesDetailRemote {
    @AuraEnabled
    public static ResourceService.ResourceWrapperContainer getResourcesById(
        String resourceId, 
        String resourceType,
        String participantData
    ) {
        try {
            return ResourceDelegate.getInstance().getResourcesById(resourceId, resourceType, participantData); 
        } catch (Exception e) {
            return (ResourceService.ResourceWrapperContainer) AuraHelper.throwException(e);
        }
    }
}