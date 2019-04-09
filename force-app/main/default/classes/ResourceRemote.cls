public with sharing class ResourceRemote {
    @TestVisible
    private static String RESOURCE_TEST_ID = 'a0I4E0000000000000';
    @TestVisible
    private static String PARTICIPANT_TEST_ID = 'a0D4E0000000000000';

    @AuraEnabled
    public static ResourceService.ResourceWrapperContainer getResources(String resourceType, String resourceMode) {

        try {
            ResourceService resourceService = (ResourceService) ClassFactory.newInstance(ResourceService.class);
            if ('Favorite'.equalsIgnoreCase(resourceMode)) {
                return resourceService.getFavoriteResources(resourceType);
            } else {
                return resourceService.getResources(resourceType);
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static void setResourceAction(String resourceId, Boolean isFavorite, Boolean isVoted) {

        try {
            CommunityService cService = (CommunityService) ClassFactory.newInstance(CommunityService.class);
            String participantId = cService.getParticipantId();
            String resourceActionQuery =
                    'SELECT Id, ' +
                            'IsFavorite__c, ' +
                            'IsVoted__c ' +
                            'FROM Resource_Action__c ' +
                            'WHERE Resource__c = \'' + resourceId + '\'' + ' AND Participant__c = \'' + participantId + '\'';
            DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
            List<Resource_Action__c> actions = (List<Resource_Action__c>) databaseProxy.query(resourceActionQuery);
            Resource_Action__c action = !actions.isEmpty() ? actions[0] : new Resource_Action__c(Resource__c = resourceId, Participant__c = participantId);
            action.IsFavorite__c = isFavorite;
            action.IsVoted__c = isVoted;
            databaseProxy.upsertRecord(action);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getTrialId(String userMode) {

        try {
            String trialId;
            ResourceService resourceService = (ResourceService) ClassFactory.newInstance(ResourceService.class);
            ParticipantService.ParticipantState state = resourceService.getParticipantState();
            if (state.ctp != null) {
                trialId = state.ctp.Id;
            } else {
                throw new CommunityServiceException(CommunityService.ERROR_MISSING_STUDY);
            }
            return trialId;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static String getNoTAMessage() {

        try {
            ResourceService resourceService = (ResourceService) ClassFactory.newInstance(ResourceService.class);
            ParticipantService.ParticipantState state = resourceService.getParticipantState();
            if ((state.value == ParticipantService.ParticipantStates.ALUMNI) && (state.participant.Conditions__c == 0)) {
                String noTAMessage;
                String message = Label.Resources_No_Therapeutic_Area;
                String goToProfile = '<br /><a href="/s/settings?tab=account-settings">' + Label.Resources_Go_To_Your_Profile + '</a>';
                noTAMessage = String.format(message, new List<String>{
                        goToProfile
                });
                return noTAMessage;
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }
}