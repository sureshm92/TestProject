/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class ResourceExpirationBatchHandlerImpl implements BatchHandler{


    public void handle(List<SObject> scope) {
        if (!scope.isEmpty()) {
            Database.DeleteResult[] deleteResult = Database.delete(scope, false);
            for (Database.DeleteResult result: deleteResult) {
                if (!result.isSuccess()) {
                    for(Database.Error err : result.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Resource fields that affected this error: ' + err.getFields());
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