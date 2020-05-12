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

    public TemplatePropertiesService(Id resourceId, String userMode) {
        String templateName = defineTemplateName(resourceId, userMode);
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

    private String defineTemplateName(Id resourceId, String userMode) {
        if(userMode != CommunityModeService.USER_MODE_PARTICIPANT) return CommunityTemplateService.TEMPLATE_DEFAULT;

        String templateName;
        try {
            if (resourceId.getSobjectType() == Participant_Enrollment__c.getSObjectType()) {
                return getTemplateNameByEnrollmentId(resourceId);
            } else if (resourceId.getSobjectType() == Case.getSObjectType()) {
                Case cs = [SELECT CommunityName__c FROM Case WHERE Id = :resourceId];
                if (cs != null) {
                    return CommunityTemplateService.getTemplateByCommunityName(cs.CommunityName__c).templateName;
                }
            } else if (resourceId.getSobjectType() == Task.getSObjectType()) {
                Task task = [SELECT Community_Template_Name__c, WhatId FROM Task WHERE Id = :resourceId];
                if(task != null) {
                    if(task.Community_Template_Name__c != null) {
                        return task.Community_Template_Name__c;
                    } else if (task.WhatId != null && task.WhatId.getSobjectType() == Participant_Enrollment__c.getSObjectType()) {
                        return getTemplateNameByEnrollmentId(task.WhatId);
                    }
                }
            } else if (resourceId.getSobjectType() == SurveyInvitation.getSObjectType()) {
                SurveyInvitation invitation = [
                        SELECT Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c
                        FROM SurveyInvitation
                        WHERE Id = :resourceId
                ];
                if(invitation != null) {
                    return CommunityTemplateService.getTemplate(
                            invitation.Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c).templateName;
                }
            }  else if (resourceId.getSobjectType() == Clinical_Trial_Profile__c.getSObjectType()) {
                Clinical_Trial_Profile__c ctp = [SELECT CommunityTemplate__c FROM Clinical_Trial_Profile__c WHERE Id = :resourceId];
                if(ctp != null) return CommunityTemplateService.getTemplate(ctp.CommunityTemplate__c).templateName;
            }
        } catch (Exception e) {
            EmailService.sendException(e, null);
        }

        return templateName;
    }

    private String getTemplateNameByEnrollmentId(Id enrollmentId) {
        Participant_Enrollment__c enrollment = [
                SELECT Id, Clinical_Trial_Profile__r.CommunityTemplate__c
                FROM Participant_Enrollment__c
                WHERE Id = :enrollmentId
        ];
        if(enrollment != null) {
            return CommunityTemplateService.getTemplate(enrollment.Clinical_Trial_Profile__r.CommunityTemplate__c).templateName;
        }

        return null;
    }
}