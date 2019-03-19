public with sharing class ResourceRemote {
    @TestVisible
    private static String RESOURCE_TEST_ID = 'a0I4E0000000000000';
    @TestVisible
    private static String PARTICIPANT_TEST_ID = 'a0D4E0000000000000';

    @AuraEnabled
    public static ResourceService.ResourceWrapperContainer getResources(String resourceType, String resourceMode) {

        ResourceService resourceService = (ResourceService) ClassFactory.newInstance(ResourceService.class);
        if ('Favorite'.equalsIgnoreCase(resourceMode)) {
            return resourceService.getFavoriteResources(resourceType);
        } else {
            return resourceService.getResources(resourceType);
        }
    }

    @AuraEnabled
    public static void setResourceAction(String resourceId, Boolean isFavorite, Boolean isVoted) {

        String participantId = (Test.isRunningTest() ? PARTICIPANT_TEST_ID : CommunityService.getParticipantId());
        String resourceActionQuery =
                'SELECT Id, ' +
                        'IsFavorite__c, ' +
                        'IsVoted__c ' +
                        'FROM Resource_Action__c ' +
                        'WHERE Resource__c = \'' + resourceId + '\'' + ' AND Participant__c = \'' + participantId + '\'';
        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        List<Resource_Action__c> actions = (List<Resource_Action__c>) databaseProxy.query(resourceActionQuery);

        Resource_Action__c action;
        if (actions.size() == 1) {
            action = actions[0];
        } else if (actions.isEmpty()) {
            action = new Resource_Action__c(Resource__c = resourceId, Participant__c = participantId);
        } else {
            //todo add logic for logging these kind of exceptions, where a participant has more than one junction to the same resource
        }
        action.IsFavorite__c = isFavorite;
        action.IsVoted__c = isVoted;
        databaseProxy.upsertRecord(action);
    }
}