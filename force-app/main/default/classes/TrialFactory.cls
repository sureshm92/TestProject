/**
 * Created by AlexKetch on 5/17/2019.
 */

public with sharing class TrialFactory {
    public static TrialDetail getTrial(String userMode, String trialId) {
        return getTrial(userMode, trialId, null, false);
    }

    public static TrialDetail getTrial(String userMode, String trialId, Boolean isNewPP) {
        return getTrial(userMode, trialId, null, isNewPP);
    }
    public static TrialDetail getTrial(String userMode, String trialId, String delegateId) {
        return getTrial(userMode, trialId, delegateId, false);
    }
    public static TrialDetail getTrial(String userMode, String trialId, String delegateId, Boolean isNewPP) {
        if (userMode == CommunityService.USER_MODE_PARTICIPANT) {
            if(isNewPP == true){
                return new ParticipantTrialBuilder(isNewPP).createTrial();
            }else{
                return new ParticipantTrialBuilder().createTrial();
            }
        } else if (userMode == CommunityService.USER_MODE_PI) {
            return new PITrialBuilder(trialId).createTrial();
        } else if (
            userMode == CommunityService.USER_MODE_HCP ||
            userMode == CommunityService.USER_MODE_CC
        ) {
            return new HCPTrialBuilder(trialId, delegateId).createTrial();
        }
        return null;
    }
}
