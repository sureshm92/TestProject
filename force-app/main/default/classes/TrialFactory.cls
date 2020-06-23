/**
 * Created by AlexKetch on 5/17/2019.
 */

public with sharing class TrialFactory {
    public static TrialDetail getTrial(String userMode, String trialId) {
        return getTrial(userMode, trialId, null);
    }
    public static TrialDetail getTrial(String userMode, String trialId, String delegateId) {
        if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
            return new ParticipantTrialBuilder().createTrial();
        } else if (userMode == CommunityService.USER_MODE_PI) {
            return new PITrialBuilder(trialId).createTrial();
        } else if (userMode == CommunityService.USER_MODE_HCP || userMode == CommunityService.USER_MODE_CC ) {
            return new HCPTrialBuilder(trialId, delegateId).createTrial();
        }
        return null;
    }

}