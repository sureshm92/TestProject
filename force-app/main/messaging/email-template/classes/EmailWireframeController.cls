/**
 * Created by Igor Malyuta on 24.04.2020.
 */
global without sharing class EmailWireframeController {

    global String titleValue { get; set; }
    global String headerValue { get; set; }
    global String greetingValue { get; set; }
    global String preSignatureValue { get; set; }
    global String signatureValue { get; set; }

    global Id sourceRecordId { get; set; }
    global String emailRecipientName { get; set; }
    global String emailRecipientId { get; set; }
    global String emailRecipientLanguage { get; set; }
    global String communityTemplateValue { get; set; }
    global String specificEmailProviderValue { get; set; }
    global String outputMode { get; set; }

    private EmailTemplateProvider templateProvider;

    global String getUserLanguageCode() {
        return getProvider().getUserLanguage();
    }

    public Map<String, String> getTemplateMap() {
        return getProvider().getParameters();
    }

    //Labels: ----------------------------------------------------------------------------------------------------------
    public String getHeaderText() {
        String headerLabelValue = getLabelValue(headerValue);
        if (headerLabelValue.contains(EmailTemplateProvider.PARAM_PREFIX)) {
            headerLabelValue = prepareLineBreaks(replaceParams(headerLabelValue));
        }
        return headerLabelValue;
    }

    public String getTitleText() {
        String titleLabelValue;
        if (String.isNotEmpty(titleValue)) {
            if (titleValue.startsWith('##')) {
                titleLabelValue = getProvider().getParameters().get(titleValue.substring(2));
            } else {
                titleLabelValue = getLabelValue(titleValue);
            }
        } else {
            titleLabelValue = getProvider().getUserMode() == CommunityService.USER_MODE_PARTICIPANT ?
                    getProvider().getParameters().get(TemplatePropertiesCatalog.TEMPLATE_PROP_TITLE_LABEL)
                    : getProvider().getParameters().get(TemplatePropertiesCatalog.TEMPLATE_PROP_TITLE_NEW_TM);
        }

        return titleLabelValue;
    }

    public String getGreetingText() {
        return prepareLineBreaks(replaceParams(getLabelValue(greetingValue)) + '\n');
    }

    public String getPreSignatureText() {
        return prepareLineBreaks(getLabelValue(preSignatureValue));
    }

    public String getSignatureText() {
        String signatureLabelValue = replaceParams(getLabelValue(signatureValue));
        return prepareLineBreaks(signatureLabelValue);
    }

    public Boolean getIsInitialized() {
        return getProvider().isInitialized();
    }

    private EmailTemplateProvider getProvider() {
        if (templateProvider == null) {
            EmailTemplateProviderService.setProviderType(
                    specificEmailProviderValue, emailRecipientId, emailRecipientName, emailRecipientLanguage,
                    communityTemplateValue, sourceRecordId, outputMode
            );
            templateProvider = EmailTemplateProviderService.getProvider();
        }
        return templateProvider;
    }

    //Service logic: ---------------------------------------------------------------------------------------------------
    private String getLabelValue(String label) {
        return TranslateHelper.getLabelValue(label, getProvider().getUserLanguage());
    }

    private String replaceParams(String labelValue) {
        return TranslateHelper.replaceParams(labelValue, EmailTemplateProvider.PARAM_PREFIX, getProvider().getParameters());
    }

    private String prepareLineBreaks(String source) {
        if (source == null) return null;
        if (getProvider().isHTML()) return source.replaceAll('\n', '<br/>');
        return source;
    }
}