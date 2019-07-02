/**
 * Created by Leonid Bartenev
 */

public without sharing class PSETriggerHandler {

    // Handlers: -------------------------------------------------------------------------------------------------------

    public class SetDefaultFieldsBeforeUpsertHandler extends TriggerHandler {

        public override void beforeInsert(List<SObject> newList) {
            setDefaultFieldsBeforeUpsert(newList);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            setDefaultFieldsBeforeUpsert(newList);
        }
    }

    public class ProcessStatusHistoryHandler extends TriggerHandler {

        public override void afterInsert(List<SObject> newList) {
            processStatusHistory(newList, null);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            processStatusHistory(newList, (Map<Id, Participant_Study_Enrollment__c>) oldMap);
        }
    }

    public class DeactivateDeceasedUsersHandler extends TriggerHandler {

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            deactivateDeceasedUsers(newList, (Map<Id, Participant_Study_Enrollment__c>) oldMap);
        }

    }
    
    public class CreateVisitsScheduleHandler extends TriggerHandler{
        
        public override void afterInsert(List<SObject> newList){
            createVisitsSchedule(newList);
        }
    }

    public class CreateWelcomeToStudyAlertHandler extends TriggerHandler {

        public override void afterInsert(List<SObject> newList) {
            List<Alert__c> alerts = new List<Alert__c>();
            for (Participant_Study_Enrollment__c pse : (List<Participant_Study_Enrollment__c>) newList) {
                alerts.add(new Alert__c(
                        Contact__c = pse.Participant_Contact__c,
                        Alert_Code__c = 'Welcome_to_the_Study',
                        Record_ID__c = pse.Participant_Enrollment__c
                ));
                for (Contact contactDelegate : PatientDelegateService.getDelegateContacts(pse.Participant_Contact__c)) {
                    alerts.add(new Alert__c(
                            Contact__c = contactDelegate.Id,
                            Alert_Code__c = 'Welcome_to_the_Study_Patient_Delegates',
                            Record_ID__c = pse.Id)
                    );
                }
            }

            insert alerts;
        }
    }

    public class CreateStatusBasedInvitations extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            createInvitations((List<Participant_Study_Enrollment__c>) newList, null);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createInvitations((List<Participant_Study_Enrollment__c>) newList, (Map<Id, Participant_Study_Enrollment__c>) oldMap);
        }
    }

    public class SendDropOutEmailHandler extends TriggerHandler {

        protected override void onAfterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            sendDropEmails((List<Participant_Study_Enrollment__c>) newList, (Map<Id, Participant_Study_Enrollment__c>) oldMap);
        }
    }

    // Logic: ----------------------------------------------------------------------------------------------------------

    @TestVisible
    private static void setDefaultFieldsBeforeUpsert(List<Participant_Study_Enrollment__c> newList) {
        Set<Id> ssIds = new Set<Id>();
        Set<Id> participantIds = new Set<Id>();
        Set<Id> peIds = new Set<Id>();
        for (Participant_Study_Enrollment__c pse : newList) {
            ssIds.add(pse.Study_Site__c);
            participantIds.add(pse.Participant__c);
            peIds.add(pse.Participant_Enrollment__c);
        }
        Map<Id, Participant_Enrollment__c> peMap = new Map<Id, Participant_Enrollment__c>([
                SELECT Id, Screening_ID__c FROM Participant_Enrollment__c WHERE Id IN: peIds
        ]);
            
        Map<Id, Study_Site__c> studySitesMap = new Map<Id, Study_Site__c>([
                SELECT Id, Principal_Investigator__c
                FROM Study_Site__c
                WHERE Id IN:ssIds
        ]);
        Map<Id, Participant__c> participantsMap = new Map<Id, Participant__c>([
                SELECT Id, Contact__c
                FROM Participant__c
                WHERE Id IN:participantIds
        ]);
        for (Participant_Study_Enrollment__c pse : newList) {
            pse.PI_Contact__c = null;
            pse.Participant_Contact__c = null;
            if (pse.Study_Site__c != null) pse.PI_Contact__c = studySitesMap.get(pse.Study_Site__c).Principal_Investigator__c;
            if (pse.Participant__c != null) {
                pse.Participant_Contact__c = participantsMap.get(pse.Participant__c).Contact__c;
            }
            Participant_Enrollment__c pe = peMap.get(pse.Participant_Enrollment__c);
            if(pe != null) pse.Screening_ID__c = pe.Screening_ID__c;
        }
    }

    @TestVisible
    private static void processStatusHistory(List<Participant_Study_Enrollment__c> newList, Map<Id, Participant_Study_Enrollment__c> oldMap) {
        List<PSE_Status_History__c> pseStatusHistories = new List<PSE_Status_History__c>();
        for (Participant_Study_Enrollment__c pse : newList) {
            if (oldMap == null || (oldMap != null && pse.Status__c != oldMap.get(pse.Id).Status__c)) {
                if (pse.Status__c == PSEService.PSE_STATUS_ENROLLED) {
                    pseStatusHistories.add(new PSE_Status_History__c(
                            PSE__c = pse.Id,
                            Status__c = pse.Status__c,
                            Changed_Date__c = Datetime.now()
                    ));
                }
            }
        }
        if (pseStatusHistories.size() > 0) insert pseStatusHistories;
    }

    @TestVisible
    public static void deactivateDeceasedUsers(List<Participant_Study_Enrollment__c> newList, Map<Id, Participant_Study_Enrollment__c> oldMap) {
        List<Id> contactIds = new List<Id>();
        List<Participant_Study_Enrollment__c> pseList = [
                SELECT Id,
                        Participant__r.Contact__c,
                        Status__c
                FROM Participant_Study_Enrollment__c
                WHERE Id IN:newList
        ];
        for (Participant_Study_Enrollment__c pse : pseList) {
            if (pse.Status__c == PSEService.PSE_STATUS_DECEASED && pse.Status__c != oldMap.get(pse.Id).Status__c) {
                contactIds.add(pse.Participant__r.Contact__c);
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
    private static void sendDropEmails(
            List<Participant_Study_Enrollment__c> newList,
            Map<Id, Participant_Study_Enrollment__c> oldMap
    ) {
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        for (Participant_Study_Enrollment__c pse : newList) {
            if (pse.Status__c != oldMap.get(pse.Id).Status__c &&
                    pse.Status__c == PSEService.PSE_STATUS_DROP_OUT) {
                messages.add(SendEmailTemplate.createEmail('Patient_dropped_out', pse.Participant_Contact__c, pse.Id));
            }
        }

        SendEmailTemplate.sendEmailMessages(messages);
    }

    @TestVisible
    private static void createInvitations(
            List<Participant_Study_Enrollment__c> newList,
            Map<Id, Participant_Study_Enrollment__c> oldMap
    ) {
        Map<Id, List<Participant_Study_Enrollment__c>> ctpPSE = new Map<Id, List<Participant_Study_Enrollment__c>>();
        for (Participant_Study_Enrollment__c pse : newList) {
            if (ctpPSE.get(pse.Clinical_Trial_Profile__c) == null) {
                ctpPSE.put(pse.Clinical_Trial_Profile__c, new List<Participant_Study_Enrollment__c>());
            }
            ctpPSE.get(pse.Clinical_Trial_Profile__c).add(pse);
        }

        List<Trial_Survey__c> trialSurveys = [
                SELECT
                        Id,
                        Clinical_Trial_Profile__c,
                        Survey__c,
                        Survey__r.Name,
                        Active_On_Status__c,
                        Expires_After_Days__c,
                        Reminder_Schedule__c,
                        Whose_response_needed__c
                FROM Trial_Survey__c
                WHERE Active_On_Status__c != NULL
                AND Clinical_Trial_Profile__c IN:ctpPSE.keySet()
        ];

        Map<Id, String> trialWhoseResponse = new Map<Id, String>();
        List<SurveyInvitation> newInvitations = new List<SurveyInvitation>();
        for (Trial_Survey__c ts : trialSurveys) {
            trialWhoseResponse.put(ts.Id, ts.Whose_response_needed__c);
            for (Participant_Study_Enrollment__c enrollment : ctpPSE.get(ts.Clinical_Trial_Profile__c)) {
                Boolean needToAdd = false;
                if (enrollment.Status__c == ts.Active_On_Status__c) {
                    if (oldMap != null) {
                        if (oldMap.get(enrollment.Id).Status__c != enrollment.Status__c) {
                            needToAdd = true;
                        }
                    } else {
                        needToAdd = true;
                    }
                }
                if (needToAdd) {
                    newInvitations.add(SurveyService.getInstance().generateInvitation(ts, enrollment.Participant_Enrollment__c));
                }
            }
        }

        insert newInvitations;
        Map<Id, String> invitationsVisible = new Map<Id, String>();
        for(SurveyInvitation inv : newInvitations) {
            invitationsVisible.put(inv.Id, trialWhoseResponse.get(inv.Trial_Survey__c));
        }

        TaskService.getInstance().createSurveyTasks(invitationsVisible);
    }
    
    @TestVisible
    private static void createVisitsSchedule(List<Participant_Study_Enrollment__c> pseList){
        Set<Id> ctpIds = new Set<Id>();
        for(Participant_Study_Enrollment__c pse : pseList) ctpIds.add(pse.Clinical_Trial_Profile__c);
        Map<Id, Clinical_Trial_Profile__c> ctpMap = new Map<Id, Clinical_Trial_Profile__c>([
                SELECT Id, Visit_Plan__c
                FROM Clinical_Trial_Profile__c
                WHERE Id IN: ctpIds
        ]);
        Set<Id> visitPlanIds = new Set<Id>();
        for(Clinical_Trial_Profile__c ctp : ctpMap.values()) visitPlanIds.add(ctp.Visit_Plan__c);
        Map<Id, Visit_Plan__c> visitPlansMap = new Map<Id,Visit_Plan__c>([
                SELECT Id, (SELECT Id, Name, Visit_Number__c, Visit_Schedule__c FROM Visits__r)
                FROM Visit_Plan__c
                WHERE Id IN: visitPlanIds
        ]);
        List<Patient_Visit__c> patientVisits = new List<Patient_Visit__c>();
        for(Participant_Study_Enrollment__c pse : pseList){
            Clinical_Trial_Profile__c ctp = ctpMap.get(pse.Clinical_Trial_Profile__c);
            if(ctp == null) continue;
            Visit_Plan__c vp = visitPlansMap.get(ctp.Visit_Plan__c);
            if(vp == null) continue;
            for(Visit__c visit : vp.Visits__r){
                patientVisits.add(VisitService.createPatientVisit(visit, pse.Id));
            }
        }
        if(patientVisits.size() > 0) insert patientVisits;
    }
    
}