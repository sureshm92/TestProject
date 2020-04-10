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
        Id peId, participantId, contactId;
        List<Id> peIds = new List<Id>();
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
                Task task = [SELECT WhatId, OwnerId FROM Task WHERE Id = :resourceIdString];
                if (task.WhatId != null) {
                    if (task.WhatId.getSobjectType() == Participant_Enrollment__c.getSObjectType()) {
                        peId = task.WhatId;
                    }
                    else {
                        participantId = task.WhatId;
                    }
                } else {
                    contactId = [SELECT Id, ContactId FROM User WHERE Id = :task.OwnerId].ContactId;
                }
            }
            if (resourceIdString.getSobjectType() == SurveyInvitation.getSObjectType()) {
                SurveyInvitation survey = [
                        SELECT Participant_Enrollment__c
                        FROM SurveyInvitation
                        WHERE Id = :resourceIdString
                ];
                peId = survey.Participant_Enrollment__c;
            }
            if (resourceIdString.getSobjectType() == Participant__c.getSObjectType()) {
                contactId = [
                        SELECT Id, Contact__c
                        FROM Participant__c
                        WHERE Id = :resourceIdString
                ].Contact__c;

            }
            if (participantId != null) {
                contactId = [
                        SELECT Id, Contact__c
                        FROM Participant__c
                        WHERE Id = :participantId
                ].Contact__c;

            }
            if (contactId != null) {
                peIds = PatientDelegateService.getAvailablePEIdsForContact(contactId);
                if (peIds.isEmpty()) {
                    peIds = PatientDelegateService.getPastPEIdsForContact(contactId);
                }
                peId = peIds[0];
            }
            if (peId != null) {
                communityTemplate = [
                        SELECT Id, Participant_Contact__c, Clinical_Trial_Profile__r.CommunityTemplate__c
                        FROM Participant_Enrollment__c
                        WHERE Id = :peId
                ].Clinical_Trial_Profile__r.CommunityTemplate__c;
            }
        }

        String communityName = CommunityTemplateService.getTemplate(communityTemplate).communityName;
        return CommunityTemplateService.getCommunityURL(communityName);
    }
}
