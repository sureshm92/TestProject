/**
 * Created by D.Yasinskyi on 26.04.2018
 * Refactored by L.Bartenev
 */

public without sharing class ParticipantEnrollmentTriggerHandler {

    // Handlers: -------------------------------------------------------------------------------------------------------

    public class PrepareAdditionalFieldsHandler extends TriggerHandler {

        public override void beforeInsert(List<SObject> newList) {
            new ParticipantEnrollmentTriggerHandler(newList).prepareAdditionalFields(newList, null);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            new ParticipantEnrollmentTriggerHandler(newList).prepareAdditionalFields(newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }
    }

    public class CheckVisitPlanFromStudySiteHandler extends TriggerHandler {

        public override void beforeInsert(List<SObject> newList, Map<Id) {
            new ParticipantEnrollmentTriggerHandler(newList).checkVisitPlanFromStudySite(newList, null);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            new ParticipantEnrollmentTriggerHandler(newList).checkVisitPlanFromStudySite(newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }
    }

    public class StudySiteHistoryHandler extends TriggerHandler {

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            new ParticipantEnrollmentTriggerHandler(newList).studySiteHistory(newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }
    }

    public class CreateUsersOrSendNotificationsHandler extends TriggerHandler {

        public override void afterInsert(List<SObject> newList) {
            new ParticipantEnrollmentTriggerHandler(newList).createUsersOrSendNotifications(newList, null);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            new ParticipantEnrollmentTriggerHandler(newList).createUsersOrSendNotifications(newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }
    }

    public class SendCalloutOnEligibilityPassedHandler extends TriggerHandler {

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            sendCalloutOnEligibilityPassed(newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }
    }

    public class CreateStatusTrackingHistoryRecordsHandler extends TriggerHandler {

        public override void beforeInsert(List<SObject> newList) {
            setChangedDate(newList);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            resetNotesAndSetChangeDate(newList, (Map<Id, Participant_Enrollment__c>) oldMap);
            createPrimaryHistoryEntry((List<Participant_Enrollment__c>) newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }

        public override void afterInsert(List<SObject> newList) {
            createPrimaryHistoryEntry((List<Participant_Enrollment__c>) newList, null);
        }
    }

    public class CreateStatusBasedInvitations extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            createInvitations((List<Participant_Enrollment__c>) newList, null);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createInvitations((List<Participant_Enrollment__c>) newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }
    }

    public class SetSourceTypeHandler extends TriggerHandler {

        public override void beforeInsert(List<SObject> newList) {
            setSourceTypeHandler(newList);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            setSourceTypeHandler(newList);
        }
    }

    public class SetParticipantStatusHandler extends TriggerHandler {

        public override void beforeInsert(List<SObject> newList) {
            setParticipantStatusHandler(newList);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            setParticipantStatusHandler(newList);
        }
    }

    public class UpdatePEHistoryOnAutoAcceptedHandler extends TriggerHandler {

        public override void afterInsert(List<SObject> newList) {
            updatePEHistoryOnAutoAccepted((List<Participant_Enrollment__c>) newList, null);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updatePEHistoryOnAutoAccepted((List<Participant_Enrollment__c>) newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }
    }

    // Handlers: On study ----------------------------------------------------------------------------------------------
    public class DeactivateDeceasedUsersHandler extends TriggerHandler {

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            deactivateDeceasedUsers((List<Participant_Enrollment__c>) newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }
    }

    public class CreateVisitsScheduleHandler extends TriggerHandler {

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createVisitsSchedule((List<Participant_Enrollment__c>) newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }
    }

    public class CreateWelcomeToStudyAlertHandler extends TriggerHandler {

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createStudyAlerts((List<Participant_Enrollment__c>) newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }
    }

    public class HideSurveyTasks extends TriggerHandler {

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            hideSurveyTaskForCompletedStatuses((List<Participant_Enrollment__c>) newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }
    }

    public class SendDropOutEmailHandler extends TriggerHandler {

        protected override void onAfterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            sendDropEmails((List<Participant_Enrollment__c>) newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }
    }

    public class SetCurrentEnrollmentHandler extends TriggerHandler {

        public override void afterInsert(List<SObject> newList) {
            setupCurrentEnrollment((List<Participant_Enrollment__c>) newList, null);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            setupCurrentEnrollment((List<Participant_Enrollment__c>) newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }

    }

    // Logic: ----------------------------------------------------------------------------------------------------------


    private Map<Id, Study_Site__c> ssMap;
    private Map<Id, HCP_Enrollment__c> hcpeMap;
    private Map<Id, Participant__c> participantMap;

    public ParticipantEnrollmentTriggerHandler(List<Participant_Enrollment__c> newList) {
        List<Id> ssIds = new List<Id>();
        List<Id> hcpeIds = new List<Id>();
        List<Id> participantIds = new List<Id>();
        for (Participant_Enrollment__c pe : newList) {
            if (pe.Study_Site__c != null) ssIds.add(pe.Study_Site__c);
            if (pe.HCP__c != null) hcpeIds.add(pe.HCP__c);
            if (pe.Participant__c != null) participantIds.add(pe.Participant__c);
        }
        ssMap = new Map<Id, Study_Site__c>([
                SELECT Id, Principal_Investigator__c,
                        Principal_Investigator__r.Name,
                        Principal_Investigator__r.Full_Name__c,
                        Principal_Investigator__r.Phone,
                        Suppress_Participant_Emails__c,
                        Clinical_Trial_Profile__c,
                        Clinical_Trial_Profile__r.Study_Code_Name__c,
                        Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                        Clinical_Trial_Profile__r.Shareback_Settings_On_Participant_Level__c,
                        Clinical_Trial_Profile__r.Visit_Data_Shareback__c,
                        Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,
                        Clinical_Trial_Profile__r.NCT_Number__c
                FROM Study_Site__c
                WHERE Id IN:ssIds
        ]);
        hcpeMap = new Map<Id, HCP_Enrollment__c>([
                SELECT Id, HCP_Contact__c
                FROM HCP_Enrollment__c
                WHERE Id IN:hcpeIds
        ]);
        participantMap = new Map<Id, Participant__c>([
                SELECT Id,
                        Contact__c,
                        Full_Name__c,
                        Contact__r.Visit_Results_Opt_In__c,
                        Name,
                        IsCountry_NOT_Eligible_for_Emails__c
                FROM Participant__c
                WHERE Id IN:participantIds
        ]);
    }

    @TestVisible
    private void prepareAdditionalFields(List<Participant_Enrollment__c> newList, Map<Id, Participant_Enrollment__c> oldMap) {
        List<Contact> participantContacts = new List<Contact>();
        for (Participant_Enrollment__c pe : newList) {
            String nctNumber;
            String participantName;
            Boolean visitOpt = false;

            if (pe.Study_Site__c != null) {
                Study_Site__c ss = ssMap.get(pe.Study_Site__c);
                if (ss != null) {
                    pe.PI_Contact__c = ss.Principal_Investigator__c;
                    pe.Clinical_Trial_Profile__c = ss.Clinical_Trial_Profile__c;
                    nctNumber = ss.Clinical_Trial_Profile__r.NCT_Number__c;
                    visitOpt = ss.Clinical_Trial_Profile__r.Shareback_Settings_On_Participant_Level__c;
                }
            }
            if (pe.HCP__c != null) {
                HCP_Enrollment__c hcpe = hcpeMap.get(pe.HCP__c);
                if (hcpe != null) pe.HCP_Contact_HCPEnroll__c = hcpe.HCP_Contact__c;
            }
            if (pe.Participant__c != null) {
                Participant__c participant = participantMap.get(pe.Participant__c);
                if (participant != null) {
                    pe.Participant_Contact__c = participant.Contact__c;
                    if (oldMap == null) {
                        participant.Contact__r.Visit_Results_Opt_In__c = visitOpt;
                        participantContacts.add(participant.Contact__r);
                    }
                    participantName = participant.Name;
                }
            }
            //populate Participant Code
            if (nctNumber != null && participantName != null) {
                pe.Participant_Key__c = participantName + ' ' + nctNumber;
            }
            //populate referred date
            if (pe.Participant_Status__c == PEStatusState.PE_STATUS_REFERRAL_SENT_TO_PI) {
                if ((oldMap == null && pe.Referred_Date__c == null) || (oldMap != null && oldMap.get(pe.Id).Participant_Status__c != pe.Participant_Status__c)) {
                    pe.Referred_Date__c = Date.today();
                }
            }
        }

        if (!participantContacts.isEmpty()) update participantContacts;
    }


    @TestVisible
    private void studySiteHistory(List<Participant_Enrollment__c> newList, Map<Id, Participant_Enrollment__c> oldMap) {
        for (Participant_Enrollment__c pe : newList) {
            if (oldMap != null && pe.Study_Site__c != oldMap.get(pe.Id).Study_Site__c) {

            }
        }
    }

    @TestVisible
    private void checkVisitPlanFromStudySite(List<Participant_Enrollment__c> newList, Map<Id, Participant_Enrollment__c> oldMap) {
        Set<Id> studySiteIds = new Set<Id>();
        for (Participant_Enrollment__c pe : newList) {
            studySiteIds.add(pe.Study_Site__c);
        }

        if (!studySiteIds.isEmpty()) {
            Map<Id, Set<Id>> visitPlansBySSId = new Map<Id, Set<Id>>();
            List<StudySiteVisitPlan__c> visitPlans = [SELECT Id, Study_Site__c, Visit_Plan__c FROM StudySiteVisitPlan__c WHERE Study_Site__c IN :studySiteIds];
            for (StudySiteVisitPlan__c visitPlan : visitPlans) {
                Set<Id> visitPlIds = visitPlansBySSId.get(visitPlan.Study_Site__c);
                if (visitPlIds == null) {
                    visitPlIds = new Set<Id>();
                    visitPlansBySSId.put(visitPlan.Study_Site__c, visitPlIds);
                }

                visitPlIds.add(visitPlan.Visit_Plan__c);
            }

            for (Participant_Enrollment__c pe : newList) {
                if (visitPlansBySSId.get(pe.Study_Site__c) == null || visitPlansBySSId.get(pe.Study_Site__c).IsEmpty() ||
                        !visitPlansBySSId.get(pe.Study_Site__c).contains(pe.Visit_Plan__c)) {
                    pe.addError(Label.Error_Message_Can_Not_Use_Visit_Plan);
                }
            }
        }
    }

    @TestVisible
    private void createUsersOrSendNotifications(List<Participant_Enrollment__c> newList, Map<Id, Participant_Enrollment__c> oldMap) {
        Map<Id, Id> toCreateUser = new Map<Id, Id>();
        Map<Id, String> notificationMapEPR = new Map<Id, String>();
        Map<Id, String> notificationMapPI = new Map<Id, String>();
        Map<Id, String> notificationMapHCP = new Map<Id, String>();
        List<Contact> contactsForChangeMode = new List<Contact>();

        //get users if exist
        Map<Id, User> usersByContactId = new Map<Id, User>();
        Set<Id> participantContactIds = new Set<Id>();
        for (Participant_Enrollment__c pe : newList) {
            Participant__c participant = participantMap.get(pe.Participant__c);
            if (participant != null && participant.Contact__c != null) participantContactIds.add(participant.Contact__c);
        }
        for (User usr : CommunityService.getCommunityUsersByContactIds(participantContactIds)) usersByContactId.put(usr.ContactId, usr);

        //process PE items:
        List<Alert__c> alertsForInsert = new List<Alert__c>();
        for (Participant_Enrollment__c newPE : newList) {
            Study_Site__c ss = ssMap.get(newPE.Study_Site__c);
            HCP_Enrollment__c hcpe = hcpeMap.get(newPE.HCP__c);
            Participant__c participant = participantMap.get(newPE.Participant__c);
            User participantUser;
            if (participant != null && participant.Contact__c != null) participantUser = usersByContactId.get(participant.Contact__c);
            Boolean updateCriteria = true;
            if (oldMap != null) {
                Participant_Enrollment__c oldPE = oldMap.get(newPE.Id);
                updateCriteria = oldPE.Participant_Status__c != newPE.Participant_Status__c ||
                        oldPE.Participant__c != newPE.Participant__c || participantUser == null;
                System.debug('OLD STATUS: ' + oldPE.Participant_Status__c);
                System.debug('NEW STATUS: ' + newPE.Participant_Status__c);
                System.debug('OLD PART ID: ' + oldPE.Participant__c);
                System.debug('NEW PART ID: ' + newPE.Participant__c);
                System.debug('PART USER: ' + participantUser);
            }
            System.debug('UPDATE CRITERIA: ' + updateCriteria);
            if (!updateCriteria) continue;
            Boolean filterCriteria =
                    (newPE.Participant_Status__c == PEStatusState.PE_STATUS_REFERRAL_SENT_TO_PI ||
                            newPE.Participant_Status__c == ParticipantEnrollmentService.PART_STATUS_ACCEPTED) &&
                            newPE.Participant__c != null &&
                            !newPE.Is_Virtual_Study_Site__c &&
                            ss != null &&
                            ss.Clinical_Trial_Profile__c != null &&
                            !ss.Suppress_Participant_Emails__c &&
                            !ss.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c &&
                            participant != null &&
                            !participant.IsCountry_NOT_Eligible_for_Emails__c &&
                            participant.Contact__c != null;
            System.debug('FILTER CRITERIA: ' + filterCriteria);
            if (filterCriteria) {
                if (participantUser == null) {
                    System.debug('CREATE USER');
                    Id hcpContact;
                    if (hcpe != null) hcpContact = hcpe.HCP_Contact__c;
                    toCreateUser.put(participant.Contact__c, hcpContact);
                    alertsForInsert.add(new Alert__c(
                            Contact__c = participant.Contact__c,
                            Alert_Code__c = Alert.ALERT_CODE_WELCOME_PH
                    ));
                } else {
                    System.debug('NOTIFY USER');
                    if (newPE.Referral_Source__c == ParticipantEnrollmentService.PE_REFERRAL_SOURCE_HCP) {
                        notificationMapHCP.put(newPE.Id, participant.Contact__c);
                    } else if (newPE.Referral_Source__c == ParticipantEnrollmentService.PE_REFERRAL_SOURCE_PI) {
                        notificationMapPI.put(newPE.Id, participant.Contact__c);
                    } else {
                        notificationMapEPR.put(newPE.Id, participant.Contact__c);
                    }
                }
                contactsForChangeMode.add(new Contact(
                        Id = participant.Contact__c,
                        userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT
                ));
            }
        }

        insert alertsForInsert;
        if (toCreateUser.size() > 0) ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createParticipantUsers(toCreateUser);
        if (notificationMapHCP.size() > 0) SendEmailTemplate.sendEmailNotification(SendEmailTemplate.EMAIL_TEMPLATE_PATIENT_SOURCE_HCP_NEW, notificationMapHCP);
        if (notificationMapPI.size() > 0) SendEmailTemplate.sendEmailNotification(SendEmailTemplate.EMAIL_TEMPLATE_PATIENT_SOURCE_PI_NEW, notificationMapPI);
        if (notificationMapEPR.size() > 0) SendEmailTemplate.sendEmailNotification(SendEmailTemplate.EMAIL_TEMPLATE_PATIENT_SOURCE_EPR_NEW, notificationMapEPR);
        update contactsForChangeMode;
    }

    @TestVisible
    private static void sendCalloutOnEligibilityPassed(List<Participant_Enrollment__c> newList, Map<Id, Participant_Enrollment__c> oldMap) {
        String acceptedStatus = PEStatusState.PE_STATUS_ELIGIBILITY_PASSED;
        for (Participant_Enrollment__c pe : newList) {
            if (pe.Participant_Status__c == acceptedStatus && (oldMap == null ||
                    oldMap.get(pe.Id).Participant_Status__c != acceptedStatus)) {
                IntegrationService.sendPEToStudyHubAsync(pe.Id);
            }
        }
    }

    @TestVisible
    private static void setChangedDate(List<Participant_Enrollment__c> newList) {
        for (Participant_Enrollment__c pe : newList) {
            pe.Medical_Record_Review_Completed_Date__c = Datetime.now();
            if (pe.Participant_Status__c != null && pe.Participant_Status_Last_Changed_Date__c == null) {
                pe.Participant_Status_Last_Changed_Date__c = Datetime.now();
            }
        }
    }

    @TestVisible
    private static void resetNotesAndSetChangeDate(List<Participant_Enrollment__c> newList, Map<Id, Participant_Enrollment__c> oldMap) {
        for (Participant_Enrollment__c pe : newList) {
            if (pe.Participant_Status__c != oldMap.get(pe.Id).Participant_Status__c ||
                    pe.Participant_Status_Last_Changed_Date__c != oldMap.get(pe.Id).Participant_Status_Last_Changed_Date__c ||
                    pe.Last_Status_Changed_Notes__c != oldMap.get(pe.Id).Last_Status_Changed_Notes__c) {
                if (pe.Participant_Status_Last_Changed_Date__c == oldMap.get(pe.Id).Participant_Status_Last_Changed_Date__c)
                    if (pe.Last_Status_Changed_Notes__c == oldMap.get(pe.Id).Last_Status_Changed_Notes__c)
                        pe.Last_Status_Changed_Notes__c = null;
                pe.Participant_Status_Last_Changed_Date__c = Datetime.now();
            }
        }
    }

    @TestVisible
    private static void createInvitations(List<Participant_Enrollment__c> newList, Map<Id, Participant_Enrollment__c> oldMap) {
        Map<Id, List<Participant_Enrollment__c>> ctpPE = new Map<Id, List<Participant_Enrollment__c>>();
        for (Participant_Enrollment__c pe : newList) {
            if (ctpPE.get(pe.Clinical_Trial_Profile__c) == null) {
                ctpPE.put(pe.Clinical_Trial_Profile__c, new List<Participant_Enrollment__c>());
            }
            ctpPE.get(pe.Clinical_Trial_Profile__c).add(pe);
        }

        List<Trial_Survey__c> trialSurveys = [
                SELECT
                        Id,
                        Clinical_Trial_Profile__c,
                        Is_Midpoint__c,
                        Survey__c,
                        Survey__r.Name,
                        Active_On_Status__c,
                        Expires_After_Days__c,
                        Reminder_Schedule__c,
                        Whose_response_needed__c
                FROM Trial_Survey__c
                WHERE Active_On_Status__c != NULL
                AND Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = TRUE
                AND Clinical_Trial_Profile__c IN:ctpPE.keySet()
        ];

        Id communityId = CommunityService.getCommunityId(null);

        Map<Id, String> trialWhoseResponse = new Map<Id, String>();
        List<SurveyInvitation> newInvitations = new List<SurveyInvitation>();
        for (Trial_Survey__c ts : trialSurveys) {
            trialWhoseResponse.put(ts.Id, ts.Whose_response_needed__c);
            for (Participant_Enrollment__c enrollment : ctpPE.get(ts.Clinical_Trial_Profile__c)) {
                Boolean needToAdd = false;
                if (enrollment.Participant_Status__c == ts.Active_On_Status__c) {
                    if (PEStatusState.PE_STATUS_GROUP_COMPLETE.contains(enrollment.Participant_Status__c)
                            && ts.Is_Midpoint__c) continue;

                    if (oldMap != null) {
                        if (oldMap.get(enrollment.Id).Participant_Status__c != enrollment.Participant_Status__c) {
                            needToAdd = true;
                        }
                    } else {
                        needToAdd = true;
                    }
                }
                if (needToAdd) {
                    newInvitations.add(SurveyService.getInstance().generateInvitation(ts, enrollment.Id, communityId));
                }
            }
        }

        if (!newInvitations.isEmpty()) {
            insert newInvitations;
            Map<Id, String> invitationsVisible = new Map<Id, String>();
            for (SurveyInvitation inv : newInvitations) {
                invitationsVisible.put(inv.Id, trialWhoseResponse.get(inv.Trial_Survey__c));
            }

            TaskService.getInstance().createSurveyTasks(invitationsVisible);
        }
    }

    @TestVisible
    private static void createPrimaryHistoryEntry(
            List<Participant_Enrollment__c> enrollments,
            Map<Id, Participant_Enrollment__c> oldMap
    ) {
        List<Participant_Enrollment_Status_History__c> histories = new List<Participant_Enrollment_Status_History__c>();
        for (Participant_Enrollment__c pe : enrollments) {
            if (pe.Participant_Status__c == PEStatusState.PE_STATUS_REFERRAL_SENT_TO_PI) {
                if (oldMap == null ||
                        (oldMap != null && oldMap.get(pe.Id).Participant_Status__c != PEStatusState.PE_STATUS_REFERRAL_SENT_TO_PI)) {
                    histories.add(new Participant_Enrollment_Status_History__c(
                            Date__c = pe.Participant_Status_Last_Changed_Date__c,
                            Status__c = pe.Participant_Status__c,
                            Notes__c = pe.Non_Referral_Notes__c,
                            ParticipantEnrollment__c = pe.Id,
                            Reason__c = pe.Non_Referral_Reason__c
                    ));
                }
            }
        }
        if (!histories.isEmpty()) insert histories;
    }

    @TestVisible
    private static void setSourceTypeHandler(List<Participant_Enrollment__c> enrollments) {
        for (Participant_Enrollment__c pe : enrollments) {
            if ('PI' == pe.Referral_Source__c) {
                pe.Source_Type__c = 'Principal Investigator';
            } else if (pe.Referral_Source__c != null && pe.Referral_Source__c.contains('HCP')) {
                pe.Source_Type__c = 'Referring Provider';
            } else {
                pe.Source_Type__c = 'Digital Recruitment';
            }
        }
    }

    @TestVisible
    private static void setParticipantStatusHandler(List<Participant_Enrollment__c> enrollments) {
        Set<String> statuses = new Set<String>();
        for (Participant_Enrollment_settings__mdt pe : [SELECT Auto_Accept_Status__c FROM Participant_Enrollment_settings__mdt WHERE Auto_Accept_Status__c != NULL]) {
            statuses.add(pe.Auto_Accept_Status__c.toLowerCase());
        }
        for (Participant_Enrollment__c pe : enrollments) {
            if (!pe.IsAutoaccepted__c && !String.isBlank(pe.Referral_Source__c) && statuses.contains(pe.Referral_Source__c.toLowerCase())) {
                pe.Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_ACCEPTED;
                pe.IsAutoaccepted__c = true;
            }
        }
    }

    @TestVisible
    public static void updatePEHistoryOnAutoAccepted(List<Participant_Enrollment__c> enrollments, Map<Id, Participant_Enrollment__c> oldMap) {
        List<Participant_Enrollment_Status_History__c> statusHistories = new List<Participant_Enrollment_Status_History__c>();

        for (Participant_Enrollment__c pe : enrollments) {
            if (pe.IsAutoaccepted__c && (oldMap == null || pe.IsAutoaccepted__c != oldMap.get(pe.Id).IsAutoaccepted__c)) {
                PEStatusState currentState = PEStatusState.STATUSES_MAP.get(pe.Participant_Status__c);

                for (PEStatusState.StatusStep step : PEStatusState.STATUS_STEPS_TABLE) {
                    if (step.name == PEStatusState.PE_ST_REFERRED) continue;
                    statusHistories.add(new Participant_Enrollment_Status_History__c(
                            Notes__c = pe.Last_Status_Changed_Notes__c,
                            Date__c = Datetime.now(),
                            ParticipantEnrollment__c = pe.Id,
                            Status__c = step.states.get(PEStatusState.STATUS_STATE_SUCCESS)
                    ));
                    if (step.name == currentState.name) break;
                }
            }
        }

        if (!statusHistories.isEmpty()) {
            insert statusHistories;
        }
    }

    // On study logic---------------------------------------------------------------------------------------------------
    @TestVisible
    public static void deactivateDeceasedUsers(List<Participant_Enrollment__c> enrollments, Map<Id, Participant_Enrollment__c> oldMap) {
        List<Id> contactIds = new List<Id>();
        for (Participant_Enrollment__c pe : enrollments) {
            if (pe.Participant_Status__c == PEStatusState.PE_STATUS_DECEASED &&
                    pe.Participant_Status__c != oldMap.get(pe.Id).Participant_Status__c) {
                contactIds.add(pe.Participant_Contact__c);
            }
        }
        if (!contactIds.isEmpty()) deactivateUsers(contactIds);
    }

    @Future
    private static void deactivateUsers(List<Id> contactIds) {
        List<User> users = [
                SELECT Id, IsActive, ContactId
                FROM User
                WHERE ContactId IN :contactIds
        ];
        for (User u : users) u.IsActive = false;
        update users;
    }

    @TestVisible
    private static void sendDropEmails(List<Participant_Enrollment__c> newList, Map<Id, Participant_Enrollment__c> oldMap) {
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        for (Participant_Enrollment__c pe : newList) {
            if (pe.Participant_Status__c != oldMap.get(pe.Id).Participant_Status__c &&
                    pe.Participant_Status__c == PEStatusState.PE_STATUS_DROP_OUT) {
                messages.add(SendEmailTemplate.createEmail('Patient_dropped_out', pe.Participant_Contact__c, pe.Id));
            }
        }

        SendEmailTemplate.sendEmailMessages(messages);
    }

    @TestVisible
    private static void createVisitsSchedule(List<Participant_Enrollment__c> enrollments, Map<Id, Participant_Enrollment__c> oldMap) {
        Set<Id> peEnrollSuccessIds = new Set<Id>();
        for (Participant_Enrollment__c pe : enrollments) {
            if (pe.Participant_Status__c != oldMap.get(pe.Id).Participant_Status__c) {
                if (pe.Participant_Status__c == PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS) {
                    peEnrollSuccessIds.add(pe.Id);
                }
            }
        }

        List<Participant_Enrollment__c> peWithParticipating = [
                SELECT Id, Clinical_Trial_Profile__c, Visit_Plan__c
                FROM Participant_Enrollment__c
                WHERE Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = true
                AND Id IN:peEnrollSuccessIds
        ];

        Set<Id> ctpIds = new Set<Id>();
        for (Participant_Enrollment__c pe : peWithParticipating) ctpIds.add(pe.Clinical_Trial_Profile__c);
        Map<Id, Clinical_Trial_Profile__c> ctpMap = new Map<Id, Clinical_Trial_Profile__c>([
                SELECT Id, Visit_Plan__c
                FROM Clinical_Trial_Profile__c
                WHERE Id IN :ctpIds
        ]);

        Set<Id> visitPlanIds = new Set<Id>();
        for (Clinical_Trial_Profile__c ctp : ctpMap.values()) visitPlanIds.add(ctp.Visit_Plan__c);
        for (Participant_Enrollment__c pe : enrollments) visitPlanIds.add(pe.Visit_Plan__c);
        Map<Id, Visit_Plan__c> visitPlansMap = new Map<Id, Visit_Plan__c>([
                SELECT Id, (SELECT Id, Name, Visit_Number__c, Visit_Schedule__c, Patient_Portal_Name__c FROM Visits__r)
                FROM Visit_Plan__c
                WHERE Id IN :visitPlanIds
        ]);

        List<Patient_Visit__c> patientVisits = new List<Patient_Visit__c>();
        for (Participant_Enrollment__c pe : peWithParticipating) {
            Clinical_Trial_Profile__c ctp = ctpMap.get(pe.Clinical_Trial_Profile__c);
            Id vpId = pe.Visit_Plan__c;
            if (vpId == null) vpId = ctp.Visit_Plan__c;
            if (vpId == null) continue;
            Visit_Plan__c vp = visitPlansMap.get(vpId);
            if (vp == null) continue;
            for (Visit__c visit : vp.Visits__r) {
                patientVisits.add(VisitService.createPatientVisit(visit, pe.Id));
            }
        }
        if (patientVisits.size() > 0) insert patientVisits;
    }

    @TestVisible
    private static void createStudyAlerts(List<Participant_Enrollment__c> enrollments, Map<Id, Participant_Enrollment__c> oldMap) {
        Set<Id> peEnrollSuccessIds = new Set<Id>();
        for (Participant_Enrollment__c pe : enrollments) {
            if (pe.Participant_Status__c != oldMap.get(pe.Id).Participant_Status__c) {
                if (pe.Participant_Status__c == PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS) {
                    peEnrollSuccessIds.add(pe.Id);
                }
            }
        }

        List<Participant_Enrollment__c> peWithParticipating = [
                SELECT Id, Participant__c, Participant_Contact__c
                FROM Participant_Enrollment__c
                WHERE Id IN:peEnrollSuccessIds
                AND Clinical_Trial_Profile__r.Patient_Portal_Enabled__c = TRUE
        ];
        List<Id> participantIds = new List<Id>();
        for (Participant_Enrollment__c pe : peWithParticipating) participantIds.add(pe.Participant__c);

        Map<Id, List<Id>> delegateCntByParticipant = PatientDelegateService.getDelegatedContactIdsByParticipantIdMap(participantIds);
        List<Alert__c> alerts = new List<Alert__c>();
        for (Participant_Enrollment__c pe : peWithParticipating) {
            alerts.add(new Alert__c(
                    Contact__c = pe.Participant_Contact__c,
                    Alert_Code__c = Alert.ALERT_CODE_WELCOME_STUDY,
                    Record_ID__c = pe.Id
            ));
            if (!delegateCntByParticipant.containsKey(pe.Participant__c)) continue;

            for (Id contactDelegateId : delegateCntByParticipant.get(pe.Participant__c)) {
                alerts.add(new Alert__c(
                        Contact__c = contactDelegateId,
                        Alert_Code__c = Alert.ALERT_CODE_WELCOME_STUDY_DELEGATE,
                        Record_ID__c = pe.Id)
                );
            }
        }

        insert alerts;
    }

    @TestVisible
    private static void hideSurveyTaskForCompletedStatuses(
            List<Participant_Enrollment__c> newList,
            Map<Id, Participant_Enrollment__c> oldMap
    ) {
        List<Participant_Enrollment__c> completedPEs = new List<Participant_Enrollment__c>();
        for (Participant_Enrollment__c pe : newList) {
            if (pe.Participant_Status__c != oldMap.get(pe.Id).Participant_Status__c &&
                    PEStatusState.PE_STATUS_GROUP_COMPLETE.contains(pe.Participant_Status__c)) {
                completedPEs.add(pe);
            }
        }
        if (completedPEs.isEmpty()) return;

        Map<Id, SurveyInvitation> invitationMap = new Map<Id, SurveyInvitation>([
                SELECT Id
                FROM SurveyInvitation
                WHERE Participant_Enrollment__c IN:completedPEs
                AND Is_Midpoint__c = TRUE
        ]);
        if (invitationMap.keySet().isEmpty()) return;

        List<Task> tasks = [
                SELECT Id
                FROM Task
                WHERE Task_Type__c = :TaskService.TASK_TYPE_SURVEY
                AND Status IN:TaskService.TASK_STATUS_GROUP_AVAILABLE
                AND Survey_Invitation__c IN:invitationMap.keySet()
        ];

        List<Task> tasksForExpire = new List<Task>();
        for (Task task : tasks) {
            task.Status = TaskService.TASK_STATUS_EXPIRED;
            tasksForExpire.add(task);
        }
        update tasksForExpire;

        SurveyService.getInstance().expireInvitation(new List<Id>(invitationMap.keySet()));
    }

    @TestVisible
    private static void setupCurrentEnrollment(List<Participant_Enrollment__c> newList, Map<Id, Participant_Enrollment__c> oldMap) {
        List<String> targetStatuses = new List<String>(PEStatusState.PE_STATUS_GROUP_ALUMNI);
        targetStatuses.add(PEStatusState.PE_STATUS_REFERRAL_SENT_TO_PI);
        targetStatuses.add(PEStatusState.PE_STATUS_CONTACT_FAILED);
        List<Id> selectedParticipantIds = new List<Id>();
        List<Id> selectedContactIds = new List<Id>();
        for (Participant_Enrollment__c pe : newList) {
            if (oldMap == null ||
                    (oldMap != null && pe.Participant_Status__c != oldMap.get(pe.Id).Participant_Status__c &&
                            targetStatuses.contains(pe.Participant_Status__c))) {
                selectedParticipantIds.add(pe.Participant__c);
                if (pe.Participant_Contact__c != null)
                    selectedContactIds.add(pe.Participant_Contact__c);
            }
        }
        if (selectedParticipantIds.size() == 0) return;
        Map<Id, List<Id>> delegatedContactIdsByParticipantIdMap = PatientDelegateService.getDelegatedContactIdsByParticipantIdMap(selectedParticipantIds);
        for (List<Id> delegatedContactIds : delegatedContactIdsByParticipantIdMap.values()) selectedContactIds.addAll(delegatedContactIds);
        if (!selectedContactIds.isEmpty())
            ContactService.updateCurrentPEOnContacts(selectedContactIds);
    }
}
