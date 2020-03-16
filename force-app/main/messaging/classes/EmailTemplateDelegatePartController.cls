/**
 * Created by Olga Skrynnikova on 2/4/2020.
 */

global without sharing class EmailTemplateDelegatePartController {

    global String delegateUserId { get; set; }
    global String dataParams {get; set;}
    global String commTemplateStr {get; set;}

    public List<String> getDelegateStudyNames() {
        Id delConId = [SELECT Id, Contact.Id FROM User WHERE Id = :delegateUserId].Contact.Id;
        List<Id> partIds = PatientDelegateService.getDelegatedParticipantIds(delConId);
        if(partIds == null || partIds.isEmpty()){
            return  new List<String>();
        }
        Id partCon = [SELECT Id, Contact__c FROM Participant__c WHERE Id = :partIds[0]].Contact__c;
        List<Id> availablePeIds = PatientDelegateService.getAvailablePEIdsForContact(partCon);
        availablePeIds.addAll(PatientDelegateService.getPastPEIdsForContact(partCon));

        List<String> delegateStudyNames = new List<String>();
        if (!availablePeIds.isEmpty()) {
            List<Participant_Enrollment__c> delegatePE = [
                    SELECT Id, Clinical_Trial_Profile__r.Study_Code_Name__c,
                            Clinical_Trial_Profile__r.CommunityTemplate__c
                    FROM Participant_Enrollment__c
                    WHERE Id IN:availablePeIds
                    AND Clinical_Trial_Profile__r.CommunityTemplate__c =: commTemplateStr
            ];
            for (Participant_Enrollment__c pe : delegatePE) delegateStudyNames.add(pe.Clinical_Trial_Profile__r.Study_Code_Name__c);
        }

        return delegateStudyNames;
    }

    global String getAfterText() {
        Map<String, String> paramsMap = (Map<String, String>)JSON.deserialize(dataParams, Map<String, String>.class);
        return TranslateHelper.replaceParams(Label.Email_Body_Initial_Patient_Delegate_AfterText, EmailTemplateController.PARAM_PREFIX, paramsMap);
    }
}

