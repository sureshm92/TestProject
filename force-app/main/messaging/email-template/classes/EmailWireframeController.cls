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
    global String outputMode { get; set; }


    private EmailTemplateProvider templateProvider;

    global String getUserLanguageCode() {
        return getProvider().getUserLanguage();
    }

    public Map<String, String> getTemplateMap() {
        return getProvider().getParameters();
    }

    private EmailTemplateProvider getProvider() {
        if (templateProvider == null) {
            if(!EmailTemplateProvider.haveTemplateInitial()) {
                EmailTemplateInitial templateInitial = new EmailTemplateInitialDefault(
                        sourceRecordId, emailRecipientId, emailRecipientName, emailRecipientLanguage, outputMode, communityTemplateValue
                );
                EmailTemplateProvider.setTemplateInitial(templateInitial);
            }

            templateProvider = EmailTemplateProvider.getInstance();
        }
        return templateProvider;
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
        String titleLabelValue = getLabelValue(titleValue);
        if (titleLabelValue.contains(EmailTemplateProvider.PARAM_PREFIX)) {
            titleLabelValue = getProvider().getUserMode() == CommunityService.USER_MODE_PARTICIPANT ?
                    getProvider().getParameters().get(TemplatePropertiesCatalog.TEMPLATE_PROP_TITLE_LABEL)
                    : getProvider().getParameters().get(TemplatePropertiesCatalog.TEMPLATE_PROP_TITLE_NEW_TM);
        }
        return titleLabelValue;
    }

    public String getGreetingText() {
        return prepareLineBreaks(replaceParams(getLabelValue(greetingValue)) + '\n\n');
    }

    public String getPreSignatureText() {
        return prepareLineBreaks(getLabelValue(preSignatureValue));
    }

    public String getSignatureText() {
        String signatureLabelValue = replaceParams(getLabelValue(signatureValue));
        return prepareLineBreaks(signatureLabelValue);
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