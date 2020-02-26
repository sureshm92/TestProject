/**
 * Created by Olga Skrynnikova on 2/26/2020.
 */

public with sharing class TemplatePropertiesService {

    public static String getTemplatePropertiesBySObject(Id resourceId, Id recipientId, String userModeString) {
        String templateName;
        Participant_Enrollment__c pe;

        if(recipientId.getSobjectType() == User.getSObjectType()) recipientId = [SELECT Id, Contact.Id FROM User WHERE Id = :recipientId].Contact.Id;

        if (resourceId.getSobjectType() == Participant_Enrollment__c.getSObjectType()) {
            pe = [
                    SELECT Id, Participant_Contact__c, Clinical_Trial_Profile__r.CommunityTemplate__c
                    FROM Participant_Enrollment__c
                    WHERE Id = :resourceId
            ];
            templateName = pe.Clinical_Trial_Profile__r.CommunityTemplate__c;
            return templateName;
        } else if (resourceId.getSobjectType() == User.getSObjectType()) {
            Id conId = [SELECT Id, Contact.Id FROM User WHERE Id = :resourceId].Contact.Id;
            pe = [
                    SELECT Id, Participant_Contact__c, Clinical_Trial_Profile__r.CommunityTemplate__c
                    FROM Participant_Enrollment__c
                    WHERE Participant_Contact__c = :conId
            ];
            templateName = pe.Clinical_Trial_Profile__r.CommunityTemplate__c;
            return templateName;
        } else if (resourceId.getSobjectType() == Case.getSObjectType()) {
            Case cs = [SELECT Id, CommunityName__c FROM Case Where Id = :resourceId];
            Community_Template__mdt commTemplate = [SELECT Id, DeveloperName, Community_Name__c FROM Community_Template__mdt WHERE Community_Name__c = :cs.CommunityName__c];
            templateName = commTemplate.DeveloperName;
            return templateName;
        } else if (resourceId.getSobjectType() == Contact.getSObjectType() && userModeString == CommunityService.USER_MODE_PARTICIPANT) {
            pe = ContactService.getCurrentPE(recipientId);
            List<Id> pastPeList;
            if (pe == null) {
                pastPEList = PatientDelegateService.getPastPEIdsForContact(resourceId);
                pe = [
                        SELECT Id, Participant_Contact__c, Clinical_Trial_Profile__r.CommunityTemplate__c
                        FROM Participant_Enrollment__c
                        WHERE Id = :pastPeList[0]
                ];
                templateName = pe.Clinical_Trial_Profile__r.CommunityTemplate__c;
                return templateName;
            } else {
                Participant_Enrollment__c currPE = [
                        SELECT Id, Participant_Contact__c, Clinical_Trial_Profile__r.CommunityTemplate__c
                        FROM Participant_Enrollment__c
                        WHERE Id = :pe.Id
                ];
                templateName = currPE.Clinical_Trial_Profile__r.CommunityTemplate__c;
                return templateName;
            }
        } else if (resourceId.getSobjectType() == Task.getSObjectType()) {
            Task task = [SELECT Id, WhatId FROM Task Where Id = :resourceId];
            if (task.WhatId != null) {
                pe = [
                        SELECT Id, Participant_Contact__c, Clinical_Trial_Profile__r.CommunityTemplate__c
                        FROM Participant_Enrollment__c
                        WHERE Id = :task.WhatId
                ];
                templateName = pe.Clinical_Trial_Profile__r.CommunityTemplate__c;
                return templateName;
            } else if (task.WhatId == null && userModeString == CommunityService.USER_MODE_PARTICIPANT) {
                pe = ContactService.getCurrentPE(recipientId);
                List<Id> pastPeList;
                if (pe == null) {
                    pastPEList = PatientDelegateService.getPastPEIdsForContact(resourceId);
                    pe = [
                            SELECT Id, Participant_Contact__c, Clinical_Trial_Profile__r.CommunityTemplate__c
                            FROM Participant_Enrollment__c
                            WHERE Id = :pastPeList[0]
                    ];
                    templateName = pe.Clinical_Trial_Profile__r.CommunityTemplate__c;
                    return templateName;
                } else {
                    Participant_Enrollment__c currPE = [
                            SELECT Id, Participant_Contact__c, Clinical_Trial_Profile__r.CommunityTemplate__c
                            FROM Participant_Enrollment__c
                            WHERE Id = :pe.Id
                    ];
                    templateName = currPE.Clinical_Trial_Profile__r.CommunityTemplate__c;
                    return templateName;
                }
            } else {
                templateName = 'Default';
                return templateName;
            }
        } else if (resourceId.getSobjectType() == SurveyInvitation.getSObjectType()) {
            SurveyInvitation survInv = [SELECT Id, Participant_Enrollment__c FROM SurveyInvitation WHERE Id = :resourceId];
            pe = [
                    SELECT Id, Clinical_Trial_Profile__r.CommunityTemplate__c
                    FROM Participant_Enrollment__c
                    WHERE Id = :survInv.Participant_Enrollment__c
            ];
            templateName = pe.Clinical_Trial_Profile__r.CommunityTemplate__c;
            return templateName;
        }
        return null;
    }
}