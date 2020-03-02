/**
 * Created by Olga Skrynnikova on 2/26/2020.
 */

public with sharing class TemplatePropertiesService {

    private Map<String, String> properties;

    public TemplatePropertiesService() {
        properties = CommunityTemplateService.getDefaultTemplate().properties;
    }

    public TemplatePropertiesService(Id resourceId, Id recipientId, String userModeString, Boolean isDelegate) {
        String templateName = getTemplateName(resourceId, recipientId, userModeString, isDelegate);
        properties = !String.isEmpty(templateName) ?
                CommunityTemplateService.getTemplate(templateName).properties :
                CommunityTemplateService.getDefaultTemplate().properties;
    }

    public String getPropertyValue(String key) {
        return properties.get(key);
    }

    private String getTemplateName(Id resourceId, Id recipientId, String userModeString, Boolean isDelegate) {
        String templateName;
        try {
            if (recipientId.getSobjectType() == User.getSObjectType()) {
                recipientId = [
                        SELECT Id, ContactId
                        FROM User
                        WHERE Id = :recipientId
                ].ContactId;
            }
            Id partConId = recipientId;

            if (isDelegate) partConId = PatientDelegateService.getParticipantByDelegateContactId(partConId).Contact__c;
            if(partConId == null) return templateName;

            String filter;
            Id enrollmentId;
            if (resourceId.getSobjectType() == Participant_Enrollment__c.getSObjectType()) {
                filter = DatabaseService.fieldEqual('Id', resourceId);
            } else if (resourceId.getSobjectType() == User.getSObjectType()) {
                filter = DatabaseService.fieldEqual('Participant_Contact__c', partConId);
            } else if (resourceId.getSobjectType() == Case.getSObjectType()) {
                Case cs = [SELECT Id, CommunityName__c FROM Case WHERE Id = :resourceId];
                if (cs != null) {
                    Community_Template__mdt commTemplate = [
                            SELECT Id, DeveloperName, Community_Name__c
                            FROM Community_Template__mdt
                            WHERE Community_Name__c = :cs.CommunityName__c
                    ];
                    templateName = commTemplate.DeveloperName;
                }
            } else if (resourceId.getSobjectType() == Task.getSObjectType()) {
                Task task = [SELECT Id, WhatId FROM Task WHERE Id = :resourceId];
                if (task != null && task.WhatId != null) filter = DatabaseService.fieldEqual('Id', task.WhatId);
            } else if (resourceId.getSobjectType() == SurveyInvitation.getSObjectType()) {
                SurveyInvitation invitation = [SELECT Id, Participant_Enrollment__c FROM SurveyInvitation WHERE Id = :resourceId];
                enrollmentId = invitation.Participant_Enrollment__c;
            }

            if (filter == null) {
                if (enrollmentId == null) {
                    Participant_Enrollment__c currentPE = ContactService.getCurrentPE(partConId);
                    enrollmentId = currentPE != null ? currentPE.Id : PatientDelegateService.getPastPEIdsForContact(partConId)[0];
                }
                filter = DatabaseService.fieldEqual('Id', enrollmentId);
            }
            if (templateName == null && filter != null) {
                List<Participant_Enrollment__c> enrollments = (List<Participant_Enrollment__c>) DatabaseService.query(
                        new List<String>{
                                'Clinical_Trial_Profile__r.CommunityTemplate__c'
                        },
                        Participant_Enrollment__c.getSObjectType(),
                        filter
                );
                if (enrollments != null) templateName = enrollments[0].Clinical_Trial_Profile__r.CommunityTemplate__c;
            }
        } catch (Exception e) {
            EmailService.sendException(e, null);
        }

        return templateName;
    }
}