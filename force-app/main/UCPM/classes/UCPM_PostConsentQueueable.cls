public with sharing class UCPM_PostConsentQueueable implements Queueable, Database.AllowsCallouts {
    String requestJSON;
    String accessToken;
    Participant_Enrollment__c per;
    List<Patient_Delegate_Enrollment__c> pDelEnrol;
    Boolean iqviaOutreach;
    String IdentityType;
    String operationtype;
    String conditionOperator;
    String createtypeIdentity;
    String createconditionOperator;
    String updatetypeIdentity;
    String updateconditionOperator;
    String createrequestJSON;
    String updaterequestJSON;
    string placeofFunctionality;
    // For two operations(Create,Update) same time
    public UCPM_PostConsentQueueable(
        Participant_Enrollment__c perRec,
        List<Patient_Delegate_Enrollment__c> pDelEnrols,
        String typeOperation,
        Boolean iqviaOutreachcheck,
        String createtypeIdentities,
        String createconditionsOperator,
        String updatetypeIdentities,
        String updateconditionOperators,
        String functionalityPlace){
        per = perRec;
        pDelEnrol = pDelEnrols;
        operationtype = typeOperation;
        iqviaOutreach = iqviaOutreachcheck;
        createtypeIdentity = createtypeIdentities;
        createconditionOperator = createconditionsOperator;
        updatetypeIdentity = updatetypeIdentities;
        updateconditionOperator = updateconditionOperators;
        placeofFunctionality = functionalityPlace;
        if (operationtype == 'Both') {
            createrequestJSON = UCPM_ConsentPostController.requestJsonGeneration_Create(
                per,
                pDelEnrol,
                iqviaOutreach,
                createconditionsOperator,
                placeofFunctionality
            );
            updaterequestJSON = UCPM_ConsentPostController.requestJsonGeneration_update(
                per,
                pDelEnrol,
                iqviaOutreach,
                updateconditionOperators,
                placeofFunctionality
            );
        }
    }
    // For one operation either create/update 
    public UCPM_PostConsentQueueable(
        Participant_Enrollment__c perRec,
        List<Patient_Delegate_Enrollment__c> pDelEnrols,
        String typeOperation,
        Boolean iqviaOutreachcheck,
        String typeIdentity,
        String conditionOperatorcheck,
        String functionalityPlace){
        per = perRec;
        pDelEnrol = pDelEnrols;
        IdentityType = typeIdentity;
        operationtype = typeOperation;
        iqviaOutreach = iqviaOutreachcheck;
        conditionOperator = conditionOperatorcheck;
        placeofFunctionality = functionalityPlace;
        if (operationtype == 'Create') {
            requestJSON = UCPM_ConsentPostController.requestJsonGeneration_Create(
                per,
                pDelEnrol,
                iqviaOutreach,
                conditionOperator,
                placeofFunctionality
            );
        } else if (operationtype == 'Update') {
            requestJSON = UCPM_ConsentPostController.requestJsonGeneration_Update(
                per,
                pDelEnrol,
                iqviaOutreach,
                conditionOperator,
                placeofFunctionality
            );
        }
    }

    public void execute(QueueableContext context){
        if (
            String.isblank(requestJSON) ||
            String.isblank(createrequestJSON) ||
            String.isblank(updaterequestJSON)
        ) {
            if (operationtype == 'Create') {
                requestJSON = UCPM_ConsentPostController.requestJsonGeneration_Create(
                    per,
                    pDelEnrol,
                    iqviaOutreach,
                    conditionOperator,
                    placeofFunctionality
                );
            } else if (operationtype == 'Update') {
                requestJSON = UCPM_ConsentPostController.requestJsonGeneration_Update(
                    per,
                    pDelEnrol,
                    iqviaOutreach,
                    conditionOperator,
                    placeofFunctionality
                );
            } else if (operationtype == 'Both') {
                createrequestJSON = UCPM_ConsentPostController.requestJsonGeneration_Create(
                    per,
                    pDelEnrol,
                    iqviaOutreach,
                    createconditionOperator,
                    placeofFunctionality
                );
                updaterequestJSON = UCPM_ConsentPostController.requestJsonGeneration_update(
                    per,
                    pDelEnrol,
                    iqviaOutreach,
                    updateconditionOperator,
                    placeofFunctionality
                );
            }
        }
        accessToken = UCPM_ConsentPostController.getAccessToken();
        if (
            operationtype == 'Both' &&
            !String.isblank(createrequestJSON) &&
            !String.isblank(updaterequestJSON)
        ) {
            UCPM_ConsentPostController.callUCPMtoPostConsents(
                createrequestJSON,
                accessToken,
                createtypeIdentity
            );
            UCPM_ConsentPostController.callUCPMtoupdateConsents(
                updaterequestJSON,
                accessToken,
                updatetypeIdentity
            );
        } else if (operationtype == 'Create' && !String.isblank(requestJSON)) {
            UCPM_ConsentPostController.callUCPMtoPostConsents(
                requestJSON,
                accessToken,
                IdentityType
            );
        } else if (operationtype == 'Update' && !String.isblank(requestJSON)) {
            UCPM_ConsentPostController.callUCPMtoupdateConsents(
                requestJSON,
                accessToken,
                IdentityType
            );
        }
    }
}