/**
 * Created by Leonid Bartenev
 */

public without sharing class BaselineSurveyRemote {
    
    @AuraEnabled
    public static String getBaselineSurveyURL(String userMode, Id invitationId){
        try {
            if (userMode != CommunityService.USER_MODE_PARTICIPANT || SurveyService.getInstance().isInvitationExpired(invitationId)) {
                List<Task> tasks = [
                        SELECT Id, Status
                        FROM Task
                        WHERE Survey_Invitation__c = :invitationId
                        AND OwnerId = :UserInfo.getUserId()
                ];
                for(Task t : tasks) t.Status = TaskService.TASK_STATUS_EXPIRED;
                update tasks;

                return 'expired';
            }

            return JSON.serialize(SurveyService.getInstance().getSurveyWrapper(invitationId));
        }catch (Exception e){
            return (String) AuraHelper.throwException(e);
        }
    }
}