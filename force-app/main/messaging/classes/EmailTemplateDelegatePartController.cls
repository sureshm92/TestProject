/**
 * Created by Olga Skrynnikova on 2/4/2020.
 */

global without sharing class EmailTemplateDelegatePartController {

    global String delegateUserId { get; set; }
    global String dataParams { get; set; }
    global String commTemplateStr { get; set; }
    global Id whatIdValue { get; set; }

    public List<String> getDelegateStudyNames() {
        Id delConId = delegateUserId;
        if(Id.valueOf(delegateUserId).getSobjectType() == User.getSObjectType()) {
            delConId = [SELECT Id, ContactId FROM User WHERE Id = :delegateUserId].ContactId;
        }

        List<Id> partIds = PatientDelegateService.getDelegatedParticipantIds(delConId);
        if (partIds == null || partIds.isEmpty()) return new List<String>();

        List<Participant__c> participants = [SELECT Contact__c FROM Participant__c WHERE Id IN: partIds];
        List<Id> partConIds = new List<Id>();
        for (Participant__c p: participants) partConIds.add(p.Contact__c);

        if(String.isEmpty(commTemplateStr) && String.isNotEmpty(whatIdValue)) {
            if(whatIdValue.getSobjectType() == Participant_Enrollment__c.getSObjectType()) {
                List<Participant_Enrollment__c> enrollment = [
                        SELECT Clinical_Trial_Profile__r.CommunityTemplate__c
                        FROM Participant_Enrollment__c
                        WHERE Id = :whatIdValue
                ];
                if(!enrollment.isEmpty()) {
                    commTemplateStr = CommunityTemplateService.getTemplate(
                            enrollment.get(0).Clinical_Trial_Profile__r.CommunityTemplate__c
                    ).templateName;
                }
            }
        }

        List<Participant_Enrollment__c> delegatePE = [
                SELECT Id, Clinical_Trial_Profile__r.Study_Code_Name__c,
                        Clinical_Trial_Profile__r.CommunityTemplate__c,
                        Participant_Contact__c
                FROM Participant_Enrollment__c
                WHERE Participant_Contact__c =:partConIds
                AND Clinical_Trial_Profile__r.CommunityTemplate__c = :commTemplateStr
        ];
        List<String> delegateStudyNames = new List<String>();
        for (Participant_Enrollment__c pe : delegatePE) delegateStudyNames.add(pe.Clinical_Trial_Profile__r.Study_Code_Name__c);

        return delegateStudyNames;
    }

    global String getAfterText() {
        if(whatIdValue != null) return '';
        Map<String, String> paramsMap = (Map<String, String>) JSON.deserialize(dataParams, Map<String, String>.class);
        return TranslateHelper.replaceParams(Label.Email_Body_Initial_Patient_Delegate_AfterText, EmailTemplateController.PARAM_PREFIX, paramsMap);
    }
}