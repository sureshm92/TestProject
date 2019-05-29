/**
 * Created by Leonid Bartenev
 */

public class BaselineSurveyRemote {
    
    @AuraEnabled
    public static String getBaselineSurveyURL(String userMode, Id psId){
        try {
            if(userMode != CommunityService.USER_MODE_PARTICIPANT) {
                throw new SurveyService.SurveyException('Survey not available');
            }
            ParticipantService.ParticipantState participantState = ParticipantService.getParticipantState();

            InitData initData = new InitData();
            initData.ctp = participantState.ctp;
            SurveyService.SurveyWrapper sw =
                    SurveyService.getInstance().getSurveyWrapper(psId);
            initData.surveyLink = sw.url;
            initData.surveyName = sw.name;

            return JSON.serialize(initData);
        }catch (Exception e){
            return (String) AuraHelper.throwException(e);
        }
    }

    public class InitData {
        public Clinical_Trial_Profile__c ctp;
        public String surveyLink;
        public String surveyName;
    }
}