/**
 * Created by Leonid Bartenev
 */

public class BaselineSurveyRemote {
    
    @AuraEnabled
    public static String getBaselineSurveyURL(String userMode, Id invitationId){
        try {
            if(userMode != CommunityService.USER_MODE_PARTICIPANT) {
                throw new SurveyService.SurveyException('Survey not available');
            }

            return JSON.serialize(SurveyService.getInstance().getSurveyWrapper(invitationId));
        }catch (Exception e){
            return (String) AuraHelper.throwException(e);
        }
    }
}