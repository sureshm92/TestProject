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
            List<Motivational_Message__c> messages = [
                    SELECT
                            Id,
                            Number_of_Days_Active_after_Enrollment__c,
                            Clinical_Trial_Profile__c,
                            Message__c
                    FROM Motivational_Message__c
                    WHERE Clinical_Trial_Profile__c = :participantState.pe.Clinical_Trial_Profile__c
            ];
            Date enrolledDate = enrolledHistoryList[0].Date__c.date();
    
            Motivational_Message__c messageForShow;
            for(Motivational_Message__c message : messages){
                Date messageDate = enrolledDate.addDays(message.Number_of_Days_Active_after_Enrollment__c.intValue());
                if(messageDate <= Date.today()) messageForShow = message;
            }
            if(messageForShow != null && participantState.pe.Motivational_Message_Id__c != messageForShow.Id){
                participantState.pe.Motivational_Message_Id__c = messageForShow.Id;
                update participantState.pe;
                String resultMessage = messageForShow.Message__c;
                //resultMessage = CatalogParametersHelper.prepareMergeFields(resultMessage, participantState.ctp.Id, 'Email_Template_Parameters_From_CTP');
                return resultMessage;
            }
        }catch (Exception e){
            AuraHelper.throwException(e);
        }
        return null;
    }

}