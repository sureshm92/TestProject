public with sharing class ResourceRemote {

    @AuraEnabled
    public static ResourceService.ResourceWrapperContainer getResources(String resourceType, String resourceMode) {
        try {
            ResourceDelegate rDelegate = ResourceDelegate.getInstance();
            if (resourceMode.equalsIgnoreCase('Favorite')) {
                return rDelegate.getFavoriteResources(resourceType);
            } else {
                return rDelegate.getResources(resourceType);
            }
        } catch (Exception e) {
            return (ResourceService.ResourceWrapperContainer) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static ResourceService.ResourceWrapperContainer getStudyDocuments() {
        try {
            ResourceService.ResourceWrapperContainer cont = ResourceDelegate.getInstance().getStudyDocuments();
            cont.wrappers = ResourceService.removeTranslations(cont.wrappers);
            return cont;
        } catch (Exception e) {
            return (ResourceService.ResourceWrapperContainer) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void setResourceAction(String resourceId, Boolean isFavorite, Boolean isVoted) {
        try {
            String participantId = ParticipantService.getInstance().getState().participant.Id;
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
            ParticipantService.ParticipantState state = ParticipantService.getInstance().getState();
            if (state.ctp != null) {
                trialId = state.ctp.Id;
            } else {
                return null;
            }
            return trialId;
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getNoTAMessage() {
        try {
            ParticipantService.ParticipantState state = ParticipantService.getInstance().getState();
            if ((state.value == ParticipantService.ParticipantStates.ALUMNI) && (state.participant.Conditions__c == 0)) {
                String message = Label.PP_Customize_Exp_Description;
                return message;
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }
}