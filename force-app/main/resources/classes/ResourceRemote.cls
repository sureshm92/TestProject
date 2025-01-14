public without sharing class ResourceRemote {
    @AuraEnabled
    public static ResourceService.ResourceWrapperContainer getResources(
        String resourceType,
        String resourceMode
    ) {
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
            ResourceService.ResourceWrapperContainer cont = ResourceDelegate.getInstance()
                .getStudyDocuments();
            cont.wrappers = ResourceService.removeTranslations(cont.wrappers);
            return cont;
        } catch (Exception e) {
            return (ResourceService.ResourceWrapperContainer) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void setResourceAction(String resourceId, Boolean isFavorite, Boolean isVoted) {
        try {
            Participant__c participant = ParticipantService.getInstance().getState().participant;
            String resourceActionQuery;
            if (participant != null && participant.Id != null) {
                resourceActionQuery =
                    'SELECT Id, ' +
                    'IsFavorite__c, ' +
                    'IsVoted__c ' +
                    'FROM Resource_Action__c ' +
                    'WHERE Resource__c = \'' +
                    resourceId +
                    '\'' +
                    ' AND Participant__c = \'' +
                    participant.Id +
                    '\'';
            } else {
                resourceActionQuery =
                    'SELECT Id, ' +
                    'IsFavorite__c, ' +
                    'IsVoted__c ' +
                    'FROM Resource_Action__c ' +
                    'WHERE Resource__c = \'' +
                    resourceId +
                    '\'';
            }
            DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(
                DatabaseProxy.class
            );
            List<Resource_Action__c> actions = (List<Resource_Action__c>) databaseProxy.query(
                resourceActionQuery,
                true
            );
            Resource_Action__c action = !actions.isEmpty()
                ? actions[0]
                : new Resource_Action__c(Resource__c = resourceId, Participant__c = participant.Id);
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
            if (
                (state.value == ParticipantService.ParticipantStates.ALUMNI) &&
                (state.participant.Conditions__c == 0)
            ) {
                String message = Label.PP_Customize_Exp_Description;
                return message;
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }
    @AuraEnabled
    public static Boolean hasCois() {
        Boolean hasCoi = true;
        ParticipantService.ParticipantState state = ParticipantService.getInstance().getState();
        Participant__c participant = PatientDelegateService.getParticipantByDelegateContactId(
            CommunityService.getUserContact().Id
        );
        if (state.participant.Conditions__c == 0 && participant != null) {
            hasCoi = false;
            return hasCoi;
        }
        return hasCoi;
    }
    @AuraEnabled
    public static void createArticlesSubmitted(String url) {
        ParticipantService.ParticipantState state = ParticipantService.getInstance().getState();
        RecordType rt = [
            SELECT Id, DeveloperName
            FROM RecordType
            WHERE DeveloperName = 'Submitted_Articles'
        ];
        List<Resource__c> submittedArticles = new List<Resource__c>();
        Resource__c res = new Resource__c();
        res.article_external_link__c = url;
        res.RecordTypeId = rt.Id;
        res.Submitted_By__c = state.participant.Id;
        submittedArticles.add(res);
        if (!submittedArticles.isEmpty())
            insert submittedArticles;
    }
}
