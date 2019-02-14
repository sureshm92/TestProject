/**
 * Created by D.Yasinskyi on 29.03.2018
 */
public without sharing class NoTanksModalController {

    @AuraEnabled
    public static void deactivateTrial(Id trialId, String userMode) {
        try{
            if (userMode == CommunityService.USER_MODE_HCP) {
                deactivateHCPEnrollment(trialId, userMode);
            } else if (userMode == CommunityService.USER_MODE_PI) {
                deactivateStudySite(trialId, userMode);
            }
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    private static void deactivateHCPEnrollment(Id trialId, String userMode) {
        HCP_Enrollment__c hcpEnrollment = HCPEnrollmentService.getHCPEnrollmentForHCPByTrial(trialId);
        HCPEnrollmentService.changeStatus(hcpEnrollment.Id, userMode, StudyActions.ACT_HCP_DECLINE);
    }

    private static void deactivateStudySite(Id trialId, String userMode) {
        List<Study_Site__c> studySites = StudySiteService.getStudySiteForPIByTrialId(trialId);
        if(studySites.isEmpty()) throw new AuraHandledException('incorrect Data');
        StudySiteService.changeStatus(studySites[0].Id, userMode, 'decline');
    }
}