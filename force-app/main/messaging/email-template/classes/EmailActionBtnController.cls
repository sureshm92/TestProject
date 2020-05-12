/**
 * Created by RAMukhamadeev on 2019-04-26.
 */

global without sharing class EmailActionBtnController {

    global String buttonLabelName { get; set; }
    global String buttonURLString { get; set; }
    global String caseIdString { get; set; }
    global Id surveyIdString { get; set; }

    //DEPRECATED
    global Id resourceIdString { get; set; }

    public String getButtonLabelValue() {
        return TranslateHelper.getLabelValue(buttonLabelName, EmailTemplateProviderService.getProvider().getUserLanguage());
    }

    public String getResultURL() {
        String result = buttonURLString;
        String invitationString = surveyIdString;
        if (String.isBlank(caseIdString)) {
            if (result == null) result = '';

            if (!result.containsIgnoreCase('http')) {
                if (String.isNotBlank(result) && !result.startsWith('/')) result = '/' + result;
                if (String.isNotBlank(invitationString) && !invitationString.startsWith('/')) result = '/s/survey?inv=' + invitationString;
                result = getCurrentCommunityURL() + result;
            }
        } else {
            result = Url.getOrgDomainUrl().toExternalForm() + '/' + caseIdString;
        }

        return result;
    }

    private String getCurrentCommunityURL() {
        return CommunityTemplateService.getCommunityURL(EmailTemplateProviderService.getProvider().getCommunityTemplateName());
    }
}