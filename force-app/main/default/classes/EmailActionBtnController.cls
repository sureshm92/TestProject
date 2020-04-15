/**
 * Created by RAMukhamadeev on 2019-04-26.
 */

global without sharing class EmailActionBtnController {

    global String buttonURLString { get; set; }
    global String caseIdString { get; set; }
    global Id resourceIdString { get; set; }
    global Id surveyIdString { get; set; }
    global String communityTemplateValue { get; set; }

    public String getResultURL() {
        String result = buttonURLString;
        String invitationString = surveyIdString;
        if (String.isBlank(caseIdString)) {
            if (result == null) result = '';

            if (!result.containsIgnoreCase('http')) {
                if (String.isNotBlank(result) && !result.startsWith('/')) result = '/' + result;
                if (String.isNotBlank(invitationString) && !invitationString.startsWith('/')) result = '/s/survey?inv=' + invitationString;
                result = CommunityTemplateService.getCommunityURL(getCurrentCommunityName()) + result;
            }
        } else {
            result = Url.getOrgDomainUrl().toExternalForm() + '/' + caseIdString;
        }

        return result;
    }

    private String getCurrentCommunityName() {
        if (String.isEmpty(communityTemplateValue) && resourceIdString != null) {
            if (resourceIdString.getSobjectType() == Clinical_Trial_Profile__c.getSObjectType()) {
                communityTemplateValue = [
                        SELECT CommunityTemplate__c
                        FROM Clinical_Trial_Profile__c
                        WHERE Id = :resourceIdString
                ].CommunityTemplate__c;
            }
            if (resourceIdString.getSobjectType() == SurveyInvitation.getSObjectType()) {
                SurveyInvitation invitation = [
                        SELECT Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c
                        FROM SurveyInvitation
                        WHERE Id = :resourceIdString
                ];
                communityTemplateValue = invitation.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c;
            }

            if (String.isEmpty(communityTemplateValue)) {
                Id participantId;
                if (resourceIdString.getSobjectType() == Participant__c.getSObjectType()) {
                    participantId = resourceIdString;
                }

                Id peId;
                if (resourceIdString.getSobjectType() == Participant_Enrollment__c.getSObjectType()) {
                    peId = resourceIdString;
                }

                Id contactId;
                if (resourceIdString.getSobjectType() == Task.getSObjectType()) {
                    Task task = [SELECT WhatId, WhoId FROM Task WHERE Id = :resourceIdString];
                    if (task.WhatId != null) {
                        if (task.WhatId.getSobjectType() == Participant_Enrollment__c.getSObjectType()) {
                            peId = task.WhatId;
                        }
                    } else {
                        contactId = task.WhoId;
                    }
                }
                if (participantId != null || contactId != null) {
                    Participant__c participant = [
                            SELECT
                                    Contact__c,
                                    Has_Studies__c,
                                    Has_Studies_In_Progress__c,
                                    Has_Past_Studies__c
                            FROM Participant__c
                            WHERE (Id = :participantId OR Contact__c = :contactId)
                    ];
                    if (participant != null && participant.Contact__c != null) {
                        if (!participant.Has_Studies__c) {
                            communityTemplateValue = CommunityTemplateService.TEMPLATE_DEFAULT;
                        } else {
                            List<Id> enrollmentIds;
                            if (participant.Has_Studies_In_Progress__c) {
                                enrollmentIds = PatientDelegateService.getAvailablePEIdsForContact(participant.Contact__c);
                            } else {
                                enrollmentIds = PatientDelegateService.getPastPEIdsForContact(participant.Contact__c);
                            }
                            if(enrollmentIds != null && !enrollmentIds.isEmpty()) peId = enrollmentIds.get(0);
                        }
                    }
                }

                if (peId != null) {
                    communityTemplateValue = [
                            SELECT Clinical_Trial_Profile__r.CommunityTemplate__c
                            FROM Participant_Enrollment__c
                            WHERE Id = :peId
                    ].Clinical_Trial_Profile__r.CommunityTemplate__c;
                }
            }
        }

        return CommunityTemplateService.getTemplate(communityTemplateValue).communityName;
    }
}