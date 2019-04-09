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
            List<Task> tasks = TaskService.getTasksCommon('Task_Code__c =\'' + TaskService.TASK_CODE_COMPLETE_BASELINE_SURVEY +'\' AND ' + TaskService.getOpenTasksFilter());
            if(tasks.size() == 0) throw new BaselineSurveyException('Baseline survey already completed');
            if(participantState.pse.Clinical_Trial_Profile__r.Baseline_Survey_URL__c == null){
                throw new BaselineSurveyException('Baseline Survey not defined');
            }
            return JSON.serialize(participantState.pse.Clinical_Trial_Profile__r);
        }catch (Exception e){
            return (String) AuraHelper.throwException(e);
        }
    }

}