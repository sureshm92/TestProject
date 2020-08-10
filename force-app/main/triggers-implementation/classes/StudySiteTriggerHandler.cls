/**
 * Created by D.Yasinskyi on 14.03.2018
 * refactored by Leonid Bartenev
 */

public without sharing class StudySiteTriggerHandler {
    
    // Handlers: -------------------------------------------------------------------------------------------------------
    
    public class DeleteStatusHistoryOnDeleteHandler extends TriggerHandler{
        
        public override void beforeDelete(List<SObject> oldList) {
            deleteStatusHistory(oldList);
        }
    }
    
    public class CreatePIOrSendNotificationHandler extends TriggerHandler{
        
        public override void afterInsert(List<SObject> newList) {
            createPIUserOrSendNotification(newList, null);
        }
        
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createPIUserOrSendNotification(newList, (Map<Id, Study_Site__c>)oldMap);
        }
    }
    
    public class SwitchContactUserModeHandler extends TriggerHandler{
        
        public override void afterInsert(List<SObject> newList) {
            switchContactUserMode(newList);
        }
        
    }
    
    public class CreateStatusHistoryHandler extends TriggerHandler{
    
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createStatusHistory(newList, (Map<Id, Study_Site__c>)oldMap);
        }
    }
    
    public class PrepareAdditionalFieldsHandler extends TriggerHandler {

        public override void beforeInsert(List<SObject> newList) {
            prepareAdditionalFields(newList);
            overrideStatusChangedBy(newList, null);
            updateRecruitmentStatus(newList);
        }

        //START INC9339329 14/02/2020 Sumit S
        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            piDoesNotReimburse(newList);
        }
        //END INC9339329

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            overrideStatusChangedBy(newList, (Map<Id, Study_Site__c>) oldMap);
            updateRecruitmentStatus(newList);
        }
    }

    public class CreateHCPEnrollmentsForRPInWhiteListHandler extends TriggerHandler{

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createHCPEnrollmentsForRPInWhiteList(newList, (Map<Id, Study_Site__c>)oldMap);
        }
    }

    public class SetSuppressEmailsFieldAccordingToStudy extends TriggerHandler{

        public override void beforeInsert(List<SObject> newList) {
            setSuppressField(newList);
        }
    }
    
    public class AssignCommunityPermissionsForUser extends TriggerHandler{
        public override void afterInsert(List<SObject> newList) {
            assignCommunityPermissions(newList);

        }
    }

    
    
    
    // Logic: ----------------------------------------------------------------------------------------------------------
    
    @TestVisible
    private static void createPIUserOrSendNotification(List<Study_Site__c> newList, Map<Id, Study_Site__c> oldMap) {
        Set<Id> piContactIds = new Set<Id>();
        for (Study_Site__c ss : newList) if(ss.Principal_Investigator__c != null) piContactIds.add(ss.Principal_Investigator__c);
        Set<Id> contactIdsWithCreatedUser = new Set<Id>();
        for (User user : CommunityService.getCommunityUsersByContactIds(piContactIds)) contactIdsWithCreatedUser.add(user.ContactId);
        Set<Id> contactIdsForCreateUsers = new Set<Id>();
        List<Notification__c> notifications = new List<Notification__c>();
        Set<Id> ssIDs = new Set<Id>();
        Set<Id> pisWithUser = new Set<Id>();
        for(Study_Site__c ss : newList) {
            if (ss.Override_PI_Referral_Status__c == StudySiteService.PI_S_INVITATION_SENT && ss.Principal_Investigator__c != null
                    && (oldMap == null || (oldMap != null && ss.Override_PI_Referral_Status__c != oldMap.get(ss.Id).Override_PI_Referral_Status__c))) {
                if(!contactIdsWithCreatedUser.contains(ss.Principal_Investigator__c)) contactIdsForCreateUsers.add(ss.Principal_Investigator__c);
                else {
                    ssIDs.add(ss.Id);
                    pisWithUser.add(ss.Principal_Investigator__c);
                }
            }
        }
        if(!ssIDs.isEmpty()) {
            Map<Id, Map<String, List<Id>>> piCommunitySS = new Map<Id, Map<String, List<Id>>>();
            for(Study_Site__c notificationSS : [
                    SELECT Id,
                            Principal_Investigator__c,
                            Clinical_Trial_Profile__c,
                            Clinical_Trial_Profile__r.CommunityTemplate__c
                    FROM Study_Site__c
                    WHERE Principal_Investigator__c IN :pisWithUser]){
                if(piCommunitySS.containsKey(notificationSS.Principal_Investigator__c)) {
                    piCommunitySS.get(notificationSS.Principal_Investigator__c).get(notificationSS.Clinical_Trial_Profile__r.CommunityTemplate__c).add(notificationSS.Id);
                } else {
                    piCommunitySS.put(notificationSS.Principal_Investigator__c, new Map<String, List<Id>>{
                            CommunityTemplateService.TEMPLATE_DEFAULT => new List<Id>(),
                            CommunityTemplateService.TEMPLATE_JANSSEN => new List<Id>(),
                            CommunityTemplateService.TEMPLATE_GSK => new List<Id>()
                    });
                }
            }
            for (Id piId : piCommunitySS.keySet()) {
                for (String community : piCommunitySS.get(piId).keySet()) {
                    if (community == CommunityTemplateService.TEMPLATE_JANSSEN) {
                        if (piCommunitySS.get(piId).get(community).size() > 1) {
                            for (Id ss : piCommunitySS.get(piId).get(community)) {
                                if (ssIDs.contains(ss)) {
                                    notifications.add(new Notification__c(
                                            Recipient__c = piId,
                                            WhatId__c = ss,
                                            Notification_Type__c = NotificationCatalog.MESSAGE_TO_PI_ACCEPT_NEW_STUDY_TYPE
                                    ));
                                }
                            }
                        }
                    } else {
                        for (Id ss : piCommunitySS.get(piId).get(community)) {
                            if (ssIDs.contains(ss)) {
                                notifications.add(new Notification__c(
                                        Recipient__c = piId,
                                        WhatId__c = ss,
                                        Notification_Type__c = NotificationCatalog.MESSAGE_TO_PI_ACCEPT_NEW_STUDY_TYPE
                                ));
                            }
                        }
                    }
                }
            }
        }
        if(contactIdsForCreateUsers.size() > 0) ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createPortalUsers(contactIdsForCreateUsers);
        insert notifications;
    }
    
    @TestVisible
    private static void switchContactUserMode(List<Study_Site__c> studySites) {
        Set<Id> piContactIds = new Set<Id>();
        for (Study_Site__c ss : studySites) {
            if (ss.Principal_Investigator__c != null) piContactIds.add(ss.Principal_Investigator__c);
        }
        if (piContactIds.isEmpty()) return;

// these changes are being on hold
// Map<Id, Participant__c> participants = CommunityService.getParticipantsByContactIds(piContactIds);
        
        List<Contact> contactsForUpdate = new List<Contact>();
        for (Contact piContact : CommunityService.getContactsByUserContactIds(piContactIds)) {
            piContact.userCommunityMode__c = CommunityService.USER_MODE_PI;
            if (piContact.userCommunytyType__c == null) {
                piContact.userCommunytyType__c = CommunityService.USER_MODE_PI;
            } else if(!piContact.userCommunytyType__c.contains(CommunityService.USER_MODE_PI)){
                piContact.userCommunytyType__c += ';' + CommunityService.USER_MODE_PI;
            }

// these changes are being on hold
//if (participants.containsKey(piContact.Id)) {
//    Participant__c participant = participants.get(piContact.Id);
//    piContact.FirstName = participant.First_Name__c;
//    piContact.LastName  = participant.Last_Name__c;
//    System.debug('-----------> StudySiteTriggerHandler.switchContactUserMode(): Contact names replaced to: ' + piContact.FirstName + ' ' + piContact.LastName);
//}
            
            contactsForUpdate.add(piContact);
        }
        update contactsForUpdate;
    }
    
    @TestVisible
    private static void createStatusHistory(List<Study_Site__c> newList, Map<Id, Study_Site__c> oldMap) {
        List<Status_History__c> historyList = new List<Status_History__c>();
        for (Study_Site__c studySite : newList) {
            if (oldMap.get(studySite.Id).Override_PI_Referral_Status__c != studySite.Override_PI_Referral_Status__c) {
                historyList.add(new Status_History__c(
                        Date__c = Datetime.now(),
                        StudySite__c = studySite.Id,
                        NewStatus__c = studySite.Override_PI_Referral_Status__c
                ));
            }
        }
        insert historyList;
    }
    
    @TestVisible
    private static void deleteStatusHistory(List<Study_Site__c> oldList) {
        delete [SELECT Id FROM Status_History__c WHERE StudySite__c IN: oldList];
    }
    
    private static void prepareAdditionalFields(List<Study_Site__c> newList){
        List<Id> ctpIds = new List<Id>();
        List<Id> siteAccountIds = new List<Id>();
        List<Id> piIds = new List<Id>();
        for(Study_Site__c ss : newList){
            if(ss.Clinical_Trial_Profile__c != null) ctpIds.add(ss.Clinical_Trial_Profile__c);
            if(ss.Site__c != null) siteAccountIds.add(ss.Site__c);
            if(ss.Principal_Investigator__c != null) piIds.add(ss.Principal_Investigator__c);
        }
        Map<Id, Clinical_Trial_Profile__c> ctpMap = new Map<Id, Clinical_Trial_Profile__c>([
                SELECT Id, Protocol_ID__c
                FROM Clinical_Trial_Profile__c WHERE Id IN: ctpIds
        ]);
        Map<Id, Account> sitesMap = new Map<Id, Account>([
                SELECT Id, BillingCountryCode FROM Account WHERE Id IN: siteAccountIds
        ]);
        Map<Id, Contact> piMap = new Map<Id, Contact>([
                SELECT Id, Investigator_Key__c
                FROM Contact
                WHERE Id IN: piIds
        ]);
    
        for(Study_Site__c ss : newList){
            Clinical_Trial_Profile__c ctp;
            if(ss.Protocol_ID__c != null) ctp = ctpMap.get(ss.Clinical_Trial_Profile__c);
            Account site;
            if(ss.Site__c != null) site = sitesMap.get(ss.Site__c);
            Contact pi;
            if(ss.Principal_Investigator__c != null) pi = piMap.get(ss.Principal_Investigator__c);
            //Set autopopulated fields:
            //Primary_Key_ePR__c
            if(ctp != null && site != null && ss.Study_Site_Number__c != null){
                ss.Primary_Key_ePR__c = ctp.Protocol_ID__c + '_' + site.BillingCountryCode + '_' + ss.Study_Site_Number__c;
            }
            //Primary_Key__c
            if(ctp != null && pi != null){
                ss.Primary_Key__c = ss.Study_Site_Key__c + '_' + pi.Investigator_Key__c + '_' + ctp.Protocol_ID__c;
            }
        }
    }

    private static void piDoesNotReimburse(List<Study_Site__c> newList){
        for(Study_Site__c site : newList){
            if(site.Sponsor_Pays_for_Referral_Activity__c == 'No') site.PI_Pays_for_Referral_Activity__c = 'No';
        }
    }

    private static void overrideStatusChangedBy(List<Study_Site__c> newList, Map<Id, Study_Site__c> oldMap) {
        Profile profile = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()];
        String profileName = profile.Name;
        for(Study_Site__c site : newList){
            if((oldMap == null && site.Override_Study_Site_Recruitment_Status__c  != null) ||
            (oldMap != null && oldMap.get(site.Id).Override_Study_Site_Recruitment_Status__c != site.Override_Study_Site_Recruitment_Status__c)){
                site.Override_Status_Updated_By__c = profileName;
            }
        }
    }

    private static void updateRecruitmentStatus(List<Study_Site__c> newList){
        Set<Id> siteIds = new Set<Id>();
        for(Study_Site__c site : newList){
            siteIds.add(site.Id);
        }
        newList = [
                SELECT
                        Id,
                        Clinical_Trial_Profile__r.Override_Recruitment_Status__c,
                        Override_PI_Referral_Status__c,
                        Override_Study_Site_Recruitment_Status__c,
                        Recruitment_Status__c
                FROM    Study_Site__c
                WHERE   Id IN :siteIds
        ];
        for(Study_Site__c site : newList){
            //TODO this if
            if(site.Clinical_Trial_Profile__r.Override_Recruitment_Status__c == 'Actively Enrolling' &&
                    site.Override_PI_Referral_Status__c == 'Accepted' &&
                    site.Clinical_Trial_Profile__r.Override_Recruitment_Status__c == null){
                site.Override_Study_Site_Recruitment_Status__c = 'Actively Enrolling';
            } else if(site.Recruitment_Status__c == 'Enrollment Closed'){
                site.Override_Study_Site_Recruitment_Status__c = 'Enrollment Closed';
            } else if(site.Clinical_Trial_Profile__r.Override_Recruitment_Status__c == 'No Longer Enrolling'){
                site.Override_Study_Site_Recruitment_Status__c = 'No Longer Enrolling';
            } else if(site.Recruitment_Status__c == 'Enrollment On Hold'){
                site.Override_Study_Site_Recruitment_Status__c = 'On Hold';
            } else if(site.Recruitment_Status__c == 'Approved for SSV' ||
                    site.Recruitment_Status__c == 'Backup' ||
                    site.Recruitment_Status__c == 'Closed' ||
                    site.Recruitment_Status__c == 'Conditional Selected' ||
                    site.Recruitment_Status__c == 'Contacted (Feasibility)' ||
                    site.Recruitment_Status__c == 'Contacted (Site ID)' ||
                    site.Recruitment_Status__c == 'Dropped' ||
                    site.Recruitment_Status__c == 'Essential Documents in place' ||
                    site.Recruitment_Status__c == 'Interested (Feasibility)' ||
                    site.Recruitment_Status__c == 'Interested (Site ID)' ||
                    site.Recruitment_Status__c == 'Non-responder (Feasibility)' ||
                    site.Recruitment_Status__c == 'Non-responder (Site ID)' ||
                    site.Recruitment_Status__c == 'Not Interest'){
                site.Override_Study_Site_Recruitment_Status__c = 'PI cannot accept referrals based on Site status';
            }
        }
    }

    private static void createHCPEnrollmentsForRPInWhiteList(List<Study_Site__c> newList, Map<Id, Study_Site__c> oldMap){
        Set<Id> PIds = new Set<Id>();
        Map<Id, Study_Site__c> acceptedStudySites = new Map<Id,Study_Site__c>();
        for(Study_Site__c ss : newList){
            if((ss.Override_PI_Referral_Status__c == StudySiteService.PI_S_ACCEPTED ||
                    ss.Override_PI_Referral_Status__c == StudySiteService.PI_S_ACCEPTED_A) &&
                    ss.Override_PI_Referral_Status__c != oldMap.get(ss.id).Override_PI_Referral_Status__c){
                PIds.add(ss.Principal_Investigator__c);
                acceptedStudySites.put(ss.Id,ss);
            }
        }
        List<PI_RP_Relationship__c> prrList = [
                SELECT Id,
                        PI_Contact__c,
                        RP_Contact__c,
                        RP_Contact__r.AccountId
                FROM PI_RP_Relationship__c
                WHERE PI_Contact__c IN :PIds
        ];
        Set<Id> hcpIds = new Set<Id>();
        for(PI_RP_Relationship__c rpp : prrList){
            hcpIds.add(rpp.RP_Contact__c);
        }
        List<HCP_Enrollment__c> enrollmentList = [
                SELECt ID,
                        Name,
                        Study_Site__c,
                        HCP_Contact__c
                FROM HCP_Enrollment__c
                WHERE Study_Site__c IN :acceptedStudySites.keySet() AND HCP_Contact__c IN :hcpIds
        ];
        Set<String> exceptionList = new Set<String>();
        for(HCP_Enrollment__c enroll : enrollmentList){
            exceptionList.add(enroll.HCP_Contact__c + '' + enroll.Study_Site__c);
        }
        List<HCP_enrollment__c> enrollmentsList = new List<HCP_Enrollment__c>();
        for(PI_RP_Relationship__c prr : prrList){
            for(Study_Site__c ss : acceptedStudySites.values()){
                if(!exceptionList.contains(prr.RP_Contact__c +''+ ss.Id)) {
                    enrollmentsList.add(new HCP_Enrollment__c(
                            HCP_Contact__c = prr.RP_Contact__c,
                            HCP_Account__c = prr.RP_Contact__r.AccountId,
                            Status__c = ss.Study_Orientation_Required__c ? HCPEnrollmentService.HCP_S_ACTIVATION_PENDING_O : HCPEnrollmentService.HCP_S_ACTIVATED,
                            Study_Site__c = ss.Id
                    ));
                }
            }
        }
        if(!enrollmentsList.isEmpty()) insert enrollmentsList;
    }

    @TestVisible
    private static void setSuppressField(List<Study_Site__c> newList) {
        Set<Id> studyIds = new Set<Id>();
        for (Study_Site__c site: newList){
            studyIds.add(site.Clinical_Trial_Profile__c);
        }
        Map<Id, Clinical_Trial_Profile__c> ctpsMap = new Map<Id, Clinical_Trial_Profile__c>();
        for (Clinical_Trial_Profile__c ctp : [SELECT Id, Suppress_PI_Emails__c FROM Clinical_Trial_Profile__c WHERE Id IN :studyIds]) {
            ctpsMap.put(ctp.Id, ctp);
        }
        for (Study_Site__c site: newList) {
            if (!site.Suppress_Study_Site_PI_Emails__c) site.Suppress_Study_Site_PI_Emails__c = ctpsMap.get(site.Clinical_Trial_Profile__c).Suppress_PI_Emails__c;
        }
    }
    
    @TestVisible
    private static void assignCommunityPermissions(List<Study_Site__c> newList) {
        Set<Id> piIds = new Set<Id>();
        Set<Id> ctpIds = new Set<Id>();
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        Map<Id, Set<Id>> piIdsByCtpIdsMap = new Map<Id, Set<Id>>();
        for (Integer i = 0, j = newList.size(); i < j; i++) {
            ctpIds.add(newList[i].Clinical_Trial_Profile__c);
            if (piIdsByCtpIdsMap.containsKey(newList[i].Clinical_Trial_Profile__c)) {
                piIdsByCtpIdsMap.get(newList[i].Clinical_Trial_Profile__c).add(newList[i].Principal_Investigator__c);
            } else {
                piIdsByCtpIdsMap.put(newList[i].Clinical_Trial_Profile__c, new Set<Id>{
                        newList[i].Principal_Investigator__c
                });
            }
        }
        if (!ctpIds.isEmpty()) {
            for (Clinical_Trial_Profile__c ctp : [
                    SELECT Id
                    FROM Clinical_Trial_Profile__c
                    WHERE CommunityTemplate__c = : CommunityTemplateService.TEMPLATE_JANSSEN AND Id IN :ctpIds
            ]) {
                piIds.addAll(piIdsByCtpIdsMap.get(ctp.Id));
            }
        }
        if (!piIds.isEmpty()) {
            List<User> users = [
                    SELECT Id, (
                            SELECT Id,
                                    PermissionSet.Name,
                                    PermissionSetId
                            FROM PermissionSetAssignments
                    )
                    FROM User
                    WHERE ContactId IN:piIds AND IsActive = TRUE
            ];
            Set<Id> usersToAddPermissions = new Set<Id>();
            Id permissionSetId = [
                    SELECT Id,
                            Name
                    FROM PermissionSet
                    WHERE Name = : CommunityTemplateService.PERMISSION_COMMUNITY_JANSSEN_NAME
                    LIMIT 1
            ].Id;
            for (User u : users) {
                Boolean permissionAdded = false;
                for (PermissionSetAssignment psa : u.PermissionSetAssignments) {
                    if (psa.PermissionSetId == permissionSetId) permissionAdded = true;
                    break;
                }
                if (permissionAdded == false) usersToAddPermissions.add(u.Id);
            }
            if (!usersToAddPermissions.isEmpty()) {
                for (Id userId : usersToAddPermissions) {
                    psaList.add(new PermissionSetAssignment(
                            AssigneeId = userId,
                            PermissionSetId = permissionSetId
                    ));
                }
            }
        }
        if(!psaList.isEmpty()) insertPsa(JSON.serialize(psaList));
    }

    @Future
    private static void insertPsa(String psaToInsert){
        insert (List<PermissionSetAssignment>) JSON.deserialize(psaToInsert, List<PermissionSetAssignment>.class);
    }
}
