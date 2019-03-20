public class ResourceDecoupler {

    @TestVisible
    private static Map<Id, List<Resource_Action__c>> resourceActionsByResourceIds = new Map<Id, List<Resource_Action__c>>();

    public static List<Resource_Action__c> getResourceActions(Resource__c resource) {
        return resourceActionsByResourceIds.get(resource.Id) == null ?
                resource.Resource_Actions__r :
                resourceActionsByResourceIds.get(resource.Id);
    }
}