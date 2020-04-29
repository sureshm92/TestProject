/**
 * Created by Igor Malyuta on 28.04.2020.
 */
global without sharing class ParagraphController {

    global String labelName { get; set; }

    public String getLabelValue() {
        EmailTemplateProvider provider = EmailTemplateProvider.getInstance();
        String bodyLabelValue = TranslateHelper.getLabelValue(labelName, provider.getUserLanguage());
        bodyLabelValue = TranslateHelper.replaceParams(bodyLabelValue, EmailTemplateProvider.PARAM_PREFIX, provider.getParameters());
        bodyLabelValue = provider.isHTML() ? bodyLabelValue.replaceAll('\n', '<br/>') : bodyLabelValue;
        return bodyLabelValue;
    }
}