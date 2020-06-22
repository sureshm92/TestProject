/**
* Created by D.Yasinskyi on 26.04.2018
* Refactored by L.Bartenev
*/

public without sharing class ParticipantEnrollmentTriggerHandler {

    // Handlers: -------------------------------------------------------------------------------------------------------

    public class PrepareAdditionalFieldsHandler extends TriggerHandler {

        public override void beforeInsert(List<SObject> newList) {
            prepareAdditionalFields(newList, null);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            prepareAdditionalFields(newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }
    }

    public class CheckVisitPlanFromStudySiteHandler extends TriggerHandler {

        public override void beforeInsert(List<SObject> newList) {
            checkVisitPlanFromStudySite(newList, null);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            checkVisitPlanFromStudySite(newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }
    }

    public class StudySiteHistoryHandler extends TriggerHandler {

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            studySiteHistory(newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }
    }

    public class CreateStatusTrackingHistoryRecordsHandler extends TriggerHandler {

        public override void beforeInsert(List<SObject> newList) {
            setChangedDate(newList);
            updateWithStepSuccessFlags(newList);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            resetNotesAndSetChangeDate(newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
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

    public class CompleteEnrollmentTasks extends TriggerHandler {

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            completeTasks((List<Participant_Enrollment__c>) newList, (Map<Id, Participant_Enrollment__c>) oldMap);
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

    public class UpdateParticipantState extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            updateParticipantStudyStatus(newList, null);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updateParticipantStudyStatus(newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }

    }

    // Handlers: On study ----------------------------------------------------------------------------------------------
    public class DeactivateDeceasedUsersHandler extends TriggerHandler {

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            deactivateDeceasedUsers((List<Participant_Enrollment__c>) newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }
    }

    public class CreateVisitsScheduleHandler extends TriggerHandler {

        public override void afterInsert(List<SObject> newList) {
            createVisitsSchedule((List<Participant_Enrollment__c>) newList, null);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createVisitsSchedule((List<Participant_Enrollment__c>) newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }
    }

    public class HideSurveyTasks extends TriggerHandler {

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            hideSurveyTaskForCompletedStatuses((List<Participant_Enrollment__c>) newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }
    }

    public class CheckReimbursableActivities extends TriggerHandler {

        public override void afterInsert(List<SObject> newList) {
            ProviderPaymentsService.checkPEForReimbursableActivities((List<Participant_Enrollment__c>) newList, null);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            ProviderPaymentsService.checkPEForReimbursableActivities((List<Participant_Enrollment__c>) newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }
    }

    // Logic: ----------------------------------------------------------------------------------------------------------

    @TestVisible
    private static void prepareAdditionalFields(List<Participant_Enrollment__c> newList, Map<Id, Participant_Enrollment__c> oldMap) {
        List<Contact> participantContacts = new List<Contact>();
        for (Participant_Enrollment__c pe : newList) {
            String nctNumber;
            String participantName;
            Boolean visitOpt = false;

            if (pe.Study_Site__c != null) {
                Study_Site__c ss = (Study_Site__c) PETriggerBuffer.getSObject(pe.Study_Site__c);
                if (ss != null) {
                    pe.PI_Contact__c = ss.Principal_Investigator__c;
                    pe.Clinical_Trial_Profile__c = ss.Clinical_Trial_Profile__c;
                    nctNumber = ss.Clinical_Trial_Profile__r.NCT_Number__c;
                    visitOpt = ss.Clinical_Trial_Profile__r.Shareback_Settings_On_Participant_Level__c;
                }
            }
            if (pe.HCP__c != null) {
                HCP_Enrollment__c hcpe = (HCP_Enrollment__c) PETriggerBuffer.getSObject(pe.HCP__c);
                if (hcpe != null) pe.HCP_Contact_HCPEnroll__c = hcpe.HCP_Contact__c;
            }
            if (pe.Participant__c != null) {
                Participant__c participant = (Participant__c) PETriggerBuffer.getSObject(pe.Participant__c);
                if (participant != null) {
                    pe.Participant_Contact__c = participant.Contact__c;
                    if (oldMap == null && pe.Participant_Contact__c != null) {
                        participant.Contact__r.Visit_Results_OptIn__c = visitOpt ? 'Vitals;Labs;Biomarkers' : null;
                        participant.Contact__r.UserCommunityIsDelegate__c = participant.Contact__r.UserCommunityIsDelegate__c = true ? false : true;
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
            if ((oldMap == null && PEStatusState.PE_ORDERED_STATUSES.containsKey(pe.Participant_Status__c) && pe.Referred_Date__c == null)
                    || (oldMap != null && oldMap.get(pe.Id).Participant_Status__c != pe.Participant_Status__c && pe.Participant_Status__c == PEStatusState.PE_STATUS_RECEIVED)) {
                pe.Referred_Date__c = Date.today();
            }

            pe.Initial_visit_scheduled_flag__c = pe.Initial_visit_scheduled_date__c != null || pe.Initial_visit_occurred_flag__c;
        }

        if (!participantContacts.isEmpty()) update participantContacts;
    }


    @TestVisible
    private static void studySiteHistory(List<Participant_Enrollment__c> newList, Map<Id, Participant_Enrollment__c> oldMap) {
        List<Participant_Site_History__c> participantSiteHistories = new List<Participant_Site_History__c>();
        for (Participant_Enrollment__c pe : newList) {
            if (oldMap != null && oldMap.get(pe.Id).Study_Site__c != null && pe.Study_Site__c != oldMap.get(pe.Id).Study_Site__c) {
                participantSiteHistories.add(
                        new Participant_Site_History__c(
                                Study_Site__c = oldMap.get(pe.Id).Study_Site__c,
                                Participant_Enrollment__c = pe.Id
                        )
                );
            }
        }

        if (!participantSiteHistories.isEmpty()) insert participantSiteHistories;
    }

    @TestVisible
    private static void checkVisitPlanFromStudySite(List<Participant_Enrollment__c> newList, Map<Id, Participant_Enrollment__c> oldMap) {
        Set<Id> studySiteIds = new Set<Id>();
        for (Participant_Enrollment__c pe : newList) {
            Boolean needsVisitPlanCheck = oldMap != null
                            && oldMap.get(pe.Id).Study_Site__c != null
                            && oldMap.get(pe.Id).Study_Site__c != pe.Study_Site__c;
            if (needsVisitPlanCheck && PEStatusState.PE_STATUS_GROUP_VISIT_PLAN_CHECK.contains(pe.Participant_Status__c)) {
                pe.Visit_Plan__c = null;
            } else {
                studySiteIds.add(pe.Study_Site__c);
            }
        }

        if (!studySiteIds.isEmpty()) {
            Map<Id, Set<Id>> visitPlansBySSId = new Map<Id, Set<Id>>();
            List<StudySiteVisitPlan__c> visitPlans = [
                    SELECT Id, Study_Site__c, Visit_Plan__c
                    FROM StudySiteVisitPlan__c
                    WHERE Study_Site__c IN :studySiteIds
            ];
            for (StudySiteVisitPlan__c visitPlan : visitPlans) {
                if (!visitPlansBySSId.containsKey(visitPlan.Study_Site__c)) {
                    visitPlansBySSId.put(visitPlan.Study_Site__c, new Set<Id>());
                }
                visitPlansBySSId.get(visitPlan.Study_Site__c).add(visitPlan.Visit_Plan__c);
            }

            for (Participant_Enrollment__c pe : newList) {
                if (pe.Visit_Plan__c != null && (visitPlansBySSId.get(pe.Study_Site__c) == null || visitPlansBySSId.get(pe.Study_Site__c).isEmpty() ||
                        !visitPlansBySSId.get(pe.Study_Site__c).contains(pe.Visit_Plan__c))) {
                    if (!Test.isRunningTest()) {
                        pe.addError(Label.Error_Message_Can_Not_Use_Visit_Plan);
                    }
                }
            }
        }
    }

    @TestVisible
    private static void setChangedDate(List<Participant_Enrollment__c> newList) {
        for (Participant_Enrollment__c pe : newList) {
            if (pe.MRR_Survey_Results_URL__c != null && pe.Medical_Record_Review_Completed_Date__c == null) {
                pe.Medical_Record_Review_Completed_Date__c = Datetime.now();
            }
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
                if (pe.Participant_Status_Last_Changed_Date__c == oldMap.get(pe.Id).Participant_Status_Last_Changed_Date__c) {
                    if (pe.Last_Status_Changed_Notes__c == oldMap.get(pe.Id).Last_Status_Changed_Notes__c) {
                        pe.Last_Status_Changed_Notes__c = null;
                    }
                }
                pe.Participant_Status_Last_Changed_Date__c = Datetime.now();
            }
        }
    }

    @TestVisible
    private static void createInvitations(List<Participant_Enrollment__c> newList, Map<Id, Participant_Enrollment__c> oldMap) {
        Map<Id, List<Participant_Enrollment__c>> ctpPE = new Map<Id, List<Participant_Enrollment__c>>();
        Map<String, Id> communitiesMap = CommunityService.getCommunityIdsMap();
        Map<Id, String> networkByPE = new Map<Id, String>();
        for (Participant_Enrollment__c pe : newList) {
            if (ctpPE.get(pe.Clinical_Trial_Profile__c) == null) {
                ctpPE.put(pe.Clinical_Trial_Profile__c, new List<Participant_Enrollment__c>());
            }
            ctpPE.get(pe.Clinical_Trial_Profile__c).add(pe);

            String communityName = CommunityTemplateService.getTemplate(((Clinical_Trial_Profile__c) PETriggerBuffer.getSObject(pe.Clinical_Trial_Profile__c)).CommunityTemplate__c).communityName;
            networkByPE.put(pe.Id, communitiesMap.get(communityName));
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
                    newInvitations.add(SurveyService.getInstance().generateInvitation(
                            ts, enrollment.Id, networkByPE.get(enrollment.Id))
                    );
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
    private static void createTasks(List<Participant_Enrollment__c> newList) {
        List<Participant_Enrollment__c> enrollments = new List<Participant_Enrollment__c>();
        Set<Id> participantContactIds = new Set<Id>();
        for (Participant_Enrollment__c pe : newList) {
            if (pe.Participant_Contact__c != null &&
                    ((Clinical_Trial_Profile__c) PETriggerBuffer.getSObject(pe.Clinical_Trial_Profile__c)).Tasks_Are_Available__c) {
                participantContactIds.add(pe.Participant_Contact__c);
                enrollments.add(pe);
            }
        }

        if (enrollments.isEmpty()) return;

        Map<Id, User> usersByContactId = new Map<Id, User>();
        for (User user : CommunityService.getCommunityUsersByContactIds(participantContactIds)) {
            usersByContactId.put(user.ContactId, user);
        }

        List<Task> tasks = new List<Task>();
        for (Participant_Enrollment__c pe : enrollments) {
            // COI tasks for GSK
            String communityTemplate = ((Clinical_Trial_Profile__c) PETriggerBuffer.getSObject(pe.Clinical_Trial_Profile__c)).CommunityTemplate__c;
            if (communityTemplate == CommunityTemplateService.TEMPLATE_GSK &&
                    !PEStatusState.PE_STATUS_GROUP_ALUMNI.contains(pe.Participant_Status__c)) {
                Task t = new Task (
                        Subject = TaskService.TASK_CODE_SELECT_COI,
                        Task_Code__c = TaskService.TASK_CODE_SELECT_COI,
                        Task_Type__c = TaskService.TASK_TYPE_NOT_SELECTED,
                        Status = TaskService.TASK_STATUS_OPEN,
                        Priority = TaskService.TASK_PRIORITY_NORMAL,
                        WhatId = pe.Id,
                        WhoId = pe.Participant_Contact__c,
                        Visible_For__c = TaskService.TASK_VISIBILITY_ALL
                );
                if (usersByContactId.get(pe.Participant_Contact__c) != null) {
                    //if user exist then assign to him:
                    t.OwnerId = usersByContactId.get(pe.Participant_Contact__c).Id;
                } else {
                    //if not, then mark owner contact, and task will be reassigned when user for this contact will be created
                    t.Owner_Contact__c = pe.Participant_Contact__c;
                }
                tasks.add(t);
            }
        }
        if (!tasks.isEmpty()) insert tasks;
    }

    @TestVisible
    private static void completeTasks(List<Participant_Enrollment__c> newList, Map<Id, Participant_Enrollment__c> oldMap) {
        Set<Id> peIds = new Set<Id>();
        for (Participant_Enrollment__c pe : newList) {
            if (PEStatusState.PE_STATUS_GROUP_ALUMNI.contains(pe.Participant_Status__c)) {
                peIds.add(pe.Id);
            }
        }

        if (peIds.isEmpty()) return;

        List<Task> tasks = new List<Task>([
                SELECT Status, Completed_Date__c
                FROM Task
                WHERE WhatId IN :peIds
                AND Task_Code__c = :TaskService.TASK_CODE_SELECT_COI
                AND Status != :TaskService.TASK_STATUS_COMPLETED
        ]);

        if (!tasks.isEmpty()) {
            for (Task task : tasks) {
                task.Status = TaskService.TASK_STATUS_COMPLETED;
                task.Completed_Date__c = Datetime.now();
            }
            update tasks;
        }
    }

    @TestVisible
    private static void createPrimaryHistoryEntry(
            List<Participant_Enrollment__c> enrollments,
            Map<Id, Participant_Enrollment__c> oldMap
    ) {
        List<Participant_Enrollment_Status_History__c> histories = new List<Participant_Enrollment_Status_History__c>();
        List<Participant_Enrollment__c> peListForTaskCreation = new List<Participant_Enrollment__c>();
        Set<Id> participantContactIds = new Set<Id>();
        List<Notification__c> notifications = new List<Notification__c>();

        for (Participant_Enrollment__c pe : enrollments) {
            if (pe.Participant_Status__c == PEStatusState.PE_STATUS_RECEIVED) {
                if (oldMap == null || (oldMap != null && oldMap.get(pe.Id).Participant_Status__c != PEStatusState.PE_STATUS_RECEIVED)) {
                    histories.add(new Participant_Enrollment_Status_History__c(
                            Date__c = pe.Participant_Status_Last_Changed_Date__c,
                            Status__c = pe.Participant_Status__c,
                            Notes__c = pe.Non_Referral_Notes__c,
                            ParticipantEnrollment__c = pe.Id,
                            Reason__c = pe.Non_Referral_Reason__c
                    ));
                    peListForTaskCreation.add(pe);
                    if (pe.Participant_Contact__c != null) participantContactIds.add(pe.Participant_Contact__c);
                }
            } else if (oldMap == null) {
                peListForTaskCreation.add(pe);
                Clinical_Trial_Profile__c ctp =
                        (Clinical_Trial_Profile__c) PETriggerBuffer.getSObject(pe.Clinical_Trial_Profile__c);
                if (pe.Participant_Contact__c != null) participantContactIds.add(pe.Participant_Contact__c);

                histories.addAll(ParticipantWorkflowService.createHistoryRecordsForPE(pe, ctp));
            }
        }
        if (!histories.isEmpty()) {
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.UpdatePEHandler.class);
            insert histories;
        }
        createTasks(peListForTaskCreation);
        PatientDelegateService.updateContactPermSetsWithDelegates(participantContactIds);

        if (!notifications.isEmpty()) insert notifications;
    }

    @TestVisible
    private static void updateWithStepSuccessFlags(List<Participant_Enrollment__c> enrollments) {
        for (Participant_Enrollment__c pe : enrollments) {
            ParticipantWorkflowService.updatePEWithPreviousStatusesSuccess(pe, (Clinical_Trial_Profile__c) PETriggerBuffer.getSObject(pe.Clinical_Trial_Profile__c));
        }
    }

    @TestVisible
    private static void setSourceTypeHandler(List<Participant_Enrollment__c> enrollments) {
        for (Participant_Enrollment__c pe : enrollments) {
            if ('PI' == pe.Referral_Source__c) {
                pe.Source_Type__c = ParticipantEnrollmentService.PE_SOURCE_TYPE_PI;
            } else if (pe.Referral_Source__c != null && pe.Referral_Source__c.contains('HCP')) {
                pe.Source_Type__c = ParticipantEnrollmentService.PE_SOURCE_TYPE_RP;
            } else {
                pe.Source_Type__c = ParticipantEnrollmentService.PE_SOURCE_TYPE_EPR;
            }
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
    private static void createVisitsSchedule(List<Participant_Enrollment__c> enrollments, Map<Id, Participant_Enrollment__c> oldMap) {
        List<Participant_Enrollment__c> peEnrollSuccessWithParticipating = new List<Participant_Enrollment__c>();
        for (Participant_Enrollment__c pe : enrollments) {
            if (oldMap == null || pe.Participant_Status__c != oldMap.get(pe.Id).Participant_Status__c) {
                if ((pe.Participant_Status__c == PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS
                        || pe.Participant_Status__c == PEStatusState.PE_STATUS_RANDOMIZATION_SUCCESS)
                        && ((Clinical_Trial_Profile__c) PETriggerBuffer.getSObject(pe.Clinical_Trial_Profile__c)).Patient_Portal_Enabled__c) {
                    peEnrollSuccessWithParticipating.add(pe);
                }
            }
        }
        Set<Id> visitPlanIds = new Set<Id>();
        for (Participant_Enrollment__c pe : enrollments) visitPlanIds.add(pe.Visit_Plan__c);
        Map<Id, Visit_Plan__c> visitPlansMap = new Map<Id, Visit_Plan__c>([
                SELECT Id, (SELECT Id, Name, Visit_Number__c, Visit_Schedule__c, Patient_Portal_Name__c FROM Visits__r)
                FROM Visit_Plan__c
                WHERE Id IN :visitPlanIds
        ]);

        List<Patient_Visit__c> patientVisits = new List<Patient_Visit__c>();
        for (Participant_Enrollment__c pe : peEnrollSuccessWithParticipating) {
            Id vpId = pe.Visit_Plan__c;
            if (vpId == null) continue;
            Visit_Plan__c vp = visitPlansMap.get(vpId);
            if (vp == null) continue;
            for (Visit__c visit : vp.Visits__r) {
                patientVisits.add(PatientVisitService.createPatientVisit(visit, pe.Id));
            }
        }
        if (patientVisits.size() > 0) insert patientVisits;
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
    private static void updateParticipantStudyStatus(List<Participant_Enrollment__c> newList, Map<Id, Participant_Enrollment__c> oldMap) {
        List<Participant__c> participants = new List<Participant__c>();
        for (Participant_Enrollment__c pe : newList) {
            if (oldMap == null || oldMap != null && pe.Participant_Status__c != oldMap.get(pe.Id).Participant_Status__c) {
                Participant__c participant = (Participant__c) PETriggerBuffer.getSObject(pe.Participant__c);
                if (participant != null) participants.add(participant);
            }
        }

        ParticipantEnrollmentService.updateParticipantState(participants);
    }
}