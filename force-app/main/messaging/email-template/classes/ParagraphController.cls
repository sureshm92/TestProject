/**
 * Created by Igor Malyuta on 28.04.2020.
 */
global without sharing class ParagraphController {

    global String labelName { get; set; }
    global String outputMode { get; set; }
    global Boolean isFilterRequired { get; set; }

    public String getLabelValue() {
        EmailTemplateProvider provider = EmailTemplateProviderService.getProvider();
        if(isFilterRequired == true){
            provider.addStudySiteNumber();
        }
        String bodyLabelValue = TranslateHelper.getLabelValue(labelName, provider.getUserLanguage());
        bodyLabelValue = TranslateHelper.replaceParams(bodyLabelValue, EmailTemplateProvider.PARAM_PREFIX, provider.getParameters());
        bodyLabelValue = outputMode.equals('HTML') ? bodyLabelValue.replaceAll('\n', '<br/>') : bodyLabelValue;
        return bodyLabelValue;
    }
}