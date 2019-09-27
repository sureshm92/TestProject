/**
 * Created by Leonid Bartenev
 */

public without sharing class MotivationalMessagesRemote {
    
    public static final String DEFAULT_MOTIVATION_PLAN = 'Default_Motivation_Plan';
    
    @AuraEnabled
    public static String getMotivationalMessage(String userMode){
        try{
            if(userMode != CommunityService.USER_MODE_PARTICIPANT) return null;
            ParticipantService.ParticipantState participantState = ParticipantService.getParticipantState();
            if(participantState.value != ParticipantService.ParticipantStates.PARTICIPANT || !participantState.isPremium) return null;
            Participant_Enrollment_Status_History__c[] enrolledHistoryList = [
                    SELECT Id, Date__c
                    FROM Participant_Enrollment_Status_History__c
                    WHERE ParticipantEnrollment__c =: participantState.pe.Id AND Status__c =: PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS
            ];
            if(enrolledHistoryList.size() == 0) return null;
            List<Motivation_Plan_Message__mdt> messages = [
                    SELECT
                            Id,
                            DeveloperName,
                            Days_From_Start__c,
                            Custom_Label_Name__c
                    FROM Motivation_Plan_Message__mdt
                    WHERE Motivation_Plan__r.DeveloperName =: DEFAULT_MOTIVATION_PLAN
                    ORDER BY Days_From_Start__c
            ];
            Date enrolledDate = enrolledHistoryList[0].Date__c.date();
    
            Motivation_Plan_Message__mdt messageForShow;
            for(Motivation_Plan_Message__mdt message : messages){
                Date messageDate = enrolledDate.addDays(message.Days_From_Start__c.intValue());
                if(messageDate <= Date.today()) messageForShow = message;
            }
            if(messageForShow != null && participantState.pe.Motivational_Message_Id__c != messageForShow.DeveloperName){
                participantState.pe.Motivational_Message_Id__c = messageForShow.DeveloperName;
                update participantState.pe;
                String resultMessage = TranslateHelper.getLabelValue(messageForShow.Custom_Label_Name__c);
                resultMessage = CatalogParametersHelper.prepareMergeFields(resultMessage, participantState.ctp.Id, 'Email_Template_Parameters_From_CTP');
                return resultMessage;
            }
        }catch (Exception e){
            AuraHelper.throwException(e);
        }
        return null;
    }

}