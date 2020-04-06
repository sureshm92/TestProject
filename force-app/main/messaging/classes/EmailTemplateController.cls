/**
 * Created by Leonid Bartenev
 */
global without sharing class EmailTemplateController {

    global String titleLabel { get; set; }
    global String headerLabel { get; set; }
    global String greetingLabel { get; set; }
    global String bodyLabel { get; set; }
    global String preSignatureLabel { get; set; }
    global String signatureLabel { get; set; }
    global String buttonLabel { get; set; }
    global String buttonUrl { get; set; }

    global Id sourceRecordId { get; set; }
    global String userCommunityType { get; set; }
    global String emailRecipientName { get; set; }
    global String emailRecipientId { get; set; }
    global String emailRecipientLanguage { get; set; }
    global String emailParametersProvider { get; set; }
    global Boolean replaceLineBreaksOnHTMLBreaks { get; set; }
    global Boolean showDelegateTableValue { get; set; }
    global Boolean multiplePIMessageValue { get; set; }
    global Boolean showDelegateSSTableValue { get; set; }
    global String communityTemplateValue { get; set; }
    global String emailTemplateName { get; set; }
    global String outputMode { get; set; }

    private EmailTemplateProviderDefault templateProvider;
    public EmailTemplateProviderDefault getProvider() {
        if (templateProvider == null) {
            Map<String, String> templateLabels = new Map<String, String>{
                    'title' => titleLabel,
                    'header' => headerLabel,
                    'greeting' => greetingLabel,
                    'body' => bodyLabel,
                    'preSignature' => preSignatureLabel,
                    'signature' => signatureLabel,
                    'button' => buttonLabel,
                    'buttonUrl' => buttonUrl
            };
            templateProvider = EmailTemplateProvidersFactory.getFactory().getProvider(
                    emailTemplateName, templateLabels, sourceRecordId, emailRecipientId, emailRecipientName,
                    emailRecipientLanguage, outputMode, communityTemplateValue
            );
        }
        return templateProvider;
    }

    global Map<String, String> getTemplateMap() {
        return getProvider().getParameters();
    }

    global String getParticipantDelegateAfterText() {
        return getProvider().getDelegateAfter();
    }

    global Id getRecipientContactId() {
        return getProvider().getRecipientId();
    }

    global String getRecipientLanguage() {
        return getProvider().getRecipientLanguage();
    }

    global String getUserLanguageCode() {
        return getProvider().getUserLanguage();
    }

    global String getResultUserMode() {
        return getProvider().getUserMode();
    }

    global Boolean getIsDelegate() {
        return getProvider().isDelegate();
    }
}