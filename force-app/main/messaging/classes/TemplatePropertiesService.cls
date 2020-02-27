/**
 * Created by Olga Skrynnikova on 2/26/2020.
 */

public with sharing class TemplatePropertiesService {

    public static String getTemplatePropertiesBySObject(Id resourceId, Id recipientId, String userModeString, Boolean isDelegate) {
        String templateName;
        List<Participant_Enrollment__c> peList;
        List<Participant_Enrollment__c> currPEList;
        String filter;
        Id partConId = recipientId;

        if (recipientId.getSobjectType() == User.getSObjectType()) {
            recipientId = [
                    SELECT Id, Contact.Id
                    FROM User
                    WHERE Id = :recipientId
            ].Contact.Id;
        }

        if(isDelegate) partConId = PatientDelegateService.getParticipantByDelegateContactId(recipientId).Contact__c;

        if (resourceId.getSobjectType() == Participant_Enrollment__c.getSObjectType()) {
            filter = DatabaseService.fieldEqual('Id', resourceId);

        } else if (resourceId.getSobjectType() == User.getSObjectType()) {
            filter = DatabaseService.fieldEqual('Participant_Contact__c', partConId);

        } else if (resourceId.getSobjectType() == Case.getSObjectType()) {
            Case cs = [SELECT Id, CommunityName__c FROM Case WHERE Id = :resourceId];
            Community_Template__mdt commTemplate = [
                    SELECT Id, DeveloperName, Community_Name__c
                    FROM Community_Template__mdt
                    WHERE Community_Name__c = :cs.CommunityName__c
            ];
            templateName = commTemplate.DeveloperName;

        } else if (resourceId.getSobjectType() == Contact.getSObjectType()
                && userModeString == CommunityService.USER_MODE_PARTICIPANT) {
            currPEList.add(ContactService.getCurrentPE(partConId));
            List<Id> pastPEList = new List<Id>();
            if (currPEList.isEmpty()) {
                pastPEList = PatientDelegateService.getPastPEIdsForContact(partConId);
                filter = DatabaseService.fieldEqual('Id', pastPEList[0]);
            } else {
                filter = DatabaseService.fieldEqual('Id', currPEList[0].Id);
            }

        } else if (resourceId.getSobjectType() == Task.getSObjectType()) {
            Task task = [SELECT Id, WhatId FROM Task WHERE Id = :resourceId];

            if (task.WhatId != null) {
                filter = DatabaseService.fieldEqual('Id', task.WhatId);
            } else if (task.WhatId == null && userModeString == CommunityService.USER_MODE_PARTICIPANT) {
                currPEList.add(ContactService.getCurrentPE(partConId));
                List<Id> pastPEList = new List<Id>();
                if (peList.isEmpty()) {
                    pastPEList = PatientDelegateService.getPastPEIdsForContact(partConId);
                    filter = DatabaseService.fieldEqual('Id', pastPEList[0]);
                } else {
                    filter = DatabaseService.fieldEqual('Id', currPEList[0].Id);
                }
            }

        } else if (resourceId.getSobjectType() == SurveyInvitation.getSObjectType()) {
            SurveyInvitation survInv = [SELECT Id, Participant_Enrollment__c FROM SurveyInvitation WHERE Id = :resourceId];
            filter = DatabaseService.fieldEqual('Id', survInv.Participant_Enrollment__c);
        }

        if (templateName == null && filter != null) {
            try {
                peList.addAll((List<Participant_Enrollment__c>)DatabaseService.query(
                    new List<String>{'Id','Participant_Enrollment__c.Clinical_Trial_Profile__r.CommunityTemplate__c', 'Participant_Contact__c'},
                    Participant_Enrollment__c.getSObjectType(),
                    filter
            ));
            }catch(Exception e) {return e.getMessage();}

            if(peList[0].Clinical_Trial_Profile__r.CommunityTemplate__c != null) templateName = peList[0].Clinical_Trial_Profile__r.CommunityTemplate__c;
        }
        return templateName;
    }
}