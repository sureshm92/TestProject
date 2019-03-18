public class ResourceDecoupler {

    @TestVisible
    private static Map<Id, List<Resource_Action__c>> resourceActionsByIds = new Map<Id, List<Resource_Action__c>>();

    public static List<Resource_Action__c> getResourceActions(Resource__c resource) {
        return resourceActionsByIds.get(resource.Id) == null ? resource.Resource_Actions__r : resourceActionsByIds.get(resource.Id);
    }
}