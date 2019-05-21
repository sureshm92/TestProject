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
            Id surveyId = participantState.ctp.Survey__c;
            if(participantState.value != ParticipantService.ParticipantStates.PARTICIPANT || surveyId == null) {
                throw new SurveyService.SurveyException('Survey not available');
            }
            List<Task> tasks = TaskService.getInstance().getTasksCommon('Task_Code__c =\'' +
                    TaskService.TASK_CODE_COMPLETE_SURVEY +'\' AND ' + TaskService.getInstance().getOpenTasksFilter());
            if(tasks.size() == 0) throw new SurveyService.SurveyException('Survey already completed');

            InitData initData = new InitData();
            initData.ctp = participantState.ctp;
            initData.surveyLink = SurveyService.getInstance().getSurveyLink(surveyId);
            initData.surveyName = participantState.ctp.Survey__r.Name;

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