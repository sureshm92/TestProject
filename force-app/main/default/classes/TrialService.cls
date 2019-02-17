/**
 * Created by Leonid Bartenev
 */

public without sharing class TrialService {
    
    public static final String STATUS_ACTIVELY_ENROLLING = 'Actively Enrolling';
    public static final String STATUS_NO_LONGER_ENROLLING = 'No Longer Enrolling';

    public static List<Clinical_Trial_Profile__c> getAvailableTrials(String mode){
        Set<Clinical_Trial_Profile__c> trials= new Set<Clinical_Trial_Profile__c>();
        if(mode == CommunityService.USER_MODE_PI){
            List<Study_Site__c> studySites = StudySiteService.getStudySitesCommon(CommunityService.USER_MODE_PI, null, false);
            for(Study_Site__c ss : studySites) trials.add(ss.Clinical_Trial_Profile__r);
        }else if(mode == CommunityService.USER_MODE_HCP){
            List<HCP_Enrollment__c> hcpEnrollments = HCPEnrollmentService.getHCPEnrollmentsCommon(mode, null, false);
            for(HCP_Enrollment__c hcpEnrollment : hcpEnrollments) {
                if(hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__r != null) trials.add(hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__r);
            }
        }
        return new List<Clinical_Trial_Profile__c>(trials);
    }
    
    public static List<Clinical_Trial_Profile__c> getOwnTrials(String userMode){
        List<Clinical_Trial_Profile__c> ownTrials = new List<Clinical_Trial_Profile__c>();
        for(Clinical_Trial_Profile__c trial : getAvailableTrials(userMode)){
            if(DelegateService.getStudyAccessLevel(trial.Id, userMode) == DelegateService.OWNER_LEVEL){
                ownTrials.add(trial);
            }
        }
        return ownTrials;
    }

    public static List<Id> getAvailableTrialIds(String mode){
        List<Clinical_Trial_Profile__c> trials = getAvailableTrials(mode);
        List<Id> trialIds = new List<Id>();
        for(Clinical_Trial_Profile__c trial : trials) trialIds.add(trial.Id);
        return trialIds;
    }

    public static Clinical_Trial_Profile__c getTrial(Id trialId){
        List<Clinical_Trial_Profile__c> trials = [
                SELECT Id, Orientation_Required__c,
                        Name,
                        Terms_And_Conditions_ID__c,
                        Study_Sponsor__c,
                        Study_Type__c,
                        Detailed_Description__c,
                        toLabel(Override_Recruitment_Status__c),
                        Brief_Summary__c,
                        Override_Description__c,
                        Override_Inclusion_Criteria__c,
                        Override_Exclusion_Criteria__c,
                        Condition_s_Therapeutic_Area__c,
                        Sponsor_Pays_for_Referral_Activity__c,
                        Study_Phase__c, NCT_Number__c,
                        Protocol_ID__c,
                        Enrollment_Start_Date__c,
                        Enrolled_End_Date__c,
                        Link_to_Medical_Record_Review__c,
                        Link_to_Pre_screening__c,
                        Study_Title__c,
                        Study_Code_Name__c,
                        Official_Title__c,
                        Interventions__c
                FROM Clinical_Trial_Profile__c
                WHERE Id =: trialId
        ];
        if(trials.size() == 0) throw new CommunityServiceException('Data not found');
        TranslateHelper.translate(trials[0]);
        return trials[0];
    }

    public static Boolean isTrialAvailable(Id trialId, String userMode){
        return getAvailableTrialIds(userMode).contains(trialId);
    }

}