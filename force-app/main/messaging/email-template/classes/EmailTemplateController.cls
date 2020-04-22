/**
 * Created by Leonid Bartenev
 */
global without sharing class EmailTemplateController {

    global String titleValue { get; set; }
    global String headerValue { get; set; }
    global String userGreetingValue { get; set; }
    global String bodyValue { get; set; }
    global String preSignatureValue { get; set; }
    global String signatureValue { get; set; }

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
    global String outputMode { get; set; }

    //Only to pass a validation
    global String emailTemplateName { get; set; }
    global Boolean hasPIRPDelegationRecords { get; set; }
    global String dataParametersValue { get; set; }
    global String emailTemplateBackground { get; set; }
    global String emailTemplateTextBackground { get; set; }
    global String emailTemplateHeaderBackground { get; set; }
    global String emailTemplateHeader { get; set; }
    global String emailTemplateTitle { get; set; }
    global String emailTemplateBrandLogo { get; set; }
    global String emailTemplateBottomLogo { get; set; }
    global String emailTemplateBrandLogoCSS { get; set; }
    global String buttonLabelValue { get; set; }
    global String buttonUrlValue { get; set; }

    private EmailTemplateProvider templateProvider;
    public EmailTemplateProvider getProvider() {
        if (templateProvider == null) {
            Map<String, String> templateLabels = new Map<String, String>{
                    'title' => titleValue,
                    'header' => headerValue,
                    'greeting' => userGreetingValue,
                    'body' => bodyValue,
                    'preSignature' => preSignatureValue,
                    'signature' => signatureValue
            };
            templateProvider = new EmailTemplateProvider(EmailTemplateInitialFactory.getTemplateInitial(
                    templateLabels, sourceRecordId, emailRecipientId, emailRecipientName,
                    emailRecipientLanguage, outputMode, communityTemplateValue
            ));
        }
        return templateProvider;
    }

    global Map<String, String> getTemplateMap() {
        return getProvider().getParameters();
    }

    global Boolean getIsInitial() {
        try {
            return Id.valueOf(emailRecipientId).getSobjectType() == User.getSObjectType();
        } catch (Exception e) {
            return false;
        }
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