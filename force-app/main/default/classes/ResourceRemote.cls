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
            if (!actions.isEmpty()) {
                action = actions[0];
            } else {
                action = new Resource_Action__c(Resource__c = resourceId, Participant__c = participantId);
            }
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
            if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
                List<Participant_Enrollment__c> peList = ParticipantEnrollmentService.getParticipantEnrollmentsForParticipant();
                if (peList.size() > 0) {
                    trialId = peList[0].Study_Site__r.Clinical_Trial_Profile__c;
                }
            }
            if (String.isBlank(trialId)) {
                throw new CommunityServiceException(CommunityService.ERROR_MISSING_STUDY);
            }
            return trialId;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static List<String> getNoTAMessage() {
        List<String> noTAMessage = new List<String>();
        ResourceService resourceService = (ResourceService) ClassFactory.newInstance(ResourceService.class);
        Participant__c currentParticipant = resourceService.getParticipant();
        if(currentParticipant.Conditions__c == 0) {
            String message = Label.Resources_No_Therapeutic_Area;
            noTAMessage.add(message.substringBefore('{'));
            noTAMessage.add(message.substringBetween('{', '}'));
            noTAMessage.add(message.substringAfter('}'));
            return noTAMessage;
        }
        return null;
    }
}