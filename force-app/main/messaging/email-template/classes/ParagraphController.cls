/**
 * Created by Igor Malyuta on 28.04.2020.
 */
global without sharing class ParagraphController {
    global String labelName { get; set; }
    global String outputMode { get; set; }
    global Boolean isFilterRequired { get; set; }

    public String getLabelValue() {
        EmailTemplateProvider provider = EmailTemplateProviderService.getProvider();
        if (isFilterRequired == true) {
            provider.addStudySiteNumber();
        }
        String bodyLabelValue = TranslateHelper.getLabelValue(
            labelName,
            provider.getUserLanguage()
        );
        bodyLabelValue = TranslateHelper.replaceParams(
            bodyLabelValue,
            EmailTemplateProvider.PARAM_PREFIX,
            provider.getParameters()
        );
        if (bodyLabelValue.contains('##ParticipantFirstName')) {
            Participant__c participant = PatientDelegateService.getParticipantByDelegateContactId(
                provider.getRecipientId()
            );
            if (participant != null) {
                String pfName = String.isNotBlank(participant.First_Name__c)
                    ? Matcher.quoteReplacement(participant.First_Name__c)
                    : participant.First_Name__c;
                bodyLabelValue = bodyLabelValue.replace('##ParticipantFirstName', pfName);
            }
        }
        bodyLabelValue = outputMode.equals('HTML')
            ? bodyLabelValue.replaceAll('\n', '<br/>')
            : bodyLabelValue;
        return bodyLabelValue;
    }
}
