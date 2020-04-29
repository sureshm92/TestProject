/**
 * Created by Olga Skrynnikova on 2/26/2020.
 */

public with sharing class TemplatePropertiesService {

    private Map<String, String> properties;
    private String templateName;
    
    public TemplatePropertiesService(String templateName){
        this.templateName = templateName;
        properties = CommunityTemplateService.getTemplate(templateName).properties;
    }

    public TemplatePropertiesService() {
        CommunityTemplate communityTemplate = CommunityTemplateService.getDefaultTemplate();
        templateName = communityTemplate.templateName;
        properties = communityTemplate.properties;
    }

    public TemplatePropertiesService(Id resourceId, Id recipientId, String userMode, Boolean isDelegate) {
        String templateName = defineTemplateName(resourceId, recipientId, userMode, isDelegate);
        CommunityTemplate communityTemplate = !String.isEmpty(templateName) ?
                CommunityTemplateService.getTemplate(templateName) :
                CommunityTemplateService.getDefaultTemplate();

        this.templateName = communityTemplate.templateName;
        properties = communityTemplate.properties;
    }

    public String getPropertyValue(String key) {
        return properties.get(key);
    }

    public String getTemplateName() {
        return templateName;
    }

    private String defineTemplateName(Id resourceId, Id recipientId, String userMode, Boolean isDelegate) {
        if(userMode != CommunityModeService.USER_MODE_PARTICIPANT) return CommunityTemplateService.TEMPLATE_DEFAULT;
        String templateName;
        try {
            if (isDelegate && userMode == CommunityService.USER_MODE_PARTICIPANT) {
                recipientId = PatientDelegateService.getParticipantByDelegateContactId(recipientId).Contact__c;
            }
            if(recipientId == null) return templateName;

            String filter;
            Id enrollmentId;
            if (resourceId.getSobjectType() == Participant_Enrollment__c.getSObjectType()) {
                filter = DatabaseService.fieldEqual('Id', resourceId);
            } else if (resourceId.getSobjectType() == User.getSObjectType() && userMode == CommunityService.USER_MODE_PARTICIPANT) {
                filter = DatabaseService.fieldEqual('Participant_Contact__c', recipientId);
            } else if (resourceId.getSobjectType() == Case.getSObjectType()) {
                Case cs = [SELECT Id, CommunityName__c FROM Case WHERE Id = :resourceId];
                if (cs != null) {
                    Community_Template__mdt commTemplate = [
                            SELECT Id, DeveloperName, Community_Name__c
                            FROM Community_Template__mdt
                            WHERE Community_Name__c = :cs.CommunityName__c
                    ];
                    return commTemplate.DeveloperName;
                }
            } else if (resourceId.getSobjectType() == Task.getSObjectType()) {
                Task task = [SELECT Id, Community_Template_Name__c, WhatId FROM Task WHERE Id = :resourceId];
                if(task.Community_Template_Name__c != null) {
                    return task.Community_Template_Name__c;
                } else if (task.WhatId != null && task.WhatId.getSobjectType() == Participant_Enrollment__c.getSObjectType()) {
                    filter = DatabaseService.fieldEqual('Id', task.WhatId);
                }
            } else if (resourceId.getSobjectType() == SurveyInvitation.getSObjectType()) {
                SurveyInvitation invitation = [SELECT Id, Participant_Enrollment__c FROM SurveyInvitation WHERE Id = :resourceId];
                enrollmentId = invitation.Participant_Enrollment__c;
            }  else if (resourceId.getSobjectType() == Clinical_Trial_Profile__c.getSObjectType()) {
                filter = DatabaseService.fieldEqual('Clinical_Trial_Profile__c', resourceId);
            }

            if (filter == null) {
                if (enrollmentId == null) {
                    Participant_Enrollment__c currentPE = ContactService.getCurrentPE(recipientId);
                    enrollmentId = currentPE != null ? currentPE.Id : PatientDelegateService.getPastPEIdsForContact(recipientId)[0];
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
                if (enrollments != null && !enrollments.isEmpty()) {
                    templateName = CommunityTemplateService.getTemplate(
                            enrollments.get(0).Clinical_Trial_Profile__r.CommunityTemplate__c).templateName;
                }
            }
        } catch (Exception e) {
            EmailService.sendException(e, null);
        }

        return templateName;
    }
}