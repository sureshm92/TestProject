/**
 * Created by Leonid Bartenev
 */

public without sharing class MotivationalMessagesRemote {
    @AuraEnabled
    public static String getMotivationalMessage(String userMode) {
        try {
            if (userMode != CommunityService.USER_MODE_PARTICIPANT)
                return null;
            ParticipantService.ParticipantState participantState = ParticipantService.getParticipantState();
            CommunityMode communityMode = UserContext.getCurrentUserMode();
            if (
                !communityMode.isDelegate &&
                participantState.value != ParticipantService.ParticipantStates.PARTICIPANT ||
                !participantState.isPremium
            )
                return null;

            Participant_Enrollment_Status_History__c[] enrolledHistoryList = [
                SELECT Id, Date__c
                FROM Participant_Enrollment_Status_History__c
                WHERE
                    ParticipantEnrollment__c = :participantState.pe.Id
                    AND Status__c IN :PEStatusState.PE_STATUS_GROUP_PARTICIPATION_IN_ENROLLMENT_SUCCESS
            ];
            if (enrolledHistoryList.size() == 0)
                return null;
            List<Motivational_Message__c> messages = [
                SELECT
                    Id,
                    Name,
                    Number_of_Days_Active_after_Enrollment__c,
                    Clinical_Trial_Profile__c,
                    Message__c
                FROM Motivational_Message__c
                WHERE Clinical_Trial_Profile__c = :participantState.pe.Clinical_Trial_Profile__c
                ORDER BY Number_of_Days_Active_after_Enrollment__c, Name ASC
            ];
            if (messages.isEmpty())
                return null;
            Date enrolledDate = enrolledHistoryList[0].Date__c.date();

            Motivational_Message__c messageForShow;
            for (Motivational_Message__c msg : messages) {
                Date messageDate = enrolledDate.addDays(
                    msg.Number_of_Days_Active_after_Enrollment__c.intValue()
                );
                if (messageDate <= Date.today())
                    messageForShow = msg;
            }
            if (messageForShow == null)
                return null;

            TranslateHelper.translate(messageForShow);

            String resultMessage = getMessage(messageForShow, participantState);

            resultMessage = CatalogParametersHelper.prepareMergeFields(
                resultMessage,
                participantState.ctp.Id,
                'Email_Template_Parameters_From_CTP'
            );
            return resultMessage;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    private static String getMessage(
        Motivational_Message__c messageForShow,
        ParticipantService.ParticipantState participantState
    ) {
        if (messageForShow == null)
            return null;
        if (participantState.pe.Motivational_Message_Id__c == messageForShow.Id)
            return null;

        participantState.pe.Motivational_Message_Id__c = messageForShow.Id;
        update participantState.pe;

        return messageForShow.Message__c;
    }
}
