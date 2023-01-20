/**
 * Created by D.Yasinskyi on 26.04.2018
 * Refactored by L.Bartenev
 */

public without sharing class ParticipantEnrollmentTriggerHandler {
    // Handlers: -------------------------------------------------------------------------------------------------------
    public static final List<User> isValidUsr = [
        SELECT Id
        FROM User
        WHERE Profile.Name = 'API Only'
    ];
    public class PrepareAdditionalFieldsHandler extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            prepareAdditionalFields(newList, null);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            prepareAdditionalFields(newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }
    }

    public class UpdateInitialVisits extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            updatePatientVisits((List<Participant_Enrollment__c>) newList, null);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updatePatientVisits(
                (List<Participant_Enrollment__c>) newList,
                (Map<Id, Participant_Enrollment__c>) oldMap
            );
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
    public class UpdateParticipantInitialVisit extends TriggerHandler {
        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            disablePESH(newList, (Map<Id, Participant_Enrollment__c>) oldMap);
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
    }
    public class DefaultEcoaTask extends TriggerHandler {
        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createDefaultTaskForEcoa(newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }
    }
    public class CompleteEnrollmentTasks extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            completeTasks(
                (List<Participant_Enrollment__c>) newList,
                (Map<Id, Participant_Enrollment__c>) oldMap
            );
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
    /*For Welcome Msg -- Added by Anitha*/
    public class createNotifications extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            createnotificationforwelcomemsg(newList, null);
        }
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createnotificationforwelcomemsg(newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }
    }
    public class CreateMissingStatuses extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createPrimaryHistoryEntry(
                (List<Participant_Enrollment__c>) newList,
                (Map<Id, Participant_Enrollment__c>) oldMap
            );
        }

        public override void afterInsert(List<SObject> newList) {
            createPrimaryHistoryEntry((List<Participant_Enrollment__c>) newList, null);
        }
    }

    // Handlers: On study ----------------------------------------------------------------------------------------------
    public class DeactivateDeceasedUsersHandler extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            deactivateDeceasedUsers(
                (List<Participant_Enrollment__c>) newList,
                (Map<Id, Participant_Enrollment__c>) oldMap
            );
        }
    }

    public class CreateVisitsScheduleHandler extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            createVisitsSchedule((List<Participant_Enrollment__c>) newList, null);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createVisitsSchedule(
                (List<Participant_Enrollment__c>) newList,
                (Map<Id, Participant_Enrollment__c>) oldMap
            );
        }
    }

    public class HideSurveyTasks extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            hideSurveyTaskForCompletedStatuses(
                (List<Participant_Enrollment__c>) newList,
                (Map<Id, Participant_Enrollment__c>) oldMap
            );
        }
    }

    public class SendFOVtoAPI extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            sendtoAPIafterInsert((List<Participant_Enrollment__c>) newList);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            if (!Test.isRunningTest()) {
                sendtoAPIafterUpdate(
                    (List<Participant_Enrollment__c>) newList,
                    (Map<Id, Participant_Enrollment__c>) oldMap
                );
            }
        }
    }

    public class UnenrollorCancelPer extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            CreatePeshafterUpdate(
                (List<Participant_Enrollment__c>) newList,
                (Map<Id, Participant_Enrollment__c>) oldMap
            );
        }
    }

    public class EcoaEvents extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            CreateEcoaEvents(
                (List<Participant_Enrollment__c>) newList,
                (Map<Id, Participant_Enrollment__c>) oldMap
            );
        }
    }

    public class StudyConsentTimestamps extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            updateStudyConsentTimestamps((List<Participant_Enrollment__c>) newList);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updateStudyConsentTimestamps(
                (List<Participant_Enrollment__c>) newList,
                (Map<Id, Participant_Enrollment__c>) oldMap
            );
        }
    }

    public class UpdatePatientConsent extends TriggerHandler {
        Boolean isPortalUser = checkCurrentusrProfile();
        public override void beforeInsert(List<SObject> newList) {
            if (isPortalUser) {
                patientConsentUpdate((List<Participant_Enrollment__c>) newList, null);
            }
        }
        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            if (isPortalUser) {
                patientConsentUpdate(
                    (List<Participant_Enrollment__c>) newList,
                    (Map<Id, Participant_Enrollment__c>) oldMap
                );
            }
        }
    }

    // Logic: ----------------------------------------------------------------------------------------------------------
    //Update initial visit scheduled and completion date and time set by PI to
    //Patient Visit record.
    @TestVisible
    private static void updatePatientVisits(
        List<Participant_Enrollment__c> newList,
        Map<Id, Participant_Enrollment__c> oldMap
    ) {
        Set<Id> perIds = new Set<Id>();
        List<Patient_Visit__c> initialVisits;
        for (Participant_Enrollment__c per : newList) {
            if (
                //Update
                (oldMap != null &&
                (per.Initial_visit_scheduled_date__c !=
                oldMap.get(per.Id).Initial_visit_scheduled_date__c ||
                per.Initial_visit_scheduled_time__c !=
                oldMap.get(per.Id).Initial_visit_scheduled_time__c ||
                per.Initial_visit_occurred_flag__c !=
                oldMap.get(per.Id).Initial_visit_occurred_flag__c ||
                per.Initial_visit_occurred_date__c !=
                oldMap.get(per.Id).Initial_visit_occurred_date__c)) ||
                //Insert
                (oldMap == null &&
                (per.Initial_visit_scheduled_date__c != null ||
                per.Initial_visit_scheduled_time__c != null ||
                per.Initial_visit_occurred_date__c != null ||
                per.Initial_visit_occurred_flag__c))
            ) {
                perIds.add(per.Id);
            }
        }
        if (perIds.isEmpty()) {
            return;
        }
        initialVisits = [
            SELECT
                id,
                Participant_Enrollment__c,
                Participant_Enrollment__r.Initial_visit_scheduled_date__c,
                Participant_Enrollment__r.Initial_visit_scheduled_time__c,
                Participant_Enrollment__r.Initial_visit_occurred_flag__c,
                Participant_Enrollment__r.Initial_visit_occurred_date__c,
                Completed_Date__c,
                Planned_Date__c,
                Status__c,
                Visit__c
            FROM Patient_Visit__c
            WHERE
                Visit__r.Visit_Plan__r.Is_Pre_Enrollment_Visit_Plan__c = :true
                AND Participant_Enrollment__c IN :perIds
                //For 2.0 studies
                AND Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c = :'PatientPortal'
                AND Participant_Enrollment__r.Clinical_Trial_Profile__r.Is_Program__c = :false
        ];

        if (!initialVisits.isEmpty()) {
            List<Patient_Visit__c> visitsToUpdate = new List<Patient_Visit__c>();
            for (Patient_Visit__c pv : initialVisits) {
                if (
                    //Update
                    (oldMap != null &&
                    pv.Participant_Enrollment__r.Initial_visit_scheduled_date__c !=
                    oldMap.get(pv.Participant_Enrollment__c).Initial_visit_scheduled_date__c ||
                    pv.Participant_Enrollment__r.Initial_visit_scheduled_time__c !=
                    oldMap.get(pv.Participant_Enrollment__c).Initial_visit_scheduled_time__c) ||
                    //Insert
                    (oldMap == null &&
                    (pv.Participant_Enrollment__r.Initial_visit_scheduled_date__c != null ||
                    pv.Participant_Enrollment__r.Initial_visit_scheduled_time__c != null))
                ) {
                    pv.Planned_Date__c = pv.Participant_Enrollment__r.Initial_visit_scheduled_date__c !=
                        null
                        ? DateTime.newInstanceGmt(
                              pv.Participant_Enrollment__r.Initial_visit_scheduled_date__c,
                              pv.Participant_Enrollment__r.Initial_visit_scheduled_time__c != null
                                  ? pv.Participant_Enrollment__r.Initial_visit_scheduled_time__c
                                  : Time.newInstance(0, 0, 0, 0)
                          )
                        : null;
                    visitsToUpdate.add(pv);
                }
                if (
                    //Update
                    (oldMap != null &&
                    (pv.Participant_Enrollment__r.Initial_visit_occurred_date__c !=
                    oldMap.get(pv.Participant_Enrollment__c).Initial_visit_occurred_date__c ||
                    pv.Participant_Enrollment__r.Initial_visit_occurred_flag__c !=
                    oldMap.get(pv.Participant_Enrollment__c).Initial_visit_occurred_flag__c)) ||
                    //Insert
                    (oldMap == null &&
                    (pv.Participant_Enrollment__r.Initial_visit_occurred_date__c != null ||
                    pv.Participant_Enrollment__r.Initial_visit_occurred_flag__c != null))
                ) {
                    pv.Completed_Date__c = pv.Participant_Enrollment__r.Initial_visit_occurred_date__c !=
                        null
                        ? DateTime.newInstanceGmt(
                                  pv.Participant_Enrollment__r.Initial_visit_occurred_date__c,
                                  Time.newInstance(0, 0, 0, 0)
                              )
                              .dateGMT()
                        : null;
                    visitsToUpdate.add(pv);
                    if (pv.Participant_Enrollment__r.Initial_visit_occurred_flag__c) {
                        pv.Status__c = 'Completed';
                        visitsToUpdate.add(pv);
                    }
                }
            }
            update visitsToUpdate;
        }
    }

    @TestVisible
    private static void prepareAdditionalFields(
        List<Participant_Enrollment__c> newList,
        Map<Id, Participant_Enrollment__c> oldMap
    ) {
        List<Contact> participantContacts = new List<Contact>();
        for (Participant_Enrollment__c pe : newList) {
            String nctNumber;
            String protocolId;
            String participantName;
            Boolean visitOpt = false;

            if (pe.Study_Site__c != null) {
                Study_Site__c ss = (Study_Site__c) PETriggerBuffer.getSObject(pe.Study_Site__c);
                if (ss != null) {
                    String ExternalKey;
                    pe.PI_Contact__c = ss.Principal_Investigator__c;
                    pe.Clinical_Trial_Profile__c = ss.Clinical_Trial_Profile__c;
                    nctNumber = ss.Clinical_Trial_Profile__r.NCT_Number__c;
                    protocolId = ss.Clinical_Trial_Profile__r.Protocol_ID__c;
                    if (protocolId != null) {
                        ExternalKey = protocolId + '~';
                    } else {
                        ExternalKey = '~';
                    }
                    if (ss.Study_Site_Number__c != null) {
                        ExternalKey = ExternalKey + ss.Study_Site_Number__c + '~';
                    } else {
                        ExternalKey = ExternalKey + '~';
                    }
                    if (pe.Screening_ID__c != null) {
                        ExternalKey = ExternalKey + pe.Screening_ID__c;
                    } else {
                        ExternalKey = ExternalKey + '';
                    }
                    pe.External_Key_WF__c = ExternalKey;
                    visitOpt = ss.Clinical_Trial_Profile__r.Shareback_Settings_On_Participant_Level__c;
                }
            }
            if (pe.HCP__c != null) {
                HCP_Enrollment__c hcpe = (HCP_Enrollment__c) PETriggerBuffer.getSObject(pe.HCP__c);
                if (hcpe != null)
                    pe.HCP_Contact_HCPEnroll__c = hcpe.HCP_Contact__c;
            }
            if (pe.Participant__c != null) {
                Participant__c participant = (Participant__c) PETriggerBuffer.getSObject(
                    pe.Participant__c
                );
                if (participant != null) {
                    //Copy Participant Name to Enrollment before insert
                    if (oldMap == null) {
                        pe.Participant_Name__c = participant.First_Name__c;
                        pe.Participant_Surname__c = participant.Last_Name__c;
                    }
                    pe.Participant_Contact__c = participant.Contact__c;
                    if (oldMap == null && pe.Participant_Contact__c != null) {
                        participant.Contact__r.Visit_Results_OptIn__c = visitOpt
                            ? 'Vitals;Labs;Biomarkers'
                            : null;
                        participant.Contact__r.UserCommunityIsDelegate__c = false;
                        participantContacts.add(participant.Contact__r);
                    }
                    participantName = participant.Name;
                }
            }
            //populate Participant Code
            if (pe.Participant_Key__c == null) {
                if (protocolId != null && participantName != null) {
                    pe.Participant_Key__c = participantName + ' ' + protocolId;
                }
            }
            //populate referred date
            if (
                (oldMap == null &&
                PEStatusState.PE_ORDERED_STATUSES.containsKey(pe.Participant_Status__c) &&
                pe.Referred_Date__c == null) ||
                (oldMap != null &&
                oldMap.get(pe.Id).Participant_Status__c != pe.Participant_Status__c &&
                pe.Participant_Status__c == PEStatusState.PE_STATUS_RECEIVED)
            ) {
                pe.Referred_Date__c = Date.today();
            }

            pe.Initial_visit_scheduled_flag__c =
                (pe.Initial_visit_scheduled_date__c != null &&
                pe.Initial_visit_scheduled_time__c != null) || pe.Initial_visit_occurred_flag__c; // @Krishna Mahto: Changes for REF-1390- added Initial_visit_scheduled_time__c
        }

        if (!participantContacts.isEmpty())
            update participantContacts;
    }

    @TestVisible
    private static void studySiteHistory(
        List<Participant_Enrollment__c> newList,
        Map<Id, Participant_Enrollment__c> oldMap
    ) {
        List<Participant_Site_History__c> participantSiteHistories = new List<Participant_Site_History__c>();
        for (Participant_Enrollment__c pe : newList) {
            if (
                oldMap != null &&
                oldMap.get(pe.Id).Study_Site__c != null &&
                pe.Study_Site__c != oldMap.get(pe.Id).Study_Site__c
            ) {
                participantSiteHistories.add(
                    new Participant_Site_History__c(
                        Study_Site__c = oldMap.get(pe.Id).Study_Site__c,
                        Participant_Enrollment__c = pe.Id
                    )
                );
            }
        }

        if (!participantSiteHistories.isEmpty())
            insert participantSiteHistories;
    }

    @TestVisible
    private static void checkVisitPlanFromStudySite(
        List<Participant_Enrollment__c> newList,
        Map<Id, Participant_Enrollment__c> oldMap
    ) {
        Set<Id> studySiteIds = new Set<Id>();
        for (Participant_Enrollment__c pe : newList) {
            Boolean needsVisitPlanCheck =
                oldMap != null &&
                oldMap.get(pe.Id).Study_Site__c != null &&
                oldMap.get(pe.Id).Study_Site__c != pe.Study_Site__c;
            if (
                needsVisitPlanCheck &&
                PEStatusState.PE_STATUS_GROUP_VISIT_PLAN_CHECK.contains(pe.Participant_Status__c)
            ) {
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
                if (
                    pe.Visit_Plan__c != null &&
                    (visitPlansBySSId.get(pe.Study_Site__c) == null ||
                    visitPlansBySSId.get(pe.Study_Site__c).isEmpty() ||
                    !visitPlansBySSId.get(pe.Study_Site__c).contains(pe.Visit_Plan__c))
                ) {
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
            if (
                pe.Participant_Status__c != null &&
                pe.Participant_Status_Last_Changed_Date__c == null
            ) {
                pe.Participant_Status_Last_Changed_Date__c = Datetime.now();
            }
        }
    }

    @TestVisible
    private static void resetNotesAndSetChangeDate(
        List<Participant_Enrollment__c> newList,
        Map<Id, Participant_Enrollment__c> oldMap
    ) {
        for (Participant_Enrollment__c pe : newList) {
            if (
                pe.Participant_Status__c != oldMap.get(pe.Id).Participant_Status__c ||
                pe.Participant_Status_Last_Changed_Date__c !=
                oldMap.get(pe.Id).Participant_Status_Last_Changed_Date__c ||
                pe.Last_Status_Changed_Notes__c != oldMap.get(pe.Id).Last_Status_Changed_Notes__c
            ) {
                if (
                    pe.Participant_Status_Last_Changed_Date__c ==
                    oldMap.get(pe.Id).Participant_Status_Last_Changed_Date__c
                ) {
                    if (
                        pe.Last_Status_Changed_Notes__c ==
                        oldMap.get(pe.Id).Last_Status_Changed_Notes__c
                    ) {
                        pe.Last_Status_Changed_Notes__c = null;
                    }
                }
                pe.Participant_Status_Last_Changed_Date__c = Datetime.now();
            }
        }
    }

    @TestVisible
    private static void createTasks(List<Participant_Enrollment__c> newList) {
        List<Participant_Enrollment__c> enrollments = new List<Participant_Enrollment__c>();
        Set<Id> participantContactIds = new Set<Id>();
        for (Participant_Enrollment__c pe : newList) {
            if (
                pe.Participant_Contact__c != null &&
                ((Clinical_Trial_Profile__c) PETriggerBuffer.getSObject(
                        pe.Clinical_Trial_Profile__c
                    ))
                    .Tasks_Are_Available__c
            ) {
                participantContactIds.add(pe.Participant_Contact__c);
                enrollments.add(pe);
            }
        }

        if (enrollments.isEmpty())
            return;

        Map<Id, User> usersByContactId = new Map<Id, User>();
        for (User user : CommunityService.getCommunityUsersByContactIds(participantContactIds)) {
            usersByContactId.put(user.ContactId, user);
        }

        List<Task> tasks = new List<Task>();
        for (Participant_Enrollment__c pe : enrollments) {
            // COI tasks for GSK
            String communityTemplate = ((Clinical_Trial_Profile__c) PETriggerBuffer.getSObject(
                    pe.Clinical_Trial_Profile__c
                ))
                .CommunityTemplate__c;
            if (
                communityTemplate == CommunityTemplateService.TEMPLATE_GSK &&
                !PEStatusState.PE_STATUS_GROUP_ALUMNI.contains(pe.Participant_Status__c)
            ) {
                Task t = new Task(
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
        if (!tasks.isEmpty())
            insert tasks;
    }

    @TestVisible
    private static void completeTasks(
        List<Participant_Enrollment__c> newList,
        Map<Id, Participant_Enrollment__c> oldMap
    ) {
        Set<Id> peIds = new Set<Id>();
        for (Participant_Enrollment__c pe : newList) {
            if (PEStatusState.PE_STATUS_GROUP_ALUMNI.contains(pe.Participant_Status__c)) {
                peIds.add(pe.Id);
            }
        }

        if (peIds.isEmpty())
            return;

        List<Task> tasks = new List<Task>(
            [
                SELECT Status, Completed_Date__c
                FROM Task
                WHERE
                    WhatId IN :peIds
                    AND Task_Code__c = :TaskService.TASK_CODE_SELECT_COI
                    AND Status != :TaskService.TASK_STATUS_COMPLETED
            ]
        );

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
        List<Id> petoUpdate = new List<Id>();
        List<Participant_Enrollment_Status_History__c> histories = new List<Participant_Enrollment_Status_History__c>();
        List<Participant_Enrollment_Status_History__c> historiestoupdate = new List<Participant_Enrollment_Status_History__c>();
        List<Participant_Enrollment__c> peListForTaskCreation = new List<Participant_Enrollment__c>();
        Set<Id> participantContactIds = new Set<Id>();
        Set<Id> invitedContactIds = new Set<Id>();
        List<Notification__c> notifications = new List<Notification__c>();

        for (Participant_Enrollment__c pe : enrollments) {
            if (pe.Participant_Status__c == PEStatusState.PE_STATUS_RECEIVED) {
                if (
                    oldMap == null ||
                    (oldMap != null &&
                    oldMap.get(pe.Id).Participant_Status__c != PEStatusState.PE_STATUS_RECEIVED)
                ) {
                    histories.add(
                        new Participant_Enrollment_Status_History__c(
                            Date__c = pe.Participant_Status_Last_Changed_Date__c,
                            Status__c = pe.Participant_Status__c,
                            Notes__c = pe.Non_Referral_Notes__c,
                            ParticipantEnrollment__c = pe.Id,
                            Non_Enrollment_Reason__c = pe.Non_Referral_Reason__c
                        )
                    );
                    peListForTaskCreation.add(pe);
                    if (pe.Participant_Contact__c != null) {
                        participantContactIds.add(pe.Participant_Contact__c);
                        if (pe.Invited_To_PP_Date__c != null) {
                            invitedContactIds.add(pe.Participant_Contact__c);
                        }
                    }
                }
            } else if (pe.Participant_Status__c == PEStatusState.PE_STATUS_ELIGIBILITY_PASSED) {
                if (
                    oldMap == null ||
                    (oldMap != null &&
                    oldMap.get(pe.Id).Participant_Status__c !=
                    PEStatusState.PE_STATUS_ELIGIBILITY_PASSED)
                ) {
                    if (
                        oldMap != null &&
                        oldMap.get(pe.Id).Participant_Status__c != 'Successfully Contacted'
                    ) {
                        histories.add(
                            new Participant_Enrollment_Status_History__c(
                                Date__c = pe.Participant_Status_Last_Changed_Date__c, //oldMap!=null && oldMap.get(pe.Id)!=null?oldMap.get(pe.Id).Participant_Status_Last_Changed_Date__c:pe.Participant_Status_Last_Changed_Date__c.addSeconds(-1),
                                Status__c = 'Successfully Contacted',
                                ParticipantEnrollment__c = pe.Id
                            )
                        );
                        if (pe.Initial_visit_scheduled_flag__c == true) {
                            peToUpdate.add(pe.Id);
                        }
                    }

                    histories.add(
                        new Participant_Enrollment_Status_History__c(
                            Date__c = pe.Participant_Status_Last_Changed_Date__c,
                            Status__c = pe.Participant_Status__c,
                            Notes__c = pe.Non_Referral_Notes__c,
                            ParticipantEnrollment__c = pe.Id,
                            Non_Enrollment_Reason__c = pe.Non_Referral_Reason__c
                        )
                    );
                    peListForTaskCreation.add(pe);
                    if (pe.Participant_Contact__c != null) {
                        participantContactIds.add(pe.Participant_Contact__c);
                        if (pe.Invited_To_PP_Date__c != null) {
                            invitedContactIds.add(pe.Participant_Contact__c);
                        }
                    }
                }
            } else if (oldMap == null) {
                peListForTaskCreation.add(pe);
                Clinical_Trial_Profile__c ctp = (Clinical_Trial_Profile__c) PETriggerBuffer.getSObject(
                    pe.Clinical_Trial_Profile__c
                );
                if (pe.Participant_Contact__c != null) {
                    participantContactIds.add(pe.Participant_Contact__c);
                    if (pe.Invited_To_PP_Date__c != null) {
                        invitedContactIds.add(pe.Participant_Contact__c);
                    }
                }

                histories.addAll(ParticipantWorkflowService.createHistoryRecordsForPE(pe, ctp));
            }
        }

        if (!peToUpdate.isEmpty()) {
            for (Participant_Enrollment_Status_History__c peshold : [
                SELECT
                    Id,
                    Additional_Notes__c,
                    ParticipantEnrollment__r.Clinical_Trial_Profile__r.Initial_Visit_Required__c
                FROM Participant_Enrollment_Status_History__c
                WHERE
                    Status__c = 'Successfully Contacted'
                    AND ParticipantEnrollment__c IN :peToUpdate
            ]) {
                if (
                    peshold.ParticipantEnrollment__r.Clinical_Trial_Profile__r.Initial_Visit_Required__c ==
                    true &&
                    peshold.Additional_Notes__c != null &&
                    peshold.Additional_Notes__c != '' &&
                    !peshold.Additional_Notes__c.contains('####')
                ) {
                    Participant_Enrollment_Status_History__c up = new Participant_Enrollment_Status_History__c();
                    up.Additional_Notes__c = '####' + peshold.Additional_Notes__c;
                    up.Id = peshold.Id;
                    histories.add(up);
                }
            }
        }

        if (!histories.isEmpty()) {
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.UpdatePEHandler.class
            );
            upsert histories;
        }
        createTasks(peListForTaskCreation);
        PatientDelegateService.updateContactPermSetsWithDelegates(
            participantContactIds,
            invitedContactIds
        );

        if (!notifications.isEmpty())
            insert notifications;
    }

    @TestVisible
    private static void updateWithStepSuccessFlags(List<Participant_Enrollment__c> enrollments) {
        for (Participant_Enrollment__c pe : enrollments) {
            ParticipantWorkflowService.updatePEWithPreviousStatusesSuccess(
                pe,
                (Clinical_Trial_Profile__c) PETriggerBuffer.getSObject(pe.Clinical_Trial_Profile__c)
            );
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
    public static void deactivateDeceasedUsers(
        List<Participant_Enrollment__c> enrollments,
        Map<Id, Participant_Enrollment__c> oldMap
    ) {
        List<Id> contactIds = new List<Id>();
        for (Participant_Enrollment__c pe : enrollments) {
            if (
                pe.Participant_Status__c == PEStatusState.PE_STATUS_DECEASED &&
                pe.Participant_Status__c != oldMap.get(pe.Id).Participant_Status__c
            ) {
                contactIds.add(pe.Participant_Contact__c);
            }
        }
        if (!contactIds.isEmpty())
            deactivateUsers(contactIds);
    }

    @Future
    private static void deactivateUsers(List<Id> contactIds) {
        List<User> users = [
            SELECT Id, IsActive, ContactId
            FROM User
            WHERE ContactId IN :contactIds
        ];
        for (User u : users)
            u.IsActive = false;
        update users;
    }

    @TestVisible
    private static void createVisitsSchedule(
        List<Participant_Enrollment__c> enrollments,
        Map<Id, Participant_Enrollment__c> oldMap
    ) {
        List<Participant_Enrollment__c> peEnrollSuccessWithParticipating = new List<Participant_Enrollment__c>();
        List<Participant_Enrollment__c> peInPreEnrollmentStatus = new List<Participant_Enrollment__c>();
        Map<Id, Id> peIdInPreEnrollmentStatusStudySiteMap = new Map<Id, id>();
        //Set<Id> peIdsToCompletePreEnrollVisits = new Set<Id>();
        for (Participant_Enrollment__c pe : enrollments) {
            if (
                oldMap == null ||
                pe.Participant_Status__c != oldMap.get(pe.Id).Participant_Status__c ||
                (oldMap.get(pe.Id).Visit_Plan__c != null ||
                pe.Visit_Plan__c != null)
            ) {
                if (
                    (pe.Participant_Status__c == PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS ||
                    pe.Participant_Status__c == PEStatusState.PE_STATUS_RANDOMIZATION_SUCCESS) &&
                    ((Clinical_Trial_Profile__c) PETriggerBuffer.getSObject(
                            pe.Clinical_Trial_Profile__c
                        ))
                        .Patient_Portal_Enabled__c
                ) {
                    peEnrollSuccessWithParticipating.add(pe);
                }
            }
            //Get the Particiapant Enrollments which are on PreEnrollment Status.
            if (
                oldMap == null ||
                pe.Participant_Status__c != oldMap.get(pe.Id).Participant_Status__c
            ) {
                // check if the Participant Enrollment are on one of the Pre Enrollment statuses or Status which qualify to complete the Pre Enrollment Visits.
                if (
                    PEStatusState.PE_STATUS_GROUP_PRE_ENROLLMENT.contains(
                        pe.Participant_Status__c
                    ) ||
                    PEStatusState.PE_STATUS_GROUP_FOR_COMPLETING_PRE_ENROLL_VISITS.contains(
                        pe.Participant_Status__c
                    )
                ) {
                    peIdInPreEnrollmentStatusStudySiteMap.put(pe.Id, pe.Study_Site__c);
                }
            }
        }

        Set<Id> ctpIds = new Set<Id>();
        for (Participant_Enrollment__c pe : peEnrollSuccessWithParticipating)
            ctpIds.add(pe.Clinical_Trial_Profile__c);
        Map<Id, Clinical_Trial_Profile__c> ctpMap = new Map<Id, Clinical_Trial_Profile__c>();
        for (Id ctpId : ctpIds) {
            ctpMap.put(ctpId, (Clinical_Trial_Profile__c) PETriggerBuffer.getSObject(ctpId));
        }
        Set<Id> visitPlanIds = new Set<Id>();
        for (Clinical_Trial_Profile__c ctp : ctpMap.values())
            visitPlanIds.add(ctp.Visit_Plan__c);
        for (Participant_Enrollment__c pe : enrollments)
            visitPlanIds.add(pe.Visit_Plan__c);
        Map<Id, Visit_Plan__c> visitPlansMap = new Map<Id, Visit_Plan__c>(
            [
                SELECT
                    Id,
                    (
                        SELECT Id, Name, Visit_Number__c, Visit_Schedule__c, Patient_Portal_Name__c
                        FROM Visits__r
                    )
                FROM Visit_Plan__c
                WHERE Id IN :visitPlanIds
            ]
        );

        List<Patient_Visit__c> patientVisits = new List<Patient_Visit__c>();
        List<Patient_Visit__c> dupCheckpatientVisits = new List<Patient_Visit__c>();
        Map<Id, List<Patient_Visit__c>> mapVisit = new Map<Id, List<Patient_Visit__c>>();
        Map<Id, Id> enrollmentPlandId = new Map<Id, Id>();
        set<Id> visitPlanId = new Set<Id>();
        set<Id> participantEnrollmentId = new Set<Id>();
        for (Participant_Enrollment__c pe : peEnrollSuccessWithParticipating) {
            Clinical_Trial_Profile__c ctp = ctpMap.get(pe.Clinical_Trial_Profile__c);
            participantEnrollmentId.add(pe.Id);
            Id vpId = pe.Visit_Plan__c;
            if (vpId == null)
                vpId = ctp.Visit_Plan__c;
            if (vpId == null)
                continue;
            Visit_Plan__c vp = visitPlansMap.get(vpId);
            visitPlanId.add(vp.Id);
            enrollmentPlandId.put(pe.Id, vp.Id);
            if (vp == null)
                continue;
            for (Visit__c visit : vp.Visits__r) {
                if (mapVisit.containsKey(pe.Id)) {
                    mapVisit.get(pe.Id).add(PatientVisitService.createPatientVisit(visit, pe.Id));
                } else {
                    mapVisit.put(
                        pe.Id,
                        new List<Patient_Visit__c>{
                            PatientVisitService.createPatientVisit(visit, pe.Id)
                        }
                    );
                }
            }
        }
        if (participantEnrollmentId != null && visitPlanId != null) {
            dupCheckpatientVisits = [
                SELECT Participant_Enrollment__c, Visit__r.Visit_Plan__r.Id
                FROM Patient_Visit__c
                WHERE
                    Participant_Enrollment__c IN :participantEnrollmentId
                    AND Visit__r.Visit_Plan__r.Id IN :visitPlanId
            ];
        }
        for (Patient_Visit__c pv : dupCheckpatientVisits) {
            if (
                enrollmentPlandId.get(pv.Participant_Enrollment__c) == pv.Visit__r.Visit_Plan__r.Id
            ) {
                participantEnrollmentId.remove(pv.Participant_Enrollment__c);
            }
        }
        for (Id peId : mapVisit.Keyset()) {
            if (participantEnrollmentId.contains(peId)) {
                patientVisits.addAll(mapVisit.get(peId));
            }
        }
        if (patientVisits.size() > 0)
            insert patientVisits;

        //Create Pre Enrollment patient Visit for the Participant on Pre Enrollment Status.
        if (
            peIdInPreEnrollmentStatusStudySiteMap != null &&
            !peIdInPreEnrollmentStatusStudySiteMap.isEmpty()
        ) {
            PreEnrollmentPatientVisitServie.processPreEnrollmentPatientVisits(
                peIdInPreEnrollmentStatusStudySiteMap
            );
        }
    }

    @TestVisible
    private static void hideSurveyTaskForCompletedStatuses(
        List<Participant_Enrollment__c> newList,
        Map<Id, Participant_Enrollment__c> oldMap
    ) {
        List<Participant_Enrollment__c> completedPEs = new List<Participant_Enrollment__c>();
        for (Participant_Enrollment__c pe : newList) {
            if (
                pe.Participant_Status__c != oldMap.get(pe.Id).Participant_Status__c &&
                PEStatusState.PE_STATUS_GROUP_COMPLETE.contains(pe.Participant_Status__c)
            ) {
                completedPEs.add(pe);
            }
        }
        if (completedPEs.isEmpty())
            return;

        Map<Id, SurveyInvitation> invitationMap = new Map<Id, SurveyInvitation>(
            [
                SELECT Id
                FROM SurveyInvitation
                WHERE Participant_Enrollment__c IN :completedPEs AND Is_Midpoint__c = TRUE
            ]
        );
        if (invitationMap.keySet().isEmpty())
            return;

        List<Task> tasks = [
            SELECT Id
            FROM Task
            WHERE
                Task_Type__c = :TaskService.TASK_TYPE_SURVEY
                AND Status IN :TaskService.TASK_STATUS_GROUP_AVAILABLE
                AND Survey_Invitation__c IN :invitationMap.keySet()
        ];

        List<Task> tasksForExpire = new List<Task>();
        for (Task task : tasks) {
            task.Status = TaskService.TASK_STATUS_EXPIRED;
            tasksForExpire.add(task);
        }
        update tasksForExpire;

        SurveyService.getInstance().expireInvitation(new List<Id>(invitationMap.keySet()));
    }
    /*For Welcome Msg -- Added by Anitha Start*/
    @TestVisible
    private static void createnotificationforwelcomemsg(
        List<Participant_Enrollment__c> newList,
        Map<Id, Participant_Enrollment__c> oldMap
    ) {
        Map<Id, Participant_Enrollment__c> perParticipant = new Map<Id, Participant_Enrollment__c>();
        Map<Id, List<Id>> partPerDelegateIds = new Map<Id, List<Id>>();
        List<ID> participantids = new List<ID>();
        List<ID> delegateconids = new List<ID>();
        Set<ID> proccessedParticipants = new Set<ID>();
        Map<ID, Map<Id, Boolean>> delegatewelcomemsg = new Map<ID, Map<ID, Boolean>>();
        Map<Id, Participant__c> participantconMap;
        List<Notification__c> welcomemsgnotifications = new List<Notification__c>();
        List<Participant_Enrollment__c> perToBeUpdated = new List<Participant_Enrollment__c>(); //For updating the welcome msg flag - Added by Sonal

        for (Participant_Enrollment__c pe : newList) {
            if (
                oldMap == null &&
                pe.Participant__c != null &&
                pe.Is_Participant_Adult__c &&
                pe.Participant_Contact__c != null &&
                !pe.Is_Contact_welcome_Message_Sent__c &&
                pe.Is_Participant_Contact_Opt_in_SMS__c
            ) {
                system.debug('platform Level');
                /*Platform Level PT mEsg*/
                welcomemsgnotifications.addAll(
                    ContactService.addwelcomeNotifications(
                        pe.Participant_Contact__c,
                        pe.Participant__c,
                        NotificationCatalog.MSG_TO_PT_PLATFORM_LVL_WELCME_MSG,
                        false
                    )
                );
            }
            Boolean studylevelPTUpdate = (oldMap != null &&
            pe.Permit_SMS_Text_for_this_study__c &&
            pe.Is_Study_Site_SMS_Are_Available__c &&
            (pe.Permit_SMS_Text_for_this_study__c !=
            oldMap.get(pe.Id).Permit_SMS_Text_for_this_study__c));

            Boolean studylevelPTInsert = (oldMap == null &&
            pe.Permit_SMS_Text_for_this_study__c &&
            pe.Is_Study_Site_SMS_Are_Available__c);

            if (
                !pe.Welcome_Message_Sent__c &&
                pe.Study_Site__c != null &&
                pe.Participant__c != null &&
                ((studylevelPTInsert) || (studylevelPTUpdate))
            ) {
                system.debug('Study Level PT');
                /*Study Level PT mEsg*/
                if (pe.Is_Participant_Adult__c) {
                    system.debug('Study Level PT is added');
                    welcomemsgnotifications.addAll(
                        ContactService.addwelcomeNotifications(
                            pe.Participant_Contact__c,
                            pe.Id,
                            NotificationCatalog.MESSAGE_TO_PT_STUDY_LEVEL_WELCOME_MSG,
                            false
                        )
                    );
                }
                //For study level Delegates
                if (!String.isBlank(pe.Participant__c)) {
                    participantids.add(pe.Participant__c);
                }
            } else if (
                oldMap != null &&
                pe.Permit_SMS_Text_for_this_study__c !=
                oldMap.get(pe.Id).Permit_SMS_Text_for_this_study__c &&
                !pe.Permit_SMS_Text_for_this_study__c
            ) {
                Participant_Enrollment__c tempPer = new Participant_Enrollment__c(Id = pe.Id); //For updating the welcome msg flag - Added by Sonal
                tempPer.Welcome_Message_Sent__c = false;
                tempPer.Welcome_Message_Delivered__c = false;
                perToBeUpdated.add(tempPer);
            }
        }
        if (participantids.size() > 0) {
            String fieldFilter = 'Patient_Delegate__r.Participant__c';
            PatientDelegateEnrollmentService.PDEWrapper pdewrapper = PatientDelegateEnrollmentService.getDelegatedContactIdsByParticipantIdMap(
                participantIds,fieldFilter
            );
           partPerDelegateIds = pdewrapper.delParticipantIds; // Actual participant with list of delegate contact IDs
    
            /*partPerDelegateIds = PatientDelegateService.getDelegatedContactIdsByParticipantIdMap(
                participantIds
            );*/
        }
        //Added for study Level Delegate
        //List<ParticipantEnrollmentPatientDelJunction__c> perDelJunctionRecList = new List<ParticipantEnrollmentPatientDelJunction__c>();
        for (Participant_Enrollment__c pe : newList) {
            if (
                oldMap == null &&
                !partPerDelegateIds.keySet().isEmpty() &&
                partPerDelegateIds.containsKey(pe.Participant__c)
            ) {
                /*if(!proccessedParticipants.contains(pe.Participant__c)){
                 proccessedParticipants.add(pe.Participant__c);*/
                for (Id delegateId : partPerDelegateIds.get(pe.Participant__c)) {
                    /*Study Level Delegate*/
                    welcomemsgnotifications.addAll(
                        ContactService.addwelcomeNotifications(
                            delegateId,
                            pe.Id,
                            NotificationCatalog.MSG_TO_DELEGATE_STUDY_LEVEL_WELCOME_MSG,
                            true
                        )
                    );
                    //Create jonction object record between PER and Patient Delegate contact records
                    /*ParticipantEnrollmentPatientDelJunction__c perPDJunObj = new ParticipantEnrollmentPatientDelJunction__c();
                    perPDJunObj.Participant_Enrollment__c = pe.Id;
                    perPDJunObj.Patient_Delegate_Contact__c = delegateId;
                    perPDJunObj.Process_Type__c = 'Welcome Message';
                    perDelJunctionRecList.Add(perPDJunObj);*/
                    Boolean isDelegatePlatformNotification =
                        ContactService.patientdelList.containskey(delegateId) &&
                        ContactService.patientdelList.get(delegateId)
                            .Contact__r.Participant_Opt_In_Status_SMS__c &&
                        !(ContactService.patientdelList.get(delegateId)
                            .Contact__r.Welcome_Message_Sent__c);

                    /*Platform Level Delegate*/
                    //if(delegatewelcomemsg.get(pe.Participant__c).Contact__c != null && !participantconMap.get(pe.Participant__c).Contact__r.Welcome_Message_Sent__c){
                    if (isDelegatePlatformNotification) {
                        welcomemsgnotifications.addAll(
                            ContactService.addwelcomeNotifications(
                                delegateId,
                                pe.Participant__c,
                                NotificationCatalog.MSG_TO_DELEGATE_PLATFORM_LVL_WELCME_MSG,
                                true
                            )
                        );
                    }
                }
                /*}*/
            }
        }
        if (!welcomemsgnotifications.isEmpty())
            insert welcomemsgnotifications;
        if (
            !perToBeUpdated.isEmpty() //For updating the welcome msg flag - Added by Sonal
        )
            update perToBeUpdated;

        /*if (perDelJunctionRecList != null && !perDelJunctionRecList.isEmpty()) {
            insert perDelJunctionRecList;
        }*/
    }
    /*For Welcome Msg -- Added by Anitha End*/
    @TestVisible
    private static void updateParticipantStudyStatus(
        List<Participant_Enrollment__c> newList,
        Map<Id, Participant_Enrollment__c> oldMap
    ) {
        List<Participant__c> participants = new List<Participant__c>();
        for (Participant_Enrollment__c pe : newList) {
            if (
                oldMap == null ||
                oldMap != null &&
                pe.Participant_Status__c != oldMap.get(pe.Id).Participant_Status__c
            ) {
                Participant__c participant = (Participant__c) PETriggerBuffer.getSObject(
                    pe.Participant__c
                );
                if (participant != null)
                    participants.add(participant);
            }
        }

        ParticipantEnrollmentService.updateParticipantState(participants);
        //ContactService.updateContactSite(participants);
    }

    @TestVisible
    private static void sendtoAPIafterInsert(List<Participant_Enrollment__c> newList) {
        List<Id> perIdList = new List<Id>();
        Datetime dt = datetime.now();
        for (Participant_Enrollment__c pe : newList) {
            if (
                pe.Initial_visit_scheduled_date__c != null &&
                pe.Initial_visit_scheduled_time__c != null &&
                ((pe.Initial_visit_scheduled_date__c == Date.today() &&
                pe.Initial_visit_scheduled_time__c > dt.time()) ||
                (pe.Initial_visit_scheduled_date__c > Date.today()))
            ) {
                perIdList.add(pe.Id);
            }
        }
        List<User> inValidUserList = isValidUsr;
        List<Participant_Enrollment__c> perDetailedList = [
            SELECT
                Id,
                Name,
                Participant_Status__c,
                Study_Site__c,
                Study_Site__r.Name,
                Study_Site__r.Scheduling_vendors__c,
                Initial_visit_scheduled_date__c,
                Initial_visit_scheduled_time__c,
                LastModifiedById
            FROM Participant_Enrollment__c
            WHERE
                Id IN :perIdList
                AND Study_Site__r.Scheduling_vendors__c != NULL
                AND LastModifiedById NOT IN :inValidUserList
        ];
        List<LL_RH_event__e> myPElist = new List<LL_RH_event__e>();
        for (Participant_Enrollment__c pe : perDetailedList) {
            LL_RH_event__e llrhEvent = new LL_RH_event__e();
            llrhEvent.ParticipantEnrollment_ID__c = String.valueOf(pe.Id);
            llrhEvent.Status__c = 'New';
            llrhEvent.Appointment_Id__c =
                String.valueOf(pe.Name) + String.valueOf(pe.Initial_visit_scheduled_date__c);
            myPElist.add(llrhEvent);
        }
        EventBus.publish(myPElist);
    }

    @TestVisible
    private static void sendtoAPIafterUpdate(
        List<Participant_Enrollment__c> newList,
        Map<Id, Participant_Enrollment__c> oldMap
    ) {
        // System.debug('#########newList: ' + newList);
        // System.debug('#########oldMap: ' + oldMap);
        //List all the records for which FOV date/time has been changed
        List<Id> perIdList = new List<Id>();
        Map<Id, String> idToStatusMap = new Map<Id, String>();
        for (Participant_Enrollment__c per : newList) {
            if (
                per.Initial_visit_scheduled_date__c !=
                oldMap.get(per.Id).Initial_visit_scheduled_date__c ||
                per.Initial_visit_scheduled_time__c !=
                oldMap.get(per.Id).Initial_visit_scheduled_time__c
            ) {
                if (
                    (oldMap.get(per.Id).Initial_visit_scheduled_date__c == null ||
                    oldMap.get(per.Id).Initial_visit_scheduled_time__c == null) &&
                    per.Initial_visit_scheduled_date__c != null &&
                    per.Initial_visit_scheduled_time__c != null
                ) {
                    idToStatusMap.put(per.Id, 'New');
                    perIdList.add(per.Id);
                } else if (
                    per.Initial_visit_scheduled_date__c != null &&
                    per.Initial_visit_scheduled_time__c != null
                ) {
                    idToStatusMap.put(per.Id, 'Reschedule');
                    perIdList.add(per.Id);
                } else if (
                    per.Initial_visit_scheduled_date__c == null &&
                    per.Initial_visit_scheduled_time__c == null
                ) {
                    idToStatusMap.put(per.Id, 'Cancel');
                    perIdList.add(per.Id);
                }
            }
        }
        Datetime dt = datetime.now();
        List<Participant_Enrollment__c> perFinalList = new List<Participant_Enrollment__c>();
        List<User> inValidUserList = isValidUsr;
        List<Participant_Enrollment__c> perList = [
            SELECT
                Id,
                Name,
                Participant_Status__c,
                Study_Site__c,
                Study_Site__r.Name,
                Study_Site__r.Scheduling_vendors__c,
                LastModifiedById,
                Initial_visit_scheduled_date__c,
                Initial_visit_scheduled_time__c
            FROM Participant_Enrollment__c
            WHERE
                Id IN :perIdList
                AND Study_Site__r.Scheduling_vendors__c != NULL
                AND LastModifiedById NOT IN :inValidUserList
        ];
        List<LL_RH_event__e> myPElist = new List<LL_RH_event__e>();

        for (Participant_Enrollment__c pe : perList) {
            LL_RH_event__e llrhEvent = new LL_RH_event__e();
            if (idToStatusMap.get(pe.Id) != 'Cancel') {
                if (
                    (pe.Initial_visit_scheduled_date__c == Date.today() &&
                    pe.Initial_visit_scheduled_time__c > dt.time()) ||
                    (pe.Initial_visit_scheduled_date__c > Date.today())
                ) {
                    llrhEvent.ParticipantEnrollment_ID__c = String.valueOf(pe.Id);
                    llrhEvent.Status__c = idToStatusMap.get(pe.Id);
                    llrhEvent.OldAppointmentDate__c = String.valueOf(
                        oldMap.get(pe.Id).Initial_visit_scheduled_date__c
                    );
                    llrhEvent.OldAppointmentTime__c = String.valueOf(
                        oldMap.get(pe.Id).Initial_visit_scheduled_time__c
                    );
                    llrhEvent.Appointment_Id__c =
                        String.valueOf(pe.Name) +
                        String.valueOf(pe.Initial_visit_scheduled_date__c);
                    myPElist.add(llrhEvent);
                }
            } else if (idToStatusMap.get(pe.Id) == 'Cancel') {
                llrhEvent.ParticipantEnrollment_ID__c = String.valueOf(pe.Id);
                llrhEvent.Status__c = idToStatusMap.get(pe.Id);
                llrhEvent.OldAppointmentDate__c = String.valueOf(
                    oldMap.get(pe.Id).Initial_visit_scheduled_date__c
                );
                llrhEvent.OldAppointmentTime__c = String.valueOf(
                    oldMap.get(pe.Id).Initial_visit_scheduled_time__c
                );
                llrhEvent.Appointment_Id__c =
                    String.valueOf(pe.Name) +
                    String.valueOf(oldMap.get(pe.Id).Initial_visit_scheduled_date__c);
                myPElist.add(llrhEvent);
            }
        }
        //System.debug('##### myPElist ' + myPElist);
        EventBus.publish(myPElist);
    }

    @TestVisible
    private static void CreatePeshafterUpdate(
        List<Participant_Enrollment__c> newList,
        Map<Id, Participant_Enrollment__c> oldMap
    ) {
        List<User> ValidUserList = new List<User>();
        List<Participant_Enrollment__c> perDetailedList = new List<Participant_Enrollment__c>();
        ValidUserList = isValidUsr;
        perDetailedList = [
            SELECT
                Id,
                Participant_Status__c,
                Participant_Status_Last_Changed_Date__c,
                Non_Referral_Reason__c,
                Non_Referral_Notes__c,
                Non_Enrollment_Reason__c,
                Last_Status_Changed_Notes__c,
                LastModifiedById
            FROM Participant_Enrollment__c
            WHERE
                Id IN :newList
                AND Participant_Status__c = 'Contacted - Not Suitable'
                AND LastModifiedById IN :ValidUserList
        ];
        if (perDetailedList != null && !perDetailedList.isEmpty() && perDetailedList.size() != 0) {
            List<Participant_Enrollment_Status_History__c> histories = new List<Participant_Enrollment_Status_History__c>();
            for (Participant_Enrollment__c pe : newList) {
                histories.add(
                    new Participant_Enrollment_Status_History__c(
                        Date__c = pe.Participant_Status_Last_Changed_Date__c,
                        Status__c = pe.Participant_Status__c,
                        Notes__c = pe.Last_Status_Changed_Notes__c,
                        ParticipantEnrollment__c = pe.Id,
                        Non_Enrollment_Reason__c = pe.Non_Enrollment_Reason__c
                    )
                );
            }
            if (histories != null && !histories.isEmpty()) {
                TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentSHTriggerHandler.UpdatePEHandler.class
                );
                insert histories;
            }
        }
    }
    public static void disablePESH(
        List<Participant_Enrollment__c> newList,
        Map<Id, Participant_Enrollment__c> oldMap
    ) {
        List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
        List<Participant_Enrollment_Status_History__c> peshList = new List<Participant_Enrollment_Status_History__c>();
        for (Participant_Enrollment__c per : newList) {
            if (
                (per.Initial_visit_scheduled_date__c !=
                oldMap.get(per.Id).Initial_visit_scheduled_date__c ||
                per.Initial_visit_scheduled_time__c !=
                oldMap.get(per.Id).Initial_visit_scheduled_time__c ||
                per.Initial_visit_occurred_flag__c !=
                oldMap.get(per.Id).Initial_visit_occurred_flag__c) &&
                ((per.Initial_visit_scheduled_date__c == null &&
                per.Initial_visit_occurred_flag__c == false) ||
                per.ParticipantNoShow__c == true ||
                per.Initial_visit_occurred_flag__c == false)
            ) {
                if (per.Status_Order__c > 3) {
                    per.Participant_Status__c = 'Successfully Contacted';
                    peList.add(per);
                }
                peList.add(per);
            }
        }
        for (Participant_Enrollment_Status_History__c pesh : [
            SELECT Id, Disabled_PESH__c, Status_Order__c
            FROM Participant_Enrollment_Status_History__c
            WHERE ParticipantEnrollment__c IN :peList
        ]) {
            if (pesh.Status_Order__c > 3) {
                pesh.Disabled_PESH__c = true;
                peshList.add(pesh);
            }
        }
        if (!peshList.isEmpty()) {
            update peshList;
        }
    }
    @TestVisible
    private static void createDefaultTaskForEcoa(
        List<Participant_Enrollment__c> newList,
        Map<Id, Participant_Enrollment__c> oldMap
    ) {
        List<Participant_Enrollment__c> enrollments = new List<Participant_Enrollment__c>();
        Set<Id> participantContactIds = new Set<Id>();
        for (Participant_Enrollment__c per : newList) {
            Boolean subjectGuidAdded = oldMap.get(per.Id).Subject_GUID__c != per.Subject_GUID__c
                ? true
                : false;
            if (subjectGuidAdded && per.Subject_GUID__c != null && per.Subject_GUID__c != '') {
                participantContactIds.add(per.Participant_Contact__c);
                enrollments.add(per);
            }
        }
        Map<Id, User> usersByContactId = new Map<Id, User>();
        List<Task> taskList = new List<Task>();
        for (User user : CommunityService.getCommunityUsersByContactIds(participantContactIds)) {
            usersByContactId.put(user.ContactId, user);
        }
        for (Participant_Enrollment__c per : enrollments) {
            Task t = new Task(
                Subject = TaskService.TASK_CODE_ECOA_TASK,
                Task_Code__c = TaskService.TASK_CODE_ECOA_TASK,
                Status = TaskService.TASK_STATUS_OPEN,
                Priority = TaskService.TASK_PRIORITY_CRITICAL,
                Action_URL__c = 'e-diaries',
                WhatId = per.Participant__c,
                WhoId = per.Participant_Contact__c,
                Visible_For__c = TaskService.TASK_VISIBILITY_ALL,
                Task_Type__c = TaskService.TASK_TYPE_NOT_SELECTED
            );
            if (usersByContactId.get(per.Participant_Contact__c) != null) {
                //if user exist then assign to him:
                t.OwnerId = usersByContactId.get(per.Participant_Contact__c).Id;
            } else {
                //if not, then mark owner contact, and task will be reassigned when user for this contact will be created
                t.Owner_Contact__c = per.Participant_Contact__c;
            }
            taskList.add(t);
        }
        if (!taskList.isEmpty())
            insert taskList;
    }
    public static void CreateEcoaEvents(
        List<Participant_Enrollment__c> newList,
        Map<Id, Participant_Enrollment__c> oldMap
    ) {
        Set<Id> peIds = new Set<Id>();
        if (newList != null) {
            for (Participant_Enrollment__c per : newList) {
                if (
                    per.Subject_GUID__c != null &&
                    oldMap.get(per.Id).Participant_Status__c != per.Participant_Status__c
                ) {
                    peIds.add(per.Id);
                }
            }
        }
        if (!peIds.isEmpty()) {
            perTriggerEcoaEventAsync(peIds);
        }
    }

    @Future(Callout=true)
    public static void perTriggerEcoaEventAsync(Set<Id> peIds) {
        List<Map<String, String>> requestMapList = new List<Map<String, String>>();
        for (Participant_Enrollment__c per : [
            SELECT
                Id,
                Subject_GUID__c,
                Clinical_Trial_Profile__r.Study_GUID__c,
                Participant_Status__c
            FROM Participant_Enrollment__c
            WHERE Id IN :peIds
        ]) {
            if (
                per.Clinical_Trial_Profile__r.Study_GUID__c != null &&
                ECOAService.apiParamsMap.get(ECOAService.ORG_GUID).ParamValue__c != null
            ) {
                string dateKey = '';
                if (
                    per.Participant_Status__c == PEStatusState.PE_STATUS_RANDOMIZATION_SUCCESS ||
                    per.Participant_Status__c == PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS ||
                    per.Participant_Status__c == PEStatusState.PE_STATUS_TREATMENT_PERIOD_STARTED ||
                    per.Participant_Status__c == PEStatusState.PE_STATUS_FOLLOW_UP_PERIOD_STARTED
                ) {
                    String statusInLowerCase = per.Participant_Status__c.toLowercase();
                    statusInLowerCase = statusInLowerCase.replaceAll('[^a-zA-Z0-9\\s+]', ' ');
                    List<String> statusStrList = statusInLowerCase.split(' ');
                    dateKey = String.join(statusStrList, '_');

                    String cMonth = String.valueof(date.Today().month());
                    String cDay = String.valueof(date.Today().day());
                    if (cMonth.length() == 1) {
                        cMonth = '0' + cMonth;
                    }
                    if (cDay.length() == 1) {
                        cDay = '0' + cDay;
                    }
                    String dateValue =
                        String.valueof(date.Today().year()) +
                        '-' +
                        cMonth +
                        '-' +
                        cDay;

                    Map<String, String> ecoaEventMap = new Map<String, String>{
                        'studyGuid' => per.Clinical_Trial_Profile__r.Study_GUID__c,
                        'orgGuid' => ECOAService.apiParamsMap.get(ECOAService.ORG_GUID)
                            .ParamValue__c,
                        'subjectGuid' => per.Subject_GUID__c,
                        'date' => dateValue,
                        'dateKey' => dateKey
                    };
                    requestMapList.add(ecoaEventMap);
                }
            }
        }
        if (requestMapList != null && !requestMapList.isEmpty()) {
            try {
                ECOAService.createEcoaEvent(requestMapList);
            } catch (Exception e) {
                System.debug('Error--->' + e.getmessage());
            }
        }
    }

    @TestVisible
    private static void updateStudyConsentTimestamps(
        List<Participant_Enrollment__c> newList,
        Map<Id, Participant_Enrollment__c> oldMap
    ) {
        for (Participant_Enrollment__c peNew : newList) {
            Participant_Enrollment__c peOld = oldMap.get(peNew.Id);
            if (
                peNew.Study_Artificial_Voice_Consent__c != peOld.Study_Artificial_Voice_Consent__c
            ) {
                peNew.Study_Artificial_Voice_Consent_Time__c = Datetime.now();
            }
            if (
                peNew.Study_Assisted_Dialing_Consent__c != peOld.Study_Assisted_Dialing_Consent__c
            ) {
                peNew.Study_Assisted_Dialing_Consent_Time__c = Datetime.now();
            }
            if (peNew.Study_Direct_Mail_Consent__c != peOld.Study_Direct_Mail_Consent__c) {
                peNew.Study_Direct_Mail_Consent_Time__c = Datetime.now();
            }
            if (
                peNew.Permit_Mail_Email_contact_for_this_study__c !=
                peOld.Permit_Mail_Email_contact_for_this_study__c
            ) {
                peNew.Study_Email_Consent_Time__c = Datetime.now();
            }
            if (
                peNew.Permit_Voice_Text_contact_for_this_study__c !=
                peOld.Permit_Voice_Text_contact_for_this_study__c
            ) {
                peNew.Study_Phone_Consent_Time__c = Datetime.now();
            }
            if (
                peNew.Permit_IQVIA_to_contact_about_study__c !=
                peOld.Permit_IQVIA_to_contact_about_study__c
            ) {
                peNew.Study_PI_Storage_Consent_Time__c = Datetime.now();
            }
            if (
                peNew.Study_Pre_recorded_Voice_Consent__c !=
                peOld.Study_Pre_recorded_Voice_Consent__c
            ) {
                peNew.Study_Pre_recorded_Calls_Consent_Time__c = Datetime.now();
            }
            if (
                peNew.Permit_SMS_Text_for_this_study__c != peOld.Permit_SMS_Text_for_this_study__c
            ) {
                peNew.Study_SMS_Consent_Time__c = Datetime.now();
            }
        }
    }

    @TestVisible
    private static void updateStudyConsentTimestamps(List<Participant_Enrollment__c> newList) {
        for (Participant_Enrollment__c peNew : newList) {
            peNew.Study_Artificial_Voice_Consent_Time__c = (peNew.Study_Artificial_Voice_Consent__c
                ? Datetime.now()
                : null);
            peNew.Study_Assisted_Dialing_Consent_Time__c = (peNew.Study_Assisted_Dialing_Consent__c
                ? Datetime.now()
                : null);
            peNew.Study_Direct_Mail_Consent_Time__c = (peNew.Study_Direct_Mail_Consent__c
                ? Datetime.now()
                : null);
            peNew.Study_Email_Consent_Time__c = (peNew.Permit_Mail_Email_contact_for_this_study__c
                ? Datetime.now()
                : null);
            peNew.Study_Phone_Consent_Time__c = (peNew.Permit_Voice_Text_contact_for_this_study__c
                ? Datetime.now()
                : null);
            peNew.Study_PI_Storage_Consent_Time__c = (peNew.Permit_IQVIA_to_contact_about_study__c
                ? Datetime.now()
                : null);
            peNew.Study_Pre_recorded_Calls_Consent_Time__c = (peNew.Study_Pre_recorded_Voice_Consent__c
                ? Datetime.now()
                : null);
            peNew.Study_SMS_Consent_Time__c = (peNew.Permit_SMS_Text_for_this_study__c
                ? Datetime.now()
                : null);
        }
    }

    @TestVisible
    private static void patientConsentUpdate(
        List<Participant_Enrollment__c> newList,
        Map<Id, Participant_Enrollment__c> oldMap
    ) {
        for (Participant_Enrollment__c peNew : newList) {
            if (oldMap == null) {
                peNew.Study_Assisted_Dialing_Consent__c = (peNew.Permit_Voice_Text_contact_for_this_study__c
                    ? true
                    : false);
                peNew.Study_Artificial_Voice_Consent__c = (peNew.Permit_Voice_Text_contact_for_this_study__c
                    ? true
                    : false);
                peNew.Study_Pre_recorded_Voice_Consent__c = (peNew.Permit_Voice_Text_contact_for_this_study__c
                    ? true
                    : false);
            } else {
                Participant_Enrollment__c peOld = oldMap.get(peNew.Id);
                if (
                    peNew.Permit_Voice_Text_contact_for_this_study__c !=
                    peOld.Permit_Voice_Text_contact_for_this_study__c &&
                    peNew.Permit_Voice_Text_contact_for_this_study__c
                ) {
                    // check 3 checkboxes
                    peNew.Study_Assisted_Dialing_Consent__c = true;
                    peNew.Study_Artificial_Voice_Consent__c = true;
                    peNew.Study_Pre_recorded_Voice_Consent__c = true;
                } else if (
                    peNew.Permit_Voice_Text_contact_for_this_study__c !=
                    peOld.Permit_Voice_Text_contact_for_this_study__c &&
                    !peNew.Permit_Voice_Text_contact_for_this_study__c
                ) {
                    // uncheck 3 checkboxes
                    peNew.Study_Assisted_Dialing_Consent__c = false;
                    peNew.Study_Artificial_Voice_Consent__c = false;
                    peNew.Study_Pre_recorded_Voice_Consent__c = false;
                }
            }
        }
    }
    public static List<Profile> currentUserProfile;
    public static boolean checkCurrentusrProfile() {
        List<Profile> profiles;
        if (currentUserProfile == null) {
            Id profileId = userinfo.getProfileId();
            currentUserProfile = [SELECT Id, Name FROM Profile WHERE Id = :profileId];
        }
        profiles = currentUserProfile;
        if (profiles != null && !profiles.isEmpty()) {
            String profileName = profiles[0].Name;
            if (profileName == System.Label.PortalUserProfile) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }
}
