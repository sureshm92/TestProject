/**
 * Created by Olga Skrynnikova on 2/4/2020.
 */

global without sharing class EmailTemplateDelegatePartController {

    global String delegateUserId { get; set; }
    global String dataParams { get; set; }
    global String commTemplateStr { get; set; }
    global Id sourceIdValue { get; set; }

    public List<String> getDelegateStudyNames() {
        List<Id> participantIds = new List<Id>();
        if(String.isEmpty(commTemplateStr) && String.isNotEmpty(sourceIdValue)) {
            if(isSourceIdEnrollment()) {
                List<Participant_Enrollment__c> enrollment = [
                        SELECT Clinical_Trial_Profile__r.CommunityTemplate__c,
                                Participant__c
                        FROM Participant_Enrollment__c
                        WHERE Id = :sourceIdValue
                ];
                if(!enrollment.isEmpty()) {
                    participantIds = new List<Id>();
                    participantIds.add(enrollment.get(0).Participant__c);
                    commTemplateStr = CommunityTemplateService.getTemplate(
                            enrollment.get(0).Clinical_Trial_Profile__r.CommunityTemplate__c
                    ).templateName;
                }
            }
        } else {
            Id delConId = delegateUserId;
            if(Id.valueOf(delegateUserId).getSobjectType() == User.getSObjectType()) {
                delConId = [SELECT ContactId FROM User WHERE Id = :delegateUserId].ContactId;
            }
            participantIds.addAll(PatientDelegateService.getDelegatedParticipantIds(delConId));
        }

        List<String> delegateStudyNames = new List<String>();
        if (participantIds.isEmpty()) return delegateStudyNames;

        List<Participant_Enrollment__c> delegatePE = [
                SELECT  Clinical_Trial_Profile__r.Study_Code_Name__c
                FROM Participant_Enrollment__c
                WHERE Participant__c IN:participantIds
                AND Clinical_Trial_Profile__r.CommunityTemplate__c = :commTemplateStr
        ];
        for (Participant_Enrollment__c pe : delegatePE) delegateStudyNames.add(pe.Clinical_Trial_Profile__r.Study_Code_Name__c);

        return delegateStudyNames;
    }

    private Boolean isSourceIdEnrollment() {
        return sourceIdValue.getSobjectType() == Participant_Enrollment__c.getSObjectType();
    }

    global String getAfterText() {
        if(isSourceIdEnrollment()) return '';
        Map<String, String> paramsMap = (Map<String, String>) JSON.deserialize(dataParams, Map<String, String>.class);
        return TranslateHelper.replaceParams(Label.Email_Body_Initial_Patient_Delegate_AfterText, EmailTemplateController.PARAM_PREFIX, paramsMap);
    }

}