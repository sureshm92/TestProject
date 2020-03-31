/**
 * Created by Igor Malyuta on 24.03.2020.
 */

public without sharing class EmailTemplateProviderPT extends EmailTemplateProviderAbstract {

    public EmailTemplateProviderPT(Id sourceId, Id recipientId, String recipientName, String recipientLanguage,
            String parametersProviderName, String outputMode, String communityTemplateName
    ) {
        super(sourceId, recipientId, recipientName, recipientLanguage, parametersProviderName, outputMode);

        Participant_Enrollment__c pe = [
                SELECT
                        HCP__r.HCP_Contact__r.Name,
                        HCP__r.HCP_Contact__r.Salutation,
                        Participant__r.Contact__r.Language__c,
                        Participant__r.Language_Preference_Code__c,
                        Participant__r.First_Name__c,
                        Participant__r.Last_Name__c,
                        Study_Site__r.Principal_Investigator__r.Name,
                        Study_Site__r.Principal_Investigator__r.Salutation
                FROM Participant_Enrollment__c
                WHERE (Id = :sourceId OR Participant__r.Contact__c = :recipientContactId)
                AND Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c = :communityTemplateName
                LIMIT 1
        ];
        parameters.put('HCPName', getFullContactName(pe.HCP__r.HCP_Contact__r));
        parameters.put('PIName', getFullContactName(pe.Study_Site__r.Principal_Investigator__r));
        parameters.put('ParticipantName', getFullParticipantName(pe.Participant__r));
        parameters.put('ParticipantLanguage', getParticipantLanguage(pe.Participant__r));

        if (isDelegate) initYourParticipantFirstName();
    }

    public override void setTitleValue(String titleLabel) {
        super.setTitleValue(titleLabel);
        String titleValue = parameters.get('titleValue');
        String title = templatePropertiesService.getPropertyValue(TemplatePropertiesCatalog.TEMPLATE_PROP_TITLE_LABEL);
        if (title != null && userMode == CommunityModeService.USER_MODE_PARTICIPANT) {
            titleValue = title;
        }

        parameters.put('titleValue', titleValue);
    }

    public override String getUserName() {
        String userNameParam = isDelegate ? 'FullName' : userMode + 'ParticipantContactFirstName';
        return parameters.get(userNameParam);
    }

    public String getReferralSource() {
        return parameters.get('ReferralSource');
    }

    private String getFullParticipantName(Participant__c participant) {
        List<String> nameParts = new List<String>();
        if (participant.First_Name__c != null) nameParts.add(participant.First_Name__c);
        if (participant.Last_Name__c != null) nameParts.add(participant.Last_Name__c);
        return String.join(nameParts, ' ');
    }

    private String getParticipantLanguage(Participant__c participant) {
        String participantLanguage = participant.Language_Preference_Code__c;
        if (participant.Contact__c != null) participantLanguage = participant.Contact__r.Language__c;
        return participantLanguage;
    }

    public String getDelegateAfter() {
        return TranslateHelper.replaceParams(
                TranslateHelper.getLabelValue(Label.Email_Body_Initial_Patient_Delegate_AfterText, recipientLanguage),
                PARAM_PREFIX, parameters
        );
    }

    protected override void updateRecipientName(Id recipientId, String recipientName, String recipientLanguage) {
        super.updateRecipientName(recipientId, recipientName, recipientLanguage);

        if (recipientContactId != null) {
            List<Participant__c> participants = [
                    SELECT First_Name__c, Last_Name__c FROM Participant__c WHERE Contact__c = :recipientContactId
            ];
            if (!participants.isEmpty()) {
                recipientName = getFullParticipantName(participants.get(0));
                recipientFirstName = participants.get(0).First_Name__c;
            }
        }
    }

    private void initYourParticipantFirstName() {
        Participant__c participant = PatientDelegateService.getParticipantByDelegateContactId(recipientContactId);
        if(participant != null) parameters.put('ParticipantFirstName', participant.First_Name__c);
    }
}