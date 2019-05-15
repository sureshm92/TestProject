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
            List<Task> tasks = TaskService.getInstance().getTasksCommon('Task_Code__c =\'' +
                    TaskService.TASK_CODE_COMPLETE_SURVEY +'\' AND ' + TaskService.getInstance().getOpenTasksFilter());
            if(tasks.size() == 0) throw new BaselineSurveyException('Baseline survey already completed');

            InitData initData = new InitData();
            initData.ctp = participantState.ctp;
            initData.surveyLink = getSurveyLink(participantState.ctp.Survey__c);
            initData.surveyName = participantState.ctp.Survey__r.Name;

            return JSON.serialize(initData);
        }catch (Exception e){
            return (String) AuraHelper.throwException(e);
        }
    }

    public static String getSurveyLink(Id surveyId) {
        List<SurveyInvitation> surveyInvitations = [
                SELECT Id, InvitationLink
                FROM SurveyInvitation
                WHERE SurveyId = :surveyId
        ];
        if(surveyInvitations.isEmpty()) throw new BaselineSurveyException('SurveyInvitation not available');

        String link;
        for(SurveyInvitation inv : surveyInvitations) {
            if(inv.InvitationLink.contains('.force.com')) {
                link = inv.InvitationLink;
                break;
            }
        }
        if(link == null) throw new BaselineSurveyException('Invitation link not found');

        return link;
    }

    public class InitData {
        public Clinical_Trial_Profile__c ctp;
        public String surveyLink;
        public String surveyName;
    }
}