/**
* Created by Kryvolap
*/

public without sharing class ParticipantEnrollmentSHTriggerHandler {
    
    //Handlers----------------------------------------------------------------------------------------------------------
    public class SendPESHToEPR extends TriggerHandler {
        
        public override void afterInsert(List<SObject> newList) {
            sendToEPR(newList);
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
    
    public class CreateWelcomeToStudyAlertHandler extends TriggerHandler {
        
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createStudyAlerts((List<Participant_Enrollment_Status_History__c>) newList, (Map<Id, Participant_Enrollment_Status_History__c>) oldMap);
        }
        public override void afterInsert(List<SObject> newList) {
            if(!Test.isRunningTest() ){
                createStudyAlerts((List<Participant_Enrollment_Status_History__c>) newList, null);
            }
        }
    }
    
    //Logic-------------------------------------------------------------------------------------------------------------
    private static void sendToEPR(List<Participant_Enrollment_Status_History__c> newList) {
        List<Id> ids = new List<Id>();
        for (Participant_Enrollment_Status_History__c obj : newList) {
            ids.add(obj.Id);
        }
        if (!System.isBatch() && !System.isFuture()) {
            IntegrationService.sendPESHToEPRAsync(ids);
        } else {
            IntegrationService.sendPESHToEPR(ids);
        }
    }
    
    @TestVisible
    private static void updateEnrollmentStatus(List<Participant_Enrollment_Status_History__c> histories) {
        Set<Id> peIds = new Set<Id>();
        Map<Id, List<Participant_Enrollment_Status_History__c>> peToHistories =
            new Map<Id, List<Participant_Enrollment_Status_History__c>>();
        
        for (Participant_Enrollment_Status_History__c history : histories) {
            if(history.Status__c == PEStatusState.PE_STATUS_REFERRAL_SENT_TO_PI || history.Status__c == PEStatusState.PE_STATUS_RECEIVED) continue;
            
            Id peId = history.ParticipantEnrollment__c;
            peIds.add(peId);
            
            if (!peToHistories.containsKey(peId)) {
                peToHistories.put(peId, new List<Participant_Enrollment_Status_History__c>());
            }
            peToHistories.get(peId).add(history);
        }
        
        List<Participant_Enrollment__c> enrollments = [
            SELECT Id,
            Enrolled_Date__c,
            Informed_Consent__c,
            Last_Status_Changed_Notes__c,
            Non_Enrollment_Reason__c,
            Participant_Status__c,
            Participant_Status_Last_Changed_Date__c
            FROM Participant_Enrollment__c
            WHERE Id IN:peIds
        ];
        for (Participant_Enrollment__c pe : enrollments) {
            Participant_Enrollment_Status_History__c headHistory = peToHistories.get(pe.Id).get(0);
            for (Participant_Enrollment_Status_History__c history : peToHistories.get(pe.Id)) {
                Integer headStatusValue = PEStatusState.PE_ORDERED_STATUSES.get(headHistory.Status__c);
                Integer currentStatusValue = PEStatusState.PE_ORDERED_STATUSES.get(history.Status__c);
                
                if((headStatusValue == currentStatusValue && headHistory.Date__c < history.Date__c)
                   || headStatusValue != Math.max(headStatusValue, currentStatusValue)) {
                       headHistory = history;
                   }
            }
            
            pe.Last_Status_Changed_Notes__c = headHistory.Notes__c;
            pe.Non_Enrollment_Reason__c = headHistory.Reason__c;
            pe.Participant_Status_Last_Changed_Date__c = headHistory.Date__c;
            pe.Participant_Status__c = headHistory.Status__c;
            if(headHistory.Status__c == PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS
               || headHistory.Status__c == PEStatusState.PE_STATUS_RANDOMIZATION_SUCCESS) {
                   pe.Informed_Consent__c = true;
                   pe.Enrolled_Date__c = headHistory.Date__c.date();
               }
        }
        System.debug('enrollments:' + enrollments);
        update enrollments;
    }
    
    @TestVisible
    private static void sendCalloutOnEligibilityPassed(List<Participant_Enrollment_Status_History__c> newList) {
        String acceptedStatus = PEStatusState.PE_STATUS_ELIGIBILITY_PASSED;
        Set<id> peIds = new Set<Id>();
        for (Participant_Enrollment_Status_History__c pesh : newList) {
            if (pesh.Status__c == acceptedStatus) {
                peIds.add(pesh.ParticipantEnrollment__c);
            }
        }
        Map<Id,Participant_Enrollment_Status_History__c> lastExitingHistoryMap = new Map<Id, Participant_Enrollment_Status_History__c>();
        for(Participant_Enrollment_Status_History__c pesh : [
            SELECT Status__c, ParticipantEnrollment__c
            FROM Participant_Enrollment_Status_History__c
            WHERE ParticipantEnrollment__c IN :peIds
            ORDER BY Date__c DESC
        ]){
            if(!lastExitingHistoryMap.containsKey(pesh.ParticipantEnrollment__c)){
                lastExitingHistoryMap.put(pesh.ParticipantEnrollment__c, pesh);
                if(pesh.Status__c == acceptedStatus){
                    peIds.remove(pesh.ParticipantEnrollment__c);
                }
            }
        }
        
        for(Id peId : peIds){
            if(System.IsBatch() == false && System.isFuture() == false) {
                IntegrationService.sendPEToStudyHubAsync(peId);
            }
            else{
                IntegrationService.sendPEToStudyHub(peId);
            }
        }
    }
    
    @TestVisible
    private static void createUsersOrSendNotifications(List<Participant_Enrollment_Status_History__c> newList) {
        Set<Id> peIds = new Set<Id>();
        for(Participant_Enrollment_Status_History__c pesh: newList){
            if(pesh.Status__c == PEStatusState.PE_STATUS_RECEIVED){
                peIds.add(pesh.ParticipantEnrollment__c);
            }
        }
        if(!peIds.isEmpty()){
            Map<Id, Id> toCreateUser = new Map<Id, Id>();
            List<Contact> contactsForChangeMode = new List<Contact>();
            List<Notification__c> notifications = new List<Notification__c>();
            
            Map<Id, User> usersByContactId = new Map<Id, User>();
            Set<Id> participantContactIds = new Set<Id>();
            List<Participant_Enrollment__c> participantEnrollments = [
                SELECT Id,
                Participant__c,
                Participant_Contact__c,
                Study_Site__c,
                Study_Site__r.Clinical_Trial_Profile__c,
                Study_Site__r.Suppress_Participant_Emails__c,
                Clinical_Trial_Profile__r.CommunityTemplate__c,
                Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,
                Is_Virtual_Study_Site__c,
                HCP__c,
                HCP__r.HCP_Contact__c,
                Referral_Source__c,
                Participant_Status__c
                FROM Participant_Enrollment__c WHERE Id IN : peIds];
            Set<Id> participantIds = new Set<Id>();
            Map<Id, Participant_Enrollment__c> participantEnrollmentMap = new Map<Id, Participant_Enrollment__c>();
            for (Participant_Enrollment__c pe : participantEnrollments) {
                participantIds.add(pe.Participant__c);
                participantEnrollmentMap.put(pe.Id, pe);
            }
            List<Participant__c> participants = [
                SELECT Id, Contact__c,IsCountry_NOT_Eligible_for_Emails__c, Adult__c
                FROM Participant__c WHERE Id IN : participantIds];
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
                        List<Alert__c> alertsForInsert = new List<Alert__c>();
            List<Id> recipientIds = new List<Id>();
            List<Id> whatIds = new List<Id>();
            for (Participant_Enrollment__c newPE : participantEnrollments) {
                whatIds.add(newPE.Id);
                recipientIds.add(newPE.Participant__c);
            }
            NotificationAvailabilityService availabilityService = new NotificationAvailabilityService(recipientIds, whatIds);
            for (Participant_Enrollment__c newPE : participantEnrollments) {
                Participant__c participant = newPE.Participant__c != null? participantMap.get(newPE.Participant__c):null;
                User participantUser;
                if (participant != null && participant.Contact__c != null) participantUser = usersByContactId.get(participant.Contact__c);
                Boolean filterCriteria = !newPE.Is_Virtual_Study_Site__c &&
                    newPE.Study_Site__c != null  &&
                    newPE.Study_Site__r.Clinical_Trial_Profile__c != null &&
                    !newPE.Study_Site__r.Suppress_Participant_Emails__c &&
                    !newPE.Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c &&
                    participant != null &&
                    !participant.IsCountry_NOT_Eligible_for_Emails__c &&
                    participant.Contact__c != null;
                if (filterCriteria && participant.Adult__c) {
                    if (participantUser == null) {
                        System.debug('CREATE USER');
                        Id hcpContact;
                        if (newPE.HCP__c != null) hcpContact = newPE.HCP__r.HCP_Contact__c;
                        toCreateUser.put(participant.Contact__c, hcpContact);
                        alertsForInsert.add(new Alert__c(
                            Contact__c = participant.Contact__c,
                            Alert_Code__c = Alert.ALERT_CODE_WELCOME_PH
                        ));
                    }else {
                        System.debug('NOTIFY USER');
                        if (newPE.Referral_Source__c == ParticipantEnrollmentService.PE_REFERRAL_SOURCE_HCP
                            && !peStatusesSuccess.contains(newPE.Participant_Status__c)
                            && !availabilityService.isDeferNotification(participant.Contact__c, newPE.Id)) {
                                notifications.add(new Notification__c(
                                    Recipient__c = participant.Contact__c,
                                    WhatId__c = newPE.Id,
                                    Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_SOURCE_HCP_TYPE
                                ));
                            } else if (newPE.Referral_Source__c == ParticipantEnrollmentService.PE_REFERRAL_SOURCE_PI
                                       && !peStatusesSuccess.contains(newPE.Participant_Status__c)
                                       && !availabilityService.isDeferNotification(participant.Contact__c, newPE.Id)) {
                                           notifications.add(new Notification__c(
                                               Recipient__c = participant.Contact__c,
                                               WhatId__c = newPE.Id,
                                               Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_SOURCE_PI_TYPE
                                           ));
                                       } else if (!peStatusesSuccess.contains(newPE.Participant_Status__c)
                                                  && !availabilityService.isDeferNotification(participant.Contact__c, newPE.Id)){
                                                      notifications.add(new Notification__c(
                                                          Recipient__c = participant.Contact__c,
                                                          WhatId__c = newPE.Id,
                                                          Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_SOURCE_ERP_TYPE
                                                      ));
                                                  }
                    }
                    contactsForChangeMode.add(new Contact(
                        Id = participant.Contact__c,
                        userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT
                    ));
                }
            }
            
            if (!alertsForInsert.isEmpty()) insert alertsForInsert;
            if (toCreateUser.size() > 0) {
                if (Test.isRunningTest()) {
                    ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createParticipantUsers(toCreateUser);
                } else {
                    ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createParticipantUsersAsync(toCreateUser, participantContactIds);
                }
            }
            if (!notifications.isEmpty()) insert notifications;
            if (!contactsForChangeMode.isEmpty()) update contactsForChangeMode;
        }
    }
    @TestVisible
    private static void createStudyAlerts(List<Participant_Enrollment_Status_History__c> enrollments, Map<Id, Participant_Enrollment_Status_History__c> oldMap) {
        List<Participant_Enrollment_Status_History__c> peEnrollSuccessWithParticipating = new List<Participant_Enrollment_Status_History__c>();
        
        List<Participant_Enrollment_Status_History__c> peStatList = [SELECT Id,ParticipantEnrollment__r.Participant_Contact__c,
                                                                     ParticipantEnrollment__r.Participant__c,Status__c,
                                                                     ParticipantEnrollment__r.Clinical_Trial_Profile__c,
                                                                     ParticipantEnrollment__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c
                                                                     FROM Participant_Enrollment_Status_History__c
                                                                     WHERE ID IN: enrollments
                                                                    ];
        for (Participant_Enrollment_Status_History__c pe : peStatList) {
            if (oldMap == null || pe.Status__c != oldMap.get(pe.Id).Status__c) {
                if ((pe.Status__c == PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS
                     || pe.Status__c == PEStatusState.PE_STATUS_RANDOMIZATION_SUCCESS
                     && ((Clinical_Trial_Profile__c)PETriggerBuffer.getSObject(pe.ParticipantEnrollment__r.Clinical_Trial_Profile__c)).Patient_Portal_Enabled__c)
                   ) {
                       peEnrollSuccessWithParticipating.add(pe);
                   }
            }
        }
        List<Id> participantIds = new List<Id>();
        for (Participant_Enrollment_Status_History__c pe : peEnrollSuccessWithParticipating)
            participantIds.add(pe.ParticipantEnrollment__r.Participant__c);
        
        Map<Id, List<Id>> delegateCntByParticipant = PatientDelegateService.getDelegatedContactIdsByParticipantIdMap(participantIds);
        List<Alert__c> alerts = new List<Alert__c>();
        for (Participant_Enrollment_Status_History__c pe : peEnrollSuccessWithParticipating) {
            if(pe.ParticipantEnrollment__r.Participant_Contact__c != null){
                alerts.add(new Alert__c(
                    Contact__c = pe.ParticipantEnrollment__r.Participant_Contact__c,
                    Alert_Code__c = Alert.ALERT_CODE_WELCOME_STUDY,
                    Record_ID__c = pe.ParticipantEnrollment__r.Id
                ));
            }
            if (!delegateCntByParticipant.containsKey(pe.ParticipantEnrollment__r.Participant__c)) continue;
            
            for (Id contactDelegateId : delegateCntByParticipant.get(pe.ParticipantEnrollment__r.Participant__c)) {
                alerts.add(new Alert__c(
                    Contact__c = contactDelegateId,
                    Alert_Code__c = Alert.ALERT_CODE_WELCOME_STUDY_DELEGATE,
                    Record_ID__c = pe.Id)
                          );
            }
        }
        
        insert alerts;
    }
}