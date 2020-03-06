/**
 * Created by RAMukhamadeev on 2019-04-26.
 */

global without sharing class EmailActionBtnController {

    global String buttonURLString { get; set; }
    global String caseIdString { get; set; }
    global Id resourceIdString { get; set; }
    global Id surveyIdString { get; set; }

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
        String communityTemplate = CommunityTemplateService.TEMPLATE_DEFAULT;
        Id peId;
        if (resourceIdString != null) {
            if (resourceIdString.getSobjectType() == Participant_Enrollment__c.getSObjectType()) {
                peId = resourceIdString;
            }
            if (resourceIdString.getSobjectType() == Clinical_Trial_Profile__c.getSObjectType()) {
                communityTemplate = [
                        SELECT CommunityTemplate__c
                        FROM Clinical_Trial_Profile__c
                        WHERE Id = :resourceIdString
                ].CommunityTemplate__c;
            }
            if (resourceIdString.getSobjectType() == Task.getSObjectType()) {
                Task task = [SELECT WhatId FROM Task WHERE Id =: resourceIdString];
                peId = task.WhatId;
            }
            if (resourceIdString.getSobjectType() == SurveyInvitation.getSObjectType()) {
                SurveyInvitation survey = [
                        SELECT Participant_Enrollment__c
                        FROM SurveyInvitation
                        WHERE Id = :resourceIdString
                ];
                peId = survey.Participant_Enrollment__c;
            }
            if (peId != null) {
                communityTemplate = [
                        SELECT Id, Participant_Contact__c, Clinical_Trial_Profile__r.CommunityTemplate__c
                        FROM Participant_Enrollment__c
                        WHERE Id = :peId].Clinical_Trial_Profile__r.CommunityTemplate__c;
            }
        }

        String communityName = CommunityTemplateService.getTemplate(communityTemplate).communityName;
        return CommunityTemplateService.getCommunityURL(communityName);
    }
}
