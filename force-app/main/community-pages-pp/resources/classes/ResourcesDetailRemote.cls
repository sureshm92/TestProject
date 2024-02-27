/**
 * Created by Yehor Dobrovolskyi
 */
public without sharing class ResourcesDetailRemote {
    @AuraEnabled
    public static ResourceService.ResourceWrapperContainer getResourcesById(
        String resourceId, 
        String resourceType
    ) {
        try {
            return ResourceDelegate.getInstance().getResourcesById(resourceId, resourceType); 
        } catch (Exception e) {
            return (ResourceService.ResourceWrapperContainer) AuraHelper.throwException(e);
        }
    }
    @AuraEnabled
    public static ResourceService.ResourceWrapperContainer getResourcesByIdNew(
        String resourceId, 
        String resourceType,
        String participantData
    ) {
        try {
            return ResourceDelegate.getInstance().getResourcesByIdNew(resourceId, resourceType, participantData); 
        } catch (Exception e) {
            return (ResourceService.ResourceWrapperContainer) AuraHelper.throwException(e);
        }
    }    
    @AuraEnabled
    public static string getDocId(String resourceId){
        return [select ContentDocumentid from ContentDocumentLink where LinkedEntityId =:resourceId].ContentDocumentid;
    }
}