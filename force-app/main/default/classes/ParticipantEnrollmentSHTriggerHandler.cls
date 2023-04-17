/**
 * Created by Kryvolap
 */

public without sharing class ParticipantEnrollmentSHTriggerHandler { 
    //Handlers----------------------------------------------------------------------------------------------------------
    public class SendPESHToEPR extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            List<Id> idsList=new List<Id>();
            for(SObject sobj: newList) idsList.add(sobj.id);
            sendToEPR(idsList);
        }
    }

    public class UpdatePEHandler extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            updateEnrollmentStatus((List<Participant_Enrollment_Status_History__c>) newList);
        }
    }

    public class SendCalloutOnEligibilityPassedHandler extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            sendCalloutOnEligibilityPassed(newList);
        }
    }

    public class CreateUsersOrSendNotificationsHandler extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            createUsersOrSendNotifications(newList);
        }
    }
    public class UpdatePERReEngaged extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            UpdatePERReEngaged(newList);
        }
    }

    public class CreateWelcomeToStudyAlertHandler extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            if (!Test.isRunningTest()) {
                List<Id> peshIdsList=new List<Id>();
                for(SObject obj: newList) peshIdsList.add(obj.Id);
                createPlatformAlerts(newList);
               // createStudyAlerts((List<Participant_Enrollment_Status_History__c>) newList);
                createStudyAlerts(peshIdsList);
            }
        }
    }

    public class UpdateLastChangedAdditionalNotes extends TriggerHandler {

        public override void afterUpdate(List<SObject> newList, Map<Id,SObject> oldMap) {
            if (!Test.isRunningTest()) {
                updateLastChangedAdditionalNotes((List<Participant_Enrollment_Status_History__c>) newList, (Map<Id,Participant_Enrollment_Status_History__c>) oldMap);
            }
        }
    }  

    //Logic-------------------------------------------------------------------------------------------------------------
   
    private static void sendToEPR(List<Id> ids) {
       /** List<Participant_Enrollment_Status_History__c> newList=[S]
        List<Id> ids = new List<Id>();
        for (Participant_Enrollment_Status_History__c obj : newList) {
            ids.add(obj.Id);
        } **/
        if (!System.isBatch() && !System.isFuture()) {
            IntegrationService.sendPESHToEPRAsync(ids);
        } else if (UploadParticipantsBatch.isCalloutFromUploadParticipantsBatch != true) {
            //Added By Krishna For REF-2183
            IntegrationService.sendPESHToEPR(ids);
        }
    }

    @TestVisible
    private static void updateLastChangedAdditionalNotes(List<Participant_Enrollment_Status_History__c> newList, Map<Id,Participant_Enrollment_Status_History__c> oldMap) {
        List<Id> peids = new List<Id>();
        Map<Id,Participant_Enrollment_Status_History__c> newMap = new Map<Id,Participant_Enrollment_Status_History__c>();
        for(Participant_Enrollment_Status_History__c pesh: newList){
            peIds.add(pesh.ParticipantEnrollment__c);
            newMap.put(pesh.Id,pesh);
        }
        List<Participant_Enrollment_Status_History__c> peshs = [SELECT Status__c,Date__c,CreatedDate,Additional_Notes__c,
                                                                Non_Enrollment_Reason__c,ParticipantEnrollment__r.Participant_Status__c,
                                                                ParticipantEnrollment__r.Participant_Status_Last_Changed_Date__c,
                                                                ParticipantEnrollment__r.Last_Status_Changed_Additional_Notes__c,
                                                                ParticipantEnrollment__r.Non_Enrollment_Reason__c 
                                                                FROM Participant_Enrollment_Status_History__c WHERE ParticipantEnrollment__c IN:peIds
                                                                ORDER BY CreatedDate DESC];
        Map<Id,Participant_Enrollment_Status_History__c> pepesh = new Map<Id,Participant_Enrollment_Status_History__c>();
        Map<Id,Participant_Enrollment__c> toUpdate = new Map<Id,Participant_Enrollment__c>();
        Map<Id,Id> headHistories = new Map<Id,Id>(); 
        for(Participant_Enrollment_Status_History__c pesh : peshs){
            if(!headHistories.containsKey(pesh.ParticipantEnrollment__c)){
                headHistories.put(pesh.ParticipantEnrollment__c,pesh.Id);
            }
          
            if(!toUpdate.containsKey(pesh.ParticipantEnrollment__c) 
               && newMap.containsKey(pesh.Id) && oldMap.containsKey(pesh.Id) 
               && newMap.get(pesh.Id)!=null && oldMap.get(pesh.Id)!=null 
               && pesh.ParticipantEnrollment__r.Participant_Status__c == pesh.Status__c
               && headHistories.get(pesh.ParticipantEnrollment__c) == pesh.Id){

                    Participant_Enrollment__c peshtoupdate = new Participant_Enrollment__c(Id=pesh.ParticipantEnrollment__c);
                    Boolean isUpdate = false;
                    if(newMap.get(pesh.Id).Additional_Notes__c != oldMap.get(pesh.Id).Additional_Notes__c){
                        peshtoupdate.Last_Status_Changed_Additional_Notes__c = pesh.Additional_Notes__c;
                        isUpdate = true;
                    }
                    if(newMap.get(pesh.Id).Non_Enrollment_Reason__c != oldMap.get(pesh.Id).Non_Enrollment_Reason__c){
                        peshtoupdate.Non_Enrollment_Reason__c = pesh.Non_Enrollment_Reason__c;
                        isUpdate = true;
                    }
                    if(isUpdate)
                    toUpdate.put(pesh.ParticipantEnrollment__c,peshtoupdate);
                }
        }
        update toUpdate.values();
    }

    @TestVisible
    private static void updateEnrollmentStatus(
        List<Participant_Enrollment_Status_History__c> histories
    ) {
        Set<Id> peIds = new Set<Id>();
        Map<Id, List<Participant_Enrollment_Status_History__c>> peToHistories = new Map<Id, List<Participant_Enrollment_Status_History__c>>();

        for (Participant_Enrollment_Status_History__c history : histories) {
            if (
                history.Status__c == PEStatusState.PE_STATUS_REFERRAL_SENT_TO_PI ||
                history.Status__c == PEStatusState.PE_STATUS_RECEIVED
            )
                continue;

            Id peId = history.ParticipantEnrollment__c;
            peIds.add(peId);

            if (!peToHistories.containsKey(peId)) {
                peToHistories.put(peId, new List<Participant_Enrollment_Status_History__c>());
            }
            peToHistories.get(peId).add(history);
        }

        List<Participant_Enrollment__c> enrollments = [
            SELECT
                Id,
                Enrolled_Date__c,
                Informed_Consent__c,
            	Succesfully_Re_Engaged__c,
                Last_Status_Changed_Notes__c,
                Non_Enrollment_Reason__c,
                Participant_Status__c,
                Participant_Status_Last_Changed_Date__c
            FROM Participant_Enrollment__c
            WHERE Id IN :peIds
        ];
        for (Participant_Enrollment__c pe : enrollments) {
            Participant_Enrollment_Status_History__c headHistory = peToHistories.get(pe.Id).get(0);
            for (Participant_Enrollment_Status_History__c history : peToHistories.get(pe.Id)) {
                Integer headStatusValue = PEStatusState.PE_ORDERED_STATUSES.get(
                    headHistory.Status__c
                );
                Integer currentStatusValue = PEStatusState.PE_ORDERED_STATUSES.get(
                    history.Status__c
                );
                Boolean maxCheck = false;
                if (headStatusValue != null && currentStatusValue != null) {
                    maxCheck = headStatusValue != Math.max(headStatusValue, currentStatusValue);
                }
                if (
                    (headStatusValue == currentStatusValue &&
                    headHistory.Date__c < history.Date__c) || maxCheck
                ) {
                    headHistory = history;
                }
            }

            pe.Last_Status_Changed_Notes__c = headHistory.Notes__c;
            pe.Non_Enrollment_Reason__c = headHistory.Non_Enrollment_Reason__c;
            pe.Participant_Status_Last_Changed_Date__c = headHistory.Date__c;
            pe.Participant_Status__c = headHistory.Status__c;
            pe.Last_Status_Changed_Additional_Notes__c = headHistory.Additional_Notes__c;
            if (
                headHistory.Status__c == PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS ||
                headHistory.Status__c == PEStatusState.PE_STATUS_RANDOMIZATION_SUCCESS
            ) {
                pe.Informed_Consent__c = true;
                if (headHistory.Date__c != null)
                    pe.Enrolled_Date__c = headHistory.Date__c.date();
            }
            if (
                headHistory.Status__c == 'Successfully re-engaged'
            ) {
                pe.Succesfully_Re_Engaged__c = true;   
            }
        }
        System.debug('enrollments:' + enrollments);
        update enrollments;
    }
    @TestVisible
    private static void UpdatePERReEngaged(
        List<Participant_Enrollment_Status_History__c> newList
    ) {
        Set<Id> peIds = new Set<Id>();
        for (Participant_Enrollment_Status_History__c history : newList) 
        {
            peIds.add(history.ParticipantEnrollment__c);

        }
        
        List<Participant_Enrollment__c> enrollments = [
            SELECT
                Id,
            	Succesfully_Re_Engaged__c,
                Participant_Status__c,
				Clinical_Trial_Profile__r.Initial_Visit_Required__c,
				Initial_visit_scheduled_date__c,
				Initial_visit_scheduled_time__c,
                Clinical_Trial_Profile__r.Promote_to_SH__c
            FROM Participant_Enrollment__c
            WHERE Id IN :peIds
        ];
        for (Participant_Enrollment__c pe : enrollments)
         {
		    if(pe.Clinical_Trial_Profile__r.Initial_Visit_Required__c==true){
                 if( pe.Succesfully_Re_Engaged__c==true && 
                 (pe.Participant_Status__c=='Successfully Contacted' || pe.Participant_Status__c=='Eligibility Passed' || pe.Participant_Status__c=='Eligibility Failed')
                && pe.Initial_visit_scheduled_time__c!=null && pe.Initial_visit_scheduled_date__c!=null)
                {
                    pe.Succesfully_Re_Engaged__c=false;
                }
            }
            else{
                if( pe.Succesfully_Re_Engaged__c==true 
               && (pe.Participant_Status__c=='Successfully Contacted' || pe.Participant_Status__c=='Eligibility Passed' || pe.Participant_Status__c=='Eligibility Failed') )
                {
                     pe.Succesfully_Re_Engaged__c=false;
                }
            }
        }
	
        System.debug('enrollments:' + enrollments);
        update enrollments;
    }

    @TestVisible
    private static void sendCalloutOnEligibilityPassed(
        List<Participant_Enrollment_Status_History__c> newList
    ) {
        String acceptedStatus = PEStatusState.PE_STATUS_ELIGIBILITY_PASSED;
        Set<id> peIds = new Set<Id>();
        for (Participant_Enrollment_Status_History__c pesh : newList) {
            if (pesh.Status__c == acceptedStatus) {
                peIds.add(pesh.ParticipantEnrollment__c);
            }
        }
        Map<Id, Participant_Enrollment_Status_History__c> lastExitingHistoryMap = new Map<Id, Participant_Enrollment_Status_History__c>();
        for (Participant_Enrollment_Status_History__c pesh : [
            SELECT Status__c, ParticipantEnrollment__c,
            ParticipantEnrollment__r.Clinical_Trial_Profile__r.Promote_to_SH__c,
            ParticipantEnrollment__r.Clinical_Trial_Profile__r.DCT_Platform__c,
            ParticipantEnrollment__r.Study_Site__r.Study_Site_Type__c
            FROM Participant_Enrollment_Status_History__c
            WHERE ParticipantEnrollment__c IN :peIds
            ORDER BY Date__c DESC
        ]) {
            if (!lastExitingHistoryMap.containsKey(pesh.ParticipantEnrollment__c)) {
                lastExitingHistoryMap.put(pesh.ParticipantEnrollment__c, pesh);
                if (pesh.Status__c == acceptedStatus) {
                    peIds.remove(pesh.ParticipantEnrollment__c);
                }
            }
        }

        for (Id peId : peIds) {
            Participant_Enrollment_Status_History__c peshToCheck = lastExitingHistoryMap.get(peId);
            if(peshToCheck==null || (peshToCheck!=null && StudySiteService.SS_TYPE_VT_INTEGRATION.contains(peshToCheck.ParticipantEnrollment__r.Study_Site__r.Study_Site_Type__c) && 
            peshToCheck.ParticipantEnrollment__r.Clinical_Trial_Profile__r.DCT_Platform__c =='Study Hub' && 
            peshToCheck.ParticipantEnrollment__r.Clinical_Trial_Profile__r.Promote_to_SH__c==true
            )
            ){
                if (System.IsBatch() == false && System.isFuture() == false) {
                    IntegrationService.sendPEToStudyHubAsync(peId);
                } else if (UploadParticipantsBatch.isCalloutFromUploadParticipantsBatch != true) {
                    //Added By Krishna For REF-2183
                    IntegrationService.sendPEToStudyHub(peId);
                }
            }
        }
    }

    @TestVisible
    private static void createUsersOrSendNotifications(
        List<Participant_Enrollment_Status_History__c> newList
    ) {
        Set<Id> peIds = new Set<Id>();
        for (Participant_Enrollment_Status_History__c pesh : newList) {
            if (pesh.Status__c == PEStatusState.PE_STATUS_RECEIVED) {
                peIds.add(pesh.ParticipantEnrollment__c);
            }
        }
        if (!peIds.isEmpty()) {
            Map<Id, Id> toCreateUser = new Map<Id, Id>();
            List<Contact> contactsForChangeMode = new List<Contact>();
            List<Notification__c> notifications = new List<Notification__c>();

            Map<Id, User> usersByContactId = new Map<Id, User>();
            Set<Id> participantContactIds = new Set<Id>();
            List<Participant_Enrollment__c> participantEnrollments = [
                SELECT
                    Id,
                    Participant__c,
                    Participant_Contact__c,
                    Participant__r.Contact__r.Visited_Communities__c,
                    Study_Site__c,
                    Study_Site__r.Clinical_Trial_Profile__c,
                    Study_Site__r.Suppress_Participant_Emails__c,
                    Clinical_Trial_Profile__r.CommunityTemplate__c,
                    Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                    Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,
                    Is_Virtual_Study_Site__c,
                    HCP__c,
                    HCP__r.HCP_Contact__c,
                    Referral_Source__c,
                    Participant_Status__c
                FROM Participant_Enrollment__c
                WHERE Id IN :peIds
            ];
            Set<Id> participantIds = new Set<Id>();
            Map<Id, Participant_Enrollment__c> participantEnrollmentMap = new Map<Id, Participant_Enrollment__c>();
            for (Participant_Enrollment__c pe : participantEnrollments) {
                participantIds.add(pe.Participant__c);
                participantEnrollmentMap.put(pe.Id, pe);
            }
            List<Participant__c> participants = [
                SELECT Id, Contact__c, IsCountry_NOT_Eligible_for_Emails__c, Adult__c
                FROM Participant__c
                WHERE Id IN :participantIds
            ];
            Map<Id, Participant__c> participantMap = new Map<Id, Participant__c>();
            for (Participant__c participant : participants) {
                participantContactIds.add(participant.Contact__c);
                participantMap.put(participant.Id, participant);
            }
            for (User usr : CommunityService.getCommunityUsersByContactIds(participantContactIds)) {
                usersByContactId.put(usr.ContactId, usr);
            }

            //process PE items:
            List<String> peStatusesSuccess = new List<String>{
                PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS,
                PEStatusState.PE_STATUS_RANDOMIZATION_SUCCESS
            };
            List<Id> recipientIds = new List<Id>();
            List<Id> whatIds = new List<Id>();
            for (Participant_Enrollment__c newPE : participantEnrollments) {
                whatIds.add(newPE.Id);
                Participant__c participant = newPE.Participant__c != null
                    ? participantMap.get(newPE.Participant__c)
                    : null;
                recipientIds.add(participant.Contact__c);
            }
            NotificationAvailabilityService availabilityService = new NotificationAvailabilityService(
                recipientIds,
                whatIds
            );
            for (Participant_Enrollment__c newPE : participantEnrollments) {
                Participant__c participant = newPE.Participant__c != null
                    ? participantMap.get(newPE.Participant__c)
                    : null;
                User participantUser;
                if (participant != null && participant.Contact__c != null)
                    participantUser = usersByContactId.get(participant.Contact__c);
                Boolean filterCriteria =
                    !newPE.Is_Virtual_Study_Site__c &&
                    newPE.Study_Site__c != null &&
                    newPE.Study_Site__r.Clinical_Trial_Profile__c != null &&
                    !newPE.Study_Site__r.Suppress_Participant_Emails__c &&
                    !newPE.Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c &&
                    newPE.Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c &&
                    participant != null &&
                    !participant.IsCountry_NOT_Eligible_for_Emails__c &&
                    participant.Contact__c != null;
                if (filterCriteria && participant.Adult__c) {
                    if (participantUser == null) {
                        System.debug('CREATE USER');
                        Id hcpContact;
                        if (newPE.HCP__c != null)
                            hcpContact = newPE.HCP__r.HCP_Contact__c;
                        toCreateUser.put(participant.Contact__c, hcpContact);
                    } else {
                        System.debug('NOTIFY USER');
                        String notificationTypeStr;
                        Boolean checkPermissionSet = !availabilityService.isDeferNotification(
                            participant.Contact__c,
                            newPE.Id
                        );
                        String sourcePe = newPE.Referral_Source__c;
                        String visitedCommunities = newPE.Participant__r.Contact__r.Visited_Communities__c;
                        String currentCommunityName = CommunityTemplateService.getTemplate(
                                newPE.Clinical_Trial_Profile__r.CommunityTemplate__c
                            )
                            .templateName;
                        Boolean checkVisitedCommunity = false;
                        if (visitedCommunities != null)
                            checkVisitedCommunity = visitedCommunities.contains(
                                currentCommunityName
                            );
                        if (
                            checkPermissionSet &&
                            !peStatusesSuccess.contains(newPE.Participant_Status__c) &&
                            checkVisitedCommunity
                        ) {
                            if (
                                sourcePe.contains(
                                    ParticipantEnrollmentService.PE_REFERRAL_SOURCE_HCP
                                )
                            ) {
                                notificationTypeStr = NotificationCatalog.MESSAGE_TO_PT_SOURCE_HCP_TYPE;
                            } else if (
                                sourcePe.contains(
                                    ParticipantEnrollmentService.PE_REFERRAL_SOURCE_PI
                                )
                            ) {
                                notificationTypeStr = NotificationCatalog.MESSAGE_TO_PT_SOURCE_PI_TYPE;
                            } else {
                                notificationTypeStr = NotificationCatalog.MESSAGE_TO_PT_SOURCE_ERP_TYPE;
                            }
                        }
                        if (notificationTypeStr != null)
                            notifications.add(
                                new Notification__c(
                                    Recipient__c = participant.Contact__c,
                                    WhatId__c = newPE.Id,
                                    Notification_Type__c = notificationTypeStr
                                )
                            );
                    }
                    contactsForChangeMode.add(
                        new Contact(
                            Id = participant.Contact__c,
                            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT
                        )
                    );
                }
            }

            if (!toCreateUser.isEmpty()) {
                if (Test.isRunningTest()) {
                    ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                        .createParticipantUsers(toCreateUser);
                } else {
                    ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                        .createParticipantUsersAsync(toCreateUser, participantContactIds, peIds);
                }
            }
            if (!notifications.isEmpty())
                insert notifications;
            if (!contactsForChangeMode.isEmpty())
                update contactsForChangeMode;
        }
    }
    @TestVisible
    private static void createPlatformAlerts(
        List<Participant_Enrollment_Status_History__c> newList
    ) {
        Set<Id> peIds = new Set<Id>();
        List<Alert__c> alertsForInsert = new List<Alert__c>();
        for (Participant_Enrollment_Status_History__c pesh : newList) {
            if (pesh.Status__c == PEStatusState.PE_STATUS_RECEIVED) {
                peIds.add(pesh.ParticipantEnrollment__c);
            }
        }
        if (!peIds.isEmpty()) {
            List<Participant_Enrollment__c> participantEnrollments = [
                SELECT
                Id,
                Participant__c,
                Participant__r.Adult__c,
                Participant_Contact__c,
                Participant__r.Contact__r.Visited_Communities__c,
                Participant__r.IsCountry_NOT_Eligible_for_Emails__c,
                Study_Site__c,
                Study_Site__r.Clinical_Trial_Profile__c,
                Study_Site__r.Suppress_Participant_Emails__c,
                Clinical_Trial_Profile__r.CommunityTemplate__c,
                Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,
                Is_Virtual_Study_Site__c,
                HCP__c,
                HCP__r.HCP_Contact__c,
                Referral_Source__c,
                Participant_Status__c
                FROM Participant_Enrollment__c
                WHERE Id IN :peIds
            ];
            for (Participant_Enrollment__c newPE : participantEnrollments) {
                Boolean filterCriteria =
                    !newPE.Is_Virtual_Study_Site__c &&
                    newPE.Study_Site__c != null &&
                    newPE.Study_Site__r.Clinical_Trial_Profile__c != null &&
                    !newPE.Study_Site__r.Suppress_Participant_Emails__c &&
                    !newPE.Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c &&
                    newPE.Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c &&
                    newPE.Participant__c != null &&
                    !newPE.Participant__r.IsCountry_NOT_Eligible_for_Emails__c &&
                    newPE.Participant_Contact__c != null &&
                    newPE.Participant__r.Adult__c;
                if(filterCriteria){
                    if (
                        newPE.Clinical_Trial_Profile__r.CommunityTemplate__c ==
                        CommunityTemplateService.TEMPLATE_PP
                    ) {
                        alertsForInsert.add(
                            new Alert__c(
                                Contact__c = newPE.Participant_Contact__c,
                                Alert_Code__c = Alert.ALERT_CODE_WELCOME_PH_PP,
                                Is_Platform_Level__c = true
                            )
                        );
                    } else {
                        alertsForInsert.add(
                            new Alert__c(
                                Contact__c = newPE.Participant_Contact__c,
                                Alert_Code__c = Alert.ALERT_CODE_WELCOME_PH,
                                Is_Platform_Level__c = true
                            )
                        );
                    }
                }
            }
            if (!alertsForInsert.isEmpty())
                insert alertsForInsert;
        }
    }
    @TestVisible
    private static void createStudyAlerts(
        List<Id> newHistories
    ) {
        Map<Id,Id> statusHistoryPER = new Map<Id,Id>();
        List<Participant_Enrollment_Status_History__c> histories = [
            SELECT
            ParticipantEnrollment__r.Participant_Contact__c,
            ParticipantEnrollment__r.Participant__c,
            ParticipantEnrollment__r.Clinical_Trial_Profile__c,
            ParticipantEnrollment__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,
            Status__c,
            Date__c,
            ParticipantEnrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c
            FROM Participant_Enrollment_Status_History__c
            WHERE Id IN :newHistories
        ];
        
        List<Participant_Enrollment__c> peSuccess = new List<Participant_Enrollment__c>();
        for (Participant_Enrollment_Status_History__c history : histories) {
            statusHistoryPER.put(history.Id, history.ParticipantEnrollment__c);
            if (
                PEStatusState.PE_STATUS_GROUP_PARTICIPATION_IN_PROGRESS.contains(history.Status__c)
            ) {
                Participant_Enrollment__c enrollment = history.ParticipantEnrollment__r;
                if (enrollment.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c) {
                    peSuccess.add(enrollment);
                    
                }
            }
        }
        set<Id> alredayEnrolledPER = new Set<Id>();
        Map<ID, Participant_Enrollment_Status_History__c> enrollmentHistories = new Map<ID, Participant_Enrollment_Status_History__c>([
            SELECT
            ParticipantEnrollment__r.Participant_Contact__c,
            ParticipantEnrollment__r.Participant__c,
            ParticipantEnrollment__r.Clinical_Trial_Profile__c,
            ParticipantEnrollment__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,
            Status__c,
            Date__c,
            ParticipantEnrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c
            FROM Participant_Enrollment_Status_History__c
            WHERE ParticipantEnrollment__c IN :statusHistoryPER.values() 
            AND Status__c IN : PEStatusState.PE_STATUS_GROUP_PARTICIPATION_IN_PROGRESS
            AND Id NOT IN : newHistories
        ]);
        
        for (Participant_Enrollment_Status_History__c pe : enrollmentHistories.values()){
            alredayEnrolledPER.add(pe.ParticipantEnrollment__c);
        }        
        
        List<Id> participantIds = new List<Id>();
        List<Id> perIdLst = new List<Id>();
        for (Participant_Enrollment__c pe : peSuccess){
            participantIds.add(pe.Participant__c);
            perIdLst.add(pe.Id);
        }
        
        PatientDelegateEnrollmentService.PDEWrapper pdewrapper = PatientDelegateEnrollmentService.getDelegatedContactIdsByParticipantIdMap(
            participantIds,perIdLst
        );
        Map<Id, List<Id>> delegateCntByParticipant = pdewrapper.delParticipantIds; // Actual participant with list of delegate contact IDs
        
        //Commented as part of PD design 
        /* Map<Id, List<Id>> delegateCntByParticipant = PatientDelegateService.getDelegatedContactIdsByParticipantIdMap(
participantIds
);*/
        
        List<Alert__c> alerts = new List<Alert__c>();
        for (Participant_Enrollment__c pe : peSuccess) {
            
            if (pe.Participant_Contact__c != null && !alredayEnrolledPER.contains(pe.Id)) {
                if (
                    pe.Clinical_Trial_Profile__r.CommunityTemplate__c ==
                    CommunityTemplateService.TEMPLATE_PP
                ) {
                    alerts.add(
                        new Alert__c(
                            Contact__c = pe.Participant_Contact__c,
                            Alert_Code__c = Alert.ALERT_CODE_WELCOME_STUDY_PP,
                            Record_ID__c = pe.Id
                        )
                    );
                } else {
                    alerts.add(
                        new Alert__c(
                            Contact__c = pe.Participant_Contact__c,
                            Alert_Code__c = Alert.ALERT_CODE_WELCOME_STUDY,
                            Record_ID__c = pe.Id
                        )
                    );
                }
            }
            
            if (!delegateCntByParticipant.containsKey(pe.Participant__c))
                continue;
            for (Id contactDelegateId : delegateCntByParticipant.get(pe.Participant__c)) {
                if(!alredayEnrolledPER.contains(pe.Id)){
                    if (
                        pe.Clinical_Trial_Profile__r.CommunityTemplate__c ==
                        CommunityTemplateService.TEMPLATE_PP 
                    ) {
                        alerts.add(
                            new Alert__c(
                                Contact__c = contactDelegateId,
                                Alert_Code__c = Alert.ALERT_CODE_WELCOME_STUDY_DELEGATE_PP,
                                Record_ID__c = pe.Id
                            )
                        );
                    } else {
                        alerts.add(
                            new Alert__c(
                                Contact__c = contactDelegateId,
                                Alert_Code__c = Alert.ALERT_CODE_WELCOME_STUDY_DELEGATE,
                                Record_ID__c = pe.Id
                            )
                        );
                    }
                }
            }
        }
        
        insert alerts;
    }
}