/**
 * Created by Leonid Bartenev
 */

public class BaselineSurveyRemote {
    
    public class BaselineSurveyException extends Exception{}
    
    @AuraEnabled
    public static String getBaselineSurveyURL(String userMode){
        try {
            if(userMode != CommunityService.USER_MODE_PARTICIPANT) {
                throw new BaselineSurveyException('Baseline Survey not available');
            }
            ParticipantService.ParticipantState participantState = ParticipantService.getParticipantState();
            if(participantState.value != ParticipantService.ParticipantStates.PARTICIPANT) {
                throw new BaselineSurveyException('Baseline Survey not available');
            }
            return JSON.serialize(participantState.pse.Clinical_Trial_Profile__r);
        }catch (Exception e){
            AuraHelper.throwException(e);
        }
        return null;
    }

}