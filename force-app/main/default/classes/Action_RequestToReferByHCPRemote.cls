/**
 * Created by Kryvolap on 26.03.2019.
 */

public without sharing class Action_RequestToReferByHCPRemote {

    @AuraEnabled
    public static void requestToReferForHCP(String studySiteId, String hcpeId) {
        Savepoint sp = Database.setSavepoint();
        try {
            HCP_Enrollment__c hcpEnrollment;
            Study_Site__c studySite = StudySiteService.getStudySiteForHCPById(studySiteId);
            if(hcpeId==null || hcpeId == ''){
                hcpEnrollment = new HCP_Enrollment__c();
                new StudyActionsHCP(studySite.Clinical_Trial_Profile__r, studySite, null).checkAction(StudyActions.ACT_REQUEST_TO_REFER);
                hcpEnrollment.HCP_Contact__c = CommunityService.getUserContact().Id;
                hcpEnrollment.Study_Site__c = studySiteId;
            }
            else{
                hcpEnrollment = [SELECT Id, Status__c FROM HCP_Enrollment__c WHERE Id = :hcpeId LIMIT 1];
            }

            hcpEnrollment.Status__c = HCPEnrollmentService.HCP_S_ACTIVATION_PENDING;
            if (studySite.Clinical_Trial_Profile__r.Orientation_Required__c) hcpEnrollment.Status__c = HCPEnrollmentService.HCP_S_APPROVAL_PENDING;
            upsert hcpEnrollment;
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

}