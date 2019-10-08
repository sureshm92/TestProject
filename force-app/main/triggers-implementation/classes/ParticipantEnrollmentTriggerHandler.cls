/**
 * Created by D.Yasinskyi on 26.04.2018
 * Refactored by L.Bartenev
 */

public without sharing class ParticipantEnrollmentTriggerHandler {

    // Handlers: -------------------------------------------------------------------------------------------------------

    public class PrepareAdditionalFieldsHandler extends TriggerHandler{

        public override void beforeInsert(List<SObject> newList) {
            new ParticipantEnrollmentTriggerHandler(newList).prepareAdditionalFields(newList, null);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            new ParticipantEnrollmentTriggerHandler(newList).prepareAdditionalFields(newList, (Map<Id, Participant_Enrollment__c>)oldMap);
        }
    }

    public class CreateUsersOrSendNotificationsHandler extends TriggerHandler{

        public override void afterInsert(List<SObject> newList) {
            new ParticipantEnrollmentTriggerHandler(newList).createUsersOrSendNotifications(newList, null);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            new ParticipantEnrollmentTriggerHandler(newList).createUsersOrSendNotifications(newList, (Map<Id, Participant_Enrollment__c>)oldMap);
        }
    }

    public class SendCalloutOnEligibilityPassedHandler extends TriggerHandler{

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            sendCalloutOnEligibilityPassed(newList, (Map<Id, Participant_Enrollment__c>)oldMap);
        }
    }

    public class CreateStatusTrackingHistoryRecordsHandler extends TriggerHandler{

        public override void beforeInsert(List<SObject> newList) {
            setChangedDate(newList);
        }

        public override void beforeUpdate(List<SObject> newList,  Map<Id, SObject> oldMap) {
            resetNotesAndSetChangeDate(newList, (Map<Id, Participant_Enrollment__c>)oldMap);
        }

        public override void afterInsert(List<SObject> newList) {
            createHistoryRecords(newList, null);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createHistoryRecords(newList, (Map<Id, Participant_Enrollment__c>)oldMap);
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
    
    // Logic: ----------------------------------------------------------------------------------------------------------


    private Map<Id, Study_Site__c> ssMap;
    private Map<Id, HCP_Enrollment__c> hcpeMap;
    private Map<Id, Participant__c> participantMap;

    public ParticipantEnrollmentTriggerHandler(List<Participant_Enrollment__c> newList){
        List<Id> ssIds = new List<Id>();
        List<Id> hcpeIds = new List<Id>();
        List<Id> participantIds = new List<Id>();
        for(Participant_Enrollment__c pe : newList){
            if(pe.Study_Site__c != null) ssIds.add(pe.Study_Site__c);
            if(pe.HCP__c != null) hcpeIds.add(pe.HCP__c);
            if(pe.Participant__c != null) participantIds.add(pe.Participant__c);
        }
        ssMap = new Map<Id, Study_Site__c>([
                SELECT Id, Principal_Investigator__c,
                        Suppress_Participant_Emails__c,
                        Clinical_Trial_Profile__c,
                        Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                        Clinical_Trial_Profile__r.Shareback_Settings_On_Participant_Level__c,
                        Clinical_Trial_Profile__r.Visit_Data_Shareback__c,
                        Clinical_Trial_Profile__r.Participating_in_Patient_Portal__c,
                        Clinical_Trial_Profile__r.NCT_Number__c
                FROM Study_Site__c
                WHERE Id IN: ssIds
        ]);
        hcpeMap = new Map<Id, HCP_Enrollment__c>([
                SELECT Id, HCP_Contact__c
                FROM HCP_Enrollment__c
                WHERE Id IN: hcpeIds
        ]);
        participantMap = new Map<Id, Participant__c>([
                SELECT Id,
                        Contact__c,
                        Contact__r.Visit_Results_Opt_In__c,
                        Name,
                        IsCountry_NOT_Eligible_for_Emails__c
                FROM Participant__c
                WHERE Id IN: participantIds
        ]);
    }

    @TestVisible
    private void prepareAdditionalFields(List<Participant_Enrollment__c> newList, Map<Id, Participant_Enrollment__c> oldMap){
        Set<Id> participantContactIds = new Set<Id>();
        List<Contact> participantContacts = new List<Contact>();
        for(Participant_Enrollment__c pe : newList){
            String nctNumber;
            String participantName;
            Boolean visitOpt = false;

            if(pe.Study_Site__c != null){
                Study_Site__c ss = ssMap.get(pe.Study_Site__c);
                if(ss != null) {
                    pe.PI_Contact__c = ss.Principal_Investigator__c;
                    pe.Clinical_Trial_Profile__c = ss.Clinical_Trial_Profile__c;
                    nctNumber = ss.Clinical_Trial_Profile__r.NCT_Number__c;
                    visitOpt = ss.Clinical_Trial_Profile__r.Shareback_Settings_On_Participant_Level__c;
                }
            }
            if(pe.HCP__c != null){
                HCP_Enrollment__c hcpe = hcpeMap.get(pe.HCP__c);
                if(hcpe != null) pe.HCP_Contact_HCPEnroll__c = hcpe.HCP_Contact__c;
            }
            if(pe.Participant__c != null){
                Participant__c participant = participantMap.get(pe.Participant__c);
                if(participant != null) {
                    pe.Participant_Contact__c = participant.Contact__c;
                    if(oldMap == null) {
                        participant.Contact__r.Visit_Results_Opt_In__c = visitOpt;
                        if(!participantContactIds.contains(participant.Contact__c)){
                        participantContacts.add(participant.Contact__r);
                            participantContactIds.add(participant.Contact__c);
                        }

                    }
                    participantName = participant.Name;
                }
            }
            //populate Participant Code
            if(nctNumber != null && participantName != null){
                pe.Participant_Key__c = participantName + ' ' + nctNumber;
            }
            //populate referred date
            if(pe.Participant_Status__c == PEStatusState.PE_STATUS_REFERRAL_SENT_TO_PI){
                if((oldMap == null && pe.Referred_Date__c == null) || (oldMap != null && oldMap.get(pe.Id).Participant_Status__c != pe.Participant_Status__c)){
                    pe.Referred_Date__c = Date.today();
                }
            }
        }

        if(!participantContacts.isEmpty()) update participantContacts;
    }

    @TestVisible
    private void createUsersOrSendNotifications(List<Participant_Enrollment__c> newList, Map<Id, Participant_Enrollment__c> oldMap) {
        Map<Id, Id> toCreateUser = new Map<Id, Id>();
        Map<Id, String> notificationMap = new Map<Id, String>();
        Map<Id, String> notificationMapEmptyHCP = new Map<Id, String>();
        List<Contact> contactsForChangeMode = new List<Contact>();

        //get users if exist
        Map<Id, User> usersByContactId = new Map<Id, User>();
        Set<Id> participantContactIds = new Set<Id>();
        for(Participant_Enrollment__c pe : newList) {
            Participant__c participant = participantMap.get(pe.Participant__c);
            if(participant != null && participant.Contact__c != null) participantContactIds.add(participant.Contact__c);
        }
        for (User usr : CommunityService.getCommunityUsersByContactIds(participantContactIds)) usersByContactId.put(usr.ContactId, usr);

        //process PE items:
        List<Alert__c> alertsForInsert = new List<Alert__c>();
        for(Participant_Enrollment__c newPE : newList){
            Study_Site__c ss = ssMap.get(newPE.Study_Site__c);
            HCP_Enrollment__c hcpe = hcpeMap.get(newPE.HCP__c);
            Participant__c participant = participantMap.get(newPE.Participant__c);
            User participantUser;
            if(participant != null && participant.Contact__c != null) participantUser = usersByContactId.get(participant.Contact__c);
            Boolean updateCriteria = true;
            if(oldMap != null){
                Participant_Enrollment__c oldPE = oldMap.get(newPE.Id);
                updateCriteria = oldPE.Participant_Status__c != newPE.Participant_Status__c ||
                        oldPE.Participant__c != newPE.Participant__c || participantUser == null;
                System.debug('OLD STATUS: ' +  oldPE.Participant_Status__c);
                System.debug('NEW STATUS: ' +  newPE.Participant_Status__c);
                System.debug('OLD PART ID: ' +  oldPE.Participant__c);
                System.debug('NEW PART ID: ' +  newPE.Participant__c);
                System.debug('PART USER: ' +  participantUser);
            }
            System.debug('UPDATE CRITERIA: ' + updateCriteria);
            if(!updateCriteria) continue;
            Boolean filterCriteria =
                    newPE.Participant_Status__c == PEStatusState.PE_STATUS_REFERRAL_SENT_TO_PI &&
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
            if(filterCriteria){
                if(participantUser == null){
                    System.debug('CREATE USER');
                    Id hcpContact;
                    if(hcpe != null) hcpContact = hcpe.HCP_Contact__c;
                    toCreateUser.put(participant.Contact__c, hcpContact);
                    alertsForInsert.add(new Alert__c(
                            Contact__c = participant.Contact__c,
                            Alert_Code__c = 'Welcome_To_The_PH'
                    ));
                }else{
                    System.debug('NOTIFY USER');
                    if(hcpe != null){
                        notificationMap.put(newPE.Id, participant.Contact__c);
                    }else{
                        notificationMapEmptyHCP.put(newPE.Id, participant.Contact__c);
                    }
                }
                contactsForChangeMode.add(new Contact(
                        Id = participant.Contact__c,
                        userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT
                ));
            }
        }

        insert alertsForInsert;
        if(toCreateUser.size() > 0) CommunityService.createParticipantUsers(toCreateUser);
        if(notificationMap.size() > 0) SendEmailTemplate.sendEmailNotification(SendEmailTemplate.EMAIL_TEMPLATE_PATIENT1_NEW, notificationMap);
        if(notificationMapEmptyHCP.size() > 0) SendEmailTemplate.sendEmailNotification(SendEmailTemplate.EMAIL_TEMPLATE_PATIENT2_NEW, notificationMapEmptyHCP);
        update contactsForChangeMode;
    }

    @TestVisible
    private static void sendCalloutOnEligibilityPassed(List<Participant_Enrollment__c> newList, Map<Id, Participant_Enrollment__c> oldMap){
        String acceptedStatus = PEStatusState.PE_STATUS_ELIGIBILITY_PASSED;
        for(Participant_Enrollment__c pe : newList){
            if(pe.Participant_Status__c == acceptedStatus && (oldMap == null ||
                    oldMap.get(pe.Id).Participant_Status__c != acceptedStatus)){
                IntegrationService.sendPEToStudyHubAsync(pe.Id);
            }
        }

    }

    @TestVisible
    private static void setChangedDate(List<Participant_Enrollment__c> newList){
        for(Participant_Enrollment__c pe : newList){
            pe.Medical_Record_Review_Completed_Date__c =  Datetime.now();
            if(pe.Participant_Status__c != null && pe.Participant_Status_Last_Changed_Date__c == null){
                pe.Participant_Status_Last_Changed_Date__c = Datetime.now();
            }
        }
    }

    @TestVisible
    private static void resetNotesAndSetChangeDate(List<Participant_Enrollment__c> newList, Map<Id, Participant_Enrollment__c> oldMap){
        for(Participant_Enrollment__c pe : newList){
            if(pe.Participant_Status__c != oldMap.get(pe.Id).Participant_Status__c ||
                    pe.Participant_Status_Last_Changed_Date__c != oldMap.get(pe.Id).Participant_Status_Last_Changed_Date__c ||
                    pe.Last_Status_Changed_Notes__c != oldMap.get(pe.Id).Last_Status_Changed_Notes__c){
                if(pe.Participant_Status_Last_Changed_Date__c == oldMap.get(pe.Id).Participant_Status_Last_Changed_Date__c)
                    if(pe.Last_Status_Changed_Notes__c == oldMap.get(pe.Id).Last_Status_Changed_Notes__c)
                        pe.Last_Status_Changed_Notes__c = null;
                pe.Participant_Status_Last_Changed_Date__c = Datetime.now();
            }
        }
    }

    @TestVisible
    private static void createHistoryRecords(List<Participant_Enrollment__c> newList, Map<Id, Participant_Enrollment__c> oldMap){
        List<Participant_Enrollment_Status_History__c> pesHistoryList = new List<Participant_Enrollment_Status_History__c>();
        for(Participant_Enrollment__c pe : newList){
            if ((oldMap == null && pe.Participant_Status__c != null) ||
                    (oldMap != null && (pe.Participant_Status__c != oldMap.get(pe.Id).Participant_Status__c ||
                            pe.Participant_Status_Last_Changed_Date__c != oldMap.get(pe.Id).Participant_Status_Last_Changed_Date__c ||
                            pe.Last_Status_Changed_Notes__c != oldMap.get(pe.Id).Last_Status_Changed_Notes__c)
                    )){
                pesHistoryList.add(new Participant_Enrollment_Status_History__c(
                        Notes__c = pe.Last_Status_Changed_Notes__c,
                        Date__c = Datetime.now(),
                        ParticipantEnrollment__c = pe.Id,
                        NewStatus__c = pe.Participant_Status__c,
                        Reason__c = pe.Non_Enrollment_Reason__c
                ));
            }
        }
        insert pesHistoryList;
    }

    @TestVisible
    private static void createInvitations(
            List<Participant_Enrollment__c> newList,
            Map<Id, Participant_Enrollment__c> oldMap
    ) {
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
                AND Clinical_Trial_Profile__c IN:ctpPE.keySet()
        ];

        Map<Id, String> trialWhoseResponse = new Map<Id, String>();
        List<SurveyInvitation> newInvitations = new List<SurveyInvitation>();
        for (Trial_Survey__c ts : trialSurveys) {
            trialWhoseResponse.put(ts.Id, ts.Whose_response_needed__c);
            for (Participant_Enrollment__c enrollment : ctpPE.get(ts.Clinical_Trial_Profile__c)) {
                Boolean needToAdd = false;
                if (enrollment.Participant_Status__c == ts.Active_On_Status__c) {
                    if (oldMap != null) {
                        if (oldMap.get(enrollment.Id).Participant_Status__c != enrollment.Participant_Status__c) {
                            needToAdd = true;
                        }
                    } else {
                        needToAdd = true;
                    }
                }
                if (needToAdd) {
                    newInvitations.add(SurveyService.getInstance().generateInvitation(ts, enrollment.Id));
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
}
