/**
 * Created by D.Yasinskyi on 23.02.2018
 * Refactored by Leonid Bartenev
 */

public without sharing class HCPEnrollmentTriggerHandler {

    // Handlers: -------------------------------------------------------------------------------------------------------

    public class PrepareAdditionalFieldsHandler extends TriggerHandler {

        public override void beforeInsert(List<SObject> newList) {
            prepareAdditionalFields(newList);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            prepareAdditionalFields(newList);
        }
    }

    public class DeleteStatusHistoryOnDeleteHandler extends TriggerHandler {

        public override void beforeDelete(List<SObject> oldList) {
            deleteStatusHistory(oldList);
        }
    }

    public class CreateHCPUserOrSendNotificationHandler extends TriggerHandler {

        public override void afterInsert(List<SObject> newList) {
            createHCPUserOrSendNotification(newList, null);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createHCPUserOrSendNotification(newList, (Map<Id, HCP_Enrollment__c>) oldMap);
            sendOnHoldNotification(newList, (Map<Id, HCP_Enrollment__c>) oldMap);
        }
    }

    public class SendNotificationForActivatedHCPEHandler extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            sendNotificationForActivatedHCPE(newList, (Map<Id, HCP_Enrollment__c>) oldMap);
        }
    }

    public class SwitchContactUserModeHandler extends TriggerHandler {

        public override void afterInsert(List<SObject> newList) {
            switchContactUserMode(newList);
        }
    }

    public class CreateRecruitingHCPStaffModeHandler extends TriggerHandler {

        public override void afterInsert(List<SObject> newList) {
//            createDelegates(newList);
        }
    }

    public class CreateStatusHistoryHandler extends TriggerHandler {

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createStatusHistory(newList, (Map<Id, HCP_Enrollment__c>) oldMap);
        }
    }

    public class CheckReimbursableActivities extends TriggerHandler {

        public override void afterInsert(List<SObject> newList) {
            ProviderPaymentsService.checkHCPEForReimbursableActivities((List<HCP_Enrollment__c>) newList, null);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            ProviderPaymentsService.checkHCPEForReimbursableActivities((List<HCP_Enrollment__c>) newList, (Map<Id, HCP_Enrollment__c>) oldMap);
        }
    }

    // Logic: ----------------------------------------------------------------------------------------------------------

    @TestVisible
    private static void prepareAdditionalFields(List<HCP_Enrollment__c> newList) {
        Set<Id> ssIds = new Set<Id>();
        for (HCP_Enrollment__c hcpe : newList) if (hcpe.Study_Site__c != null) ssIds.add(hcpe.Study_Site__c);
        Map<Id, Study_Site__c> studySiteMap = new Map<Id, Study_Site__c>([
                SELECT Id, Principal_Investigator__c,
                        Clinical_Trial_Profile__c
                FROM Study_Site__c
                WHERE Id IN:ssIds
        ]);
        for (HCP_Enrollment__c hcpe : newList) {
            if (hcpe.Study_Site__c != null) {
                Study_Site__c ss = studySiteMap.get(hcpe.Study_Site__c);
                if (ss != null) {
                    hcpe.Study_Site_PI_Contact__c = ss.Principal_Investigator__c;
                    hcpe.Clinical_Trial_Profile__c = ss.Clinical_Trial_Profile__c;
                }
            }
        }
    }

    @TestVisible
    private static void createHCPUserOrSendNotification(List<HCP_Enrollment__c> newList, Map<Id, HCP_Enrollment__c> oldMap) {
        Set<Id> hcpContactIds = new Set<Id>();
        for (HCP_Enrollment__c hcpe : newList) if (hcpe.HCP_Contact__c != null) hcpContactIds.add(hcpe.HCP_Contact__c);
        Set<Id> contactIdsWithCreatedUser = new Set<Id>();
        for (User user : CommunityService.getCommunityUsersByContactIds(hcpContactIds)) contactIdsWithCreatedUser.add(user.ContactId);
        Set<Id> contactIdsForCreateUsers = new Set<Id>();
        Map<Id, HCP_Enrollment__c> newMap = new Map<Id, HCP_Enrollment__c>(newList);
        Map<Id, Contact> alreadyCreatedContactsMap = new Map<Id, Contact>([SELECT Id, Is_First_Logon__c FROM Contact WHERE Id IN :hcpContactIds]);
        List<Healthcare_Provider__c> hps = [SELECT Id, HCP_Enrollment__c FROM Healthcare_Provider__c WHERE HCP_Enrollment__c IN :newMap.keySet()];
        Map<Id, Healthcare_Provider__c> hpsByHCPE = new Map<Id, Healthcare_Provider__c>();
        for (Healthcare_Provider__c hp : hps) {
            hpsByHCPE.put(hp.HCP_Enrollment__c, hp);
        }
        List<Notification__c> notifications = new List<Notification__c>();
        String notificationType;
        for (HCP_Enrollment__c hcpe : newList) {
            if (hcpe.Status__c == HCPEnrollmentService.HCP_S_INVITATION_SENT && hcpe.HCP_Contact__c != null &&
                    ((oldMap == null) || (oldMap != null && hcpe.Status__c != oldMap.get(hcpe.Id).Status__c))) {
                if (contactIdsWithCreatedUser.contains(hcpe.HCP_Contact__c)) {
                    if (hpsByHCPE.get(hcpe.Id) != null || alreadyCreatedContactsMap.containsKey(hcpe.HCP_Contact__c)) {
                        notificationType = NotificationCatalog.MESSAGE_TO_HCP_NEW_STUDY_BY_PI_TYPE;
                    }
                    notifications.add(new Notification__c(
                            Recipient__c = hcpe.HCP_Contact__c,//hcpe.Id,
                            WhatId__c = hcpe.Id,//hcpe.HCP_Contact__c,
                            Notification_Type__c = notificationType));
                } else {
                    contactIdsForCreateUsers.add(hcpe.HCP_Contact__c);
                }
            }
        }

        if (contactIdsForCreateUsers.size() > 0) ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createPortalUsers(contactIdsForCreateUsers);
        insert notifications;
    }

    @TestVisible
    private static void sendOnHoldNotification(List<HCP_Enrollment__c> newList, Map<Id, HCP_Enrollment__c> oldMap) {
        List<Notification__c> notificationsToSend = new List<Notification__c>();
        for(HCP_Enrollment__c hcpe : newList){
            if(HCPEnrollmentService.STATUS_GROUP_ON_HOLD.contains(hcpe.Status__c) && hcpe.Status__c != oldMap.get(hcpe.Id).Status__c){
                notificationsToSend.add(new Notification__c(
                        Recipient__c = hcpe.HCP_Contact__c,
                        WhatId__c = hcpe.Id,
                        Notification_Type__c = NotificationCatalog.MESSAGE_TO_HCP_HCPE_ON_HOLD_TYPE));
            }
        }
        if(!notificationsToSend.isEmpty()) insert notificationsToSend;
    }

    @TestVisible
    private static void switchContactUserMode(List<HCP_Enrollment__c> newList) {
        Set<Id> hcpEContactIds = new Set<Id>();
        for (HCP_Enrollment__c enrol : newList) {
            if (enrol.HCP_Contact__c != null) hcpEContactIds.add(enrol.HCP_Contact__c);
        }
        if (hcpEContactIds.isEmpty()) return;

// these changes are being on hold
// Map<Id, Participant__c> participants = CommunityService.getParticipantsByContactIds(hcpEContactIds);

        List<Contact> contactsForUpdate = new List<Contact>();
        for (Contact piContact : CommunityService.getContactsByUserContactIds(hcpEContactIds)) {
            piContact.userCommunityMode__c = CommunityService.USER_MODE_HCP;
            if (piContact.userCommunytyType__c == null) {
                piContact.userCommunytyType__c = CommunityService.USER_MODE_HCP;
            } else if (!piContact.userCommunytyType__c.contains(CommunityService.USER_MODE_HCP)) {
                piContact.userCommunytyType__c += ';' + CommunityService.USER_MODE_HCP;
            }

// these changes are being on hold
//if (participants.containsKey(piContact.Id)) {
//    Participant__c participant = participants.get(piContact.Id);
//    piContact.FirstName = participant.First_Name__c;
//    piContact.LastName  = participant.Last_Name__c;
//    System.debug('-----------> HCPEnrollmentTriggerHandler.switchContactUserMode(): Contact names replaced to: ' + piContact.FirstName + ' ' + piContact.LastName);
//}

            contactsForUpdate.add(piContact);
        }
        update contactsForUpdate;
    }

