/**
 * Created by Leonid Bartenev
 */

public without sharing class StudyDetailAboutStudyRemote {
    
    /*@AuraEnabled
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
    public static String selectNoSites(Id trialId){
        Savepoint sp = Database.setSavepoint();
        try{
            return JSON.serialize(setStatusHCP(trialId, 'On Hold (Acceptance)'));
        }catch (Exception e){
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String setTrialDeclinedForHCP(Id trialId){
        Savepoint sp = Database.setSavepoint();
        try{
            return JSON.serialize(setStatusHCP(trialId, 'Declined (Acceptance)'));
        }catch (Exception e){
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static void setTrialDeclinedForPI(Id trialId){
        Savepoint sp = Database.setSavepoint();
        try{
            setStatusPI(trialId, 'Trial Declined', null);
        }catch (Exception e){
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }*/

    @AuraEnabled
    public static void setTrialAcceptedForPI(Id trialId, String piPaysForReferralActivity){
        Savepoint sp = Database.setSavepoint();
        try{
            setStatusPI(trialId, 'Accepted', piPaysForReferralActivity);
        }catch (Exception e){
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    /*private static Map<Id, HCP_Enrollment__c> setStatusHCP(Id trialId, String status){
        List<HCP_Enrollment__c> enrollments = [
                SELECT Id, Study_Site__c
                FROM HCP_Enrollment__c
                WHERE Study_Site__r.Clinical_Trial_Profile__c =: trialId
                AND HCP_Contact__c =: DelegateService.getContactId(trialId, CommunityService.USER_MODE_HCP)
        ];
        Map<Id, HCP_Enrollment__c> enrollmentsMap = new Map<Id, HCP_Enrollment__c>();
        for(HCP_Enrollment__c enrollment : enrollments){
            enrollment.Status__c = status;
            enrollmentsMap.put(enrollment.Study_Site__c, enrollment);
        }
        update enrollments;
        return enrollmentsMap;
    }*/

    private static void setStatusPI(Id trialId, String status, String piPaysForReferralActivity){
        List<Study_Site__c> studySites = StudySiteService.getStudySiteForPIByTrialId(trialId);
        if(studySites.size() == null) throw new AuraHandledException('Data not found');
        studySites[0].Override_PI_Referral_Status__c = status;
        if(piPaysForReferralActivity != null) studySites[0].PI_Pays_for_Referral_Activity__c = piPaysForReferralActivity;
        update studySites[0];
    }

}