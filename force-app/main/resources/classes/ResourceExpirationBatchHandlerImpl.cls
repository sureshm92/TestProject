/**
 * Created by Yehor Dobrovolskyi
 */ 
public with sharing class ResourceExpirationBatchHandlerImpl implements BatchHandler {
    public void handle(List<SObject> scope) {
        if (!scope.isEmpty()) {
            List<Resource__c> resourcesToDelete = new List<Resource__c>();
            List<Resource__c> resourcesToUpdate = new List<Resource__c>();
            for (Resource__c singleResource : (List<Resource__c>) scope) {
                if (
                    ResourceService.RESOURCE_SOURCE_PLATFORM.equalsIgnoreCase(
                        singleResource.Content_Class__c
                    )
                ) {
                    singleResource.Remove_sharing__c = true;
                    resourcesToUpdate.add(singleResource);
                } else {
                    resourcesToDelete.add(singleResource);
                }
            }
            Database.DeleteResult[] deleteResult = Database.delete(resourcesToDelete, false);
            for (Database.DeleteResult result : deleteResult) {
                if (!result.isSuccess()) {
                    for (Database.Error err : result.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug(
                            'Resource fields that affected this error: ' + err.getFields()
                        );
                    }
                }
            }
            Database.SaveResult[] updateResult = Database.update(resourcesToUpdate, false);
            for (Database.SaveResult result : updateResult) {
                if (!result.isSuccess()) {
                    for (Database.Error err : result.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug(
                            'Resource fields that affected this error: ' + err.getFields()
                        );
                    }
                }
            }
        }
    }

    public void processResult() {
    }

    public void processScopeResult() {
    }
}
