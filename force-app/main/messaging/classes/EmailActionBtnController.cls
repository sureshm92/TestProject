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
                if (!String.isBlank(result) && !result.startsWith('/')) result = '/' + result;
                if (String.isNotBlank(invitationString) && !invitationString.startsWith('/')) result = '/s/survey?inv=' + invitationString;
                result = getCurrentCommunityURL() + result;
            }
        } else {
            result = Url.getOrgDomainUrl().toExternalForm() + '/' + caseIdString;
        }

        return result;
    }

    private String getCurrentCommunityURL() {
        String communityTemplate = 'Default';
        if(String.isNotEmpty(buttonURLString) && buttonURLString.contains('/gsk/')) communityTemplate = 'GSK';

        if(resourceIdString != null) {
            if (resourceIdString.getSobjectType() == Participant_Enrollment__c.getSObjectType()) {
                Participant_Enrollment__c pe = [
                        SELECT Id, Participant_Contact__c, Clinical_Trial_Profile__r.CommunityTemplate__c
                        FROM Participant_Enrollment__c
                        WHERE Id = :resourceIdString
                ];
                communityTemplate = pe.Clinical_Trial_Profile__r.CommunityTemplate__c;
            } else if (resourceIdString.getSobjectType() == Clinical_Trial_Profile__c.getSObjectType()) {
                Clinical_Trial_Profile__c ctp = [
                        SELECT Id, CommunityTemplate__c
                        FROM Clinical_Trial_Profile__c
                        WHERE Id = :resourceIdString
                ];
                communityTemplate = ctp.CommunityTemplate__c;
            } else if (resourceIdString.getSobjectType() == Task.getSObjectType()) {
                Task task = [SELECT Id, WhatId FROM Task WHERE Id =: resourceIdString];
                List<Participant_Enrollment__c> enrollments = [
                        SELECT Id, Participant_Contact__c, Clinical_Trial_Profile__r.CommunityTemplate__c
                        FROM Participant_Enrollment__c
                        WHERE Id = :task.WhatId
                ];
                if(!enrollments.isEmpty()) communityTemplate = enrollments.get(0).Clinical_Trial_Profile__r.CommunityTemplate__c;
            }
        }

        String communityName = CommunityTemplateService.getTemplate(communityTemplate).communityName;
        String urlStr = CommunityTemplateService.getCommunityURL(communityName);
        return urlStr;
    }
}