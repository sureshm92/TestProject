/**
 * Created by Kryvolap on 26.03.2019.
 */

public without sharing class Action_RequestToReferByHCPRemote {

    @AuraEnabled
    public static void requestToReferForHCP(String studySiteId) {
        Savepoint sp = Database.setSavepoint();
        try {
            Study_Site__c studySite = StudySiteService.getStudySiteForHCPById(studySiteId);
            HCP_Enrollment__c hcpEnrollment = new HCP_Enrollment__c();
            new StudyActionsHCP(studySite.Clinical_Trial_Profile__r, studySite, null).checkAction(StudyActions.ACT_REQUEST_TO_REFER);
            hcpEnrollment.HCP_Contact__c = CommunityService.getUserContact().Id;
            hcpEnrollment.Study_Site__c = studySiteId;
            hcpEnrollment.Status__c = HCPEnrollmentService.HCP_S_ACTIVATION_PENDING;
            if (studySite.Clinical_Trial_Profile__r.Orientation_Required__c) hcpEnrollment.Status__c = HCPEnrollmentService.HCP_S_APPROVAL_PENDING;
            insert hcpEnrollment;
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

}