global without sharing class ParticipantParagraphController {
    
    global String outputMode { get; set; }
    global String learnmoreLabelValue { get; set; }
    global String discoverLabelValue { get; set; }
    global String trackLabelValue { get; set; }
    global String communityNameHelpLabelValue { get; set; }
    global  EmailTemplateProvider provider= EmailTemplateProviderService.getProvider();
    global Boolean isFilterRequired { get; set; }
    public String getLearnValue()
    {
       
        if(isFilterRequired == true){
            provider.addStudySiteNumber();
        }
       String bodyLabelValue = TranslateHelper.getLabelValue(learnmoreLabelValue, provider.getUserLanguage());
        bodyLabelValue = TranslateHelper.replaceParams(bodyLabelValue, EmailTemplateProvider.PARAM_PREFIX, provider.getParameters());
        bodyLabelValue = outputMode.equals('HTML') ? bodyLabelValue.replaceAll('\n', '<br/>') : bodyLabelValue;
        return bodyLabelValue;
    }
    public String getdiscoverValue()
    {
       
        if(isFilterRequired == true){
            provider.addStudySiteNumber();
        }
       String bodyLabelValue = TranslateHelper.getLabelValue(discoverLabelValue, provider.getUserLanguage());
        bodyLabelValue = TranslateHelper.replaceParams(bodyLabelValue, EmailTemplateProvider.PARAM_PREFIX, provider.getParameters());
        bodyLabelValue = outputMode.equals('HTML') ? bodyLabelValue.replaceAll('\n', '<br/>') : bodyLabelValue;
        return bodyLabelValue;
    }
    public String getTrackValue()
    {
       
        if(isFilterRequired == true){
            provider.addStudySiteNumber();
        }
       String bodyLabelValue = TranslateHelper.getLabelValue(trackLabelValue, provider.getUserLanguage());
        bodyLabelValue = TranslateHelper.replaceParams(bodyLabelValue, EmailTemplateProvider.PARAM_PREFIX, provider.getParameters());
        bodyLabelValue = outputMode.equals('HTML') ? bodyLabelValue.replaceAll('\n', '<br/>') : bodyLabelValue;
        return bodyLabelValue;
    }
    public String getCommunityHelpValue()
    {
       
        if(isFilterRequired == true){
            provider.addStudySiteNumber();
        }
       String bodyLabelValue = TranslateHelper.getLabelValue(communityNameHelpLabelValue, provider.getUserLanguage());
        bodyLabelValue = TranslateHelper.replaceParams(bodyLabelValue, EmailTemplateProvider.PARAM_PREFIX, provider.getParameters());
        bodyLabelValue = outputMode.equals('HTML') ? bodyLabelValue.replaceAll('\n', '<br/>') : bodyLabelValue;
        return bodyLabelValue;
    }
    public Boolean getisRTL()
    {
        return ((System.Label.RTL_Languages).contains(UserInfo.getLanguage())||(System.Label.RTL_Languages).contains(provider.getUserLanguage()));
    }

}