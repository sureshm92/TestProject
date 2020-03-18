/**
 * Created by D.Yasinskyi on 29.03.2018
 */
public without sharing class NoTanksModalController {

    @AuraEnabled
    public static void deactivateTrial(Id trialId, String userMode, String ssId) {
        try{
            if(String.isEmpty(ssId)) {
                if (userMode == CommunityService.USER_MODE_HCP) {
                    deactivateHCPEnrollment(trialId, userMode);
                } else if (userMode == CommunityService.USER_MODE_PI) {
                    deactivateStudySite(trialId, userMode);
                }
            }
            else{
                deactivateStudySiteById(ssId, userMode);
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
        Set<Id> ssIdSet = new Set<Id>();
        if(studySites.isEmpty()) throw new AuraHandledException('incorrect Data');
        for (Integer i = 0; i <studySites.size(); i++) {
            if(studySites[i].Override_PI_Referral_Status__c == StudySiteService.PI_S_INVITATION_SENT) {
                ssIdSet.add(studySites[i].Id);
            }
        }
        StudySiteService.changeStatus(ssIdSet, userMode, 'decline');
    }

    private static void deactivateStudySiteById(Id ssId, String userMode) {
        Study_Site__c studySites = StudySiteService.getStudySiteForHCPById(ssId);
        if(studySites==null) throw new AuraHandledException('incorrect Data');
        StudySiteService.changeStatus(studySites.Id, userMode, 'decline');
    }
}