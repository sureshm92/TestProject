/**
 * Created by RAMukhamadeev on 2019-04-26.
 */

global without sharing class EmailActionBtnController {
    global String buttonLabelName { get; set; }
    global String buttonURLString { get; set; }
    global String caseIdString { get; set; }
    global Id surveyIdString { get; set; }
    global String communityTemplateValue { get; set; }

    //DEPRECATED
    global Id resourceIdString { get; set; }

    public String getButtonLabelValue() {
        return TranslateHelper.getLabelValue(
            buttonLabelName,
            EmailTemplateProviderService.getProvider().getUserLanguage()
        );
    }

    public Boolean getEnableNewStyle() {
        List<New_Style_Enablement__mdt> nseList = [
            SELECT Id, CommunityName__c
            FROM New_Style_Enablement__mdt
        ];
        List<String> communitiesList = new List<String>();
        for (New_Style_Enablement__mdt ns : nseList)
            communitiesList.add(ns.CommunityName__c);
        if (communityTemplateValue == 'Default') {
            return communitiesList.contains('IQVIA Referral Hub');
        }

        return communitiesList.contains(
            EmailTemplateProviderService.getProvider().getCommunityName()
        );
    }

    public String getResultURL() {
        String result = buttonURLString;
        String invitationString = surveyIdString;
        if (String.isBlank(caseIdString)) {
            if (result == null && communityTemplateValue != 'PatientPortal') {
                result = '';
            } else if (result == null && communityTemplateValue == 'PatientPortal') {
                result = 'pp/s';
            }

            if (!result.containsIgnoreCase('http') && communityTemplateValue != 'PatientPortal') {
                if (String.isNotBlank(result) && !result.startsWith('/'))
                    result = '/' + result;
                if (String.isNotBlank(invitationString) && !invitationString.startsWith('/'))
                    result = '/s/survey?inv=' + invitationString;
                result = getCurrentCommunityURL() + result;
            } else if (
                !result.containsIgnoreCase('http') && communityTemplateValue == 'PatientPortal'
            ) {
                //Need to unit test
                if (String.isNotBlank(result) && !result.startsWith('/'))
                    result = '/' + result;
                if (String.isNotBlank(invitationString) && !invitationString.startsWith('/'))
                    result = '/pp/s/survey?inv=' + invitationString;
                result = getCurrentCommunityURL() + result;
            }
        } else {
            result = Url.getOrgDomainUrl().toExternalForm() + '/' + caseIdString;
        }

        return result;
    }

    private String getCurrentCommunityURL() {
        if (communityTemplateValue == 'Default') {
            return CommunityTemplateService.getCommunityURL('IQVIA Referral Hub');
        }
        return CommunityTemplateService.getCommunityURL(
            EmailTemplateProviderService.getProvider().getCommunityName()
        );
    }
}
