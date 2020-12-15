/**
 * Created by Nikita Abrazhevitch on 05-Sep-19.
 */

public without sharing class ParticipantInformationRemote {
    @AuraEnabled
    public static AddPatientByPIRemote.FormData getInitData() {
        try {
            AddPatientByPIRemote.FormData formData = AddPatientByPIRemote.getInitData(null);
            return formData;
        } catch (Exception e) {
            return (AddPatientByPIRemote.FormData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getSteps(String peId, String userMode, String delegateId) {
        try {
            String steps = ReferralProfileRemote.getReferralProfileDetail(
                peId,
                userMode,
                delegateId
            );
            return steps;
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getPrintInformation(String peId, String userMode, String delegateId) {
        try {
            Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(
                peId,
                userMode,
                delegateId
            );
            ParticipantItem pi = new ParticipantItem(pe);
            ParticipantWorkflowService.populatePatientItemsWithPathWrappers(
                new List<ParticipantItem>{ pi }
            );
            pi.pe.Participant_Status__c = TranslateHelper.getPickListLabel(
                Participant_Enrollment__c.Participant_Status__c,
                pi.pe.Participant_Status__c
            );
            return JSON.serialize(pi);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static Participant__c getDelegates(String participantId) {
        List<Participant__c> delegates = [
            SELECT Id, First_Name__c, Last_Name__c, Phone__c
            FROM Participant__c
            WHERE
                Contact__c IN (
                    SELECT Contact__c
                    FROM Patient_Delegate__c
                    WHERE
                        Participant__c = :participantId
                        AND Status__c = :PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS
                )
        ];
        if (!delegates.isEmpty()) {
            return delegates[0];
        } else {
            return null;
        }
    }

    /**
     * This method is created to accomodate the requirements of REF-1192
     * It calls getSteps(String, String, String) and
     * getPrintInformation(String, String, String) returns the combined
     * return value of these methods
     * @param peId Participant_Enrollment__c.Id
     * @param userMode in String
     * @param delegateId in String
     * @return ParticipantItemWithSteps in JSON String format.
     * @exception AuraHandledException to community UI
     * @see AuraHandledException
     */
    @AuraEnabled
    public static String getPrintInfoWithSteps(String peId, String userMode, String delegateId) {
        try {
            ParticipantItemWithSteps itemSteps = new ParticipantItemWithSteps();

            itemSteps.participantItem = getPrintInformation(peId, userMode, delegateId);
            itemSteps.initData = getSteps(peId, userMode, delegateId);

            return JSON.serialize(itemSteps);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static PIDelegateLevelInfo checkPILevelI(String studySiteId) {
        PIDelegateLevelInfo levelInfo = new PIDelegateLevelInfo();
        levelInfo.isDisabled = DelegateService.DELEGATE_LEVEL_2_AND_LOW.contains(
            DelegateService.getPIStudySitesAccessLevelMap().get(studySiteId)
        );

        return levelInfo;
    }

    @AuraEnabled
    public static void updatePatientInfo(String participantJSON, String peJSON) {
        AddPatientByPIRemote.updatePatientInfo(participantJSON, peJSON);
    }

    @AuraEnabled
    public static Participant_Enrollment__c updatePatientInfoWithDelegate(
        String participantJSON,
        String peJSON,
        String delegateJSON,
        String userInfoJSON
    ) {
        Participant_Enrollment__c pe = AddPatientByPIRemote.updatePatientInfo(
            participantJSON,
            peJSON
        );
        Participant__c part = [
            SELECT Id, Adult__c, Emancipation_in_progress__c
            FROM Participant__c
            WHERE Id = :pe.Participant__c
        ];
        pe.Participant__r.Adult__c = part.Adult__c;
        pe.Participant__r.Emancipation_in_progress__c = part.Emancipation_in_progress__c;

        if (!String.isBlank(delegateJSON)) {
            Participant__c delegateParticipant = (Participant__c) JSON.deserialize(
                delegateJSON,
                Participant__c.class
            );
            if (delegateParticipant != null && !String.isBlank(delegateParticipant.Id)) {
                try {
                    update delegateParticipant;
                } catch (Exception exp) {
                    system.debug('No delegate was provided');
                }
            }
        }
        updateUserLanguage(userInfoJSON);
        return pe;
    }

    @AuraEnabled
    public static List<User> createUserForPatientProtal(String peJSON, Boolean sendEmails) {
        Participant_Enrollment__c pe = (Participant_Enrollment__c) JSON.deserialize(
            peJSON,
            Participant_Enrollment__c.class
        );
        if (sendEmails) {
            update new Contact(
                Id = pe.Participant_Contact__c,
                Consent_To_Inform_About_Study__c = true
            );
        }
        try {
            List<User> returnUsers = new List<User>();
            if (pe.HCP_Contact__c == null) {
                returnUsers = ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                    .createParticipantUsers(
                        new Map<Id, Id>{ pe.Participant_Contact__c => pe.PI_Contact__c }
                    );
            } else {
                returnUsers = ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                    .createParticipantUsers(
                        new Map<Id, Id>{ pe.Participant_Contact__c => pe.HCP_Contact__c }
                    );
            }

            Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
            String permissionSetName = CommunityTemplateService.getTemplate(
                    pe.Clinical_Trial_Profile__r.CommunityTemplate__c
                )
                .permissionSet;
            actionAssignContactPermissions.addPermission(
                pe.Participant_Contact__c,
                permissionSetName
            );
            if (!actionAssignContactPermissions.isEmpty()) {
                ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
            }
            return returnUsers;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static ReferHealthcareProviderRemote.HealthcareProvider checkDelegateDuplicate(
        String email,
        String firstName,
        String lastName,
        String participantId
    ) {
        return ReferHealthcareProviderRemote.checkDuplicate(
            null,
            email,
            firstName,
            lastName,
            participantId
        );
    }

    @AuraEnabled
    public static DelegateConnectedInfo connectDelegateToPatient(
        String participantS,
        String delegateS,
        String studySiteId,
        Boolean isConnected,
        String duplicateDelegateInfo,
        Boolean NoInvite
    ) {
        DelegateConnectedInfo isConnectedRes = new DelegateConnectedInfo();
        isConnectedRes.isConnected = isConnected;

        try {
            ReferHealthcareProviderRemote.HealthcareProvider ddi = (ReferHealthcareProviderRemote.HealthcareProvider) JSON.deserialize(
                duplicateDelegateInfo,
                ReferHealthcareProviderRemote.HealthcareProvider.class
            );
            Participant__c participant = (Participant__c) JSON.deserialize(
                participantS,
                Participant__c.class
            );
            Participant__c delegateParticipant = (Participant__c) JSON.deserialize(
                delegateS,
                Participant__c.class
            );
            isConnectedRes.contactId = delegateParticipant.Contact__c;
            Map<Id, Id> toCreateUser = new Map<Id, Id>();
            List<Patient_Delegate__c> patientDelegatesToInsert = new List<Patient_Delegate__c>();
            Contact delegateContact;
            Boolean userNotExists = false;

            if (String.isBlank(delegateParticipant.Contact__c) && String.isBlank(ddi.contactId)) {
                /*ParticipantDuplicateService duplicateService = new ParticipantDuplicateService(new List<Participant__c>{
                        delegateParticipant
                });*/

                delegateContact = new Contact(
                    AccountId = [SELECT Site__c, Id FROM Study_Site__c WHERE Id = :studySiteId]
                    .Site__c,
                    MailingState = delegateParticipant.Mailing_State__c,
                    MailingCountry = delegateParticipant.Mailing_Country__c,
                    MailingStateCode = delegateParticipant.Mailing_State_Code__c,
                    MailingCountryCode = delegateParticipant.Mailing_Country_Code__c,
                    MailingPostalCode = delegateParticipant.Mailing_Zip_Postal_Code__c,
                    FirstName = delegateParticipant.First_Name__c,
                    LastName = delegateParticipant.Last_Name__c,
                    Email = delegateParticipant.Email__c,
                    Language__c = UserInfo.getLanguage(),
                    Second_Choice_Language__c = '',
                    Third_Choice_Language__c = '',
                    userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT,
                    userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
                    userCommunityIsDelegate__c = true
                );
                /*if (duplicateService.findDuplicateContact(delegateParticipant) != null) {
                    delegateContact.Id = duplicateService.findDuplicateContact(delegateParticipant).Id;
                } else if (!String.isBlank(delegateParticipant.Contact__c)) {
                    delegateContact.Id = delegateParticipant.Contact__c;
                }*/
                insert delegateContact;
            } else {
                delegateContact = new Contact(Id = ddi.contactId);
            }

            List<Patient_Delegate__c> patientDelegatesEver = [
                SELECT Id, Participant__c, Contact__c, Status__c
                FROM Patient_Delegate__c
                WHERE Participant__c = :participant.Id AND Contact__c = :delegateContact.Id
            ];
            userNotExists = patientDelegatesEver.isEmpty();

            if (patientDelegatesEver.isEmpty() && !isConnected) {
                patientDelegatesToInsert.add(
                    new Patient_Delegate__c(
                        Participant__c = participant.Id,
                        Contact__c = delegateContact.Id,
                        Status__c = PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS
                    )
                );
                toCreateUser.put(delegateContact.Id, null);
                isConnectedRes.isConnected = true;
            } else {
                for (Patient_Delegate__c ptDelegate : patientDelegatesEver) {
                    if (!String.isBlank(ptDelegate.Id)) {
                        ptDelegate.Status__c = isConnected
                            ? PatientDelegateTriggerHandler.PATIENT_DELEGATE_DISCONNECTED_STATUS
                            : PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS;
                        patientDelegatesToInsert.add(ptDelegate);
                        isConnectedRes.isConnected = !isConnected;
                    }
                }
            }

            if (String.isBlank(delegateParticipant.Contact__c)) {
                delegateParticipant.Contact__c = delegateContact.Id;
                isConnectedRes.contactId = delegateContact.Id;
            }
            if (String.isBlank(delegateParticipant.Phone__c)) {
                delegateParticipant.Phone__c = participant.Phone__c;
                delegateParticipant.Phone_Type__c = participant.Phone_Type__c;
            }
            if (!String.isBlank(ddi.participantId)) {
                delegateParticipant.Id = ddi.participantId;
            }
            upsert delegateParticipant;
            isConnectedRes.participantId = delegateParticipant.Id;

            if (!patientDelegatesToInsert.isEmpty()) {
                upsert patientDelegatesToInsert;
            }
            if (String.isBlank(ddi.contactId) && NoInvite == false) {
                createCommunityUser(toCreateUser, userNotExists);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }

        return isConnectedRes;
    }

    @Future
    private static void createCommunityUser(Map<Id, Id> toCreateUser, Boolean userNotExists) {
        if (!toCreateUser.isEmpty() && userNotExists)
            ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                .createParticipantUsers(toCreateUser);
    }

    @AuraEnabled
    public static void updateParticipantAndDelegates(
        String participantS,
        String participantContactS,
        String delegatesS,
        List<String> doNotContinueIds,
        Boolean needsInvite,
        String studySiteId
    ) {
        try {
            Participant__c participant = (Participant__c) JSON.deserialize(
                participantS,
                Participant__c.class
            );
            Contact participantContact = (Contact) JSON.deserialize(
                participantContactS,
                Contact.class
            );
            List<Participant__c> delegates = (List<Participant__c>) JSON.deserialize(
                delegatesS,
                List<Participant__c>.class
            );

            Study_Site__c studySite = StudySiteService.getStudySiteForPIById(studySiteId);
            Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
            String permissionSetName = CommunityTemplateService.getTemplate(
                    studySite.Clinical_Trial_Profile__r.CommunityTemplate__c
                )
                .permissionSet;

            system.debug('Participant__c: ' + participant);
            system.debug('Contact: ' + participantContact);
            system.debug('List<Participant__c>: ' + delegates);
            system.debug('List<Id>: ' + doNotContinueIds);
            system.debug('Boolean: ' + needsInvite);

            update participant;
            if (participantContact.Id != null) {
                participantContact.Email = participant.Email__c;
                if (participant.Phone_Type__c == 'Home') {
                    participantContact.HomePhone = participant.Phone__c;
                }
                if (participant.Phone_Type__c == 'Mobile') {
                    participantContact.MobilePhone = participant.Phone__c;
                } else {
                    participantContact.Phone = participant.Phone__c;
                }
                update participantContact;
            }

            Map<Id, Id> toCreateUser = new Map<Id, Id>();
            if (needsInvite) {
                system.debug('needsInvite: ' + needsInvite);
                toCreateUser.put(participant.Contact__c, null);
                actionAssignContactPermissions.addPermission(
                    participant.Contact__c,
                    permissionSetName
                );
            }

            Set<String> idsToCheck = new Set<String>(doNotContinueIds);
            List<Patient_Delegate__c> patientDelegates = [
                SELECT Id, Participant__c, Contact__c, Status__c
                FROM Patient_Delegate__c
                WHERE
                    Participant__c = :participant.Id
                    AND Status__c != :PatientDelegateTriggerHandler.PATIENT_DELEGATE_DISCONNECTED_STATUS
            ];
            Map<Id, Patient_Delegate__c> patientDelegateByDelegate = new Map<Id, Patient_Delegate__c>();
            List<Patient_Delegate__c> delegatesToUpdate = new List<Patient_Delegate__c>();
            if (!patientDelegates.isEmpty()) {
                system.debug('patientDelegates: ' + patientDelegates);
                for (Patient_Delegate__c patientDelegate : patientDelegates) {
                    if (
                        idsToCheck.contains(patientDelegate.Contact__c) &&
                        PatientDelegateTriggerHandler.PATIENT_DELEGATE_DISCONNECTED_STATUS !=
                        patientDelegate.Status__c
                    ) {
                        patientDelegate.Status__c = PatientDelegateTriggerHandler.PATIENT_DELEGATE_DISCONNECTED_STATUS;
                        delegatesToUpdate.add(patientDelegate);
                    }
                    patientDelegateByDelegate.put(patientDelegate.Contact__c, patientDelegate);
                }
            }

            for (Participant__c delegateParticipant : delegates) {
                if (
                    !String.isBlank(delegateParticipant.Contact__c) &&
                    !idsToCheck.contains(delegateParticipant.Contact__c) &&
                    patientDelegateByDelegate.containsKey(delegateParticipant.Contact__c)
                ) {
                    delegatesToUpdate.add(
                        new Patient_Delegate__c(
                            Id = patientDelegateByDelegate.get(delegateParticipant.Contact__c).Id,
                            Status__c = PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS
                        )
                    );
                }
            }
            if (!delegates.isEmpty() && needsInvite == true) {
                update delegates;
            }
            if (!delegatesToUpdate.isEmpty() && needsInvite == true) {
                update delegatesToUpdate;
            }
            if (!delegates.isEmpty() && needsInvite == false) {
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateTriggerHandler.CreateReactivatedNotification.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class
                );
                update delegates;
            }
            if (!delegatesToUpdate.isEmpty() && needsInvite == false) {
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateTriggerHandler.CreateReactivatedNotification.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class
                );
                update delegatesToUpdate;
            }

            system.debug('toCreateUser: ' + toCreateUser);
            if (!toCreateUser.isEmpty() && needsInvite == true) {
                ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                    .createParticipantUsers(toCreateUser);
            }
            if (!toCreateUser.isEmpty() && needsInvite == false) {
                ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                    .createParticipantUsers(new Map<Id, Id>{ participantContact.Id => null });
            }
            if (!actionAssignContactPermissions.isEmpty() && needsInvite == true) {
                ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
            }
            if (!actionAssignContactPermissions.isEmpty() && needsInvite == false) {
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateTriggerHandler.CreateReactivatedNotification.class
                );
                TriggerHandlerExecutor.bypassHandler(
                    PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class
                );
                ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
            }
        } catch (Exception exp) {
            throw new AuraHandledException(exp.getMessage() + '\n' + exp.getStackTraceString());
        }
    }

    @AuraEnabled
    public static List<Participant__c> getParticipantDelegates(String participantId) {
        try {
            List<Participant__c> participants = [
                SELECT
                    Id,
                    Contact__c,
                    First_Name__c,
                    Middle_Name__c,
                    Last_Name__c,
                    Mailing_Zip_Postal_Code__c,
                    Mailing_State_Code__c,
                    Mailing_State__c,
                    Mailing_Country_Code__c,
                    Mailing_Country__c,
                    Email__c,
                    Phone__c,
                    Phone_Type__c
                FROM Participant__c
                WHERE
                    Contact__c IN (
                        SELECT Contact__c
                        FROM Patient_Delegate__c
                        WHERE
                            Participant__c = :participantId
                            AND (Status__c = :PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS
                            OR Status__c = :PatientDelegateTriggerHandler.PATIENT_DELEGATE_ONHOLD_STATUS)
                    )
            ];
            return participants;
        } catch (Exception exp) {
            throw new AuraHandledException(exp.getMessage() + '\n' + exp.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String updatePatientStatus(
        String pathWrapperJSON,
        String peId,
        Boolean historyToUpdate,
        Boolean notesToBeAdded,
        String outcome
    ) {
        Participant_Enrollment__c pe = new Participant_Enrollment__c(Id = peId);
        return updatePatientStatus(pathWrapperJSON, pe, historyToUpdate, notesToBeAdded, outcome);
    }

    @AuraEnabled
    public static String updatePatientStatusCC(
        String pathWrapperJSON,
        String peId,
        Boolean historyToUpdate,
        Boolean notesToBeAdded,
        String outcome
    ) {
        Participant_Enrollment__c pe = new Participant_Enrollment__c(Id = peId);
        return updatePatientStatusCC(pathWrapperJSON, pe, historyToUpdate, notesToBeAdded, outcome);
    }

    public static String updatePatientStatus(
        String pathWrapperJSON,
        Participant_Enrollment__c pe,
        Boolean historyToUpdate,
        Boolean notesToBeAdded,
        String outcome
    ) {
        try {
            ParticipantWorkflowService.ParticipantWorkflowWrapper pathWrapper = (ParticipantWorkflowService.ParticipantWorkflowWrapper) JSON.deserialize(
                pathWrapperJSON,
                ParticipantWorkflowService.ParticipantWorkflowWrapper.class
            );
            //Participant_Enrollment__c oldParticipantEnrollment = ParticipantEnrollmentService.getParticipantEnrollment(pe.Id, CommunityModeService.USER_MODE_PI, null);
            Participant_Enrollment__c oldParticipantEnrollment = ParticipantEnrollmentService.getParticipantEnrollment(
                pe.Id,
                CommunityModeService.USER_MODE_PI,
                null,
                ViewPatientsRemote.PE_MY_PARTICIPANTS_FIELDS
            );
            Clinical_Trial_Profile__c ctp = StudyTrialService.getFullTrial(
                oldParticipantEnrollment.Clinical_Trial_Profile__c
            );
            ParticipantWorkflowService.populatePEFromWorkflowWrapper(
                pathWrapper,
                pe,
                ctp,
                oldParticipantEnrollment
            );
            update pe;
            if (
                (oldParticipantEnrollment.Initial_visit_scheduled_date__c == null ||
                oldParticipantEnrollment.Initial_visit_scheduled_time__c == null) &&
                (pe.Initial_visit_scheduled_date__c != null &&
                pe.Initial_visit_scheduled_time__c != null)
            ) {
                IncentiveProgramService.completeIncentiveTaskCurrentContact(
                    IncentiveTaskCatalog.INCENTIVE_TASK_ENTERED_INITIAL_VISIT_SCHEDULED_TIME,
                    oldParticipantEnrollment.Study_Site__c,
                    oldParticipantEnrollment.Name
                );
            }
            //pe = ParticipantEnrollmentService.getParticipantEnrollment(pe.Id, CommunityService.USER_MODE_PI);
            pe = ParticipantEnrollmentService.getParticipantEnrollment(
                pe.Id,
                CommunityModeService.USER_MODE_PI,
                null,
                ViewPatientsRemote.PE_MY_PARTICIPANTS_FIELDS
            );
            Participant_Enrollment_Status_History__c pesh = ParticipantWorkflowService.createPESHFromPathWrapper(
                pathWrapper,
                pe,
                ctp,
                oldParticipantEnrollment
            );
            if (pesh != null && historyToUpdate) {
                if (
                    oldParticipantEnrollment.Participant_Status__c ==
                    PEStatusState.PE_STATUS_RECEIVED &&
                    (pesh.Status__c == PEStatusState.PE_STATUS_CONTACT_ATTEMPTED ||
                    pesh.Status__c == PEStatusState.PE_STATUS_SUCCESSFULLY_CONTACTED ||
                    pesh.Status__c == PEStatusState.PE_STATUS_CONTACTED_NOT_SUITABLE ||
                    pesh.Status__c == PEStatusState.PE_STATUS_UNABLE_TO_REACH) &&
                    oldParticipantEnrollment.Participant_Status_Last_Changed_Date__c.date()
                        .daysBetween(Date.today()) <= 1
                ) {
                    IncentiveProgramService.completeIncentiveTaskCurrentContact(
                        IncentiveTaskCatalog.INCENTIVE_TASK_MADE_CONTACT_ATTEMPT_WITHIN_1_DAY,
                        oldParticipantEnrollment.Study_Site__c,
                        oldParticipantEnrollment.Name
                    );
                }
                insert pesh;
            } else if (notesToBeAdded && pe != null && pe.Id != null) {
                Boolean isCCUser=false;
                updateNotes(pathWrapper, pe, outcome,isCCUser);
            } else if (pe != null && pe.Id != null) {
                updateWithDividerWithNotes(pathWrapper, pe, outcome);
            }
            //pe = ParticipantEnrollmentService.getParticipantEnrollment(pe.Id, CommunityService.USER_MODE_PI);
            pe = ParticipantEnrollmentService.getParticipantEnrollment(
                pe.Id,
                CommunityModeService.USER_MODE_PI,
                null,
                ViewPatientsRemote.PE_MY_PARTICIPANTS_FIELDS
            );
            if (pe == null)
                throw new CommunityServiceException('Participant enrollment not found');
            return JSON.serialize(
                new UpdateResponse(
                    pe,
                    ParticipantWorkflowService.prepareParticipantWorkflow(ctp, pe)
                )
            );
        } catch (Exception e) {
            System.debug('ERROR: ' + e.getMessage() + '\n' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    @testVisible
    private static void updateNotes(
        ParticipantWorkflowService.ParticipantWorkflowWrapper pathWrapper,
        Participant_Enrollment__c pe,
        String outcome,
        Boolean isCCUser
    ) {
        Participant_Enrollment_Status_History__c peshnotes;
        if (outcome != null) {
            peshnotes = [
                SELECT Id, Additional_Notes__c, Notes__c, Status__c
                FROM Participant_Enrollment_Status_History__c
                WHERE ParticipantEnrollment__c = :pe.Id AND Status__c = :outcome
                ORDER BY Date__c DESC
                LIMIT 1
            ][0];
        } else {
            peshnotes = [
                SELECT Id, Additional_Notes__c, Notes__c, Status__c
                FROM Participant_Enrollment_Status_History__c
                WHERE ParticipantEnrollment__c = :pe.Id
                ORDER BY Date__c DESC
                LIMIT 1
            ][0];
        }

        if (peshnotes != null) {
            Map<String, Participant_Workflow_Step__mdt> stepsWithName = new Map<String, Participant_Workflow_Step__mdt>();
            for (Participant_Workflow_Step__mdt s : [
                SELECT
                    Id,
                    MasterLabel,
                    DeveloperName,
                    Additional_Notes_For_Statuses__c,
                    In_Progress_Condition__c,
                    Success_Condition__c
                FROM Participant_Workflow_Step__mdt
            ]) {
                stepsWithName.put(s.MasterLabel, s);
            }
            //Mask Created by Name for  Portal user whose User Community Mode is 'CC'
            String createdbyName = '';
             
            if(isCCUser){
                createdbyName=UserInfo.getName() +'('+ System.Label.RH_Masked_IQVIA_User + ')' ;         
            }
            else{
                createdbyName =UserInfo.getName();
            }
            
            for (Integer i = 0; i < pathWrapper.steps.size(); i = i + 1) {
                ParticipantWorkflowService.ParticipantWorkflowStepWrapper step = pathWrapper.steps[
                    i
                ];
                if (step.isCurrentStep == true && step.isCurrentStepValid == true) {
                    String note = step.notes;
                    if (step.reason != null && step.reason != '') {
                        note = peshnotes.Status__c + ' - ' + step.reason + ', ' + step.notes;
                    }
                    if (i + 1 < pathWrapper.steps.size()) {
                        Boolean nextStepStateNew = isStepSuccessfulOrInProgress(
                            stepsWithName.get(pathWrapper.steps[i + 1].title),
                            pe,
                            peshnotes.Status__c
                        );
                        String nextStepStateOld = pathWrapper.steps[i + 1].state;
                        if (
                            nextStepStateNew &&
                            !(nextStepStateOld == PEStatusState.STATUS_STATE_SUCCESS ||
                            nextStepStateOld == PEStatusState.STATUS_STATE_IN_PROGRESS ||
                            nextStepStateOld == PEStatusState.STATUS_STATE_FAILURE)
                        ) {
                            if (peshnotes.Additional_Notes__c == null) {
                                peshnotes.Additional_Notes__c =
                                    '####' +
                                    note +
                                    ' ' +
                                    Label.PE_Status_History_On_Date +
                                    ' ' +
                                    DateTime.now().format() +
                                    ' ' +
                                    Label.PG_IMI_L_by_user +
                                    ' ' +
                                    createdbyName +
                                    '#';
                                break;
                            } else if (
                                peshnotes.Additional_Notes__c != null &&
                                !peshnotes.Additional_Notes__c.contains('####')
                            ) {
                                peshnotes.Additional_Notes__c =
                                    '####' +
                                    note +
                                    ' ' +
                                    Label.PE_Status_History_On_Date +
                                    ' ' +
                                    DateTime.now().format() +
                                    ' ' +
                                    Label.PG_IMI_L_by_user +
                                    ' ' +
                                    createdbyName +
                                    '#' +
                                    peshnotes.Additional_Notes__c;
                                break;
                            }
                        }
                    }
                    if (peshnotes.Additional_Notes__c == null) {
                        peshnotes.Additional_Notes__c =
                            ' ' +
                            note +
                            ' ' +
                            Label.PE_Status_History_On_Date +
                            ' ' +
                            DateTime.now().format() +
                            ' ' +
                            Label.PG_IMI_L_by_user +
                            ' ' +
                            createdbyName +
                            '#';
                        break;
                    } else {
                        peshnotes.Additional_Notes__c =
                            note +
                            ' ' +
                            Label.PE_Status_History_On_Date +
                            ' ' +
                            DateTime.now().format() +
                            ' ' +
                            Label.PG_IMI_L_by_user +
                            ' ' +
                            createdbyName +
                            '#' +
                            peshnotes.Additional_Notes__c;
                        break;
                    }
                }
            }
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.UpdatePEHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.CreateWelcomeToStudyAlertHandler.class
            );
            update peshnotes;
        }
    }

    @testVisible
    private static void updateWithDividerWithNotes(
        ParticipantWorkflowService.ParticipantWorkflowWrapper pathWrapper,
        Participant_Enrollment__c pe,
        String outcome
    ) {
        Participant_Enrollment_Status_History__c peshnotes;
        if (outcome != null) {
            peshnotes = [
                SELECT Id, Additional_Notes__c, Notes__c, Status__c
                FROM Participant_Enrollment_Status_History__c
                WHERE ParticipantEnrollment__c = :pe.Id AND Status__c = :outcome
                ORDER BY Date__c DESC
                LIMIT 1
            ][0];
        } else {
            peshnotes = [
                SELECT Id, Additional_Notes__c, Notes__c, Status__c
                FROM Participant_Enrollment_Status_History__c
                WHERE ParticipantEnrollment__c = :pe.Id
                ORDER BY Date__c DESC
                LIMIT 1
            ][0];
        }
        if (peshnotes != null) {
            Map<String, Participant_Workflow_Step__mdt> stepsWithName = new Map<String, Participant_Workflow_Step__mdt>();
            for (Participant_Workflow_Step__mdt s : [
                SELECT
                    Id,
                    MasterLabel,
                    DeveloperName,
                    Additional_Notes_For_Statuses__c,
                    In_Progress_Condition__c,
                    Success_Condition__c
                FROM Participant_Workflow_Step__mdt
            ]) {
                stepsWithName.put(s.MasterLabel, s);
            }
            for (Integer i = 0; i < pathWrapper.steps.size(); i = i + 1) {
                ParticipantWorkflowService.ParticipantWorkflowStepWrapper step = pathWrapper.steps[
                    i
                ];
                if (step.isCurrentStep == true && step.isCurrentStepValid == true) {
                    if (i + 1 < pathWrapper.steps.size()) {
                        Boolean nextStepStateNew = isStepSuccessfulOrInProgress(
                            stepsWithName.get(pathWrapper.steps[i + 1].title),
                            pe,
                            peshnotes.Status__c
                        );
                        String nextStepStateOld = pathWrapper.steps[i + 1].state;
                        if (
                            nextStepStateNew &&
                            !(nextStepStateOld == PEStatusState.STATUS_STATE_SUCCESS ||
                            nextStepStateOld == PEStatusState.STATUS_STATE_IN_PROGRESS ||
                            nextStepStateOld == PEStatusState.STATUS_STATE_FAILURE)
                        ) {
                            if (
                                peshnotes.Additional_Notes__c != null &&
                                !peshnotes.Additional_Notes__c.contains('####')
                            ) {
                                peshnotes.Additional_Notes__c =
                                    '####' + peshnotes.Additional_Notes__c;
                                break;
                            }
                        }
                    }
                }
            }
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.UpdatePEHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.CreateWelcomeToStudyAlertHandler.class
            );
            update peshnotes;
        }
    }

    private static Boolean isStepSuccessfulOrInProgress(
        Participant_Workflow_Step__mdt step,
        Participant_Enrollment__c pe,
        String Status
    ) {
        Boolean stepSuccessful = false;
        Boolean stepInProgress = false;
        Boolean statusPresent = false;

        if (step != null) {
            stepSuccessful =
                String.isNotBlank(step.Success_Condition__c) &&
                ConditionCheckerService.checkConditionForObject(step.Success_Condition__c, pe);
            stepInProgress =
                String.isBlank(step.In_Progress_Condition__c) ||
                ConditionCheckerService.checkConditionForObject(step.In_Progress_Condition__c, pe);
            statusPresent =
                step.Additional_Notes_For_Statuses__c != null &&
                step.Additional_Notes_For_Statuses__c.contains(';' + Status + ';');
        }
        Boolean res = (statusPresent && (stepSuccessful || stepInProgress));
        return res;
    }

    //CC
    @AuraEnabled
    public static String updatePatientStatusCC(
        String pathWrapperJSON,
        Participant_Enrollment__c pe,
        Boolean historyToUpdate,
        Boolean notesToBeAdded,
        String outcome
    ) {
        try {
            ParticipantWorkflowService.ParticipantWorkflowWrapper pathWrapper = (ParticipantWorkflowService.ParticipantWorkflowWrapper) JSON.deserialize(
                pathWrapperJSON,
                ParticipantWorkflowService.ParticipantWorkflowWrapper.class
            );

            //Participant_Enrollment__c oldParticipantEnrollment = ParticipantEnrollmentService.getParticipantEnrollment(pe.Id, CommunityModeService.USER_MODE_CC, null);
            Participant_Enrollment__c oldParticipantEnrollment = ParticipantEnrollmentService.getParticipantEnrollment(
                pe.Id,
                CommunityModeService.USER_MODE_CC,
                null,
                ViewPatientsRemote.PE_MY_PARTICIPANTS_FIELDS
            );
            Clinical_Trial_Profile__c ctp = StudyTrialService.getFullTrial(
                oldParticipantEnrollment.Clinical_Trial_Profile__c
            );
            ParticipantWorkflowService.populatePEFromWorkflowWrapper(
                pathWrapper,
                pe,
                ctp,
                oldParticipantEnrollment
            );
            update pe;
            if (
                (oldParticipantEnrollment.Initial_visit_scheduled_date__c == null ||
                oldParticipantEnrollment.Initial_visit_scheduled_time__c == null) &&
                (pe.Initial_visit_scheduled_date__c != null &&
                pe.Initial_visit_scheduled_time__c != null)
            ) {
                IncentiveProgramService.completeIncentiveTaskCurrentContact(
                    IncentiveTaskCatalog.INCENTIVE_TASK_ENTERED_INITIAL_VISIT_SCHEDULED_TIME,
                    oldParticipantEnrollment.Study_Site__c,
                    oldParticipantEnrollment.Name
                );
            }
            //pe = ParticipantEnrollmentService.getParticipantEnrollment(pe.Id, CommunityService.USER_MODE_CC);
            pe = ParticipantEnrollmentService.getParticipantEnrollment(
                pe.Id,
                CommunityModeService.USER_MODE_CC,
                null,
                ViewPatientsRemote.PE_MY_PARTICIPANTS_FIELDS
            );
            Participant_Enrollment_Status_History__c pesh = ParticipantWorkflowService.createPESHFromPathWrapper(
                pathWrapper,
                pe,
                ctp,
                oldParticipantEnrollment
            );
            if (pesh != null && historyToUpdate) {
                if (
                    oldParticipantEnrollment.Participant_Status__c ==
                    PEStatusState.PE_STATUS_RECEIVED &&
                    (pesh.Status__c == PEStatusState.PE_STATUS_CONTACT_ATTEMPTED ||
                    pesh.Status__c == PEStatusState.PE_STATUS_SUCCESSFULLY_CONTACTED) &&
                    oldParticipantEnrollment.Participant_Status_Last_Changed_Date__c.date()
                        .daysBetween(Date.today()) <= 1
                ) {
                    IncentiveProgramService.completeIncentiveTaskCurrentContact(
                        IncentiveTaskCatalog.INCENTIVE_TASK_MADE_CONTACT_ATTEMPT_WITHIN_1_DAY,
                        oldParticipantEnrollment.Study_Site__c,
                        oldParticipantEnrollment.Name
                    );
                }
                insert pesh;
            } else if (notesToBeAdded && pe != null && pe.Id != null) {
               	Boolean isCCUser=true;
                updateNotes(pathWrapper, pe, outcome,isCCUser);
            } else if (pe != null && pe.Id != null) {
                updateWithDividerWithNotes(pathWrapper, pe, outcome);
            }
            //pe = ParticipantEnrollmentService.getParticipantEnrollment(pe.Id, CommunityService.USER_MODE_CC);
            pe = ParticipantEnrollmentService.getParticipantEnrollment(
                pe.Id,
                CommunityModeService.USER_MODE_CC,
                null,
                ViewPatientsRemote.PE_MY_PARTICIPANTS_FIELDS
            );
            if (pe == null)
                throw new CommunityServiceException('Participant enrollment not found');
            return JSON.serialize(
                new UpdateResponse(
                    pe,
                    ParticipantWorkflowService.prepareParticipantWorkflow(ctp, pe)
                )
            );
        } catch (Exception e) {
            System.debug('ERROR: ' + e.getMessage() + '\n' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String updatePatientInfoAndStatus(
        String participantJSON,
        String peJSON,
        String pathWrapperJSON,
        String peId
    ) {
        Participant__c participant = (Participant__c) JSON.deserialize(
            participantJSON,
            Participant__c.class
        );
        Participant_Enrollment__c pe = (Participant_Enrollment__c) JSON.deserialize(
            peJSON,
            Participant_Enrollment__c.class
        );
        update participant;
        return updatePatientStatus(pathWrapperJSON, pe, false, false, null);
    }

    @AuraEnabled
    public static String updatePatientInfoAndStatusWithDelegate(
        String participantJSON,
        String peJSON,
        String pathWrapperJSON,
        String peId,
        String delegateJSON,
        String userInfoJSON,
        Boolean historyToUpdate,
        Boolean notesToBeAdded,
        String outcome
    ) {
        try {
            Participant__c participant = (Participant__c) JSON.deserialize(
                participantJSON,
                Participant__c.class
            );
            update participant;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        Participant_Enrollment__c pe = (Participant_Enrollment__c) JSON.deserialize(
            peJSON,
            Participant_Enrollment__c.class
        );

        if (!String.isBlank(delegateJSON)) {
            Participant__c delegateParticipant = (Participant__c) JSON.deserialize(
                delegateJSON,
                Participant__c.class
            );
            if (delegateParticipant != null && !String.isBlank(delegateParticipant.Id)) {
                try {
                    update delegateParticipant;
                } catch (Exception exp) {
                    system.debug('No delegate was provided');
                }
            }
        }
        updateUserLanguage(userInfoJSON);

        return updatePatientStatus(pathWrapperJSON, pe, historyToUpdate, notesToBeAdded, outcome);
    }

    //CC
    @AuraEnabled
    public static String updatePatientInfoAndStatusWithDelegateCC(
        String participantJSON,
        String peJSON,
        String pathWrapperJSON,
        String peId,
        String delegateJSON,
        String userInfoJSON,
        Boolean historyToUpdate,
        Boolean notesToBeAdded,
        String outcome
    ) {
        try {
            Participant__c participant = (Participant__c) JSON.deserialize(
                participantJSON,
                Participant__c.class
            );
            update participant;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        Participant_Enrollment__c pe = (Participant_Enrollment__c) JSON.deserialize(
            peJSON,
            Participant_Enrollment__c.class
        );

        if (!String.isBlank(delegateJSON)) {
            Participant__c delegateParticipant = (Participant__c) JSON.deserialize(
                delegateJSON,
                Participant__c.class
            );
            if (delegateParticipant != null && !String.isBlank(delegateParticipant.Id)) {
                try {
                    update delegateParticipant;
                } catch (Exception exp) {
                    system.debug('No delegate was provided');
                }
            }
        }
        updateUserLanguage(userInfoJSON);

        return updatePatientStatusCC(pathWrapperJSON, pe, historyToUpdate, notesToBeAdded, outcome);
    }
    //

    public static void updateUserLanguage(String userJSON) {
        if (!String.isBlank(userJSON)) {
            try {
                User userL = (User) JSON.deserialize(userJSON, User.class);
                if (userL != null) {
                    update userL;
                }
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
            }
        }
    }

    public class UpdateResponse {
        @AuraEnabled
        public Participant_Enrollment__c pe;
        @AuraEnabled
        public ParticipantWorkflowService.ParticipantWorkflowWrapper participantPath;

        public UpdateResponse(
            Participant_Enrollment__c pe,
            ParticipantWorkflowService.ParticipantWorkflowWrapper participantPath
        ) {
            this.pe = pe;
            this.participantPath = participantPath;
        }
    }

    /**
     * This wapper class is created to accomodate the requirements of REF-1192
     * It intends to combine the return value of getSteps(String, String, String)
     * and getPrintInformation(String, String, String)
     * @param args Unused.
     * @return Nothing.
     * @exception IOException On input error.
     * @see IOException
     */
    public class ParticipantItemWithSteps {
        @AuraEnabled
        public String participantItem;
        @AuraEnabled
        public String initData;
        ParticipantItemWithSteps() {
            this.participantItem = '';
            this.initData = '';
        }
    }
    public class DelegateInfo {
        @AuraEnabled
        public String email { get; set; }
        @AuraEnabled
        public String firstName { get; set; }
        @AuraEnabled
        public String lastName { get; set; }
        @AuraEnabled
        public Boolean isDuplicate { get; set; }
        @AuraEnabled
        public String contactId { get; set; }
    }

    public class DelegateConnectedInfo {
        @AuraEnabled
        public Boolean isConnected { get; set; }
        @AuraEnabled
        public Id participantId { get; set; }
        @AuraEnabled
        public Id contactId { get; set; }
    }

    public class PIDelegateLevelInfo {
        @AuraEnabled
        public Boolean isDisabled { get; set; }
    }
}
