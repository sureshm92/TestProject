/**
 * Created by AlexKetch on 5/17/2019.
 */

public with sharing class TrialFactory {
    public static TrialDetail getTrial(String userMode, String trialId) {
        return getTrial(userMode, trialId, null);
    }
    public static TrialDetail getTrial(String userMode, String trialId, String delegateId) {
        if (trialId == null && userMode == CommunityService.USER_MODE_PARTICIPANT) {
            List<Participant_Enrollment__c> peList = ParticipantEnrollmentService.getParticipantEnrollmentsForParticipant();
            if (peList.size() > 0) {
                trialId = peList[0].Study_Site__r.Clinical_Trial_Profile__c;
            }
        }
        if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
            return new ParticipantTrialBuilder(trialId).createTrial();
        } else if (userMode == CommunityService.USER_MODE_PI) {
            return new PITrialBuilder(trialId).createTrial();
        } else if (userMode == CommunityService.USER_MODE_HCP) {
            return new HCPTrialBuilder(trialId, delegateId).createTrial();
        }
        return null;
    }

}