/**
 * Created by Leonid Bartenev
 */

public without sharing class Action_SendSiteRequestByHCPRemote {
    
    @AuraEnabled
    public static void changeStudyForHCP(String studySiteId, String hcpeId){
        Savepoint sp = Database.setSavepoint();
        try{
            Study_Site__c studySite = StudySiteService.getStudySiteForHCPById(studySiteId);
            HCP_Enrollment__c hcpEnrollment = HCPEnrollmentService.getHCPEnrollmentForHCPById(hcpeId);
            new StudyActionsHCP(hcpEnrollment).checkAction(StudyActions.ACT_SEND_SITE_REQUEST);
            hcpEnrollment.Study_Site__c = studySiteId;
            hcpEnrollment.Status__c = HCPEnrollmentService.HCP_S_ACTIVATION_PENDING;
            if(studySite.Clinical_Trial_Profile__r.Orientation_Required__c) hcpEnrollment.Status__c = HCPEnrollmentService.HCP_S_APPROVAL_PENDING;
            upsert hcpEnrollment;
        }catch (Exception e){
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static void selectNoSites(String hcpeId){
        Savepoint sp = Database.setSavepoint();
        try{
            HCP_Enrollment__c hcpEnrollment = HCPEnrollmentService.getHCPEnrollmentForHCPById(hcpeId);
            new StudyActionsHCP(hcpEnrollment).checkAction(StudyActions.ACT_SEND_SITE_REQUEST);
            hcpEnrollment.Status__c = HCPEnrollmentService.HCP_S_ON_HOLD_ACCEPTANCE;
            update hcpEnrollment;
        }catch (Exception e){
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

}