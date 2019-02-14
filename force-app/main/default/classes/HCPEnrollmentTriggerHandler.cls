/**
 * Created by D.Yasinskyi on 23.02.2018
 */
public without sharing class HCPEnrollmentTriggerHandler {
    
    public static void prepareAdditionalFieldsBeforeInsertUpdate(){
        if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)){
            List<HCP_Enrollment__c> hcpeList = (List<HCP_Enrollment__c>)Trigger.new;
            Set<Id> ssIds = new Set<Id>();
            for(HCP_Enrollment__c hcpe : hcpeList) if(hcpe.Study_Site__c != null) ssIds.add(hcpe.Study_Site__c);
            Map<Id, Study_Site__c> studySiteMap = new Map<Id, Study_Site__c>([
                    SELECT Id, Principal_Investigator__c,
                            Clinical_Trial_Profile__c
                    FROM Study_Site__c WHERE Id IN: ssIds
            ]);
            for(HCP_Enrollment__c hcpe : hcpeList){
                if(hcpe.Study_Site__c != null){
                    Study_Site__c ss = studySiteMap.get(hcpe.Study_Site__c);
                    if(ss != null) {
                        hcpe.Study_Site_PI_Contact__c = ss.Principal_Investigator__c;
                        hcpe.Clinical_Trial_Profile__c = ss.Clinical_Trial_Profile__c;
                    }
                }
            }
        }
    }

    public static void onBeforeDelete(Map<Id, HCP_Enrollment__c> oldEnrollments) {
        //delete status history
        deleteStatusHistory(oldEnrollments);
    }
    public static void onAfterInsert(List<HCP_Enrollment__c> enrollments) {
        //send notification to HCP users [new HCP enrollment] or create new User(if not exist)
        sendNotification(enrollments);
        //prepopulate contacts for HCP procces
        prepopulateUserMode(enrollments);
        
        //switch user mode
        List<Contact> contacts = new List<Contact>();
        for(HCP_Enrollment__c hcpe : [SELECT Id, HCP_Contact__c FROM HCP_Enrollment__c WHERE Id IN: enrollments]){
            contacts.add(new Contact(
                    Id = hcpe.HCP_Contact__c,
                    userCommunityMode__c = CommunityService.USER_MODE_HCP
            ));
        }
        update contacts;
    }
    
    public static void onAfterUpdate(Map<Id, HCP_Enrollment__c> newEnrollments, Map<Id, HCP_Enrollment__c> oldEnrollments) {
        //send notification to HCP users [new HCP enrollment]
        sendNotificationOnUpdate(newEnrollments, oldEnrollments);
        //prepopulate contacts for HCP procces
        prepopulateUserModeOnUpdate(newEnrollments, oldEnrollments);
        //treck status history
        createStatusHistory(newEnrollments, oldEnrollments);
    }

    private static void sendNotification(List<HCP_Enrollment__c> enrollments) {
        //prepare community users map:
        Set<Id> contactIds = new Set<Id>();
        List<HCP_Enrollment__c> processedHCPEList = new List<HCP_Enrollment__c>();
        for (HCP_Enrollment__c enrol : enrollments) {
            if (enrol.HCP_Contact__c != null && enrol.Status__c == HCPEnrollmentService.HCP_S_INVITATION_SENT) {
                contactIds.add(enrol.HCP_Contact__c);
                processedHCPEList.add(enrol);
            }
        }
        if (contactIds.isEmpty()) return;
        Map<Id, User> communityUsersMap = new Map<Id, User>();
        for (User usr : CommunityService.getCommunityUsersByContactIds(contactIds)) communityUsersMap.put(usr.ContactId, usr);
        
        //prepare lists:
        Set<Id> contactIdsForCreateUser = new Set<Id>();
        Map<Id, String> hcpeMapForSend = new Map<Id, String>();
        for (HCP_Enrollment__c hcpe : processedHCPEList) {
            if (communityUsersMap.containsKey(hcpe.HCP_Contact__c)) {
                hcpeMapForSend.put(hcpe.Id, hcpe.HCP_Contact__c);
            } else {
                contactIdsForCreateUser.add(hcpe.HCP_Contact__c);
            }
        }

        //process lists:
        if (!contactIdsForCreateUser.isEmpty()) CommunityService.createPortalUsers(contactIdsForCreateUser);
        if (!hcpeMapForSend.isEmpty()) SendEmailTemplate.sendEmailNotification(CommunityService.COMMUNITY_ET_HCP, hcpeMapForSend);
    }

    private static void sendNotificationOnUpdate(Map<Id, HCP_Enrollment__c> newEnrollments, Map<Id, HCP_Enrollment__c> oldEnrollments) {

        List<HCP_Enrollment__c> enrolmentsToSendNotification = new List<HCP_Enrollment__c>();

        for (HCP_Enrollment__c enrollment: newEnrollments.values()) {

            if (oldEnrollments.get(enrollment.Id).HCP_Contact__c != enrollment.HCP_Contact__c
                    || (enrollment.Status__c == HCPEnrollmentService.HCP_S_INVITATION_SENT
                    && oldEnrollments.get(enrollment.Id).Status__c != enrollment.Status__c)
                    ) {
                enrolmentsToSendNotification.add(enrollment);
            }
        }
        sendNotification(enrolmentsToSendNotification);
    }

    private static void prepopulateUserMode(List<HCP_Enrollment__c> enrollments) {

        Set<Id> hcpEContactIds = new Set<Id>();

        for (HCP_Enrollment__c enrol : enrollments) {
            if (enrol.HCP_Contact__c != null) {
                hcpEContactIds.add(enrol.HCP_Contact__c);
            }
        }

        if (hcpEContactIds.isEmpty()) return;

        Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();

        for (Contact hcpContact : CommunityService.getContactsByUserContactIds(hcpEContactIds)) {

            String userType = hcpContact.userCommunytyType__c;
            String userMode = hcpContact.userCommunityMode__c;

            if (userMode == null || userType == null || !userType.contains(CommunityService.USER_MODE_HCP)) {

                if (userMode == null) {
                    hcpContact.userCommunityMode__c = CommunityService.USER_MODE_HCP;
                }
                if (userType == null || !userType.contains(CommunityService.USER_MODE_HCP)) {

                    if (userType == null) {
                        hcpContact.userCommunytyType__c = CommunityService.USER_MODE_HCP;
                    } else {
                        hcpContact.userCommunytyType__c = userType + ';' + CommunityService.USER_MODE_HCP;
                    }
                }
                if (!contactsToUpdate.containsKey(hcpContact.Id)) {
                    contactsToUpdate.put(hcpContact.Id, hcpContact);
                }
            }
        }
        update contactsToUpdate.values();
    }

    private static void prepopulateUserModeOnUpdate(Map<Id, HCP_Enrollment__c> newEnrollments, Map<Id, HCP_Enrollment__c> oldEnrollments) {

        List<HCP_Enrollment__c> enrollmentsToPopulate = new List<HCP_Enrollment__c>();
        for (HCP_Enrollment__c enrollment: newEnrollments.values()) {
            if (oldEnrollments.get(enrollment.Id).HCP_Contact__c != enrollment.HCP_Contact__c) {
                enrollmentsToPopulate.add(enrollment);
            }
        }
        prepopulateUserMode(enrollmentsToPopulate);
    }

    private static void createStatusHistory(Map<Id, HCP_Enrollment__c> newEnrollments, Map<Id, HCP_Enrollment__c> oldEnrollments) {

        List<Status_History__c> hcpEHistoryList = new List<Status_History__c>();

        for (HCP_Enrollment__c enrollment: newEnrollments.values()) {

            if (oldEnrollments.get(enrollment.Id).Status__c != enrollment.Status__c) {

                hcpEHistoryList.add(new Status_History__c(
                        Date__c = Datetime.now(),
                        HCP_Enrollment__c = enrollment.Id,
                        NewStatus__c = enrollment.Status__c
                ));
            }
        }

        insert hcpEHistoryList;
    }

    private static void deleteStatusHistory(Map<Id, HCP_Enrollment__c> oldEnrollments) {
        delete [SELECT Id FROM Status_History__c WHERE HCP_Enrollment__c IN :oldEnrollments.keySet()];
    }
}