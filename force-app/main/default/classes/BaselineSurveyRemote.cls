/**
 * Created by Leonid Bartenev
 */

public class BaselineSurveyRemote {
    
    @AuraEnabled
    public static String getBaselineSurveyURL(String userMode){
        try {
            if(userMode != CommunityService.USER_MODE_PARTICIPANT) {
                throw new SurveyService.SurveyException('Survey not available');
            }
            ParticipantService.ParticipantState participantState = ParticipantService.getParticipantState();
            List<Task> tasks = TaskService.getInstance().getTasksCommon('Task_Code__c =\'' +
                    TaskService.TASK_CODE_COMPLETE_SURVEY +'\' AND ' + TaskService.getInstance().getOpenTasksFilter());
            if(tasks.size() == 0) throw new SurveyService.SurveyException('Survey already completed');

            InitData initData = new InitData();
            initData.ctp = participantState.ctp;
            SurveyService.SurveyWrapper sw =  SurveyService.getInstance().getSurveyLinkForCTP(initData.ctp);
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