//    @TestVisible
//    private static void createDelegates(List<HCP_Enrollment__c> newList) {
//        Set<Id> hcpEContactIds = new Set<Id>();
//        for (HCP_Enrollment__c enrol : newList) if (enrol.HCP_Contact__c != null) hcpEContactIds.add(enrol.HCP_Contact__c);
//        if (hcpEContactIds.isEmpty()) return;
//        Map<Id, Map<Id, String>> delegatesMapbyHCP = DelegateService.getHCPTeamLevelMapByHCP(hcpEContactIds);
//        List<Referring_HCP_Staff__c> newDelegateRecords = new List<Referring_HCP_Staff__c>();
//        for (HCP_Enrollment__c enrol : newList){
//            if (enrol.HCP_Contact__c != null) {
//                if(delegatesMapbyHCP.containsKey(enrol.HCP_Contact__c)){
//                    Map<Id, String> delegateMap = delegatesMapbyHCP.get(enrol.HCP_Contact__c);
//                    for(Id key: delegateMap.keySet()){
//                        Referring_HCP_Staff__c newDelegate = new Referring_HCP_Staff__c();
//                        newDelegate.Delegate_Level__c = delegateMap.get(key);
//                        newDelegate.Contact__c = key;
//                        newDelegate.HCP_Enrollment__c = enrol.Id;
//                        newDelegateRecords.add(newDelegate);
//                    }
//                }
//            }
//        }
//        if(!newDelegateRecords.isEmpty()){
//            insert newDelegateRecords;
//        }
//    }

    @TestVisible
    private static void createStatusHistory(List<HCP_Enrollment__c> newList, Map<Id, HCP_Enrollment__c> oldMap) {
        List<Status_History__c> hcpEHistoryList = new List<Status_History__c>();
        for (HCP_Enrollment__c enrollment : newList) {
            if (oldMap.get(enrollment.Id).Status__c != enrollment.Status__c) {
                hcpEHistoryList.add(new Status_History__c(
                        Date__c = Datetime.now(),
                        HCP_Enrollment__c = enrollment.Id,
                        NewStatus__c = enrollment.Status__c
                ));
            }
        }
        insert hcpEHistoryList;
    }

    @TestVisible
    private static void deleteStatusHistory(List<HCP_Enrollment__c> oldList) {
        delete [SELECT Id FROM Status_History__c WHERE HCP_Enrollment__c IN:oldList];
    }

    @TestVisible
    private static void sendNotificationForActivatedHCPE(List<HCP_Enrollment__c> newList, Map<Id, HCP_Enrollment__c> oldMap) {
        Map<Id, HCP_Enrollment__c> hcpeMapWithUpdatedStatuses = new Map<Id, HCP_Enrollment__c>();
        for (HCP_Enrollment__c hcpe : newList) {
            if ((hcpe.Status__c == HCPEnrollmentService.HCP_S_ACTIVATED || hcpe.Status__c == HCPEnrollmentService.HCP_S_ACTIVATION_PENDING_O) && hcpe.Status__c != oldMap.get(hcpe.Id).Status__c) {
                hcpeMapWithUpdatedStatuses.put(hcpe.Id, hcpe);
            }
        }
        if (!hcpeMapWithUpdatedStatuses.isEmpty()) {
            Map<Id, List<HCP_Enrollment__c>> mapHCPEByHcpContact = new Map<Id, List<HCP_Enrollment__c>>();
            List<HCP_Enrollment__c> hcpeWithUniqueHCP = new List<HCP_Enrollment__c>();
            Set<Id> hcpWithSingleHCPE = new Set<Id>();
            for (HCP_Enrollment__c hcpe : [
                    SELECT Id,
                            HCP_Contact__c,
                            Study_Site_PI_Contact__c
                    FROM HCP_Enrollment__c
                    WHERE HCP_Contact__r.HCP_Opt_In_Referral_Status_Emails__c = true AND ID IN :hcpeMapWithUpdatedStatuses.keySet()
            ]) {
                if (!mapHCPEByHcpContact.containsKey(hcpe.HCP_Contact__c)) {
                    mapHCPEByHcpContact.put(hcpe.HCP_Contact__c, new List<HCP_Enrollment__c>{
                            hcpe
                    });
                } else {
                    mapHCPEByHcpContact.get(hcpe.HCP_Contact__c).add(hcpe);
                }
            }
            List<Notification__c> listNotificationsToSend = new List<Notification__c>();
            for (Id hcpeContactId : mapHCPEByHcpContact.keySet()) {
                List<HCP_Enrollment__c> enrollmentsForHcp = mapHCPEByHcpContact.get(hcpeContactId);
                if (enrollmentsForHcp.size() > 1) {
                    Boolean wasInPendingOrientationStateBoolean =  oldMap.get(enrollmentsForHcp[0].Id).Status__c == HCPEnrollmentService.HCP_S_ACTIVATION_PENDING_O;
                    listNotificationsToSend.add(new Notification__c(
                            Recipient__c = hcpeContactId,
                            WhatId__c = enrollmentsForHcp[0].Id,
                            Notification_Type__c = (wasInPendingOrientationStateBoolean?
                                    NotificationCatalog.MESSAGE_TO_HCP_ORIENTATION_COMPLETED_TYPE
                                    :NotificationCatalog.MESSAGE_TO_HCP_APPROVED_TYPE)
                    ));
                } else {
                    hcpeWithUniqueHCP.add(enrollmentsForHcp[0]);
                    hcpWithSingleHCPE.add(hcpeContactId);
                }
            }
            if (!hcpWithSingleHCPE.isEmpty()) {
                Map<Id, Set<Id>> rpPiRelationshipsMap = new Map<Id, Set<Id>>();
                for (PI_RP_Relationship__c relationship : [
                        SELECT PI_Contact__c,
                                RP_Contact__c
                        FROM PI_RP_Relationship__c
                        WHERE RP_Contact__c IN :hcpWithSingleHCPE
                ]){
                    if (!rpPiRelationshipsMap.containsKey(relationship.RP_Contact__c)) {
                        rpPiRelationshipsMap.put(relationship.RP_Contact__c, new Set<Id>{relationship.PI_Contact__c});
                    }
                    else{
                        rpPiRelationshipsMap.get(relationship.RP_Contact__c).add(relationship.PI_Contact__c);
                    }
                }
                for (HCP_Enrollment__c hcpEnrollment : hcpeWithUniqueHCP){
                    Boolean wasApprovedByPIForAllStudies = rpPiRelationshipsMap.containsKey(hcpEnrollment.HCP_Contact__c)
                            && rpPiRelationshipsMap.get(hcpEnrollment.HCP_Contact__c).contains(hcpEnrollment.Study_Site_PI_Contact__c);
                    Boolean wasInPendingOrientationState =  oldMap.get(hcpEnrollment.Id).Status__c == HCPEnrollmentService.HCP_S_ACTIVATION_PENDING_O;
                    Boolean wasInOnHoldState =  oldMap.get(hcpEnrollment.Id).Status__c == HCPEnrollmentService.HCP_S_ON_HOLD_A
                            || oldMap.get(hcpEnrollment.Id).Status__c == HCPEnrollmentService.HCP_S_ON_HOLD_ACCEPTANCE
                            || oldMap.get(hcpEnrollment.Id).Status__c == HCPEnrollmentService.HCP_S_ON_HOLD_ACTIVATION
                            || oldMap.get(hcpEnrollment.Id).Status__c == HCPEnrollmentService.HCP_S_ON_HOLD_APPROVAL;
                    Boolean isInPendingOrientationState = hcpEnrollment.Status__c == HCPEnrollmentService.HCP_S_ACTIVATION_PENDING_O;
                    String notificationType;
                    if (isInPendingOrientationState) {
                        notificationType = NotificationCatalog.MESSAGE_TO_HCP_ORIENTATION_REQUIRED_TYPE;
                    }
                    else if (wasInPendingOrientationState) {
                        notificationType = NotificationCatalog.MESSAGE_TO_HCP_ORIENTATION_COMPLETED_TYPE;
                    }
                    else if (wasApprovedByPIForAllStudies && !wasInOnHoldState) {
                        notificationType = NotificationCatalog.MESSAGE_TO_HCP_APPROVED_TYPE;
                    }
                    else{
                        notificationType = NotificationCatalog.MESSAGE_TO_HCP_APPROVED_SINGLE_TYPE;
                    }

                    listNotificationsToSend.add(new Notification__c(
                            Recipient__c = hcpEnrollment.HCP_Contact__c,
                            WhatId__c = hcpEnrollment.Id,
                            Notification_Type__c = notificationType
                    ));
                }
            }
            if (!listNotificationsToSend.isEmpty()) insert listNotificationsToSend;
        }
    }
}