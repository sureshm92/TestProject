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
    //Use semicolon separated value for multiple types
    @AuraEnabled
    public static ResourceService.ResourceWrapperContainer getUnsortedResourcesByType(
        String resourceType,
        String participantData
    ) {
        try {
            ResourceService.ResourceWrapperContainer resourceWrapperContainer = resourceType.equalsIgnoreCase(
                    ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT
                )
                ? getStudyDocuments()
                : ResourceArticleVideoService.getInstance()
                      .ppInit(resourceType, participantData)
                      .getResourceWrapperContainer();
            return resourceWrapperContainer;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static ResourceService.ResourceWrapperContainer getPastStudyResources(
        String resourceType,
        String participantData,
        Id peId
    ) {
        try {
            String queryString =
            'SELECT '+
            'id ,'+
            'Enrolled_DateTime__c ,'+
            'Participant_Status__c ,'+
            'Days_After_Enrolled__c ,'+
            'Study_Site__r.Principal_Investigator__r.Name ,'+
            'Study_Site__r.Site__r.Name ,'+
            'Clinical_Trial_Profile__c ,'+
            'Clinical_Trial_Profile__r.Profile_Picture__c ,'+
            'Clinical_Trial_Profile__r.Study_Code_Name__c ,'+
            'Clinical_Trial_Profile__r.Detailed_Description__c ,'+
            'Clinical_Trial_Profile__r.Study_Documents_Are_Available__c ,'+
            'Clinical_Trial_Profile__r.Visit_Data_Shareback__c ,'+
            'Study_Site__r.Messages_Are_Available__c ,'+
            'Study_Site__r.Study_Site_Phone__c ,'+
            'Study_Site__r.Study_Site_Email__c ,'+
            'Study_Site__r.Approved_Lng__c ,'+
            'Study_Site__r.Override_PI_Referral_Status__c ,'+
            'Study_Site__r.Site__r.BillingCountryCode '+
            'FROM Participant_Enrollment__c '+
            'WHERE Id =: peId ';
            Participant_Enrollment__c  alumiPer =  Database.query(queryString);
            ResourceService.ResourceWrapperContainer resourceWrapperContainer = resourceType.equalsIgnoreCase(
                    ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT
                )
                ? getPastStudyDocuments(alumiPer)
                : ResourceArticleVideoService.getInstance()
                      .ppInit(resourceType, participantData)
                      .getResourceWrapperContainer();
            return resourceWrapperContainer;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static ResourceService.ResourceWrapperContainer getArticleAndVideos(
        String participantData
    ) {
        try {
            ResourceService.ResourceWrapperContainer resourceWrapperContainer = getUnsortedResourcesByType(
                'Article;Video',
                participantData
            );
            resourceWrapperContainer.wrappers = ResourceService.sortResourcesByCOI(
                resourceWrapperContainer.wrappers
            );
            /**Separate Study and Platform Level Resources*/
            resourceWrapperContainer.wrappers = ResourceService.sortResourcesByType(
                resourceWrapperContainer.wrappers
            );

            return resourceWrapperContainer;
        } catch (Exception e) {
            return (ResourceService.ResourceWrapperContainer) AuraHelper.throwException(e);
        }
    }
    @AuraEnabled
    public static UpdateWrapper getUpdateResources(String linkWrapperText, String participantData) {
        //get all resources //get counter // send wrapper // check for toggles for participant
        try {
            Integer counter = 0;
            //Relevant links data
            RelevantLinksRemote.DataWrapper linkWrapper = (RelevantLinksRemote.DataWrapper) JSON.deserialize(
                linkWrapperText,
                RelevantLinksRemote.DataWrapper.class
            );
            List<ResourceService.ResourceWrapper> resUpdates = linkWrapper?.resources;

            //Article/Video Data
            //for delegate in participant view
            if (
                linkWrapper.isDelegate &&
                linkWrapper.participantStateValue ==
                String.valueOf(ParticipantService.ParticipantStates.ALUMNI)
            ) {
                if (linkWrapper.VideoAndArticlesAreAvailable) {
                    ResourceService.ResourceWrapperContainer contExplore = getUnsortedResourcesByType(
                        'Article;Video;Multimedia',
                        participantData
                    );

                    resUpdates.addAll(contExplore.wrappers);
                }
            } else if (
                linkWrapper.participantStateValue ==
                String.valueOf(ParticipantService.ParticipantStates.ALUMNI)
            ) {
                //for delegate and alumni view
                ResourceService.ResourceWrapperContainer contExplore = getUnsortedResourcesByType(
                    'Article;Video;Multimedia',
                    participantData
                );

                resUpdates.addAll(contExplore.wrappers);
            } else if (linkWrapper.VideoAndArticlesAreAvailable) {
                //for participant view
                ResourceService.ResourceWrapperContainer contExplore = getUnsortedResourcesByType(
                    'Article;Video;Multimedia',
                    participantData
                );

                resUpdates.addAll(contExplore.wrappers);
            }

            //Documents Data
            if (linkWrapper.StudyDocumentsAreAvailable) {
                ResourceService.ResourceWrapperContainer contDocs = ResourceStudyDocumentService.getInstance()
                    .ppInit(
                        ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT,
                        participantData
                    )
                    .getResourceWrapperContainer();
                contDocs.wrappers = ResourceService.removeTranslations(contDocs.wrappers);

                resUpdates.addAll(contDocs.wrappers);
            }

            if (resUpdates.size() > 0) {
                resUpdates = ResourceService.sortResourcesByCreatedDate(resUpdates);
                resUpdates = ResourceService.sortUpdateResourcesByCOI(resUpdates);
                if (
                    linkWrapper.participantStateValue !=
                    String.valueOf(ParticipantService.ParticipantStates.ALUMNI) ||
                    !linkWrapper.isDelegate
                ) {
                    counter = ResourceService.getUpdatesCounter(resUpdates);
                }
            }
            UpdateWrapper up = new UpdateWrapper();
            up.resources = resUpdates;
            up.counter = counter;

            return up;
        } catch (Exception e) {
            return (UpdateWrapper) AuraHelper.throwException(e);
        }
    }
    @AuraEnabled
    public static ResourceService.ResourceWrapperContainer getMultimediaResources(
        String linkWrapperText,
        String participantData
    ) {
        try {
            ResourceService.ResourceWrapperContainer resourceWrapperContainer = getUnsortedResourcesByType(
                'Multimedia',
                participantData
            );
            resourceWrapperContainer.wrappers = ResourceService.sortResourcesByCOI(
                resourceWrapperContainer.wrappers
            );
            /**Separate Study and Platform Level Resources*/
            resourceWrapperContainer.wrappers = ResourceService.sortResourcesByType(
                resourceWrapperContainer.wrappers
            );

            return resourceWrapperContainer;
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
    public static ResourceService.ResourceWrapperContainer getPastStudyDocuments(Participant_Enrollment__c pe) {
        try {
            ResourceService.ResourceWrapperContainer resourceWrapperContainer = ResourceStudyDocumentService.getInstance()
            .init(ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT)
            .getResourceWrapperContainer(pe);
            resourceWrapperContainer.wrappers = ResourceService.sortResourcesByCOI(
                    resourceWrapperContainer.wrappers
                );
            resourceWrapperContainer.wrappers = ResourceService.removeTranslations(resourceWrapperContainer.wrappers);
            return resourceWrapperContainer;
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
    public class UpdateWrapper {
        @AuraEnabled
        public Integer counter = 0;
        @AuraEnabled
        public List<ResourceService.ResourceWrapper> resources = new List<ResourceService.ResourceWrapper>();
    }
}
