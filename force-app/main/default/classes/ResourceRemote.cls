public with sharing class ResourceRemote {

    @AuraEnabled
    public static ResourceService.ResourceWrapperContainer getResources(String resourceType, String resourceMode) {

        try {
            ResourceDelegate rDelegate = (ResourceDelegate) ClassFactory.newInstance(ResourceDelegate.class);
            if ('Favorite'.equalsIgnoreCase(resourceMode)) {
                return rDelegate.getFavoriteResources(resourceType);
            } else {
                return rDelegate.getResources(resourceType);
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static ResourceService.ResourceWrapperContainer getStudyDocuments() {

        try {
            return ((ResourceDelegate) ClassFactory.newInstance(ResourceDelegate.class)).getStudyDocuments();
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static void setResourceAction(String resourceId, Boolean isFavorite, Boolean isVoted) {

        try {
            String participantId = ((ResourceService) ClassFactory.newInstance(ResourceService.class)).getParticipantId();
            String resourceActionQuery =
                    'SELECT Id, ' +
                            'IsFavorite__c, ' +
                            'IsVoted__c ' +
                            'FROM Resource_Action__c ' +
                            'WHERE Resource__c = \'' + resourceId + '\'' + ' AND Participant__c = \'' + participantId + '\'';
            DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
            List<Resource_Action__c> actions = (List<Resource_Action__c>) databaseProxy.query(resourceActionQuery, true);
            Resource_Action__c action = !actions.isEmpty() ? actions[0] : new Resource_Action__c(Resource__c = resourceId, Participant__c = participantId);
            action.IsFavorite__c = isFavorite;
            action.IsVoted__c = isVoted;
            databaseProxy.upsertRecord(action, true);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getTrialId() {

        try {
            String trialId;
            ParticipantService.ParticipantState state = ((ResourceService) ClassFactory.newInstance(ResourceService.class)).getParticipantState();
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
            ParticipantService.ParticipantState state = ((ResourceService) ClassFactory.newInstance(ResourceService.class)).getParticipantState();
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